function checkEnvironment()
% checkEnvironment - Ensures MATLAB and MTEX versions meet requirements.

    % Check MATLAB version
    if verLessThan('matlab','9.8')
        error('MATLAB 9.8 (R2020a) or newer is required.');
    end

    % Check if mtex_path function exists
    if exist('mtex_path', 'file') ~= 2
        error('Function mtex_path not found. Cannot determine MTEX installation path.');
    end

    % Get MTEX path and extract version
    mtexPath = char(mtex_path());  % Call the function
    tokens = regexp(mtexPath, 'mtex[-_]?(\d+\.\d+\.\d+)', 'tokens');
    
    if ~isempty(tokens) && ~isempty(tokens{1})
        mtexVer = tokens{1}{1};
    else
        error('Unable to extract MTEX version from path: %s', mtexPath);
    end

    % Compare version
    requiredVersion = '5.4.0';
    if ~strcmp(strtrim(mtexVer), requiredVersion)
        error('MTEX version %s is required. Detected %s.', requiredVersion, mtexVer);
    end
end
