clear; clc;

%% User-defined variables

% add SPM25 and data to path
spmDir = 'C:\Users\Roman\Documents\MATLAB\toolbox\spm';
%data_dir = 'C:\Users\Roman\Documents\MATLAB\projects\udce-fmri\tasks\data';
data_dir = 'D:\bids-numword';
skipProcessWhen = '^s2_w_r_'; % if this file exists, skip the preprocessing for this task
exclude_subj  = {'sub-000'};

tasks  = {'nct2', 'nct2', 'nct1', 'phono', 'syntax', 'morpho', 'lexi'};
pattern = {'_run-1_', '_run-2_', '', '', '', '', ''};

% Important variables:
%TR            = 2.0;              % Repetition Time (s)
nOmit          = 3;                % omit first "nOmit" volumes in the raw functional file
smoothFact     = 2;                % Smoothing kernel (mm)
targetVoxelBox = [3.0 3.0 3.0];    % size of the voxel (mm)


%% Start the preprocessing

% printing deliminator:
printDelim = '========================================================================';

% fire up SPM
addpath(genpath(spmDir));
spm('defaults','fmri');
spm_jobman('initcfg');

% List of subjects:
data_subdirs = subdirs(data_dir);
subjects = data_subdirs(startsWith(data_subdirs, 'sub-'));
%subjects  = {'sub-007'};
subjects = setdiff(subjects, exclude_subj);


for s = 1:numel(subjects) % loop over all participants
    % s = 1; t = 1;
    subject_name = char(subjects(s));
    fprintf('\n\n%s\nStarted pre-processing data for %s\n%s\n\n', ...
            printDelim, subject_name, printDelim);
    subjectDir = fullfile(data_dir, subject_name);
    if ~isfolder(subjectDir)
        warning('\nSubject folder not found: %s\n', subjectDir);
        continue;
    end

    if ~isfolder(fullfile(subjectDir, 'func'))
        warning('\nNo subdirectory for functional data (/func) found in %s folder: %s\n', subject_name, subjectDir);
        continue;
    end
    
    for t = 1:numel(tasks) % loop over all tasks
        
        task_name  = char(tasks(t));
        fn_pattern = char(pattern(t));
        
        % Try to select potentially previously processed files:
        fileselector = {skipProcessWhen, [subject_name '_'], ['_task-' task_name], fn_pattern, '_bold.nii'};
        bidsSelected = bids_select(data_dir, [subject_name '/func/'], fileselector);
        if ~isempty(bidsSelected)
            fprintf('\nSkipped task-%s in subject %s: Already pre-processed.\n', task_name, subject_name);
            continue;
        end
        
        fprintf('\nStarted pre-processing task-%s in subject %s.\n', task_name, subject_name);
        
        % functional file
        fileselector = {['^' subject_name '_'], ['_task-' task_name], fn_pattern, '_bold.nii'};
        bidsSelected = bids_select(data_dir, [subject_name '/func/'], fileselector);
        if isempty(bidsSelected)
            warning('\nSkipped task-%s in subject %s: No functional file found.\n', task_name, subject_name);
            continue;
        end
        [funcDir, funcFilename, funcFormat] = fileparts(char(bidsSelected(1)));
        funcFilename = [funcFilename funcFormat];
        
        % anatomical file:
        % Careful: for sub-005, pick the most recent anatomical file!!!
        % We want to earlier series number?
        fileselector = {['^' subject_name '_'], '_T1w.nii'};
        bidsSelected = bids_select(data_dir, [subject_name '/anat/'], fileselector);
        [anatDir, anatFilename, anatFormat] = fileparts(char(bidsSelected(1)));
        anatFilename = [anatFilename anatFormat];
        
        funcFile = fullfile(funcDir, funcFilename);
        anatFile = fullfile(subjectDir, 'anat', anatFilename); % ['sub-' subject '_T1w.nii']
        
        funcVols = spm_vol(funcFile);
        nVolumes = size(funcVols, 1);
        nDim = funcVols.dim;
        fprintf('Raw NIfTI dimentions: [%d×%d×%d] with %d volumes.\n', nDim, nVolumes);
        sliceOrder     = 1:nDim(3);        % Ascending: 1 to  number of slices
        refSlice       = floor(nDim(3)/2); % Middle slice (for STC): here 16
        
        %% Read JSON description file:
        % filename in JSON extension (same name as NIfTI file but ending with ".json"):
        jsonFile    = regexprep(funcFile,'\.nii(\.gz)?$','.json');
        jsonData    = jsondecode(fileread(jsonFile)); % parse JSON from string 
        sliceHeight = jsonData.SliceThickness;
        sliceGap    = jsonData.SpacingBetweenSlices - sliceHeight;
        
        % 32 slices, 64*72
        
        % Create output directory (func) if it does not exist:
        if ~isfolder(funcDir)
            mkdir(funcDir);
        end
        
        %% Cut out first volumes:
        
        % build list of volumes like 'file.nii,4', 'file.nii,5' and so on
        volFiles = strcat(funcFile, ',', strsplit(num2str(((nOmit+1):nVolumes)),' '));
        
        % create filenames with NIfTI volumes:
        cutOutfile = fullfile(funcDir,['v_' funcFilename]);
        
        % merge into one 4D file; (0,0): no scaling, no reorientation:
        fprintf('Cutting functional volumes ...\n');
        spm_file_merge(volFiles, cutOutfile, 0, 0); 
        
        fprintf('Saved cut file:\n%s\n', cutOutfile);
        
        funcVols = spm_vol(cutOutfile);
        nVolumes = size(funcVols, 1);
        nDim = funcVols.dim;
        fprintf('NIfTI dimentions in cut file: [%d×%d×%d] with %d volumes.\n', nDim, nVolumes);
        
        % check if previous error prevents further processing:
        continue_processing = true;
        
        
        %% Realignment (Motion Correction):
        
        fprintf('\nRealignment...\n');
        
        vFunc = spm_select('FPList', funcDir, ['^v_.*' spm_file(funcFile,'basename') '.*\.nii$']);
        batch.spatial.realign.estwrite.data = {{cutOutfile}};
        
        batch.spatial.realign.estwrite.eoptions.quality = 0.95;
        batch.spatial.realign.estwrite.eoptions.sep     = 1.5;
        batch.spatial.realign.estwrite.eoptions.fwhm    = 1;
        batch.spatial.realign.estwrite.eoptions.rtm     = 1;  % realign + reslice
        batch.spatial.realign.estwrite.eoptions.interp  = 2;
        batch.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
        batch.spatial.realign.estwrite.eoptions.weight  = '';
        
        batch.spatial.realign.estwrite.roptions.which   = [2 1];  % mean + all
        batch.spatial.realign.estwrite.roptions.interp  = 4;
        batch.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
        batch.spatial.realign.estwrite.roptions.mask    = 1;
        batch.spatial.realign.estwrite.roptions.prefix  = 'r_';
        
        continue_processing = execute_spm_jobman(batch, continue_processing);
        clear batch;
        
        % Create a motion plot:
        motion_plot(funcFile);
        
        
        %% Coregistration (T1 → mean functional):
        
        fprintf('Coregistration (T1 → mean func)...\n');
        meanFunc = spm_select('FPList', fileparts(cutOutfile), ['^mean.*' spm_file(funcFile,'basename') '.*\.nii$']);
        
        batch.spatial.coreg.estimate.ref    = {[meanFunc ',1']};
        batch.spatial.coreg.estimate.source = {[anatFile ',1']};
        batch.spatial.coreg.estimate.other  = {''};
        batch.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        batch.spatial.coreg.estimate.eoptions.sep      = [4 2];
        batch.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        batch.spatial.coreg.estimate.eoptions.fwhm     = [7 7];
        batch.spatial.coreg.estimate.roptions.prefix = 'ra_';
        
        continue_processing = execute_spm_jobman(batch, continue_processing);
        clear batch;
        
        
        %% segmentation and anatomical normalization:
        
        fprintf('Segmentation + Normalization...\n');
        
        % before discarding reslicing anatomy:
        % raAnat = spm_select('FPList', anatDir, '^ra_*.*\.nii$');
        
        % increment batch number:
        batch.spatial.preproc.channel.vols  = {[anatFile ',1']}; % !!! before: {[raAnat ',1']}
        batch.spatial.preproc.channel.biasreg = 0.0001;
        batch.spatial.preproc.channel.biasfwhm = 60;
        batch.spatial.preproc.channel.write = [0 0];
        
        batch.spatial.preproc.tissue(1).tpm = {fullfile(spm('dir'),'tpm','TPM.nii,1')};
        batch.spatial.preproc.tissue(1).ngaus = 1;
        batch.spatial.preproc.tissue(1).native = [1 0];
        batch.spatial.preproc.tissue(1).warped = [0 0];
        batch.spatial.preproc.tissue(2).tpm = {fullfile(spm('dir'),'tpm','TPM.nii,2')};
        batch.spatial.preproc.tissue(2).ngaus = 1;
        batch.spatial.preproc.tissue(2).native = [1 0];
        batch.spatial.preproc.tissue(2).warped = [0 0];
        batch.spatial.preproc.tissue(3).tpm = {fullfile(spm('dir'),'tpm','TPM.nii,3')};
        batch.spatial.preproc.tissue(3).ngaus = 2;
        batch.spatial.preproc.tissue(3).native = [1 0];
        batch.spatial.preproc.tissue(3).warped = [0 0];
        batch.spatial.preproc.tissue(4).tpm = {fullfile(spm('dir'),'tpm','TPM.nii,4')};
        batch.spatial.preproc.tissue(4).ngaus = 3;
        batch.spatial.preproc.tissue(4).native = [1 0];
        batch.spatial.preproc.tissue(4).warped = [0 0];
        batch.spatial.preproc.tissue(5).tpm = {fullfile(spm('dir'),'tpm','TPM.nii,5')};
        batch.spatial.preproc.tissue(5).ngaus = 4;
        batch.spatial.preproc.tissue(5).native = [1 0];
        batch.spatial.preproc.tissue(5).warped = [0 0];
        batch.spatial.preproc.tissue(6).tpm = {fullfile(spm('dir'),'tpm','TPM.nii,6')};
        batch.spatial.preproc.tissue(6).ngaus = 2;
        batch.spatial.preproc.tissue(6).native = [0 0];
        batch.spatial.preproc.tissue(6).warped = [0 0];
        batch.spatial.preproc.warp.mrf     = 1;
        batch.spatial.preproc.warp.cleanup = 1;
        batch.spatial.preproc.warp.reg     = [0 0.001 0.5 0.05 0.2];
        batch.spatial.preproc.warp.affreg  = 'mni';
        batch.spatial.preproc.warp.fwhm    = 0;
        batch.spatial.preproc.warp.samp    = 3;
        batch.spatial.preproc.warp.write   = [0 1];
        batch.spatial.preproc.warp.vox     = NaN;
        batch.spatial.preproc.warp.bb      = [NaN NaN NaN
                                              NaN NaN NaN];
        
        continue_processing = execute_spm_jobman(batch, continue_processing);
        clear batch;
        
        
        %% normalize functional (using segmentation):
        
        fprintf('Normalizing functional...\n');
        yraAnat = spm_select('FPList', anatDir, ['^y_.*' spm_file(anatFile,'basename') '.*\.nii$']); % before discarding T1 reslicing: '^y_ra_.*'
        rvFunc  = spm_select('FPList', funcDir, ['^r_v_.*'  spm_file(funcFile,'basename') '.*\.nii$']);
        
        % when running normalise.estwrite: --> [yraAnat ',1']
        % when running normalise.write:    -->  yraAnat
        
        batch.spatial.normalise.write.subj.def        = {yraAnat};
        batch.spatial.normalise.write.subj.resample   = strcat(rvFunc, ',', strsplit(num2str((1:nVolumes)),' '))';
        batch.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
        batch.spatial.normalise.write.woptions.vox    = targetVoxelBox;
        batch.spatial.normalise.write.woptions.interp = 4;
        batch.spatial.normalise.write.woptions.prefix = 'w_';
        
        continue_processing = execute_spm_jobman(batch, continue_processing);
        clear batch;
        
        
        %% smoothing:
        
        fprintf('Smoothing (over %d voxels)...\n', smoothFact);
        % increment batch number:
        wrvFunc  = spm_select('FPList', funcDir, ['^w_r_v_.*' spm_file(funcFile,'basename') '*.*\.nii$']);
        batch.spatial.smooth.data = strcat(wrvFunc, ',', strsplit(num2str((1:nVolumes)),' '))';
        batch.spatial.smooth.fwhm = targetVoxelBox * smoothFact;
        batch.spatial.smooth.dtype = 0;
        batch.spatial.smooth.im = 0;
        batch.spatial.smooth.prefix = ['s' num2str(smoothFact) '_'];
        
        continue_processing = execute_spm_jobman(batch, continue_processing);
        clear batch;

    end % loop over tasks
end % loop over subject directories
