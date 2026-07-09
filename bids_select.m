function [matches] = bids_select(bidsdir, subdir, patterns) 

% type checking
if ~iscell(patterns)
    patterns = {patterns};  % make sure it's a cell
end

% Force column vector (safest)
patterns = patterns(:);

% Remove empty char cells '' from patterns:
patterns(cellfun('isempty', patterns)) = [];

% Debug (remove later)
% disp('patterns size:'); disp(size(patterns));
% disp(patterns);

files = dir(fullfile(bidsdir, subdir));
matches = {};

for i = 1:length(files)   % better than height()
    if strcmp(files(i).name, '.') || strcmp(files(i).name, '..') || ...
       isfolder(fullfile(files(i).folder, files(i).name))
        continue;
    end
    
    fileMatches = true;
    for j = 1:length(patterns)
        pat = char(patterns{j});           % ensure char
        if isempty(regexpi(files(i).name, pat, 'ONCE'))
            fileMatches = false;
            break;
        end
    end
    
    if fileMatches
        filepath = fullfile(files(i).folder, files(i).name);
        matches{end+1} = filepath;     % safer than matches(end+1) = ...
    end
end % loop over files

end
