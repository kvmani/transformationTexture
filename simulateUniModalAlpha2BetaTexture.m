% simulateUniModalAlpha2BetaTexture.m

% Demonstrate the use of parentToProductTexture for a unimodal α→β transformation.
% This script builds ideal α and β unimodal textures, saves them into tmp/
% as simulatedAlpha.odf and simulatedBeta.odf, then executes the reverse
% transformation for a set of selection (sel) values. Pole figures are
% stored under results/simulatedTextures/.

clear; clc; close all;

checkEnvironment();

fprintf('\n=== Simulate α→β Transformation on Unimodal Data ===\n');

%% setup directories
rootDir = pwd;
tmpDir  = fullfile(rootDir,'tmp');
outDir  = fullfile(rootDir,'results','simulatedTextures');
if ~exist(tmpDir,'dir'), mkdir(tmpDir); end
if ~exist(outDir,'dir'), mkdir(outDir); end

%% crystal and specimen symmetries
csA = crystalSymmetry('6/mmm',[2.951 2.951 4.684],'mineral','α-Ti');
csB = crystalSymmetry('m-3m',[3.32 3.32 3.32],'mineral','β-Ti');
ss  = specimenSymmetry('1');

%% create unimodal parent and pre-existing product textures
alphaFile = fullfile(tmpDir,'simulatedAlpha.odf');
betaFile  = fullfile(tmpDir,'simulatedBeta.odf');

g0A = orientation('Euler',0*degree,0*degree,0*degree,csA,ss);
odfA = unimodalODF(g0A,15*degree);
export(odfA,alphaFile,'Bunge');
fprintf('Saved parent α ODF to %s\n',alphaFile);

g0B = orientation('Euler',0*degree,0*degree,0*degree,csB,ss);
odfBpre = unimodalODF(g0B,15*degree);
export(odfBpre,betaFile,'Bunge');
fprintf('Saved pre-existing β ODF to %s\n',betaFile);

%% plot initial α (0001) pole figure
fig = figure('Visible','off');
plotPDF(odfA,Miller({0,0,0,1},csA),'contourf','resolution',5*degree,'antipodal');
mtexColorbar;
print(fig,fullfile(outDir,'alpha_0001_pf.png'),'-dpng','-r300');
close(fig);
fprintf('Saved parent α (0001) pole figure.\n');

%% perform transformation for various sel values
selList = 0.1:0.2:1.0;
for sel = selList
    fprintf('\n--- Running parentToProductTexture with sel = %.2f ---\n',sel);
    [odfBeta,~] = parentToProductTexture(alphaFile,'alpha','beta', ...
        'Sel',sel,'PreTransformed',true,'PreTextureFile',betaFile, ...
        'PreFraction',0.2,'OutputDir',outDir,'DataSetName','unimodal_demo');

    fig = figure('Visible','off');
    plotPDF(odfBeta,Miller(1,1,0,csB),'contourf','resolution',5*degree,'antipodal');
    mtexColorbar;
    pfName = sprintf('beta_110_pf_sel_%0.2f.png',sel);
    print(fig,fullfile(outDir,pfName),'-dpng','-r300');
    close(fig);
    fprintf('Saved product β (110) pole figure: %s\n',pfName);
end

fprintf('\nAll α→β simulations complete. Results in %s\n',outDir);
=======
% Demonstrates use of parentToProductTexture for a simple \alpha\rightarrow\beta transformation.
% A unimodal parent \alpha texture is transformed to \beta while a small
% fraction of pre-existing \beta texture is mixed in. Variant selection is
% varied and resulting pole figures are stored in results/simulatedTextures/.

clear; clc; close all;

fprintf('\n=== Simulate \u03b1\u2192\u03b2 Transformation on Unimodal Data ===\n');

% --- setup directories ----------------------------------------------------
rootDir = pwd;
tmpDir  = fullfile(rootDir, 'tmp');
outDir  = fullfile(rootDir, 'results', 'simulatedTextures');
if ~exist(tmpDir,'dir'), mkdir(tmpDir); end
if ~exist(outDir,'dir'), mkdir(outDir); end

% --- create unimodal parent and pre-existing product textures -------------
alphaFile = fullfile(tmpDir,'simulatedAlpha.odf');
betaFile  = fullfile(tmpDir,'simulatedBeta.odf');

parentOri = [0 0 0 1];

fprintf('Saving parent \u03b1 orientation to %s\n', alphaFile);
dlmwrite(alphaFile,parentOri,'delimiter',' ');
fprintf('Saving pre-existing \u03b2 orientation to %s\n', betaFile);
dlmwrite(betaFile,parentOri,'delimiter',' ');

% --- plot initial \u03b1 (0001) pole figure -------------------------------
csA = crystalSymmetry('6/mmm',[2.951 2.951 4.684],'mineral','\alpha-Ti');
ss  = specimenSymmetry('1');
oriA = orientation('Euler',0*degree,0*degree,0*degree,csA,ss);
odfA = calcODF(oriA,'weights',1);
fig = figure('Visible','off');
plotPDF(odfA,Miller({0,0,0,1},csA),'contourf','levels',linspace(0.5,2.0,10), ...
        'resolution',5*degree,'antipodal');
mtexColorbar;
print(fig, fullfile(outDir,'alpha_0001_pf.png'),'-dpng','-r300');
close(fig);
fprintf('Saved parent \u03b1 (0001) pole figure.\n');

% --- perform transformation for various sel values -----------------------
selList = 0.1:0.2:1.0;
for sel = selList
    fprintf('\n--- Running parentToProductTexture with sel = %.2f ---\n', sel);
    [odfB,~] = parentToProductTexture(alphaFile,'alpha','beta', ...
        'Sel',sel,'PreTransformed',true,'PreTextureFile',betaFile, ...
        'PreFraction',0.2,'OutputDir',outDir,'DataSetName','unimodal_demo');

    csB = crystalSymmetry('m-3m',[3.32 3.32 3.32],'mineral','\beta-Ti');
    fig = figure('Visible','off');
    plotPDF(odfB,Miller(1,1,0,csB),'contourf','levels',linspace(0.5,2.0,10), ...
            'resolution',5*degree,'antipodal');
    mtexColorbar;
    pfName = sprintf('beta_110_pf_sel_%0.2f.png', sel);
    print(fig, fullfile(outDir,pfName),'-dpng','-r300');
    close(fig);
    fprintf('Saved product \u03b2 (110) pole figure: %s\n', pfName);
end

fprintf('\nAll \u03b1\u2192\u03b2 simulations complete. Results in %s\n', outDir);

