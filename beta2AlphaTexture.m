%==========================================================================
% MATLAB Script for Batch β→α Texture Transformation
%==========================================================================

clear all
close all

debug = true;
consider_PreExistingAlpha = true;

%==================== User-Defined Paths and Parameters ====================
rootDir  = 'Z:\backUps\currentProjects\colloborations\shibayan_iitKgp\Mani Sir';
jsonFile = fullfile(rootDir, 'xrdmlInfo_2.json');
selList  = 0.1:0.3:1.0;
levels10 = linspace(0.5,2.0,10);
manualJsonText = [ ...
    '[', ...
    '  {', ...
    '    "folder": "Data_Ti6242\\\\Deformed Ti6242-HC 900C-1s-1\\\\HT XRT\\\\1000C\\\\beta",', ...
    '    "data_set_name": "Defmd_Ti6242_1000_beta",', ...
    '    "pre_transformed_alpha_present": true,', ...
    '    "pre_transformed_alpha_texture_data": "Data_Ti6242\\\\Deformed Ti6242-HC 900C-1s-1\\\\HT XRT\\\\1000C\\\\alpha",', ...
    '    "pre_transformed_alpha_fraction": 0.2,', ...
    '    "files": [', ...
    '      { "file": "PF-1 beta _1000.2°C_1000C.xrdml", "hkl": [1, 1, 0], "twoTheta": 38.43 },', ...
    '      { "file": "PF-2 beta _1000.2°C_1000C.xrdml", "hkl": [2, 0, 0], "twoTheta": 53.55 },', ...
    '      { "file": "PF-3 beta_1000.2°C_1000C.xrdml", "hkl": [2, 1, 1], "twoTheta": 68.47 }', ...
    '    ]', ...
    '  },', ...
    '  {', ...
    '    "folder": "Data_Ti6242\\\\Deformed Ti6242-HC 900C-1s-1\\\\HT XRT\\\\1000C\\\\alpha",', ...
    '    "data_set_name": "Defmd_Ti6242_1000_alpha",', ...
    '    "files": [', ...
    '      { "file": "PF-1 alpha _1000.2°C_1000C.xrdml", "hkl": [1, 0, 0], "twoTheta": 34.74 },', ...
    '      { "file": "PF-2 alpha _1000.2°C_1000C.xrdml", "hkl": [1, 0, 2], "twoTheta": 39.6 },', ...
    '      { "file": "PF-3 alpha _1000.2°C_1000C.xrdml", "hkl": [1, 0, 2], "twoTheta": 52.08 },', ...
    '      { "file": "PF-4 alpha _1000.2°C_1000C.xrdml", "hkl": [1, 0, 3], "twoTheta": 69.36 }', ...
    '    ]', ...
    '  }', ...
    ']'
    ];
if ~isempty(strtrim(manualJsonText))
    fprintf('INFO: Using in-script manual JSON for testing.\n');
    folders = jsondecode(manualJsonText);
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
fprintf('\n=======  Batch β→α ODF conversion  =======\n');
ticGlobal = tic;
procCount = 0;

for idx = 1:numel(folders)
    folderPath = fullfile(rootDir, folders{idx}.folder);
    if ~endsWith(lower(folderPath), '\beta'); continue; end

    odfFile = fullfile(folderPath, 'odf.txt');
    if ~isfile(odfFile)
        warning('Folder "%s" has no odf.txt – skipped.', folderPath);
        continue
    end

    tbl = readmatrix(odfFile,'FileType','text','CommentStyle','%');
    if debug
        tbl = tbl(1:40:end, :);
        fprintf('DEBUG MODE: Using every 40th row only from odf.txt.');
    end
    betaEul = tbl(:,1:3);
    wBeta   = tbl(:,4) / sum(tbl(:,4));
    odfBeta = calcODF(orientation('Euler', betaEul(:,1)*degree, ...
                                           betaEul(:,2)*degree, ...
                                           betaEul(:,3)*degree, csB, ss), ...
                      'weights', wBeta );

    tFolder = tic;
    for s = 1:numel(selList)
        sel = selList(s);
        [gA, wA] = beta2alphaVariants(betaEul, wBeta, sel, false);
        wA = wA / sum(wA);

        % CASE 1: Without pre-existing alpha
        alphaFrac = 0.0;
        odfA = calcODF(gA, 'weights', wA);
        dataSetName = getCleanDataSetName(folders{idx}, idx);
        outODF = fullfile(folderPath, ...
            sprintf('alpha_texture_sel_%04.2f_Alpha_Frac_%04.2f.odf', sel, alphaFrac));
        export(odfA, outODF, 'Bunge');
        plotAndSaveODF(odfA, hA, outODF, sel, alphaFrac, dataSetName);

        % CASE 2: With pre-existing alpha
        if consider_PreExistingAlpha
            if isfield(folders{idx}, 'pre_transformed_alpha_present') && folders{idx}.("pre_transformed_alpha_present")
                fprintf(1,"INFO: Found pre-existing alpha texture. Adding its contribution.\n");

                alphaFolder  = fullfile(rootDir, folders{idx}.("pre_transformed_alpha_texture_data"));
                odfAlphaFile = fullfile(alphaFolder, 'odf.txt');
                if isfile(odfAlphaFile)
                    tblAlpha = readmatrix(odfAlphaFile, 'FileType', 'text', 'CommentStyle', '%');
                    if debug
                        tblAlpha = tblAlpha(1:40:end, :);
                        fprintf('DEBUG MODE: Using every 40th row from alpha odf.txt');
                    end
                    alphaEul = tblAlpha(:, 1:3);
                    wAlpha   = tblAlpha(:, 4) / sum(tblAlpha(:, 4));
                    odfAlpha_pre = calcODF( ...
                        orientation('Euler', alphaEul(:,1)*degree, ...
                                            alphaEul(:,2)*degree, ...
                                            alphaEul(:,3)*degree, csA, ss), ...
                                            'weights', wAlpha );

                    alphaFrac = folders{idx}.("pre_transformed_alpha_fraction");
                    odfA_combined = odfA * (1 - alphaFrac) + odfAlpha_pre * alphaFrac;
                    outODF_combined = fullfile(folderPath, ...
                        sprintf('alpha_texture_sel_%04.2f_Alpha_Frac_%04.2f.odf', sel, alphaFrac));
                    export(odfA_combined, outODF_combined, 'Bunge');
                    plotAndSaveODF(odfA_combined, hA, outODF_combined, sel, alphaFrac, dataSetName);
                else
                    warning('Missing file: %s Probably there was no pre-exisitng alppha !!!', odfAlphaFile);
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
function addFigureAnnotation(figHandle, sel, alphaFrac, dataSetName)
    annotationText = sprintf('\\eta=%.2f\n\\alpha_{f}=%.2f\nData:%s', ...
                         sel, alphaFrac, dataSetName);
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

function plotAndSaveODF(odf, hA, outFilePath, sel, alphaFrac, dataSetName)
    fig = figure('Visible','off');
    plotPDF(odf, hA, 'contourf', 'levels', linspace(0.5,2.0,10), ...
            'resolution', 5*degree, 'antipodal');
    mtexColorbar;
    set(fig, 'Visible', 'off');
    addFigureAnnotation(fig, sel, alphaFrac, dataSetName);
    print(fig, [outFilePath '.png'], '-dpng', '-r300');
    close(fig);
end
