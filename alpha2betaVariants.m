function [gBeta, wBeta] = alpha2betaVariants(alphaEuler, wAlpha, sel, doPlot)
% alpha2betaVariants
% ------------------
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
%  Convert each α-orientation to its first n = round(sel*6) β variants.
%
%  alphaEuler : N×3  Euler angles [φ1 Φ φ2] (deg) of α grains
%  wAlpha     : N×1  weights for the α grains
%  sel        :      selection factor 0–1 (fraction of 6 variants, default 1)
%  doPlot     :      logical, plot PFs if true (default false)
%
%  gBeta      : N·n ×1  β-orientations (cubic symmetry)
%  wBeta      : N·n ×1  weights (α weight split evenly across variants)

if nargin < 3 || isempty(sel),    sel = 1;    end
if nargin < 4,                    doPlot = false; end
nSel = max(1, round(sel * 6))    % Max 6 variants per α orientation

%% crystal & specimen symmetries
csAlpha = crystalSymmetry('6/mmm', [2.951 2.951 4.684], 'mineral', 'α-Ti');
csBeta  = crystalSymmetry('m-3m',  [3.32 3.32 3.32],    'mineral', 'β-Ti');
ss      = specimenSymmetry('1');

%% 6 fixed variant operators (hcp → bcc reverse Burgers OR)
V6 = buildBetaVariantsFromAlpha();   % User-defined function

%% parent α orientations
gAlpha = orientation('Euler', alphaEuler(:,1)*degree, ...
                               alphaEuler(:,2)*degree, ...
                               alphaEuler(:,3)*degree, csAlpha, ss);

%% transform each grain
gBeta = orientation.empty;  
wBeta = [];
nAlpha = size(alphaEuler,1);

for i = 1:nAlpha
    gFull = betaVariantsFromAlpha(gAlpha(i), V6);     % 6 β variants from α
%    fprintf('size of gFulll is :%d',numel(gFull))
    gKeep = gFull(1:nSel);                            % select top n variants

    gBeta = [gBeta; gKeep]; %#ok<AGROW>
    wBeta = [wBeta; repmat(wAlpha(i)/nSel, nSel, 1)]; %#ok<AGROW>
end

%% optional plotting
if doPlot
    hA = {Miller(0,0,0,1,csAlpha), Miller(1,0,-1,0,csAlpha)};
    hB = {Miller(1,1,0,csBeta),    Miller(1,1,1,csBeta)};

    figure('Color','w'); plotPDF(gAlpha, hA{:}); title('\alpha parents'); mtexColorbar;
    figure('Color','w'); plotPDF(gBeta, hB{:});  title('\beta variants'); mtexColorbar;
end

end
