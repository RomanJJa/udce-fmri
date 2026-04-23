function table = read_stimuli(filename)
    % Read the stimuli:
    % Detect import options
    opts = detectImportOptions(filename, 'TextType', 'char');
    
    % Ensure stim1 and stim2 are read as char
    opts.VariableTypes{strcmp(opts.VariableNames, 'stim1')} = 'char';
    opts.VariableTypes{strcmp(opts.VariableNames, 'stim2')} = 'char';
    opts.VariableTypes{strcmp(opts.VariableNames, 'stim2')} = 'char';
    opts.VariableTypes{strcmp(opts.VariableNames, 'condition')} = 'char';
    opts.VariableTypes{strcmp(opts.VariableNames, 'isi')} = 'double';
    
    % Read the table
    table = readtable(filename, opts);
end