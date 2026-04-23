function [strPart, numPart, isMulti] = extract_task_info(inputStr)
% old function name: taskAndSequence;
% separate task from block number
% "sub-000_taskname.?-practive_stim.csv" where "?" is a number:
% Initialize outputs
strPart = inputStr;
numPart = 0;
isMulti = false;

% Check if the string ends with a period followed by digits
pattern = '\.(\d+)$';
matches = regexp(inputStr, pattern, 'tokens');

if ~isempty(matches)
    isMulti = true;
    % Extract the number part
    numPart = str2double(matches{1}{1});
    % Extract the string part (before the period and number)
    strPart = regexprep(inputStr, '\.\d+$', '');
end

end