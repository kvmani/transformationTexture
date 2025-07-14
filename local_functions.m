
function addFigureAnnotation(figHandle, sel, alphaFrac, dataSetName)
% addFigureAnnotation - Annotates a given figure with simulation parameters.
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
%
% Syntax:
%   addFigureAnnotation(figHandle, sel, alphaFrac, dataSetName)
%
% Inputs:
%   figHandle    - Handle to the figure to annotate
%   sel          - Variant selection parameter (η)
%   alphaFrac    - Fraction of pre-existing alpha phase
%   dataSetName  - Short descriptive name of dataset (underscores replaced with space)

    annotationText = sprintf('$$\eta$$ = %.2f\newline$$\alpha_f$$ = %.2f\newline\textbf{Data:} %s', ...
                             sel, alphaFrac, dataSetName);
    annotation(figHandle, 'textbox', [0.02, 0.01, 0.3, 0.12], ...
               'String', annotationText, ...
               'Interpreter', 'latex', ...
               'HorizontalAlignment', 'left', ...
               'VerticalAlignment', 'bottom', ...
               'EdgeColor', 'none', ...
               'FontSize', 16, ...
               'FontWeight', 'bold');
end

function dataSetName = getCleanDataSetName(folderStruct, idx)
% getCleanDataSetName - Retrieves and formats a dataset name.
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
%
% Syntax:
%   dataSetName = getCleanDataSetName(folderStruct, idx)
%
% Inputs:
%   folderStruct - Struct entry from JSON containing folder metadata
%   idx          - Index of the current folder being processed
%
% Output:
%   dataSetName  - Cleaned dataset name (underscores replaced with spaces)

    if isfield(folderStruct, 'data_set_name')
        rawName = folderStruct.data_set_name;
    else
        rawName = sprintf('DataSet_%02d', idx);
    end
    dataSetName = strrep(rawName, '_', ' ');
end

function plotAndSaveODF(odf, hA, outFilePath, sel, alphaFrac, dataSetName)
% plotAndSaveODF - Plots the ODF, adds annotation, and saves to PNG.
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
%
% Syntax:
%   plotAndSaveODF(odf, hA, outFilePath, sel, alphaFrac, dataSetName)
%
% Inputs:
%   odf          - Orientation distribution function to plot
%   hA           - Array of Miller indices for pole figure directions
%   outFilePath  - Path prefix to save the ODF and figure
%   sel          - Variant selection parameter
%   alphaFrac    - Alpha phase fraction
%   dataSetName  - Clean dataset name used in annotation

    fig = figure('Visible','off');
    plotPDF(odf, hA, 'contourf', 'levels', linspace(0.5,2.0,10), ...
            'resolution', 5*degree, 'antipodal');
    mtexColorbar;
    set(fig, 'Visible', 'off');
    addFigureAnnotation(fig, sel, alphaFrac, dataSetName);
    print(fig, [outFilePath '.png'], '-dpng', '-r300');
    close(fig);
end
