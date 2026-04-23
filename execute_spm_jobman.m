function [doexecute] = execute_spm_jobman(spmbatch, doexecute)
    % Execute SPM's Jobman:
    % @argument spmbatch: the batch struct to be used in SPM
    % @argument doexecute: boolian to express if the jobman ought to be
    %                      executed
    matlabbatch{1}.spm = spmbatch;
    try
        if doexecute
            spm_jobman('run', matlabbatch);
        end
    catch error_jobman
        doexecute = false;
        warning(error_jobman.identifier, ...
                "Error during SPM jobman execution:\n%s", ...
                error_jobman.message);
    end
end
