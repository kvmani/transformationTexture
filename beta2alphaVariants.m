function [gAlpha, wAlpha] = beta2alphaVariants(betaEuler, wBeta, sel, doPlot)
% beta2alphaVariants
% ------------------
%  Convert each β-orientation to its first n = round(sel*12) α variants.
%
%  betaEuler : N×3  Euler angles [φ1 Φ φ2] (deg)  of β grains
%  wBeta     : N×1  weights for the β grains
%  sel       :      selection factor 0–1  (fraction of 12 variants, default 1)
%  doPlot    :      logical, plot PFs if true   (default false)
%
%  gAlpha    : N·n ×1  α-orientations   (hcp symmetry)
%  wAlpha    : N·n ×1  weights (β weight split evenly across its variants)

if nargin < 3 || isempty(sel),    sel    = 1;    end
if nargin < 4,                    doPlot = false; end
nSel = max(1, round(sel*12));

%% crystal & specimen symmetries
csBeta  = crystalSymmetry('m-3m',[3.32 3.32 3.32],'mineral','β-Ti');
csAlpha = crystalSymmetry('6/mmm',[2.951 2.951 4.684],'mineral','α-Ti');
ss      = specimenSymmetry('1');

%% 12 fixed variant operators (bcc→hcp Burgers OR)
V12 = buildBurgersVariantOperators();   

%% parent β orientations
gBeta = orientation('Euler', betaEuler(:,1)*degree, ...
                              betaEuler(:,2)*degree, ...
                              betaEuler(:,3)*degree, csBeta, ss);

%% transform each grain
gAlpha = orientation.empty;  wAlpha = [];
nBeta = size(betaEuler,1);
for i = 1:nBeta
    gFull = alphaVariantsFromBeta(gBeta(i),V12);            % 12 α variants
    gKeep = gFull(1:nSel);              % crude variant-selection rule
    gAlpha = [gAlpha; gKeep]; %#ok<AGROW>

    wAlpha = [wAlpha; repmat(wBeta(i)/nSel, nSel,1)]; %#ok<AGROW>
end

%% optional plotting (simple, one window each)
if doPlot
    hB = {Miller(1,1,0,csBeta),  Miller(1,1,1,csBeta)};
    hA = {Miller(0,0,0,1,csAlpha), Miller(1,0,-1,0,csAlpha)};

    figure('Color','w'); plotPDF(gBeta ,hB{:});  title('\beta parents'); mtexColorbar;
    figure('Color','w'); plotPDF(gAlpha,hA{:});  title('\alpha variants'); mtexColorbar;
end
end
