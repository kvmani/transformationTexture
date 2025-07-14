function [odfProduct, report] = parentToProductTexture(inputTextureFile, parentPhase, productPhase, varargin)
%parentToProductTexture Convert parent texture to product texture.
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
%
% This utility replaces both beta2AlphaTexture and alpha2BetaTexture.
% It performs orientation variant selection and optional mixing of
% pre-transformed product phase texture. Results are saved to the
% specified output directory.
%
% Syntax:
%   [odfProduct, report] = parentToProductTexture(inputTextureFile,
%       parentPhase, productPhase, 'Parameter', value, ...)
%
% Parameters:
%   inputTextureFile - path to odf.txt containing the parent texture
%   parentPhase      - 'alpha' or 'beta'
%   productPhase     - 'beta' or 'alpha'
%
% Name-Value Pairs:
%   'Sel'            - selection factor in [0,1] (default 1)
%   'PreTransformed' - logical, whether to mix pre-existing texture (default false)
%   'PreTextureFile' - odf.txt for the pre-existing product texture
%   'PreFraction'    - fraction of pre texture in [0,1] (default 0)
%   'OutputDir'      - directory to save results (default same as file)
%   'DataSetName'    - string used in plot annotation (optional)
%   'Debug'          - true to print debug messages
%
% Outputs:
%   odfProduct - MTEX ODF object for the product phase
%   report     - struct summarising inputs and outputs, also written as
%                results.json in OutputDir
%
% Example:
%   parentToProductTexture('beta/odf.txt','beta','alpha',
%       'Sel',0.2,'PreTransformed',true,
%       'PreTextureFile','alpha/odf.txt','PreFraction',0.1,
%       'OutputDir','results');

checkEnvironment();

% ---- parse inputs -------------------------------------------------------
p = inputParser;
addRequired(p,'inputTextureFile',@(x)ischar(x)||isstring(x));
addRequired(p,'parentPhase',@(x)ischar(x)||isstring(x));
addRequired(p,'productPhase',@(x)ischar(x)||isstring(x));
addParameter(p,'Sel',1,@(x)isnumeric(x) && x>=0 && x<=1);
addParameter(p,'PreTransformed',false,@islogical);
addParameter(p,'PreTextureFile','',@(x)ischar(x)||isstring(x));
addParameter(p,'PreFraction',0,@(x)isnumeric(x) && x>=0 && x<=1);
addParameter(p,'OutputDir','',@(x)ischar(x)||isstring(x));
addParameter(p,'DataSetName','Dataset',@(x)ischar(x)||isstring(x));
addParameter(p,'Debug',false,@islogical);
parse(p,inputTextureFile,parentPhase,productPhase,varargin{:});

sel            = p.Results.Sel;
preTransformed = p.Results.PreTransformed;
preFile        = p.Results.PreTextureFile;
preFrac        = p.Results.PreFraction;
outputDir      = char(p.Results.OutputDir);
if isempty(outputDir)
    outputDir = fileparts(p.Results.inputTextureFile);
end
if ~exist(outputDir,'dir'), mkdir(outputDir); end
nameStr        = char(p.Results.DataSetName);
DBG            = p.Results.Debug;

parentPhase  = lower(char(parentPhase));
productPhase = lower(char(productPhase));

if ~exist(p.Results.inputTextureFile,'file')
    error('Input texture file "%s" not found.', p.Results.inputTextureFile);
end
if preTransformed && ~exist(preFile,'file')
    error('Pre-transformed texture file "%s" not found.', preFile);
end

% ---- crystal symmetries -------------------------------------------------
csA = crystalSymmetry('6/mmm',[2.951 2.951 4.684],'mineral','\alpha-Ti');
csB = crystalSymmetry('m-3m',[3.32 3.32 3.32],'mineral','\beta-Ti');
ss  = specimenSymmetry('1');

switch parentPhase
    case 'alpha'
        csParent = csA;
    case 'beta'
        csParent = csB;
    otherwise
        error('Unsupported parent phase "%s".', parentPhase);
end
switch productPhase
    case 'alpha'
        csProduct = csA;
        hDirs = [Miller({0,0,0,1},csA), Miller({1,0,-1,0},csA), Miller({2,-1,-1,0},csA)];
    case 'beta'
        csProduct = csB;
        hDirs = [Miller(1,1,0,csB), Miller(1,1,1,csB)];
    otherwise
        error('Unsupported product phase "%s".', productPhase);
end

% ---- read parent texture ------------------------------------------------
tbl = readmatrix(p.Results.inputTextureFile,'FileType','text','CommentStyle','%');
if DBG
    fprintf('Loaded %d orientations from %s\n', size(tbl,1), p.Results.inputTextureFile);
end
parentEul = tbl(:,1:3);
wParent  = tbl(:,4); wParent = wParent / sum(wParent);
oriParent = orientation('Euler', parentEul(:,1)*degree, parentEul(:,2)*degree, parentEul(:,3)*degree, csParent, ss);

% ---- variant transformation --------------------------------------------
if strcmp(parentPhase,'beta') && strcmp(productPhase,'alpha')
    [gProd, wProd] = beta2alphaVariants(parentEul, wParent, sel, false);
elseif strcmp(parentPhase,'alpha') && strcmp(productPhase,'beta')
    [gProd, wProd] = alpha2betaVariants(parentEul, wParent, sel, false);
else
    error('Unsupported phase pair %s -> %s', parentPhase, productPhase);
end
wProd = wProd / sum(wProd);
odfProduct = calcODF(gProd,'weights',wProd);

% ---- include pre-transformed texture -----------------------------------
if preTransformed
    tblPre = readmatrix(preFile,'FileType','text','CommentStyle','%');
    preEul = tblPre(:,1:3);
    wPre   = tblPre(:,4); wPre = wPre / sum(wPre);
    odfPre = calcODF(orientation('Euler',preEul(:,1)*degree,preEul(:,2)*degree,preEul(:,3)*degree, csProduct, ss), 'weights', wPre);
    odfProduct = odfProduct*(1-preFrac) + odfPre*preFrac;
end

% ---- save outputs -------------------------------------------------------
baseName = sprintf('%s_texture_sel_%04.2f_%s_Frac_%04.2f', productPhase, sel, productPhase, preFrac);
outOdfFile = fullfile(outputDir,[baseName '.odf']);
export(odfProduct, outOdfFile,'Bunge');

% plot
fig = figure('Visible','off');
plotPDF(odfProduct, hDirs,'contourf','levels',linspace(0.5,2.0,10), 'resolution',5*degree,'antipodal');
mtexColorbar;
addFigureAnnotation(fig, sel, preFrac, nameStr);
print(fig, [outOdfFile '.png'],'-dpng','-r300');
close(fig);

% ---- produce report -----------------------------------------------------
report = struct();
report.inputTextureFile  = p.Results.inputTextureFile;
report.parentPhase       = parentPhase;
report.productPhase      = productPhase;
report.sel               = sel;
report.preTransformed    = preTransformed;
report.preFraction       = preFrac;
report.outputFile        = outOdfFile;
report.timestamp         = datestr(now, 'yyyy-mm-dd HH:MM:SS');

json = jsonencode(report);
json = prettyJSON(json);
fid = fopen(fullfile(outputDir,'results.json'),'w');
fwrite(fid,json); fclose(fid);
end
