function [matches] = bids_select(bidsdir, subdir, patterns) 

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
% 
% , , 


% Height checking:
if (height(patterns) < width(patterns))
    patterns = patterns';
end

% files = dir('D:\Data\**\*.mat')
files = dir(fullfile(bidsdir, subdir));
matches = {};
for i = 1:height(files)
    % i = 6
    if strcmp(files(i).name, '.') || strcmp(files(i).name, '..') || ...
       isfolder(fullfile(files(i).folder, files(i).name))
        continue;
    end
    
    fileMatches = true;
    for j = 1:height(patterns)
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