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


%{
function [matches] = bids_select(bidsdir, subdir, selector) 

% bidsdir:  directory to the BIDS structure 
%           (the folder containing the folders sub-001, sub-002, ...)
% subdir:   any sub-directory to be checked; 
%           either '' checking the whole BIDS directory or
%           something like 'sub-004/func' checking functional images of
%           subject 4.
% patterns: cell array of fragments to check for in the files 
%           (like 'ses-2' for session 2)


% for testing:
%bidsdir  = 'C:\Users\Roman\Documents\MATLAB\projects\udce-fmri\tasks\data';
%subdir   = 'sub-004/func/task-lexi_run-1_model-spm';
%subdir   = 'sub-004/func';
%patterns = [{'^sig', '\.csv$'}];
%bids_select(bidsdir, subdir, patterns);

% For testing 2:
%bidsdir  = rootDirectory;
%subdir   = fullfile(['sub-' char(subject)], 'beh');
%patterns = [{sprintf('sub-%s', subject)}, {sprintf('_task-%s', taskName)}, {sprintf('_ses-%d_', sesNumber)}, {'_events\.log$'}];

if isrow(selector)
    patterns = selector(:);  % Transpose to column
end


% Remove empty char cells '' from patterns:
patterns(cellfun('isempty', patterns)) = [];

fprintf('Removed empty cells:\n');
disp(patterns);

% files = dir('D:\Data\**\*.mat')
files = dir(fullfile(bidsdir, subdir));
matches = {};
for i = 1:length(files)
    % i = 1
    if strcmp(files(i).name, '.') || strcmp(files(i).name, '..') || ...
       isfolder(fullfile(files(i).folder, files(i).name))
        continue;
    end
    
    fileMatches = true;
    for j = 1:length(patterns)
        if isempty(regexpi(files(i).name, char(patterns(j)), 'ONCE'))
            fileMatches = false;
            break;
        end
    end
	    
    if (fileMatches)
        filepath = fullfile(files(i).folder, files(i).name);
        matches(end+1) = {filepath};
    end
end

end
%}