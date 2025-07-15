function [odfProduct, report] = parentToProductTexture(inputTextureFile, parentPhase, productPhase, varargin)
% parentToProductTexture  Convert parent texture to its product texture.
%
%   [odfProduct, report] = parentToProductTexture(inputTextureFile, ...
%       parentPhase, productPhase, Name,Value)
%
% Purpose
%   Read a parent-phase texture from ``inputTextureFile`` and apply the
%   Burgers orientation relationship to obtain the product texture. An
%   optional pre-existing product texture can be mixed using the
%   ``PreTransformed`` options.
%
% Input Arguments
%   inputTextureFile - path to a Bunge formatted ``odf.txt`` file
%   parentPhase      - either ``'alpha'`` or ``'beta'``
%   productPhase     - either ``'alpha'`` or ``'beta'``
%
% Name-Value Pairs
%   'Sel'            - orientation variant selection factor [0–1]
%   'PreTransformed' - include a pre-existing product texture (logical)
%   'PreTextureFile' - file path to the pre-existing texture
%   'PreFraction'    - weight fraction of the pre-existing texture
%   'OutputDir'      - folder to save ``*.odf`` and ``*.png`` files
%   'DataSetName'    - string used for plot annotations
%   'Data_Set_Name'  - subfolder name under ``results/``
%   'Debug'          - true enables verbose debug information
%
% Output Arguments
%   odfProduct - MTEX ``odf`` object of the product texture
%   report     - structure summarising run parameters and output files
%
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01

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
addParameter(p,'Data_Set_Name','',@(x)ischar(x)||isstring(x));  % NEW
addParameter(p,'Debug',false,@islogical);
parse(p,inputTextureFile,parentPhase,productPhase,varargin{:});

% ---- set up output directory under 'results/' --------------------------
dataSetSub = char(p.Results.Data_Set_Name);
if isempty(dataSetSub)
    dataSetSub = char(p.Results.DataSetName);
end
outputDir = fullfile('results', dataSetSub);
if ~exist(outputDir,'dir'), mkdir(outputDir); end

% ---- assign parameters --------------------------------------------------
sel            = p.Results.Sel;
preTransformed = p.Results.PreTransformed;
preFile        = p.Results.PreTextureFile;
preFrac        = p.Results.PreFraction;
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
    tbl = tbl(1:40:end, :);
    fprintf('DEBUG MODE: Using every 40th row only from odf.txt.');
    fprintf('Loaded %d orientations from %s\n', size(tbl,1), p.Results.inputTextureFile);
end
parentEul = tbl(:,1:3);
wParent  = tbl(:,4); wParent = wParent / sum(wParent);

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
    if DBG
        tblPre = tblPre(1:40:end, :);
        fprintf('DEBUG MODE: Using every 40th row only from pre‑transformed odf.txt.');
    end
    preEul = tblPre(:,1:3);
    wPre   = tblPre(:,4); wPre = wPre / sum(wPre);
    odfPre = calcODF(orientation('Euler',preEul(:,1)*degree,preEul(:,2)*degree,preEul(:,3)*degree, csProduct, ss), 'weights', wPre);
    odfProduct = odfProduct*(1-preFrac) + odfPre*preFrac;
end

% ---- save outputs -------------------------------------------------------
baseName = sprintf('%s_texture_sel_%04.2f_%s_Frac_%04.2f', productPhase, sel, productPhase, preFrac);
outOdfFile = fullfile(outputDir, [baseName '.odf']);
export(odfProduct, outOdfFile,'Bunge');

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

% unchanged helper
function addFigureAnnotation(figHandle, sel, frac, dataSetName)
    dataSetName =  strrep(dataSetName, '_', ' ');
    annotationText = sprintf('\\eta=%.2f\nparent_{f}=%.2f\nData:%s', ...
                         sel, frac, dataSetName);
    annotation(figHandle, 'textbox', [0.02, 0.01, 0.3, 0.12], ...
               'String', annotationText, ...
               'HorizontalAlignment', 'left', ...
               'VerticalAlignment', 'bottom', ...
               'EdgeColor', 'none', ...
               'FontSize', 16, ...
               'FontWeight', 'bold');
end
