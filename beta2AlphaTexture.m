%==========================================================================
% MATLAB Script for Batch \beta\to\alpha Texture Transformation
%==========================================================================
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
% Batch processing wrapper that uses parentToProductTexture to
% perform the forward Burgers transformation for each dataset.

clear all
close all

checkEnvironment();

debug = true;
consider_PreExistingAlpha = true;

%==================== User-Defined Paths and Parameters ====================
if ~exist('rootDir','var')
    rootDir = 'Z:\\backUps\\currentProjects\\colloborations\\shibayan_iitKgp\\Mani Sir';
end
if ~exist('jsonFile','var')
    jsonFile = fullfile(rootDir, 'xrdmlInfo_2.json');
end
if ~exist('selList','var')
    selList = 0.1:0.3:1.0;
end
levels10 = linspace(0.5,2.0,10);
if ~exist('manualJsonText','var')
manualJsonText = [ ...
    '[', ...
    '  {', ...
    '    "folder": "Data_Ti6242\\\\Deformed Ti6242-HC 900C-1s-1\\\\HT XRT\\\\1000C\\\\beta",', ...
    '    "data_set_name": "Defmd_Ti6242_1000_beta",', ...
    '    "pre_transformed_alpha_present": true,', ...
    '    "pre_transformed_alpha_texture_data": "Data_Ti6242\\\\Deformed Ti6242-HC 900C-1s-1\\\\HT XRT\\\\1000C\\\\alpha",', ...
    '    "pre_transformed_alpha_fraction": 0.2,', ...
    '    "files": [', ...
    '      { "file": "PF-1 beta _1000.2\xC2\xB0C_1000C.xrdml", "hkl": [1, 1, 0], "twoTheta": 38.43 },', ...
    '      { "file": "PF-2 beta _1000.2\xC2\xB0C_1000C.xrdml", "hkl": [2, 0, 0], "twoTheta": 53.55 },', ...
    '      { "file": "PF-3 beta_1000.2\xC2\xB0C_1000C.xrdml", "hkl": [2, 1, 1], "twoTheta": 68.47 }', ...
    '    ]', ...
    '  },', ...
    '  {', ...
    '    "folder": "Data_Ti6242\\\\Deformed Ti6242-HC 900C-1s-1\\\\HT XRT\\\\1000C\\\\alpha",', ...
    '    "data_set_name": "Defmd_Ti6242_1000_alpha",', ...
    '    "files": [', ...
    '      { "file": "PF-1 alpha _1000.2\xC2\xB0C_1000C.xrdml", "hkl": [1, 0, 0], "twoTheta": 34.74 },', ...
    '      { "file": "PF-2 alpha _1000.2\xC2\xB0C_1000C.xrdml", "hkl": [1, 0, 2], "twoTheta": 39.6 },', ...
    '      { "file": "PF-3 alpha _1000.2\xC2\xB0C_1000C.xrdml", "hkl": [1, 0, 2], "twoTheta": 52.08 },', ...
    '      { "file": "PF-4 alpha _1000.2\xC2\xB0C_1000C.xrdml", "hkl": [1, 0, 3], "twoTheta": 69.36 }', ...
    '    ]', ...
    '  }', ...
    ']'
    ];
end
if ~isempty(strtrim(manualJsonText))
    fprintf('INFO: Using in-script manual JSON for testing.\n');
    folders = jsondecode(manualJsonText);
else
    fprintf('INFO: Using JSON input file: %s\n', jsonFile);
    folders = jsondecode(fileread(jsonFile));
end

%======================= Start Batch Processing Loop ======================
fprintf('\n=======  Batch β→α ODF conversion  =======\n');
ticGlobal = tic;
procCount = 0;

for idx = 1:numel(folders)
    folderPath = fullfile(rootDir, folders{idx}.folder);
    if ~endsWith(lower(folderPath), '\\beta'); continue; end

    odfFile = fullfile(folderPath, 'odf.txt');
    if ~isfile(odfFile)
        warning('Folder "%s" has no odf.txt – skipped.', folderPath);
        continue
    end

    dataSetName = getCleanDataSetName(folders{idx}, idx);
    tFolder = tic;
    for s = 1:numel(selList)
        sel = selList(s);
        % CASE 1: Without pre-existing alpha
        parentToProductTexture(odfFile,'beta','alpha','Sel',sel,...
            'OutputDir',folderPath,'DataSetName',dataSetName,'PreFraction',0.0);
        % CASE 2: With pre-existing alpha
        if consider_PreExistingAlpha
            if isfield(folders{idx}, 'pre_transformed_alpha_present') && folders{idx}.("pre_transformed_alpha_present")
                alphaFolder  = fullfile(rootDir, folders{idx}.("pre_transformed_alpha_texture_data"));
                preFile = fullfile(alphaFolder,'odf.txt');
                if isfile(preFile)
                    alphaFrac = folders{idx}.("pre_transformed_alpha_fraction");
                    parentToProductTexture(odfFile,'beta','alpha','Sel',sel,
                        'PreTransformed',true,'PreTextureFile',preFile,
                        'PreFraction',alphaFrac,'OutputDir',folderPath,
                        'DataSetName',dataSetName);
                else
                    warning('Missing file: %s Probably there was no pre-exisitng alppha !!!', preFile);
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

    fprintf('  \xE2\x9C\x94  %s  (%.1f s)\n', folderPath, toc(tFolder));
    procCount = procCount + 1;

    if debug
        fprintf('Debug mode: processed first folder only.\n');
        break
    end
end
fprintf('\nProcessed %d folder(s) in %.1f s total.\n', procCount, toc(ticGlobal));
