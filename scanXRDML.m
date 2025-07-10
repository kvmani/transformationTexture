% scanXRDML  –  build JSON inventory of {hkl, 2θ} values in .xrdml files
%
%   scanXRDML('C:\diffraction\data');
%
% The script produces  xrdmlInfo.json  in the *rootDir* folder with content:
% [
%   { "folder": "sub\Alpha",
%     "files": [
%         { "file": "PF-1 alpha.xrdml", "hkl":[1 0 0], "twoTheta":34.14 },
%         ...
%     ] },
%   ...
% ]

% ------------------------------------------------------------------ checks
% if nargin==0 || ~isfolder(rootDir)
%     error('Give a valid root folder, e.g.  scanXRDML(''C:\data'').');
% end

% ------------------------------------------------------------------ setup
rootDir = 'Z:\backUps\currentProjects\colloborations\shibayan_iitKgp\Mani Sir'
fileList  = dir(fullfile(rootDir,'**','*.xrdml'));   % recursive search
if isempty(fileList)
    fprintf('No .xrdml files found under %s\n',rootDir);  return
end

folderMap = containers.Map('KeyType','char','ValueType','any');

% ------------------------------------------------------------------ loop
for idx = 1:numel(fileList)
    fPath = fullfile(fileList(idx).folder, fileList(idx).name);

    % ---------- read XML -------------------------------------------------
    try
        xDoc = xmlread(fPath);
    catch
        warning('Could not parse XML: %s',fPath);  continue
    end

    % ---------- first <hkl> ---------------------------------------------
    hNode = xDoc.getElementsByTagName('hkl');
    if hNode.getLength == 0,  continue,  end
    hElem = hNode.item(0);
    h = str2double(char(hElem.getElementsByTagName('h').item(0).getTextContent));
    k = str2double(char(hElem.getElementsByTagName('k').item(0).getTextContent));
    l = str2double(char(hElem.getElementsByTagName('l').item(0).getTextContent));

    % ---------- first 2θ <commonPosition> -------------------------------
    twoTheta = NaN;
    posNode  = xDoc.getElementsByTagName('positions');
    for j = 0:posNode.getLength-1
        p = posNode.item(j);
        if strcmpi(char(p.getAttribute('axis')),'2Theta')
            cp = p.getElementsByTagName('commonPosition');
            if cp.getLength>0
                twoTheta = str2double(char(cp.item(0).getTextContent));
                break
            end
        end
    end

    % ---------- relative folder key -------------------------------------
    relPath   = erase(fPath,[rootDir filesep]);
    relFolder = fileparts(relPath);

    fileEntry = struct( ...
        'file',     fileList(idx).name, ...
        'hkl',      [h k l], ...
        'twoTheta', twoTheta );

    if folderMap.isKey(relFolder)            % append
        tmp          = folderMap(relFolder);
        tmp.files(end+1) = fileEntry;
        folderMap(relFolder) = tmp;
    else                                     % new bucket
        folderMap(relFolder) = struct( ...
            'folder', relFolder, ...
            'files',  fileEntry );
    end
end

% ------------------------------------------------------------------ write
%infoGrouped = [values(folderMap){:}];      % struct array
vals        = values(folderMap);   % returns a 1×N cell array of structs
infoGrouped = [vals{:}];           % concatenate into a 1×N struct array
rawJSON     = jsonencode(infoGrouped);     % compact
prettyJSONtxt  = prettyJSON(rawJSON);    % indent

outFile = fullfile(rootDir,'xrdmlInfo_2.json');
fid     = fopen(outFile,'w');  fwrite(fid,prettyJSONtxt,'char');  fclose(fid);

fprintf('Saved grouped JSON to  %s\n',outFile);

% =======================================================================
