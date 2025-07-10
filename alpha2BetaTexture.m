%==========================================================================
% MATLAB Script for Batch α→β Texture Transformation (Reverse Burgers OR)
%==========================================================================
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
% This script converts alpha texture data back to beta phase using inverse Burgers orientation relationship.


clear all
close all

debug = true;
consider_PreExistingBeta = true;

%==================== User-Defined Paths and Parameters ====================
if ~exist('rootDir','var')
    rootDir  = 'Z:\backUps\currentProjects\colloborations\shibayan_iitKgp\Mani Sir';
end
if ~exist('jsonFile','var')
    jsonFile = fullfile(rootDir, 'xrdmlInfo_2.json');
end
if ~exist('selList','var')
    selList  = 0.1:0.3:1.0;
end
levels10 = linspace(0.5,2.0,10);

if ~exist('manualJsonText','var')
manualJsonText = [ ...
    '{ "folder": "SP-700\\Deformed @ 850 deg C 1S-1\\HT XRT\\RT (30 deg C) Texture\\Alpha", ', ...
    '  "data_set_name": "SP700_RT_alpha", ', ...
    '  "pre_transformed_beta_present": true, ', ...
    '  "pre_transformed_beta_texture_data": "SP-700\\Deformed @ 850 deg C 1S-1\\HT XRT\\RT (30 deg C) Texture\\Beta", ', ...
    '  "pre_transformed_beta_fraction": 0.2, ', ...
    '  "files": [ ', ...
    '    { "file": "PF-1 alpha _RT_25.1°C.xrdml", "hkl": [1, 0, 0], "twoTheta": 35.58 }, ', ...
    '    { "file": "PF-2 alpha _RT_25.1°C.xrdml", "hkl": [0, 0, 2], "twoTheta": 38.62 }, ', ...
    '    { "file": "PF-3 alpha _RT_25.1°C.xrdml", "hkl": [1, 0, 1], "twoTheta": 40.57 }, ', ...
    '    { "file": "PF-4 alpha _RT_25.4°C.xrdml", "hkl": [1, 0, 2], "twoTheta": 53.41 } ', ...
    '  ] ', ...
    '}' ...
];

end
% ---------- Load folder metadata ----------
if ~isempty(strtrim(manualJsonText))
    fprintf('INFO: Using in-script manual JSON for testing.\n');
    folders = {jsondecode(manualJsonText)};
else
    fprintf('INFO: Using JSON input file: %s\n', jsonFile);
    folders = jsondecode(fileread(jsonFile));
end


%======================= Crystal and Specimen Symmetries ===================
csB = crystalSymmetry('m-3m',  [3.32 3.32 3.32], 'mineral', 'β-Ti');
csA = crystalSymmetry('6/mmm', [2.951 2.951 4.684], 'mineral', 'α-Ti');
ss  = specimenSymmetry('1');

%======================= Pole Figure Plotting Directions ===================
hB = [Miller(1,1,0,csB), Miller(1,1,1,csB)];
hA = [Miller({0,0,0,1},csA), Miller({1,0,-1,0},csA), Miller({2,-1,-1,0},csA)];

%======================= Start Batch Processing Loop =======================
fprintf('\n=======  Batch α→β ODF conversion  =======\n');
ticGlobal = tic;
procCount = 0;

for idx = 1:numel(folders)
    folderPath = fullfile(rootDir, folders{idx}.folder);
    if ~endsWith(lower(folderPath), '\alpha'); continue; end

    odfFile = fullfile(folderPath, 'odf.txt');
    if ~isfile(odfFile)
        warning('Folder "%s" has no odf.txt – skipped.', folderPath);
        continue
    end

    tbl = readmatrix(odfFile,'FileType','text','CommentStyle','%');
    if debug
        tbl = tbl(1:40:end, :);
        fprintf('DEBUG MODE: Using every 40th row only from odf.txt.\n');
    end
    alphaEul = tbl(:,1:3);
    wAlpha   = tbl(:,4) / sum(tbl(:,4));
    odfAlpha = calcODF(orientation('Euler', alphaEul(:,1)*degree, ...
                                            alphaEul(:,2)*degree, ...
                                            alphaEul(:,3)*degree, csA, ss), ...
                       'weights', wAlpha );

    tFolder = tic;
    for s = 1:numel(selList)
        sel = selList(s);
        [gB, wB] = alpha2betaVariants(alphaEul, wAlpha, sel, false);
        wB = wB / sum(wB);

        % CASE 1: Without pre-existing beta
        betaFrac = 0.0;
        odfBeta = calcODF(gB, 'weights', wB);
        dataSetName = getCleanDataSetName(folders{idx}, idx);
        outODF = fullfile(folderPath, ...
            sprintf('beta_texture_sel_%04.2f_Beta_Frac_%04.2f.odf', sel, betaFrac));
        export(odfBeta, outODF, 'Bunge');
        plotAndSaveODF(odfBeta, hB, outODF, sel, betaFrac, dataSetName);

        % CASE 2: With pre-existing beta
        if consider_PreExistingBeta
            if isfield(folders{idx}, 'pre_transformed_beta_present') && folders{idx}.("pre_transformed_beta_present")
                fprintf(1,"INFO: Found pre-existing beta texture. Adding its contribution.\n");

                betaFolder  = fullfile(rootDir, folders{idx}.("pre_transformed_beta_texture_data"));
                odfBetaFile = fullfile(betaFolder, 'odf.txt');
                if isfile(odfBetaFile)
                    tblBeta = readmatrix(odfBetaFile, 'FileType', 'text', 'CommentStyle', '%');
                    if debug
                        tblBeta = tblBeta(1:40:end, :);
                        fprintf('DEBUG MODE: Using every 40th row from beta odf.txt.\n');
                    end
                    betaEul = tblBeta(:, 1:3);
                    wBeta0  = tblBeta(:, 4) / sum(tblBeta(:, 4));
                    odfBeta_pre = calcODF( ...
                        orientation('Euler', betaEul(:,1)*degree, ...
                                            betaEul(:,2)*degree, ...
                                            betaEul(:,3)*degree, csB, ss), ...
                                            'weights', wBeta0 );

                    betaFrac = folders{idx}.("pre_transformed_beta_fraction");
                    odfBeta_combined = odfBeta * (1 - betaFrac) + odfBeta_pre * betaFrac;
                    outODF_combined = fullfile(folderPath, ...
                        sprintf('beta_texture_sel_%04.2f_Beta_Frac_%04.2f.odf', sel, betaFrac));
                    export(odfBeta_combined, outODF_combined, 'Bunge');
                    plotAndSaveODF(odfBeta_combined, hB, outODF_combined, sel, betaFrac, dataSetName);
                else
                    warning('Missing file: %s', odfBetaFile);
                end
            end
        end

        % Progress bar
        pct = s / numel(selList);
        bar = repmat('#', 1, round(pct*20));
        pad = repmat('.', 1, 20 - numel(bar));
        fprintf('\r[%s%s]   sel = %.2f  (folder %d/%d)', ...
                 bar, pad, sel, idx, numel(folders));
    end

    fprintf('  ✔  %s  (%.1f s)\n', folderPath, toc(tFolder));
    procCount = procCount + 1;

    if debug
        fprintf('Debug mode: processed first folder only.\n');
        break
    end
end
fprintf('\nProcessed %d folder(s) in %.1f s total.\n', procCount, toc(ticGlobal));

%==========================================================================
function addFigureAnnotation(figHandle, sel, frac, dataSetName)
    annotationText = sprintf('\\eta=%.2f\n\\beta_{f}=%.2f\nData:%s', ...
                         sel, frac, dataSetName);
    annotation(figHandle, 'textbox', [0.02, 0.01, 0.3, 0.12], ...
               'String', annotationText, ...
               'HorizontalAlignment', 'left', ...
               'VerticalAlignment', 'bottom', ...
               'EdgeColor', 'none', ...
               'FontSize', 16, ...
               'FontWeight', 'bold');
end

function dataSetName = getCleanDataSetName(folderStruct, idx)
    if isfield(folderStruct, 'data_set_name')
        rawName = folderStruct.data_set_name;
    else
        rawName = sprintf('DataSet_%02d', idx);
    end
    dataSetName = strrep(rawName, '_', ' ');
end

function plotAndSaveODF(odf, hDirs, outFilePath, sel, frac, dataSetName)
    fig = figure('Visible','off');
    plotPDF(odf, hDirs, 'contourf', 'levels', linspace(0.5,2.0,10), ...
            'resolution', 5*degree, 'antipodal');
    mtexColorbar;
    set(fig, 'Visible', 'off');
    addFigureAnnotation(fig, sel, frac, dataSetName);
    print(fig, [outFilePath '.png'], '-dpng', '-r300');
    close(fig);
end
