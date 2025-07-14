%==========================================================================
% MATLAB Script for Batch \alpha\to\beta Texture Transformation (Reverse Burgers OR)
%==========================================================================
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
% This script converts alpha texture data back to beta phase using
% parentToProductTexture for each dataset listed in a JSON file.

clear all
close all

checkEnvironment();

debug = true;
consider_PreExistingBeta = true;

%==================== User-Defined Paths and Parameters ====================
if ~exist('rootDir','var')
    rootDir  = 'Z:\\backUps\\currentProjects\\colloborations\\shibayan_iitKgp\\Mani Sir';
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
    '    { "file": "PF-1 alpha _RT_25.1\xC2\xB0C.xrdml", "hkl": [1, 0, 0], "twoTheta":35.58 }, ', ...
    '    { "file": "PF-2 alpha _RT_25.1\xC2\xB0C.xrdml", "hkl": [0, 0, 2], "twoTheta":38.62 }, ', ...
    '    { "file": "PF-3 alpha _RT_25.1\xC2\xB0C.xrdml", "hkl": [1, 0, 1], "twoTheta":40.57 }, ', ...
    '    { "file": "PF-4 alpha _RT_25.4\xC2\xB0C.xrdml", "hkl": [1, 0, 2], "twoTheta":53.41 } ', ...
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

%======================= Start Batch Processing Loop ======================
fprintf('\n=======  Batch α→β ODF conversion  =======\n');
ticGlobal = tic;
procCount = 0;

for idx = 1:numel(folders)
    folderPath = fullfile(rootDir, folders{idx}.folder);
    if ~endsWith(lower(folderPath), '\\alpha'); continue; end

    odfFile = fullfile(folderPath, 'odf.txt');
    if ~isfile(odfFile)
        warning('Folder "%s" has no odf.txt – skipped.', folderPath);
        continue
    end

    dataSetName = getCleanDataSetName(folders{idx}, idx);
    tFolder = tic;
    for s = 1:numel(selList)
        sel = selList(s);
        % CASE 1: Without pre-existing beta
        parentToProductTexture(odfFile,'alpha','beta','Sel',sel,...
            'OutputDir',folderPath,'DataSetName',dataSetName,'PreFraction',0.0);

        % CASE 2: With pre-existing beta
        if consider_PreExistingBeta
            if isfield(folders{idx}, 'pre_transformed_beta_present') && folders{idx}.("pre_transformed_beta_present")
                betaFolder  = fullfile(rootDir, folders{idx}.("pre_transformed_beta_texture_data"));
                preFile = fullfile(betaFolder,'odf.txt');
                if isfile(preFile)
                    betaFrac = folders{idx}.("pre_transformed_beta_fraction");
                    parentToProductTexture(odfFile,'alpha','beta','Sel',sel,...
                        'PreTransformed',true,'PreTextureFile',preFile,...
                        'PreFraction',betaFrac,'OutputDir',folderPath,...
                        'DataSetName',dataSetName);
                else
                    warning('Missing file: %s', preFile);
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
