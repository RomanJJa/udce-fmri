function [res] = get_bids_attribute(attr, file)
    % Select the value from a BIDS attribute "attr" from any file "file"
    % file = 'sub-002/func/s2_w_r_v_sub-002_task-nct2_run-1_sn-6000_bold.nii'; attr ='task'
    % file = 'D:\bids-numword\sub-002\beh\sub-002_task-nct2-test_run-1_try-1_beh.csv'; attr ='task'

    [~,fn,ext] = fileparts(file);
    res = '';
    
    if strcmpi('extension', attr)
        res = ext;
        return
    end
    
    attributes = split(fn, '_', 2);

    if strcmpi('type', attr)
        res = char(attributes(end));
        if contains(res, '-')
            res = '';
            return
        end
        return
    end
    
    for i = 1:numel(attributes)
        % i = 2
        a    = attributes(i);
        aspl = split(a, '-', 2);
        if strcmpi(char(aspl(1)), attr)
            res  = char(join(aspl(2:end), '-'));
            return
        end
    end
end