% simulateUniModalBeta2AlphaTexture.m
% Demonstrates use of parentToProductTexture for a simple \beta\rightarrow\alpha transformation.
% It creates a unimodal parent \beta texture, mixes in a small fraction of
% pre-existing \alpha texture and computes product textures for a range of
% variant selection (sel) values.
% All results are written to results/simulatedTextures/ and pole figures are
% produced for the parent (110) and product (0001) planes.

clear; clc; close all;

fprintf('\n=== Simulate \u03b2\u2192\u03b1 Transformation on Unimodal Data ===\n');

% --- setup directories ----------------------------------------------------
rootDir = pwd;
tmpDir  = fullfile(rootDir, 'tmp');
outDir  = fullfile(rootDir, 'results', 'simulatedTextures');
if ~exist(tmpDir,'dir'), mkdir(tmpDir); end
if ~exist(outDir,'dir'), mkdir(outDir); end

% --- create unimodal parent and pre-existing product textures -------------
betaFile  = fullfile(tmpDir,'simulatedBeta.odf');
alphaFile = fullfile(tmpDir,'simulatedAlpha.odf');

% ideal [0 0 0] Euler angles with unit weight
parentOri = [0 0 0 1];

fprintf('Saving parent \u03b2 orientation to %s\n', betaFile);
dlmwrite(betaFile,parentOri,'delimiter',' ');
fprintf('Saving pre-existing \u03b1 orientation to %s\n', alphaFile);
dlmwrite(alphaFile,parentOri,'delimiter',' ');

% --- plot initial \u03b2 (110) pole figure --------------------------------
csB = crystalSymmetry('m-3m',[3.32 3.32 3.32],'mineral','\beta-Ti');
ss  = specimenSymmetry('1');
oriB = orientation('Euler',0*degree,0*degree,0*degree,csB,ss);
odfB = calcODF(oriB,'weights',1);
fig = figure('Visible','off');
plotPDF(odfB,Miller(1,1,0,csB),'contourf','levels',linspace(0.5,2.0,10), ...
        'resolution',5*degree,'antipodal');
mtexColorbar;
print(fig, fullfile(outDir,'beta_110_pf.png'),'-dpng','-r300');
close(fig);
fprintf('Saved parent \u03b2 (110) pole figure.\n');

% --- perform transformation for various sel values -----------------------
selList = 0.1:0.2:1.0;
for sel = selList
    fprintf('\n--- Running parentToProductTexture with sel = %.2f ---\n', sel);
    [odfA,~] = parentToProductTexture(betaFile,'beta','alpha', ...
        'Sel',sel,'PreTransformed',true,'PreTextureFile',alphaFile, ...
        'PreFraction',0.2,'OutputDir',outDir,'DataSetName','unimodal_demo');

    % save product (0001) pole figure
    csA = crystalSymmetry('6/mmm',[2.951 2.951 4.684],'mineral','\alpha-Ti');
    fig = figure('Visible','off');
    plotPDF(odfA,Miller({0,0,0,1},csA),'contourf','levels',linspace(0.5,2.0,10), ...
            'resolution',5*degree,'antipodal');
    mtexColorbar;
    pfName = sprintf('alpha_0001_pf_sel_%0.2f.png', sel);
    print(fig, fullfile(outDir,pfName),'-dpng','-r300');
    close(fig);
    fprintf('Saved product \u03b1 (0001) pole figure: %s\n', pfName);
end

fprintf('\nAll \u03b2\u2192\u03b1 simulations complete. Results in %s\n', outDir);
