function strOut = prettyJSON(strIn, indent)
% prettyJSON – pretty-print & compact JSON
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
% Format JSON text with indentation for readability.
% • classic indenter  • inline [h,k,l] and {file:…,hkl:…,twoTheta:…}

if nargin<2, indent = '    '; end
json = char(strIn);                   % ensure CHAR

% ---- 1. basic indentation ----------------------------------------------
out = '';  depth = 0;  inStr = false; esc = false;
for ch = json
    if esc,  esc=false;  out=[out ch];  continue; end
    if ch=='\' && inStr, esc=true; out=[out ch]; continue; end
    if ch=='"', inStr = ~inStr; out=[out ch]; continue; end
    if ~inStr
        switch ch
            case {'{','['}
                depth = depth+1;
                out = [out ch newline repmat(indent,1,depth)]; continue
            case {'}',']'}
                depth = depth-1;
                out = [out newline repmat(indent,1,depth) ch]; continue
            case ','
                out = [out ch newline repmat(indent,1,depth)]; continue
            case ':'
                out = [out ': ']; continue
        end
    end
    out = [out ch];
end

% ---- 2a  inline 3-number arrays  ---------------------------------------
out = regexprep(out, ...
      '\[\s*([0-9eE\+\-\.]+)\s*,\s*([0-9eE\+\-\.]+)\s*,\s*([0-9eE\+\-\.]+)\s*\]', ...
      '[$1, $2, $3]');

% ---- 2b  inline each {file:…,hkl:…,twoTheta:…} object -------------------
% simple parser: collapse text between "{ " and " }" that contains no brace
lines = regexp(out,'\n','split');
i = 1;
while i <= numel(lines)
    if contains(lines{i}, '"file"')                       % start of a file-object
        j      = i;
        buffer = strtrim(lines{j});
        while j < numel(lines) && ~endsWith(strtrim(lines{j}), '}')
            j      = j + 1;
            buffer = [buffer ' ' strtrim(lines{j})];      % concatenate
        end
        lines(i:j) = [];                % delete original block
        lines      = [lines(1:i-1), {buffer}, lines(i:end)];  % insert compact line
        i = i + 1;                      % move past the newly inserted line
    else
        i = i + 1;                      % no "file", just advance
    end
end
lines = regexprep(lines, ',\s*\{', [',' newline indent indent '{']);
strOut = strjoin(lines,newline);
strOut = regexprep(strOut, '\{\s*\n\s*"', '{ "');  
strOut = regexprep(strOut, ['\n' repmat(' ',1,12) '\{ "file"'], ...
                           ['\n' indent indent '{ "file"']);
end
