%% MATLAB script: Convert DICOM folders to NIfTI using MRIcroGL's dcm2niix

% === USER SETTINGS ===
mricrogl_path = 'C:\Users\Roman\Documents\MATLAB\MRIcroGL_windows\MRIcroGL';
%data_dir      = 'C:\Users\Roman\Documents\MATLAB\projects\udce-fmri\tasks\data';
data_dir      = 'D:\bids-numword';
seq_subdir    = 'DICOM';
tmp_subdir    = 'NIfTI';
dcm2niix_file = 'dcm2niix';
exclude_subj  = {'sub-000'};
if ispc
    dcm2niix_file = [dcm2niix_file '.exe'];
end
dcm2niix_exe  = fullfile(mricrogl_path, 'Resources', dcm2niix_file);

% dictionary with Protocol names to task names:
protocol2fn_path = fileparts(data_dir);
protocol2fn_str = fileread(fullfile(protocol2fn_path, 'protocol2bids.json'));
protocol2fn = jsondecode(protocol2fn_str);

dada_subdirs = subdirs(data_dir);
subj_dirs = dada_subdirs(startsWith(dada_subdirs, 'sub-'));
subj_dirs = setdiff(subj_dirs, exclude_subj);
%subj_dirs = {'sub-006','sub-007'};

% dcm2niix options:
dcm2niix_options = '-z y -b y -f "%s_%p"'; % -z: compress; -b: bids json; -f: nice filenames

for s = 1:numel(subj_dirs) % loop through all participants
    % s = 1

    subject_name = char(subj_dirs(s));
    subject_dir  = fullfile(data_dir, subject_name);
    
    dicom_dir  = fullfile(data_dir, subject_name, 'dicom');
    dicom_seqs = subdirs(dicom_dir);
    
    seq_dirs  = fullfile(subject_dir, 'dicom', dicom_seqs, seq_subdir);
    tmp_dirs  = fullfile(subject_dir, 'dicom', dicom_seqs, tmp_subdir);
    func_dir  = fullfile(subject_dir, 'func');
    anant_dir = fullfile(subject_dir, 'anat');
    
    %% First check if functional files already exist:
    if max(height(dicom_seqs), width(dicom_seqs)) < 0 || ...
       (length(dir(func_dir)) > 2 && length(dir(anant_dir)) > 2)
        fprintf('\nSkipped subject %s\n', subject_name);
        continue;
    end
    
    % Add more if needed: ' -x y' for cropping, etc.
    
    %fprintf('Found %d subject folder(s).\n', numel(seq_dirs));
    
    if ~exist(func_dir)
        mkdir(func_dir);
    end

    if isempty(seq_dirs)
        warning('Folder "dicom" in subject %s is empty.', subject_name);
    end

    for i = 1:numel(seq_dirs)
        % i=4

        nifti_dir = char(tmp_dirs(i));
        if ~exist(nifti_dir, 'file')
            mkdir(nifti_dir);
        end
        
        % Build command (quote paths with spaces)
        cmd = sprintf('"%s" %s -o "%s" "%s"', dcm2niix_exe, dcm2niix_options, ...
                      nifti_dir, char(seq_dirs(i)));
        
        dicom_seq = char(dicom_seqs(i));
        
        fprintf('\n=== Converting %s_sn-%s ===\n', subject_name, dicom_seq);
        fprintf('Command: %s\n', cmd);
        
        [status, result] = system(cmd, '-echo');   % '-echo' shows live output
        
        if status ~= 0
            warning('FAILED (status %d): %s (sn-%s)\nOutput:\n%s', status, subject_name, dicom_seq, result);
        end
        
        % Now rename and move the files:
        new_files = {dir(nifti_dir).name};
        new_files(ismember(new_files, {'.', '..'})) = [];
        
        isJson    = endsWith(new_files, '.json', 'IgnoreCase', true);
        json_file = new_files(isJson);
        json_file = char(json_file(1));
        json_path = fullfile(nifti_dir, json_file);
        json_str  = fileread(json_path);
        json_data = jsondecode(json_str);

        isNiftiGz   = endsWith(new_files, '.nii.gz', 'IgnoreCase', true);
        isNifti     = endsWith(new_files, '.nii', 'IgnoreCase', true);
        nifti_files = new_files(isNiftiGz | isNifti);
        nifti_file  = char(nifti_files(1));
        nifti_path  = fullfile(nifti_dir, nifti_file);
        
        seriesNumber = 'NULL';
        if isfield(json_data, 'SeriesNumber')
            seriesNumber = json_data.SeriesNumber;
            if (class(seriesNumber))
                seriesNumber = num2str(seriesNumber);
            end
        end
        
        % Parallel noise reduction technique (usually some factor, as in Canon,
        % or multiband in Siemens):
        parallelReduction = 'NULL';
        if isfield(json_data, 'ParallelReductionFactorInPlane')
            parallelReduction = json_data.ParallelReductionFactorInPlane;
            if (class(parallelReduction))
                parallelReduction = num2str(parallelReduction);
            end
        end
        
        % Sequence used to identify T1/T2 images:
        scanningSequence = 'NULL';
        if isfield(json_data, 'ScanningSequence')
            scanningSequence = json_data.ScanningSequence;
        end
        
        %% Read protocol:
        if ~isfield(json_data, 'ProtocolName')
            error('There is no protocol name in:\n%s\n%s', json_path, json_str);
        end
        
        protocol_name = json_data.ProtocolName;
        % hopefully, differences between protocol names will not be due to
        % periods! MATLAB does not allow any characters in structs.
        protocol_name_mat = regexprep(protocol_name, '[^a-zA-Z0-9_]', '_');  % replace(protocol_name, '.', '_');
        if ~isfield(protocol2fn, protocol_name_mat)
            error('Protocol name "%s" does not exist in pre-defined protocol2fn object\n(subject %s at series number: %s).', ...
                  protocol_name, subject_name, dicom_seq);
        end
        
        info = protocol2fn.(protocol_name_mat);
        
        %% Distinguish between functional and anatomical files
        
        if ~isfield(info, 'name')
            info.name = 'NULL';
        end
        if ~strcmp(info.name, '')
            info.name = ['_' info.name];
        end
        
        if ~isfield(info, 'type')
            info.type = 'bold';
        end
        
        if ~isfield(info, 'folder')
            info.folder = 'func';
        end
        
        if ~isfolder(fullfile(subject_dir, info.folder))
            mkdir(fullfile(subject_dir, info.folder));
        end

        new_filename = sprintf('%s%s_sn-%s_%s', subject_name, info.name, seriesNumber, info.type);
        
        %% Now move file into /func directory and rename it:
        copyfile(json_path, fullfile(subject_dir, info.folder, [new_filename '.json']));
        copied_path = fullfile(subject_dir, info.folder, [new_filename '.nii.gz']);
        copyfile(nifti_path, copied_path);
        gunzip(copied_path); % unzip in copied path
        delete(copied_path);
    end
    
end

fprintf('\nAll done.\n');
