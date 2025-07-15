% simulateUniModalBeta2AlphaTexture
% --------------------------------------------------------------
% Demonstration script for the forward \beta\rightarrow\alpha
% transformation using ``parentToProductTexture``.
%
% Purpose
%   Build synthetic unimodal \beta and \alpha textures and call the
%   converter for a range of selection factors ``Sel``. Generated pole
%   figures are written to ``results/simulatedTextures``.
%
% Inputs
%   None. All parameters such as ``Sel`` and the pre-existing \alpha
%   fraction are defined within this file.
%
% Outputs
%   ODF files and pole figure PNGs created in
%   ``results/simulatedTextures``.
%
% Author: Dr K V Mani Krishna
% Date  : 2025-07-15

clear; clc; close all;

checkEnvironment();

fprintf('\n=== Simulate β→α Transformation on Unimodal Data ===\n');

%% setup directories
rootDir = pwd;
tmpDir  = fullfile(rootDir,'tmp');
outDir  = fullfile(rootDir,'results','simulatedTextures');
if ~exist(tmpDir,'dir'), mkdir(tmpDir); end
if ~exist(outDir,'dir'), mkdir(outDir); end

%% crystal and specimen symmetries
csB = crystalSymmetry('m-3m',[3.32 3.32 3.32],'mineral','β-Ti');
csA = crystalSymmetry('6/mmm',[2.951 2.951 4.684],'mineral','α-Ti');
ss  = specimenSymmetry('1');

%% create unimodal parent and pre-existing product textures
betaFile  = fullfile(tmpDir,'simulatedBeta.odf');
alphaFile = fullfile(tmpDir,'simulatedAlpha.odf');

g0B = orientation('Euler',0*degree,0*degree,0*degree,csB,ss);
odfB = unimodalODF(g0B,15*degree);
export(odfB,betaFile,'Bunge');
fprintf('Saved parent β ODF to %s\n',betaFile);

%%%% following is for simulating pre-existing α
g0A = orientation('Euler',0*degree,0*degree,0*degree,csA,ss);
odfApre = unimodalODF(g0A,15*degree);
export(odfApre,alphaFile,'Bunge');
fprintf('Saved pre-existing α ODF to %s\n',alphaFile);

%% plot initial β (110) pole figure
fig = figure('Visible','off');
plotPDF(odfB,Miller(1,1,0,csB),'contourf','resolution',5*degree,'antipodal');
mtexColorbar;
print(fig,fullfile(outDir,'beta_110_pf.png'),'-dpng','-r300');
close(fig);
fprintf('Saved parent β (110) pole figure.\n');

%% perform transformation for various sel values
% Selection factors to test (η)
selList = 0.1:0.2:1.0;
for sel = selList
    fprintf('\n--- Running parentToProductTexture with sel = %.2f ---\n',sel);
    [odfAlpha,~] = parentToProductTexture(betaFile,'beta','alpha', ...
        'Sel',sel,'PreTransformed',true,'PreTextureFile',alphaFile, ...
        'PreFraction',0.2,'OutputDir',outDir,'DataSetName','unimodal_demo');

    fig = figure('Visible','off');
    plotPDF(odfAlpha,Miller({0,0,0,1},csA),'contourf','resolution',5*degree,'antipodal');
    mtexColorbar;
    pfName = sprintf('alpha_0001_pf_sel_%0.2f.png',sel);
    print(fig,fullfile(outDir,pfName),'-dpng','-r300');
    close(fig);
    fprintf('Saved product α (0001) pole figure: %s\n',pfName);
end

fprintf('\nAll β→α simulations complete. Results in %s\n',outDir);
