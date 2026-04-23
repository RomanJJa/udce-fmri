clear; clc;

% add SPM25 and data to path
spmDir = 'C:\Users\Roman\Documents\MATLAB\toolbox\spm';
dataDir = 'C:\Users\Roman\Documents\MATLAB\projects\udce-fmri\tasks\data';
addpath(genpath(spmDir));

% initialize SPM
spm('defaults','fmri');
spm_jobman('initcfg');


subject = '001';

subjectDir = fullfile(dataDir, ['sub-' subject]);
if ~isfolder(subjectDir)
    error('Subject folder not found: %s', subjectDir);
end


%% File names

if strcmp(subject, '001')
    %%% 3.0mm, gap: 0.6mm
    % phono:
    %funcFilename = '11000_phono_BOLD_st3.0_gap.6_20251028135022_11000.nii';
    % 2NCT:
    funcFilename = '8000_func_BOLD_st3.0_gap.6_20251028135022_8000.nii';
    
    %%% 3.4mm, gap: 0.6mm
    % phono:
    %funcFilename = '12000_phono_BOLD_st3.4_gap.6_20251028135022_12000.nii';
    % 2NCT:
    %funcFilename = '9000_func_BOLD_st3.4_gap.6_20251028135022_9000.nii';
    
    %%% 3.4mm, gap: 0.0mm
    % phono:
    %funcFilename = '13000_phono_BOLD_st3.4_gap0_20251028135022_13000.nii';
    % 2NCT:
    %funcFilename = '10000_func_BOLD_st3.4_gap0_20251028135022_10000.nii';
    
    %%% Anatomical file:
    anatFilename = '6001_anat-T1w_acq-MPRAGE_20251028135022_6001.nii';

elseif strcmp(subject, '002')
    
    %%% 3mm, gap: 0.6mm
    % 2NCT, block 1:
    funcFilename = '4000-func_BOLD_st3_0_gap_6_func_BOLD_st3.0_gap.6_20251128111225_4000.nii';
    
    %%% 3.4mm, gap: 0.6mm
    % 2NCT, block 2:
    %funcFilename = '5000-func_BOLD_st3_4_gap_6_func_BOLD_st3.4_gap.6_20251128111225_5000.nii';
    % 2NCT, block 3:
    %funcFilename = '10000-func_BOLD_st3_4_gap_6_func_BOLD_st3.4_gap.6_20251128111225_10000.nii';
    % phono:
    %funcFilename = '11000-phono_BOLD_st3_4_gap_6_phono_BOLD_st3.4_gap.6_20251128111225_11000.nii';

    %%% Anatomical file:
    anatFilename = '3001-anat_T1w_acq_MPRAGE_anat-T1w_acq-MPRAGE_20251128111225_3001.nii';
elseif strcmp(subject, '003')
    
    %%% 3mm, gap: 0.6mm
    %funcFilename = '6000_func_BOLD_st3.0_gap.6_20251204144119_6000.nii';
    %funcFilename = '9000_morpho_BOLD_3.0_gap.6_20251204144119_9000.nii';
    %funcFilename = '12000_lexi_BOLD_3.0_gap.6_20251204144119_12000.nii';

    %%% 3.4mm, gap: 0.6mm %% CONTINUE HERE !!!!
    %funcFilename = '5000_func_BOLD_st3.4_gap.6_20251204144119_5000.nii';
    %funcFilename = '7000_func_BOLD_st3.4_gap.6_20251204144119_7000.nii';
    %funcFilename = '8000_phono_BOLD_st3.4_gap.6_20251204144119_8000.nii';
    %funcFilename = '10000_lexi_BOLD_3.4_gap.6_20251204144119_10000.nii';
    funcFilename = '11000_morpho_BOLD_3.4_gap.6_20251204144119_11000.nii';

    %%% Anatomical file:
    anatFilename = '4001_anat-T1w_acq-MPRAGE_20251204144119_4001.nii';
elseif strcmp(subject, '004')
    
    %%% functional file (3.4mm, 0.4mm gap):
    %funcFilename = '4000_BOLD_NCT_2d_st3.4_gap.6_20251216152646_4000.nii';
    %funcFilename = '5000_BOLD_NCT_2d_st3.4_gap.6_20251216152646_5000.nii';
    %funcFilename = '6000_BOLD_NCT_2d_st3.4_gap.6_20251216152646_6000.nii';
    %funcFilename = '7000_bold_NCT_1d_st3.4_gap.6_20251216152646_7000.nii';
    %funcFilename = '8000_morpho_BOLD_st3.4_gap.6_20251216152646_8000.nii';
    %funcFilename = '9000_phono_BOLD_st3.4_gap.6_20251216152646_9000.nii';
    %funcFilename = '10000_synt_BOLD_st3.4_gap.6_20251216152646_10000.nii';
    %funcFilename = '11000_lexi_BOLD_st3.4_gap.6_20251216152646_11000.nii';
    funcFilename = '12000_morpho_BOLD_st3.0_gap.6_20251216152646_12000.nii';
    
    %%% Anatomical file:
    anatFilename = '3001_anat-T1w_acq-MPRAGE_20251216152646_3001.nii';
else
    fprintf('No subject data available.');
end


% 4D functional:
funcDir  = fullfile(subjectDir, 'func');
funcFile = fullfile(funcDir, funcFilename); % 'sub-' subject 

% 3D anatomical:
anatDir  = fullfile(subjectDir, 'anat');
anatFile = fullfile(subjectDir, 'anat', anatFilename); % ['sub-' subject '_T1w.nii']

outputDir  = funcDir;

funcVols = spm_vol(funcFile);
nVolumes = size(funcVols, 1);
nDim = funcVols.dim;
fprintf('Raw NIfTI dimentions: [%d×%d×%d] with %d volumes.\n', nDim, nVolumes);

nOmit          = 3;                % omit first "nOmit" volumes in the raw functional file
TR             = 2.0;              % Repetition Time (s)
sliceOrder     = 1:nDim(3);        % Ascending: 1 to  number of slices
refSlice       = floor(nDim(3)/2); % Middle slice (for STC): here 16
smoothFact     = 2;                % Smoothing kernel (mm)
targetVoxelBox = [3.0 3.0 3.0];    % size of the voxel (mm)

%% Read JSON description file:
% filename in JSON extension (same name as NIfTI file but ending with ".json"):
jsonFile = regexprep(funcFile,'\.nii(\.gz)?$','.json');
jsonData = jsondecode(fileread(jsonFile)); % parse JSON from string 
sliceHeight = jsonData.SliceThickness;
sliceGap = jsonData.SpacingBetweenSlices - sliceHeight;

% 32 slices, 64*72

% Create output directory if it does not exist:
if ~isfolder(outputDir)
    mkdir(outputDir);
end


%% Cut out first volumes:

% build list of volumes like 'file.nii,4', 'file.nii,5' and so on
volFiles = strcat(funcFile, ',', strsplit(num2str(((nOmit+1):nVolumes)),' '));

% create filenames with NIfTI volumes:
cutOutfile = fullfile(outputDir,['v_' funcFilename]);

% merge into one 4D file; (0,0): no scaling, no reorientation:
fprintf('Cutting functional volumes ...\n');
spm_file_merge(volFiles, cutOutfile, 0, 0); 

fprintf('Saved cut file:\n%s\n', cutOutfile);

funcVols = spm_vol(cutOutfile);
nVolumes = size(funcVols, 1);
nDim = funcVols.dim;
fprintf('NIfTI dimentions in cut file: [%d×%d×%d] with %d volumes.\n', nDim, nVolumes);



%% initialize batchnumber
bn = 0;
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
motionPlot(funcFile);


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


%% Functions:

% Create a motion plot:
% @argument funcFile: the path and filename towards the raw functional NIfTI
function motionPlot(funcFile)
    rp_file = spm_select('FPList', fileparts(funcFile), ['^rp_.*' spm_file(funcFile,'basename') '.*\.txt$']);
    if ~isempty(rp_file)
        rp = load(rp_file);
        figure; 
        subplot(2,1,1); plot(rp(:,1:3)); title('Translation (mm)'); legend('x','y','z');
        subplot(2,1,2); plot(rp(:,4:6)*180/pi); title('Rotation (deg)'); legend('pitch','roll','yaw');
        saveas(gcf, fullfile(spm_file(funcFile,'path'), 'motion_plot.png'));
        fprintf('Motion plot generated and saved.\n');
    else
        warning('Motion TXT file not found:\n%s\n', rp_file);
    end
end
