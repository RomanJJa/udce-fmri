function [matches] = subdirs(x) 
    matches = dir(x);
    matches(~[matches.isdir]) = [];
    matches(ismember({matches.name}, {'.', '..'})) = [];
    matches = {matches.name};
end