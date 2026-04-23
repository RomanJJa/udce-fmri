
clear; clc;

% add SPM25 and data to path
spmDir  = 'C:\Users\Roman\Documents\MATLAB\toolbox\spm';
dataDir = 'C:\Users\Roman\Documents\MATLAB\projects\udce-fmri\tasks\data';
addpath(genpath(spmDir));

% initialize SPM
spm('defaults','fmri');
spm_jobman('initcfg');

subject = '001';    % subject number (three digits)
nVolOmited = 3;     % number of omitted volumes in the beginning
repetitionTime = 2; % TR in seconds

subjectDir = fullfile(dataDir, ['sub-' subject]);
if ~isfolder(subjectDir)
    error('Subject folder not found: %s', subjectDir);
end

%% Subject 001

%%% 11000: 3.0mm, gap: 0.6mm
% phono:
%funcFilename = '11000_phono_BOLD_st3.0_gap.6_20251028135022_11000.nii';
% 2NCT:
funcFilename = '8000_func_BOLD_st3.0_gap.6_20251028135022_8000.nii';
logFilename  = 'sub-001_task-nct2.2_runTask_events2.log';
behFilename  = 'sub-001_task_nct2.2-test_beh.csv';

%%% 12000: 3.4mm, gap: 0.6mm
% phono:
%funcFilename = '12000_phono_BOLD_st3.4_gap.6_20251028135022_12000.nii';
% 2NCT:
%funcFilename = '9000_func_BOLD_st3.4_gap.6_20251028135022_9000.nii';
%logFilename  = 'sub-001_task-nct2.3_runTask_events3.log';
%behFilename  = 'sub-001_task_nct2.3-test_beh.csv';

%%% 13000: 3.4mm, gap: 0.0mm
% phono:
%funcFilename = '13000_phono_BOLD_st3.4_gap0_20251028135022_13000.nii';
% 2NCT:
%funcFilename = '10000_func_BOLD_st3.4_gap0_20251028135022_10000.nii';
%logFilename  = 'sub-001_task-nct2.1_runTask_events4.log';
%behFilename  = 'sub-001_task_nct2.1-test_beh.csv';

%% subject 002

%%% 4000: 3.0mm, gap: 0.6mm
%funcFilename = '4000-func_BOLD_st3_0_gap_6_func_BOLD_st3.0_gap.6_20251128111225_4000.nii';
%logFilename  = 'sub-002_task-nct2.2_runTask_events.log';
%rpFilename   = 'rp_v_4000-func_BOLD_st3_0_gap_6_func_BOLD_st3.0_gap.6_20251128111225_4000.txt';

%%% 5000: nct2.2: 3.4mm, gap: 0.6mm
%funcFilename = '5000-func_BOLD_st3_4_gap_6_func_BOLD_st3.4_gap.6_20251128111225_5000.nii';
%logFilename  = 'sub-002_task-nct2.3_runTask_events.log';
%rpFilename   = 'rp_v_5000-func_BOLD_st3_4_gap_6_func_BOLD_st3.4_gap.6_20251128111225_5000.txt';

%%% 10000: nct2.3: 3.4mm, gap: 0.6mm
%funcFilename = '10000-func_BOLD_st3_4_gap_6_func_BOLD_st3.4_gap.6_20251128111225_10000.nii';
%logFilename  = 'sub-002_task-nct2.1_runTask_events.log';
%behFilename  = 'sub-003_task-nct2.1-test_beh.csv';

%%% 11000: phono: 3.4mm, gap: 0.6mm
%funcFilename = '11000-phono_BOLD_st3_4_gap_6_phono_BOLD_st3.4_gap.6_20251128111225_11000.nii';
%logFilename  = 'sub-002_task-phono_runTask_events.log';
%behFilename  = 'sub-002_task-phono-test_beh.csv';

%% subject 003

%funcFilename = '5000_func_BOLD_st3.4_gap.6_20251204144119_5000.nii';
%logFilename  = 'sub-003_task-nct2.1_runTask_events.log';
%behFilename  = 'sub-003_task-nct2.1-test_beh.csv';

%funcFilename = '6000_func_BOLD_st3.0_gap.6_20251204144119_6000.nii';
%logFilename  = 'sub-003_task-nct2.2_runTask_events.log';
%behFilename  = 'sub-003_task-nct2.2-test_beh.csv';

%funcFilename = '7000_func_BOLD_st3.4_gap.6_20251204144119_7000.nii';
%logFilename  = 'sub-003_task-nct2.3_runTask_events.log';
%behFilename  = 'sub-003_task-nct2.3-test_beh.csv';

%funcFilename = '8000_phono_BOLD_st3.4_gap.6_20251204144119_8000.nii';
%logFilename  = 'sub-003_task-phono_runTask_events.log';
%behFilename  = 'sub-003_task-phono-test_beh.csv';


%% subject 004: 3.4mm, gap: 0.6mm

%%% 4000: nct2
%funcFilename = '4000_BOLD_NCT_2d_st3.4_gap.6_20251216152646_4000.nii';
%logFilename  = 'sub-004_task-nct2_ses-1_run-1_events.log';
%behFilename  = 'sub-004_task-nct2-test_ses-1_run-1_beh.csv';

%%% 5000: nct2
%funcFilename = '5000_BOLD_NCT_2d_st3.4_gap.6_20251216152646_5000.nii';
%logFilename  = 'sub-004_task-nct2_ses-2_run-2_events.log';
%behFilename  = 'sub-004_task-nct2-test_ses-2_run-2_beh.csv';

%%% 6000: nct2
%funcFilename = '6000_BOLD_NCT_2d_st3.4_gap.6_20251216152646_6000.nii';
%logFilename  = 'sub-004_task-nct2_ses-3_run-3_events.log';
%behFilename  = 'sub-004_task-nct2-test_ses-3_run-3_beh.csv';

%%% 7000: nct1
%funcFilename = '7000_bold_NCT_1d_st3.4_gap.6_20251216152646_7000.nii';
%logFilename  = 'sub-004_task-nct1_run-1_events.log';
%behFilename  = 'sub-004_task-nct1-test_run-1_beh.csv';

%%% 8000: morpho
%funcFilename = '8000_morpho_BOLD_st3.4_gap.6_20251216152646_8000.nii';
%logFilename  = 'sub-004_task-morpho_run-1_events.log';
%behFilename  = 'sub-004_task-morpho-test_run-1_beh.csv';

%%% 9000: phono
%funcFilename = '9000_phono_BOLD_st3.4_gap.6_20251216152646_9000.nii';
%logFilename  = 'sub-004_task-phono_run-1_events.log';
%behFilename  = 'sub-004_task-phono-test_run-1_beh.csv';

%%% 10000: synt
%funcFilename = '10000_synt_BOLD_st3.4_gap.6_20251216152646_10000.nii';
%logFilename  = 'sub-004_task-syntax_run-1_events.log';
%behFilename  = 'sub-004_task-syntax-test_run-1_beh.csv';

%%% 11000: lexi
%funcFilename = '11000_lexi_BOLD_st3.4_gap.6_20251216152646_11000.nii';
%logFilename  = 'sub-004_task-lexi_run-1_events.log';
%behFilename  = 'sub-004_task-lexi-test_run-1_beh.csv';

%%% 12000: morpho
%funcFilename = '12000_morpho_BOLD_st3.0_gap.6_20251216152646_12000.nii';
%logFilename  = 'sub-004_task-morpho_run-2_events.log';
%behFilename  = 'sub-004_task-morpho-test_run-2_beh.csv';

% Derive filename for the RP file:
[~,baseFuncFile,~] = fileparts(funcFilename);
rpFilename = ['rp_v_' baseFuncFile '.txt'];
clear baseFuncFile;

%% If NCT2: merge the three different blocks
% If the task is the two-digit number magnitude comparison task (nct2),
% then merge the different blocks ...

% set task:
bidsTask = regexp(logFilename, 'task-([a-zA-Z0-9\.]+)_', 'tokens', 'once');
task = split(bidsTask, '.');
block = 0;
if size(task) > 1
    block = str2double(task{2,1});
end
task = task{1,1};

fprintf('Task: %s   Block/run: %d\n', task, block);

% BIDS run:
bidsRun  = regexp(logFilename, '_run-([0-9]+)_', 'tokens', 'once');
if isempty(bidsRun)
    bidsRun = {'0'};
end
bidsRun = bidsRun{1,1};


%% Setting file locations:

% functional preprocessed file:
funcFilename = ['s2_w_r_v_' funcFilename];

funcDir  = fullfile(subjectDir, 'func');
funcFile = fullfile(funcDir, funcFilename);
rpFile   = fullfile(funcDir, rpFilename);

behDir  = fullfile(subjectDir, 'beh');
logFile = fullfile(behDir, logFilename);
behFile = fullfile(behDir, behFilename);

if (~isfile(funcFile))
    error('The preprocessed BOLD NIfTI does not exist:\n%s\n', funcFile);
end
if (~isfile(logFile))
    error('The log file does not exist:\n%s\n', logFile);
end
if (~isfile(behFile))
    error('The CSV file does not exist:\n%s\n', behFile);
end

% Create directory for the model if it doesn't exist:
modelDir = fullfile(funcDir, sprintf('task-%s_run-%s_model-spm', ...
                                     char(bidsTask), bidsRun));
if ~isfolder(modelDir)
    mkdir(modelDir);
end

%% Load the log file (tab-separated) as a table:
T    = readtable(logFile, 'FileType','text', 'Delimiter','\t');
Tbeh = readtable(behFile, 'FileType','text', 'Delimiter',',');

%% Find the exact time of the first scanner trigger
idx_scanner_start = find(strcmp(T.action, 'sequence-start'), 1, 'first');
if isempty(idx_scanner_start)
    error('No "sequence-start" found! Check the log file for "sequence-start".');
end

t0 = T.timestamp(idx_scanner_start);   % this is the time of the first volume!
fprintf('Scanner started at Unix time %.4f --> this will be t=0 for SPM\n', t0);

% Shift all timestamps so that first volume = 0
% Also correct for omitted volumes:
T.onset = T.timestamp - t0 - (nVolOmited * repetitionTime);

% Keep only rows AFTER the scanner started (phase == 'test')
Tscan = T(T.onset >= 0 & strcmp(T.phase,'test'), :);

%% Define the predictors
% You probably want at least these:
%   - "large_top"      → top number bigger  (press near head → right hand)
%   - "large_bottom"   → bottom number bigger (press far → left hand)
%   - "null_event"     → ## vs ##
%   - Optionally: fixation, blank, stimulus_any, response, etc.

% From your log, the condition is coded as cond=sm60_b10w_b20w etc.
% Let's extract the real experimental condition from the "specifics" column
condTokens  = regexp(Tscan.specifics, 'cond=([^ ]+)',  'tokens');
stim1Tokens = regexp(Tscan.specifics, ': "([^ ]+)" vs. ', 'tokens');
stim2Tokens = regexp(Tscan.specifics, '" vs. "([^ ]+)" of cond=', 'tokens');
matched  = strings(height(Tscan),  1);
Tscan.stim1 = strings(height(Tscan), 1);
Tscan.stim2 = strings(height(Tscan), 1);
Tscan.isStim = zeros(height(Tscan), 1);
Tscan.isFixcross = zeros(height(Tscan), 1);
for i = 1:height(Tscan)
    
    %%%%%% Also deal with responses here!!!
    if ~isempty(condTokens{i})
        matched(i) = condTokens{i}{1}{1};
        Tscan.stim1(i) = stim1Tokens{i}{1}{1};
        Tscan.stim2(i) = stim2Tokens{i}{1}{1};
        Tscan.isStim(i) = 1;
    else
        matched(i) = 'none';
        Tscan.stim1(i) = '';
        Tscan.stim2(i) = '';
        Tscan.isFixcross(i) = strcmp(Tscan.action(i), 'fixation');
    end
end
Tscan.condition = matched;

b0 = zeros(max(size(matched)), 1);

% If we are dealing with the nct2:
if (strcmp(task, 'nct2'))
    Tscan.numCond = strings(height(Tscan),  1);
    Tscan.num1 = b0;
    Tscan.num2 = b0;
    Tscan.gr60 = b0;
    Tscan.b10incomp = b0;
    Tscan.b20incomp = b0;
    Tscan.b10within = b0;
    Tscan.b20within = b0;
    Tscan.decDist   = b0;
    Tscan.unitDist  = b0;
    Tscan.totalDist = b0;
    Tscan.nullEvent = b0;
    Tscan.respStim1 = b0;
    % stimulus offset???
    for i = 1:max(size(matched))
        if matched(i) == "none"
            continue;
        end
        Tscan.nullEvent(i) = contains(Tscan.stim1(i), "##") && ...
                             contains(Tscan.stim2(i), '##');
        Tscan.gr60(i)      = contains(matched(i), "gr60");
        Tscan.b10incomp(i) = contains(matched(i), "_b10i");
        Tscan.b10within(i) = contains(matched(i), "_b10w");

        if (Tscan.gr60(i))
            Tscan.b20incomp(i) = contains(matched(i), "_b20i");
            Tscan.b20within(i) = contains(matched(i), "_b20w");
        else
            % matched condition for base-20 effect does not mean that there
            % are base-20 effects for numbers smaller than 60
            splitMatched = split(matched(i), '_'); % {'sm60','b10w','b20w'}
            Tscan.condition(i) = join(splitMatched(1:2), '_');
        end
        
        num1 = str2double(regexp(Tscan.stim1(i), '\d+', 'match', 'once'));
        num2 = str2double(regexp(Tscan.stim2(i), '\d+', 'match', 'once'));
        Tscan.num1(i) = num1;
        Tscan.num2(i) = num2;
        Tscan.respStim1(i) = num1 > num2;
        Tscan.decDist(i)   = abs((num1 - mod(num1, 10)) - (num2 - mod(num2, 10)))/10;
        Tscan.unitDist(i)  = abs(mod(num1, 10) - mod(num2, 10));
        Tscan.totalDist(i) = abs(num1 - num2);
        
        if Tscan.b10incomp(i)
            Tscan.numCond(i) = 'incomp';
        elseif Tscan.b10within(i)
            Tscan.numCond(i) = 'within';
        elseif Tscan.nullEvent(i)
            Tscan.numCond(i) = 'null';
        else
            Tscan.numCond(i) = 'comp';
        end
    end
elseif strcmp(task, 'nct1')
    Tscan.num1 = b0;
    Tscan.num2 = b0;
    for i = 1:max(size(matched))
        if matched(i) == "none"
            continue;
        elseif matched(i) == "dist_1" || matched(i) == "dist_2"
            matched(i) = "dist_12";
        elseif matched(i) == "dist_3" || matched(i) == "dist_4"
            matched(i) = "dist_34";
        elseif matched(i) == "dist_5" || matched(i) == "dist_6"
            matched(i) = "dist_56";
        elseif matched(i) == "dist_7" || matched(i) == "dist_8"
            matched(i) = "dist_78";
        end
    end
    Tscan.condition = matched;
elseif strcmp(task, 'lexi')
    It = 1;
    for i = 1:max(size(matched))
        if matched(i) == "none"
            continue;
        end

        if Tbeh.Error_position_syllable(It)==0
            matched(i) = "word_true";
        elseif Tbeh.Error_position_syllable(It)==1
            matched(i) = "prefix_false";
        elseif Tbeh.Error_position_syllable(It)==2
            matched(i) = "suffix_false";
        end
        It = It + 1;
    end
    Tscan.condition = matched;
elseif strcmp(task, 'morpho')
    It = 1;
    for i = 1:max(size(matched))
        if matched(i) == "none"
            continue;
        end
        
        if     strcmp(char(Tbeh.condition(It)), 'prefix') && Tbeh.correct(It)==1
            matched(i) = "prefix_true";
        elseif strcmp(char(Tbeh.condition(It)), 'suffix') && Tbeh.correct(It)==1
            matched(i) = "suffix_true";
        elseif strcmp(char(Tbeh.condition(It)), 'prefix') && Tbeh.correct(It)==0
            matched(i) = "prefix_false";
        elseif strcmp(char(Tbeh.condition(It)), 'suffix') && Tbeh.correct(It)==0
            matched(i) = "suffix_false";
        end
        It = It + 1;
    end
    Tscan.condition = matched;
elseif strcmp(task, 'syntax')
    It = 1;
    for i = 1:max(size(matched))
        if matched(i) == "none"
            continue;
        end
        
        if     Tbeh.inflection_type_word_2(It)==1 && Tbeh.correct(It)==1
            matched(i) = "conj_true";
        elseif Tbeh.inflection_type_word_2(It)==2 && Tbeh.correct(It)==1
            matched(i) = "decl_true";
        elseif Tbeh.inflection_type_word_2(It)==1 && Tbeh.correct(It)==0
            matched(i) = "conj_false";
        elseif Tbeh.inflection_type_word_2(It)==2 && Tbeh.correct(It)==0
            matched(i) = "decl_false";
        end
        It = It + 1;
    end
    Tscan.condition = matched;
end


%% Define the experimental conditions:
if strcmp(task, 'nct2')
    MainConditions = {'within','comp','incomp'};   % 'null', order of regressors
%elseif strcmp(task, 'nct1')
    
else
    MainConditions = unique(Tscan.condition);
    MainConditions = MainConditions(~strcmp(MainConditions(:,1), 'none'));
    MainConditions = cellstr(MainConditions(:,1)');
end
% Object with contrasts?


% Prepare a structure that collects onsets
onsets = struct();
for c = 1:numel(MainConditions)
    thisCond = MainConditions{c};
    if strcmp(task, 'nct2')
        idx = strcmp(Tscan.numCond, thisCond);
    else
        idx = strcmp(Tscan.condition, thisCond);
    end
    onsets.(thisCond) = Tscan.onset(idx);
end

tscanFile = ['SPM_onsets_' bidsTask{1}];
save([tscanFile '.mat'], 'onsets','Tscan');
writetable(Tscan,[tscanFile '.txt'],'Delimiter','\t')  

funcVols = spm_vol(funcFile);
nVolumes = size(funcVols, 1);


%% Define model path:


%% Build SPM Matlabbatch

matlabbatch = {};

%% Design specification:
matlabbatch{1}.spm.stats.fmri_spec.dir = {modelDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = repetitionTime; % <-- change to your TR
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = strcat(funcFile, ',', ...
                                                       strsplit(num2str((1:nVolumes)),' '))';

% Add conditions
cindex = 1;
for c = 1:numel(MainConditions)
    cname = MainConditions{c};
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cindex).name = cname;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cindex).onset = onsets.(cname);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cindex).duration = zeros(height(onsets.(MainConditions{c})), 1);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cindex).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cindex).pmod = struct([]);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cindex).orth = 1;
    cindex = cindex + 1;
end


% No regressors or movement parameters added here (add if needed)
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';


% Load the motion file
rp = load(rpFile);   % N_volumes × 6 (or 12 or 24)

% Optional: add Volterra expansion (24 regressors: 6 + 6 derivatives + 6 squared + 6 squared-derivatives)
rp24 = spm_detrend(rp);               % remove linear trends (recommended)
rp24 = [rp24, zeros(size(rp24,1),6)]; % placeholder for derivatives
rp24(2:end,7:12) = diff(rp24(:,1:6)); % first differences
rp24(:,13:18) = rp24(:,1:6).^2;       % squared
rp24(:,19:24) = rp24(:,7:12).^2;      % squared derivatives

% Insert as separate motion regressors
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = {};
for i = 1:size(rp24,2)
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress(end+1).name = sprintf('motion_r%d', i);
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress(end).val   = rp24(:,i);
end


%% Estimate the model
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(modelDir, 'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


%% Contrasts
contrasts = create_contrasts(MainConditions);
matlabbatch{3}.spm.stats.con.spmmat = {fullfile(modelDir, 'SPM.mat')};
matlabbatch{3}.spm.stats.con.delete = 0;
matlabbatch{3}.spm.stats.con.consess = contrasts;

spm_jobman('run', matlabbatch);


%% Generate Tables

load(fullfile(modelDir, 'SPM.mat'));

for i=1:max(size(contrasts)) % i=3;
    
    xSPM = SPM;
    xSPM.swd       = SPM.swd;
    xSPM.u         = 0.001;    % voxel threshold
    xSPM.thresDesc = 'none';   % 'FWE', 'FDR', or 'none'
    xSPM.k         = 10;       % cluster extent: at least 10 sig. voxels per cluster
    xSPM.Ic        = i;        % contrast index: loop through 1:nContrasts
    xSPM.Im        = 'none';   % Apply masking? --> spm_getSPM.m
    [SPM, xSPM] = spm_getSPM(xSPM);
    if ~isfield(xSPM,'Z') || ~isfield(xSPM,'XYZ') || ~isfield(xSPM,'STAT') % should be true
        error('When printing results, spm_getSPM.m did not output parameters Z, XYZ, or STAT.');
    end
    
    % contrasts{1}.tcon; % for reading from the contrasts
    
    xSPM.Ic = i;        % set contrast based on previous contrasts
    
    TabDat = spm_list('Table', xSPM);
    
    filespec = contrasts{i}.tcon.name;
    filespec = replace(filespec, '<', 'sm');
    filespec = replace(filespec, '>', 'gr');
    filespec = replace(filespec, '!=', 'neq');
    filespec = replace(filespec, '~=', 'neq');
    filespec = replace(filespec, '~', 'neq');
    filespec = replace(filespec, '=', 'eq');
    
    sig = sprintf('%04d', i);
    fid = fopen(fullfile(modelDir, ['sig_' sig '_' filespec '.csv']), 'w');
    
    % write header
    fprintf(fid, '%s,',  TabDat.hdr{2,1:end-1});
    fprintf(fid, '%s\n', TabDat.hdr{2,end});
    
    % write data
    for h = 1:size(TabDat.dat,1)
        for j = 1:size(TabDat.dat,2)
            val = TabDat.dat{h,j};
            if isnumeric(val)
                fprintf(fid, '%g,', val);
            else
                fprintf(fid, '"%s",', val);
            end
        end
        fprintf(fid, '\n');
    end
    
    fclose(fid);
    clear fid;
    
    % Now the glass brain:
    xSPM.thresDesc = 'none';
    hReg = spm_results_ui('Setup',xSPM);
    %spm_results_ui('Plot', 'Glass brain');
    hFig = gcf;
    set(hFig, 'PaperPositionMode', 'auto');
    print(hFig, fullfile(modelDir, ['glassbrain_' sig '_' filespec '.png']), '-dpng', '-r300');
    
    %%% Problems with the new SPM version SPM25:
    %rendfile = fullfile(spm('Dir'),'rend','render_single_subj.mat');
    %spm_render(xSPM, ['spmT_' sig '.nii'], rendfile);
    %spm_results_ui('Plot','Sections');
    %spm_results_ui('Plot','Orthogonal');
    %spm_results_ui('Plot','Maximum intensity');
end


%{



% ------------------------------------------------------------------
% 4. Build onsets & durations for the main conditions
% ------------------------------------------------------------------
names     = {};
onsets    = {};
durations = {};

% Helper function to add a condition
add_cond = @(name, rows, dur) ...
    deal([names     {name}], ...
         [onsets    {Tscan.onset(rows)}], ...
         [durations {repmat(dur,1,numel(Tscan.onset(rows)))}]);

% 4a – Main experimental conditions (stimulus onset → response or max 2 s)
stim_rows = strcmp(Tscan.action,'stimulus');
cond_list = unique(Tscan.condition(stim_rows));

for c = 1:numel(cond_list)
    this_cond = cond_list{c};
    if strcmp(this_cond,'null_event') || strcmp(this_cond,'other')
        continue;   % treat separately
    end
    rows = stim_rows & strcmp(Tscan.condition, this_cond);
    % Duration = time from stimulus onset until response OR until next event
    % (here we take until response if exists, otherwise 2 s)
    dur_vec = zeros(sum(rows),1);
    onset_times = Tscan.onset(rows);
    for k = 1:numel(onset_times)
        t_stim = onset_times(k);
        % find next response for this trial (same trial number if you have it,
        % or simply the next "response" after this stimulus)
        next_resp = find(strcmp(Tscan.action,'response') & Tscan.onset > t_stim, 1);
        if ~isempty(next_resp)
            dur_vec(k) = Tscan.onset(next_resp) - t_stim;
        else
            dur_vec(k) = 2;   % fallback
        end
    end
    names{end+1}     = this_cond;
    onsets{end+1}    = onset_times;
    durations{end+1} = dur_vec';
end

% 4b – Null events (## vs ##)
null_rows = stim_rows & strcmp(Tscan.condition,'null_event');
names{end+1}     = 'null_event';
onsets{end+1}    = Tscan.onset(null_rows);
durations{end+1} = 2*ones(1,sum(null_rows));   % they last 2 s (no response expected)

% 4c – (Optional) Every single screen change as Tscan.b10within(i) = contains(matched(i), "_b10w");-events (very robust modelling)
% This is what you asked for: "represent each change on the screen"
micro_names = unique(Tscan.action);
for i = 1:numel(micro_names)
    act = micro_names{i};
    rows = strcmp(Tscan.action, act);
    if strcmp(act,'stimulus') || strcmp(act,'fixation') || strcmp(act,'blank') || contains(act,'pause')
        names{end+1}     = ['micro_' act];
        onsets{end+1}    = Tscan.onset(rows);
        durations{end+1} = zeros(1,sum(rows));   % delta functions (or put real duration if you want)
    end
end

% ------------------------------------------------------------------
% 5. Remove empty cells (if any condition had zero trials)
% ------------------------------------------------------------------
keep = ~cellfun(@isempty, onsets);
names     = names(keep);
onsets    = onsets(keep);
durations = durations(keep);

% ------------------------------------------------------------------
% 6. Save as .mat for SPM
% ------------------------------------------------------------------

fprintf('Done! You now have "%s".', [tscanFile '.mat']);
fprintf('Content:\n\n');
for i = 1:numel(names)
    fprintf('  %d. %s : %d events\n', i, names{i}, numel(onsets{i}));
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First-level analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Column that contains condition/trial type (string or categorical)
condition_col = 'condition'; 

% optional parametric modulators (numeric columns)
% will be added in this order to every condition
pmod_cols = {'decDist', 'unitDist'};   % empty {} if none

% nuisance regressors (0/1 or continuous)
% These will be added as separate regressors (not modulators)
nuisance_cols = {'isFixcross'};      % empty {} if none

% Onset column (in seconds)
onset_col     = 'onset';

% Duration column – if missing, we will create zeros
duration_col  = ''; 

% Create duration column if missing
if isempty(duration_col) || ~ismember(duration_col, Tscan.Properties.VariableNames)
    Tscan.duration = zeros(height(Tscan),1);
    duration_col = 'duration';
end

% Unique condition names
conditions = unique(Tscan.(condition_col));
if iscell(conditions)
    conditions = string(conditions);
end


funcVols = spm_vol(funcFile);
nVolumes = size(funcVols, 1);


%% Build the matlabbatch
matlabbatch{1}.spm.stats.fmri_spec.dir            = {funcDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units   = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT      = repetitionTime;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t  = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.scans     = strcat(funcFile, ',', ...
                                                           strsplit(num2str((1:nVolumes)),' '))';
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf       = 128;

% --------------------------------------------------------------------
% Conditions
% --------------------------------------------------------------------
for cond = 1:numel(conditions)
    cond_name = conditions(cond);
    idx = strcmp(string(Tscan.(condition_col)), cond_name);
    
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cond).name     = char(cond_name);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cond).onset    = Tscan.(onset_col)(idx);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cond).duration = Tscan.(duration_col)(idx);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cond).tmod     = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cond).orth     = 1;
    
    % Parametric modulators (in the order you listed)
    if ~isempty(pmod_cols)
        valid_pmods = intersect(pmod_cols, Tscan.Properties.VariableNames);
        for p = 1:numel(valid_pmods)
            col = valid_pmods{p};
            values = Tscan.(col)(idx);
            % Only add if not all zero/missing
            if any(values(~isnan(values)))
                matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cond).pmod(p).name  = col;
                matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cond).pmod(p).param = values;
                matlabbatch{1}.spm.stats.fmri_spec.sess.cond(cond).pmod(p).poly  = 1;
            end
        end
    end
end

% --------------------------------------------------------------------
% Nuisance / additional regressors
% --------------------------------------------------------------------
if ~isempty(nuisance_cols)
    valid_nuis = intersect(nuisance_cols, Tscan.Properties.VariableNames);
    for r = 1:numel(valid_nuis)
        col = valid_nuis{r};
        vec = Tscan.(col);
        if any(vec(~isnan(vec)))
            matlabbatch{1}.spm.stats.fmri_spec.sess.regress(r).name = col;
            matlabbatch{1}.spm.stats.fmri_spec.sess.regress(r).val  = vec(:);
        end
    end
end

matlabbatch{1}.spm.stats.fmri_spec.sess.multi    = {};
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {};

matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

spm_jobman('interactive', matlabbatch);



%% Model estimation
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(funcDir, 'SPM.mat')};  % FIX: Hardcode path
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% Run it
spm_jobman('run', matlabbatch);
disp('First-level model specified and estimated – all manual!');

%}

