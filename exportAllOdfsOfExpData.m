%function exportAllOdfsOfExpData(jsonFile)
% RUN_TEXTURE_ANALYSIS  – loop over folders in xrdmlInfo.json,
%                         build ODFs and pole-figure PNGs.
%
%   run_texture_analysis('xrdmlInfo.json')

%if nargin < 1, jsonFile = 'xrdmlInfo.json'; end
rootDir = 'Z:\backUps\currentProjects\colloborations\shibayan_iitKgp\Mani Sir'
jsonFile='Z:\backUps\currentProjects\colloborations\shibayan_iitKgp\Mani Sir\xrdmlInfo_2.json'
folders = jsondecode(fileread(jsonFile) );

% --- common specimen symmetry & plot style ------------------------------
SS = specimenSymmetry('1');
setMTEXpref('xAxisDirection','east');   % your favourite defaults
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('defaultColorMap','parula');

for b = 1:numel(folders)    
    folder   = folders(b).folder;
    files    = folders(b).files;
    fPaths = fullfile(rootDir,folder, {files.file});
    fPaths = strrep(fPaths, '\', '/');     
    workDir = fileparts(fPaths{1});           % the folder being processed

    if exist(fullfile(workDir,'odf.txt'),     'file') && ...
       exist(fullfile(workDir,'polefigs.png'),'file')
        warning('Folder "%s": odf.txt and polefigs.png already exist – skipping.', workDir);
        continue                               % go on to next folder / loop
    end

    % -------- phase decision --------------------------------------------
    if contains(lower(folder), '\alpha')      

        phase   = 'alpha';
        isAlpha = true
        CS      = crystalSymmetry('6/mmm',[2.951 2.951 4.684],'mineral','α-Ti');
        hklList = {
            [files(1).hkl(1),files(2).hkl(1),files(3).hkl(1), files(4).hkl(1)],
            [files(1).hkl(2),files(2).hkl(2),files(3).hkl(2), files(4).hkl(2)],
            [files(1).hkl(3),files(2).hkl(3),files(3).hkl(3), files(4).hkl(3)],                       
            }
         H_pf = { ...
            Miller( 0,  0,  0,  2, CS), ...   % {0002}
            Miller( 1,  0, -1,  0, CS), ...   % {10-10}
            Miller( 2, -1, -1,  0, CS)  ...   % {20-110}
        };
       
        
    elseif contains(lower(folder), '\beta')
        isAlpha =false
        phase   = 'beta';
        CS      = crystalSymmetry('m-3m',[3.32 3.32 3.32],'mineral','β-Ti');
        hklList = {
            [files(1).hkl(1),files(2).hkl(1),files(3).hkl(1), ],
            [files(1).hkl(2),files(2).hkl(2),files(3).hkl(2), ],
            [files(1).hkl(3),files(2).hkl(3),files(3).hkl(3), ],                       
            }
        H_pf = { ...
            Miller(0,0,1, CS),  ...            % {001}
            Miller(1,1,0, CS),  ...            % {110}
            Miller(1,1,1, CS)   ...            % {111}
        };
       
    else
        warning('Folder “%s” not recognised as alpha or beta – skipped.',folder);
        continue
    end

    % -------- assemble file paths & Miller list -------------------------
    
    H      = Miller(hklList,CS)

    % -------- load pole figures & build ODF -----------------------------
    try
        pf  = PoleFigure.load(fPaths,H,CS,SS,'interface','xrdml');
    catch ME
        warning('Load failed in %s : %s',folder,ME.message); continue
    end
    odf = calcODF(pf);

    % -------- export ODF & plot PFs -------------------------------------
    odfTxt = fullfile(rootDir, folder,'odf.txt');
    export(odf,odfTxt,'Bunge');

    fig = figure('Visible','off','Color','w');
    if (isAlpha )
        plotPDF(odf, [H_pf(1),H_pf(2),H_pf(3)],  'contourf','levels',10,'resolution',5*degree,'antipodal');
    else
        plotPDF(odf, [H_pf(1),H_pf(2),H_pf(3)], 'contourf','levels',10,'resolution',5*degree,'antipodal');
    end    
    mtexColorbar;
    sgtitle(sprintf('%s pole figures – %s',phase,folder),'Interpreter','none');
    print(fig, fullfile(rootDir, folder,'polefigs.png'), '-dpng','-r300');
    close(fig);

    fprintf('✔  %s : ODF + PF saved\n',folder);

    
end
