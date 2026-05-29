function runTaskMRI_de

% directory of BIDS data in relation to this script
dataDirectory = 'data';
rootDirectory = pwd; % directory of the script
language = 'de';
% Defining the constants: timing parameters (in seconds)
allTaskNames = {'nct2.1', 'nct2.2', 'nct1', 'phono', 'lexi', 'morpho', 'syntax'};

fixationDuration = 0.4; % 300ms
stimulusDuration = 3.0; % 2s?
feedbackDuration = 0.8; % 800ms for practice feedback
pauseSeconds = 10.0; % 10s break every 50 trials
nBlock = 32; % Number of trials per rgrgrrrgblock
responseKeys = {'m', 'z'}; % Adjust as needed: 'r' is the upper stimulus; magenta instead of red and yellow instead of green
pulseKey = 't'; % key for scanner to send pulse
delay = 0.004;
recordFieldmap = false; % Should we record a field map?
fontSize = 55; % Stimulus font size; instructions are 70% of that
fontFamily = 'DejaVu Sans Mono'; % 'DejaVu Sans Mono';
fixationStarCorners = 4;
practiceLoopPercent = 0.66; % minimum percent correct for practice loop
[subject, noteInput, task, skipPractice] = experiment_pre_popup(allTaskNames);

[taskName, runNumber, areMultipleRuns] = extract_task_info(task);
validKeys = [responseKeys, 'ESCAPE']; 

%% Adapt task-specific settings if necessary
% Change in case we deal with the two-digit NCT
if taskName == "nct2"
    nBlock = 55;
    recordFieldmap = true;
end
if taskName == "nct2" || taskName == "nct1"
    stimulusDuration = 2;
end


fprintf('Subject number: %s\n', subject);
fprintf('Second input: %s\n', noteInput);
fprintf('Task: %s\n', task);
fprintf('Skip practice? %d\n', skipPractice);


% Create log entry with task parameters defined above:
loggedParameters = sprintf(['language (ISO-639-1): %s; ', ...
                            'stimulus font size: %d pt (instructions are 75 percent of that); ', ...
                            'font-family: "%s"; ', ...
                            'practice loop can be exited with more than %d percent correct; ', ...
                            'fixation star with %d corners was presented for %d ms; ', ...
                            'the stimulus was presented for %d ms; ', ...
                            'a pause occured during testing every %d trials for %d s'], ...
                           language, fontSize, fontFamily, practiceLoopPercent*100, ...
                           fixationStarCorners, fixationDuration*1000, ...
                           stimulusDuration*1000, ...
                           nBlock, pauseSeconds);

% Check if any "test" file (not practice) exists for that participant
% Check if the date of the participant fits.

% checking participant number:
subjectNum = str2double(subject);
if isnan(subjectNum)
    error('Please provide a number for the participant.');
elseif mod(subjectNum, 1) ~= 0
    error('Please do not provide decimal numbers for the participant (avoid using ''.'' or '','').');
elseif subjectNum < 0
    error('Please provide a ''Participant Number'' which is positive (no ''-'' sign).');
else
    subject = sprintf('%03d', str2double(subject));
end

% now check if the participant has been established in the data folder:
subjectDir = fullfile(rootDirectory, 'data', sprintf("sub-%s", subject));
if ~isfolder(subjectDir)
    error('Folder for subject %s not found. It needs to be prepared.', subject);
end

% checking if task is valid:
if ~ismember(task, allTaskNames)
    error('Please provide a valid ''Task Name'' as defined in the variable ''allTaskNames''.');
end

% Check if there are three digits
if subjectNum < 1000
    subject = sprintf("%03d", subjectNum);
end

% Display the entered values (for verification)
fprintf('Participant Number: %s\n', subject);
fprintf('Task Name: %s\n', task);

%% load instructions:

anyKeyToContinue = fileread("instructions/scanner/press_any_key_to_continue."+language+".txt");

longInstructions  = fileread(sprintf("instructions/instructions_%s_long.%s.txt", taskName, language));
longInstructions  = strcat(longInstructions, '\n\n', anyKeyToContinue);
shortInstructions = fileread(sprintf("instructions/instructions_%s_short.%s.txt", taskName, language));
shortInstructions = strcat(shortInstructions, '\n\n', anyKeyToContinue);

feedbackNoResponse = fileread("instructions/practice/feedback_no_response."+language+".txt");
feedbackCorrect    = fileread("instructions/practice/feedback_correct."+language+".txt");
feedbackIncorrect  = fileread("instructions/practice/feedback_incorrect."+language+".txt");
practiceStarting   = fileread("instructions/practice/practice_starting."+language+".txt");
continuePracticing = fileread("instructions/practice/continue_practicing."+language+".txt");
practiceFinished   = fileread("instructions/practice/practice_finished."+language+".txt");

waitingForScanner = fileread("instructions/scanner/waiting_for_scanner."+language+".txt");
scanningFieldmaps = fileread("instructions/scanner/recording_field_maps."+language+".txt");

taskStarts    = fileread("instructions/task/task_starts."+language+".txt");
shortPause    = fileread("instructions/task/short_pause."+language+".txt");
taskContinues = fileread("instructions/task/task_continues."+language+".txt");
taskComplete  = fileread("instructions/task/task_complete."+language+".txt");

% Create a path to output files (CSV and LOG files):
outputPath = fullfile(rootDirectory, dataDirectory, sprintf('sub-%s', subject), 'beh');
inputPath  = fullfile(rootDirectory, dataDirectory, sprintf('sub-%s', subject), 'stimuli');
dataPath   = fullfile(rootDirectory, dataDirectory);

% input files:
% Important columns: stim1, stim2, condition, isi, stim1_correct
fprintf("reading file from\n%s", fullfile(inputPath, sprintf('sub-%s_task-%s-practice_stim.csv', subject, task)));

% previous selections:
%practiceStimuliFile =  sprintf('sub-%s_task-%s-practice_stimuli.csv', subject, taskName);
% mainStimuliFile = sprintf('sub-%s_task-%s_stimuli.csv', subject, task);

fileselector = {['sub-',char(subject),'_'], ['_task-',taskName,'-practice_'], '_stimuli.csv'};
practiceStimuliFile = bids_select(dataPath, ...
                                  sprintf('sub-%s/stimuli',subject), ...
                                  fileselector);

if (areMultipleRuns)
    fileselector = {['sub-',char(subject),'_'], ['_task-', taskName,'_'], ...
                    ['_run-', num2str(runNumber),'_'], '_stimuli.csv'};
    mainStimuliFile = bids_select(dataPath, ...
                                  sprintf('sub-%s/stimuli',subject), ...
                                  fileselector);
else 
    fileselector = {['sub-',char(subject),'_'], ['_task-',taskName,'_'], '_stimuli.csv'};
    mainStimuliFile = bids_select(dataPath, ...
                                  sprintf('sub-%s/stimuli',subject), ...
                                  fileselector);
end

practiceStimuli = read_stimuli(char(practiceStimuliFile(1)));
mainStimuli     = read_stimuli(char(mainStimuliFile(1)));
subjectFile     = sprintf('sub-%s_task-%s', subject, taskName);

bidsRun = ''; % BIDS session tag
if areMultipleRuns % if there are multiple sessions for the task
    bidsRun = sprintf('_run-%d', runNumber);
end

% look for previous runs and determine the current run
logFiles = bids_select(fullfile(rootDirectory, dataDirectory), ...
                       fullfile(['sub-' char(subject)], 'beh'), ...
                       [{sprintf('sub-%s', subject)}, {sprintf('_task-%s', taskName)}, ...
                        {bidsRun}, {'_events\.log$'}]);
nTry = max(size(logFiles))+1;

% output files:
logFile         = fullfile(outputPath, sprintf([subjectFile '%s_try-%d_events.log'], bidsRun, nTry));
outTestFile     = fullfile(outputPath, sprintf([subjectFile '-test%s_try-%d_beh.csv'], bidsRun, nTry));
outPracticeFile = fullfile(outputPath, sprintf([subjectFile '-practice%s_try-%d_beh.csv'], bidsRun, nTry));

if isfile(outTestFile) && subjectNum ~= 0 % if output CSV already exists, there is a danger that we already created it!
    error("Final CSV file for task already exists for subject '%s' at: \n%s\n" + ...
          "If you would like to re-record the task, remove the file from the directory.\n", ...
          "Make sure that you do not overwrite an older participant", ...
          subject, outTestFile);
elseif ~isfolder(outputPath) % if folder for output does not exist, create it!
    mkdir(outputPath);
end

% Open log file:
logID = fopen(logFile, "w");
if logID == -1
    error('Unable to open or create the log file.');
end

% Disable writing in the script.
ListenChar(2);

fprintf(logID, "timestamp\tphase\taction\tspecifics");

%% set datetime
dt = datetime("now");
dt.Format = 'dd-MM-yyyy HH:mm:ss';

% usage:
% logTable = appendLog(logID, <someTimestamp> (float), "stim", "37_85")
appendLog(logID, GetSecs, "setup", "setting-variables", ...
          "task has been started, variables are loaded...");
appendLog(logID, GetSecs, "setup", "current-datetime", string(dt));
appendLog(logID, GetSecs, "setup", "provided-parameters", loggedParameters);
appendLog(logID, GetSecs, "setup", "setting-task", ...
          sprintf("task-%s", taskName));
appendLog(logID, GetSecs, "setup", "setting-block", ...
          sprintf("experimental block (run): %d; number of restart/retry (try): %d", runNumber, nTry));
appendLog(logID, GetSecs, "setup", "setting-subject", ...
          sprintf("sub-%s", subject));
appendLog(logID, GetSecs, "setup", "experimenter-note", ...
          sprintf("Note by experimenter: ""%s""", noteInput));

% add columns for responses to practice trials:
practiceStimuli.responseKey = repmat({'NA'}, size(practiceStimuli, 1), 1);
practiceStimuli.responseTime = NaN(size(practiceStimuli, 1), 1);
practiceStimuli.responseCorrect = NaN(size(practiceStimuli, 1), 1);
practiceStimuli.trialStart = NaN(size(practiceStimuli, 1), 1);
if (string(class(practiceStimuli.stim1)) == "double")
    practiceStimuli.stim1 = cellstr(num2str(practiceStimuli.stim1));
end
if (string(class(practiceStimuli.stim2)) == "double")
    practiceStimuli.stim2 = cellstr(num2str(practiceStimuli.stim2));
end

% add columns for responses to test trials:
mainStimuli.responseKey = repmat({'NA'}, size(mainStimuli, 1), 1);
mainStimuli.responseTime = NaN(size(mainStimuli, 1), 1);
mainStimuli.responseCorrect = NaN(size(mainStimuli, 1), 1);
mainStimuli.trialStart = NaN(size(mainStimuli, 1), 1);
if (string(class(mainStimuli.stim1)) == "double")
    mainStimuli.stim1 = cellstr(num2str(mainStimuli.stim1));
end
if (string(class(mainStimuli.stim2)) == "double")
    mainStimuli.stim2 = cellstr(num2str(mainStimuli.stim2));
end

appendLog(logID, GetSecs, "setup", "append-variables", "appended stimulus sets with response variables");

% Debugging settings:
Screen('Preference', 'Verbosity', 1);
Screen('Preference', 'VisualDebugLevel', 0);
Screen('Preference', 'SkipSyncTests', 1); % Skip sync tests for development (remove for real experiment)

% Set key names
KbName('UnifyKeyNames');
try
    % Open a window
    % 0 is primary screen, 1 is second screen available:
    screennumber = max(Screen('Screens')); 
    backgroundColor = [0 0 0]; % black background
    [window, r_orig] = Screen('OpenWindow', screennumber, backgroundColor);
catch error_openWindow
    appendLog(logID, GetSecs, "setup", "error", error_openWindow.message);
    ListenChar(0);
    rethrow(error_openWindow);
end


% rotations de l'affichage pour stim IRM
Screen('glPushMatrix', window);
Screen('glTranslate', window, r_orig(3)/2, r_orig(4)/2, 0 );
Screen('glScale', window, -1, 1, 1);
Screen('glTranslate', window, -r_orig(3)/2, -r_orig(4)/2, 0 );

% definition de la zone d'affichage
% r = [480 435 1440 975];
r = [];

% Monospaced font for consistent sizing, used to be 'Consolas':
Screen('TextFont', window, fontFamily);
Screen('TextSize', window, fontSize); % Adjust text size as needed
Screen('TextStyle', window, 1);

%% Response hand test
% if the subject has
if mod(subjectNum, 2)== 0
    resp1 = struct("hand", "left",  "key", responseKeys(1), "stim", ' ← '); % ' ← '
    resp2 = struct("hand", "right", "key", responseKeys(2), "stim", ' → '); % ' → '
else % subject number uneven
    resp1 = struct("hand", "left",  "key", responseKeys(2), "stim", ' ← '); % ' ← '
    resp2 = struct("hand", "right", "key", responseKeys(1), "stim", ' → '); % ' → '
end

% log which response key
appendLog(logID, GetSecs, "setup", "set-"+resp1.hand+"-hand", ...
          sprintf("%s hand on '%s' key --> correct / affirming / positive / upper stimulus greater", ...
                  resp1.hand, resp1.key));
appendLog(logID, GetSecs, "setup", "set-"+resp2.hand+"-hand", ...
          sprintf("%s hand on '%s' key --> incorrect / rejecting / negative / choose lower stimulus greater", ...
                  resp2.hand, resp2.key));

lineHeight = Screen('TextSize', window) * 0.75; % Approximate line height
[screenWidth, screenHeight] = Screen('WindowSize', window);
centerX = screenWidth / 2;
centerY = screenHeight / 2;
appendLog(logID, GetSecs, "setup", "set-line-height", ...
          sprintf("line-height: %dpx", lineHeight));

% Test where the text of stim1 and stim2 should be located:
[up.nx, up.ny, up.textbounds, up.wordbounds] = ...
    DrawFormattedText(window, '85', 'center', centerY - lineHeight, 0,[],[],[],[],[],r);
[down.nx, down.ny, down.textbounds, down.wordbounds] = ....
    DrawFormattedText(window, '79', 'center', centerY + lineHeight, 0,[],[],[],[],[],r);
% maybe loop through stimulus set and calculate center for every stimulus

% Fixation star coordinates:
ray = 15;
centerYstar = down.textbounds(2) + (up.textbounds(4) - down.textbounds(2))/2;
A_c = [centerX, centerYstar];
fibosq = ((1+sqrt(5))/2)^2;
cs = fixationStarCorners; % 4 corners?
pl = [];
for i = 1:cs
    pl = [pl ;
        [ray*cos(pi/2 + 2*(i-1)*pi/cs) ray*sin(pi/2 + 2*(i-1)*pi/cs)] ;
        [ray/fibosq*cos(pi/2 + (2*(i-1)+1)*pi/cs) ray/fibosq*sin(pi/2 + (2*(i-1)+1)*pi/cs)]];
end
star_coordinates = repmat(A_c,cs*2,1) - pl;

% Display star_coordinates
disp(star_coordinates);

RestrictKeysForKbCheck(KbName(validKeys)); % Reset to experiment keys
appendLog(logID, GetSecs, "setup", "loading", "restricted key input");

try
    
    %% Task instructions:
    % maybe load instructions for each task with the CSV files
    % short and long instructions?
    Screen('TextSize', window, round(fontSize * 0.75));
    DrawFormattedText(window, longInstructions, 'center', 'center', 255,[],[],[],[],[],r);
    Screen('TextSize', window, fontSize);
    [onset, ~] = Screen('Flip', window);
    appendLog(logID, onset, "practice", "long-instructions", longInstructions);
    awaitKey(Inf, responseKeys, onset, pulseKey, logID);
    
    %% If we are in a subsequent block: ...
    if runNumber < 2 && ~skipPractice
    
        % because of the practice loop, we could have multiple columns
        practiceData = practiceStimuli;
        practiceIterator = -1;
        
        %% Practice starts
        DrawFormattedText(window, practiceStarting, 'center', 'center', 255,[],[],[],[],[],r);
        [onset, ~] = Screen('Flip', window);
        appendLog(logID, onset, "practice", "practice-start", string(practiceStarting));
        awaitKey(2 - delay, {'ESCAPE'}, onset, pulseKey, logID);
        
        %% Practice loop
        % introduce practice loop: As long as correct answers are less than 70%
        % of trials, the participant remains in the practice loop.
        nPracticeCorrect = 0;
        while practiceLoopPercent > (nPracticeCorrect / size(practiceStimuli, 1))
            practiceIterator = practiceIterator + 1;
            nPracticeCorrect = 0;
            for trial = 1:size(practiceStimuli, 1)
                
                % Draw fixation star:
                Screen('FillPoly', window, 255, star_coordinates);
                [onset, ~] = Screen('Flip', window);
                appendLog(logID, onset, "practice", "fixation", "star");
                awaitKey(fixationDuration - delay, {'ESCAPE'}, onset, pulseKey, logID);
                
                % Draw stimulus:
                appendLog(logID, GetSecs + delay, "loading", "rendering-stimulus", ...
                          sprintf("trial %d: stim1=""%s"", stim2=""%s""", trial, ...
                                  char(practiceStimuli.stim1(trial)), ...
                                  char(practiceStimuli.stim2(trial))));
                
                displayStimuli(window, practiceStimuli.stim1(trial), practiceStimuli.stim2(trial), centerX, centerY, lineHeight,r);
                %DrawFormattedText(window, char(practiceStimuli.stim1(trial)), 'center', centerY - lineHeight, 255);
                %DrawFormattedText(window, char(practiceStimuli.stim2(trial)), 'center', centerY + lineHeight, 255);
                
                [onset, ~] = Screen('Flip', window);
                appendLog(logID, onset, "practice", "stimulus", ...
                          sprintf("trial %d: ""%s"" vs. ""%s"" of cond=%s", trial, ...
                                  strrep(string(practiceStimuli.stim1(trial)), ' ', '_'), ...
                                  strrep(string(practiceStimuli.stim2(trial)), ' ', '_'), ...
                                  string(practiceStimuli.condition(trial))));
                
                % Wait for response: 
                [rk, rt] = awaitKey(stimulusDuration - delay, responseKeys, onset, pulseKey, logID);
    
                % Was there any response?
                if isempty(rk)
                    rk = 'none';
                end
    
                correct = (string(rk) == string(responseKeys(1)) & ...
                           practiceStimuli.stim1_correct(trial)==1) || ...
                          (string(rk) == string(responseKeys(2)) & ...
                           practiceStimuli.stim1_correct(trial)==0) || ...
                          (string(rk) == "none" && strcmp(practiceStimuli.condition(trial), 'null_event'));
                appendLog(logID, onset + rt, "practice", "button-response", ...
                          sprintf("'%s' (after %dms), correct='%s'", ...
                                  string(rk), round(rt*1000), string(correct)));
                
                % wait for the rest of stimulus time after response:
                if ~isnan(rt) || rt < stimulusDuration
                    awaitKey(stimulusDuration - delay, responseKeys, onset, pulseKey, logID);
                    WaitSecs(stimulusDuration - rt);
                end
    
                % Evaluate feedback:
                if correct
                    feedback = feedbackCorrect;
                    nPracticeCorrect = nPracticeCorrect + 1;
                    feedbackColor = [170 170 255];
                elseif (isempty(rk) || string(rk) == "none")
                    feedback = feedbackNoResponse;
                    feedbackColor = [255 210 150];
                    rk = 'none';
                else
                    feedback = feedbackIncorrect;
                    feedbackColor = [255 170 170];
                end
                
                % Matlab console:
                fprintf("Key:   ""%s""\n\n", rk);
                
                % draw feedback:
                DrawFormattedText(window, feedback, 'center', ...
                                  centerYstar + lineHeight/3, ...
                                  feedbackColor,[],[],[],[],[],r);
                
                % Feedback:
                [~, onset] = Screen('Flip', window);
                appendLog(logID, onset, "practice", "feedback", feedback);
                if strcmp(rk, 'none')
                    awaitKey(feedbackDuration - delay + 0.7, {}, onset, pulseKey, logID);
                else 
                    awaitKey(feedbackDuration - delay, {}, onset, pulseKey, logID);
                end
                % Blank:
                [~, onset] = Screen('Flip', window);
                appendLog(logID, onset, "practice", "blank", "");
                awaitKey(practiceStimuli.isi(trial)/1000 - delay, {}, onset, pulseKey, logID);
                
                % Store results:
                row = practiceIterator * size(practiceStimuli, 1) + trial;
                practiceData.responseKey(row) = {rk};
                practiceData.responseTime(row) = rt;
                practiceData.responseCorrect(row) = correct;
            end
            
            % If practice did not go very well, show the participant the short
            % instructions again.
            if nPracticeCorrect < practiceLoopPercent * size(practiceStimuli, 1)
                
                % Append practiceData
                appendLog(logID, GetSecs, "loading", "append-rows", ...
                          "appending practiceData with new rows (new round of practice trials)");
                practiceData = [practiceData; practiceStimuli];
                
                % Repeat instructions shortly:
                Screen('TextSize', window, round(fontSize * 0.75));
                DrawFormattedText(window, shortInstructions, 'center', 'center', 255,[],[],[],[],[],r);
                [onset, ~] = Screen('Flip', window);
                appendLog(logID, onset, "practice", "short-instructions", shortInstructions);
                awaitKey(Inf, responseKeys, onset, pulseKey, logID);
                
                % Continue practicing:
                DrawFormattedText(window, continuePracticing, 'center', 'center', 255,[],[],[],[],[],r);
                Screen('TextSize', window, fontSize);
                [onset, ~] = Screen('Flip', window);
                appendLog(logID, onset, "practice", "continue-practice", continuePracticing);
                awaitKey(3 - delay, {}, onset, pulseKey, logID);
            end
        end
    
        % Store CSV for practice trials:
        appendLog(logID, GetSecs, "loading", "practice-csv-storing", ...
                  sprintf("Attempting to store practice file CSV at '%s'.", strrep(outPracticeFile,'\','/')));
        writetable(practiceData, outPracticeFile);
        appendLog(logID, GetSecs, "loading", "practice-csv-stored", ...
                  sprintf("Successfully stored practice file CSV at '%s'.", strrep(outPracticeFile,'\','/')));
        
        % Practice is over
        DrawFormattedText(window, practiceFinished, 'center', 'center', 255,[],[],[],[],[],r);
        [onset, ~] = Screen('Flip', window);
        appendLog(logID, onset, "practice", "practice-finished", practiceFinished);
        awaitKey(Inf, responseKeys, onset, pulseKey, logID);
        
    end 

    %% fieldmap (fmap) recording

    if recordFieldmap
        DrawFormattedText(window, scanningFieldmaps, 'center', 'center', 255,[],[],[],[],[],r);
        [onset, ~] = Screen('Flip', window);
        appendLog(logID, onset, "fieldmap", "fieldmap-recording", scanningFieldmaps);
        awaitKey(Inf, {'f', 'ESCAPE'}, onset, pulseKey, logID);
    end


    %% Prepare test phase:

    % Display "waiting for scanner ..."
    DrawFormattedText(window, waitingForScanner, 'center', 'center', 255,[],[],[],[],[],r);
    [onset, ~] = Screen('Flip', window);
    appendLog(logID, onset, "practice", "waiting-for-scanner", waitingForScanner);
    %RestrictKeysForKbCheck(KbName({pulseKey, 'ESCAPE'}));
    
    % Waiting for scanner response:
    % d_ttl = 0; sequenceStart = GetSecs; k_ttl = zeros(1,256);
    %[d_ttl, sequenceStart, k_ttl] = KbCheck;
    fprintf('Start session on the sync box\nThen start scan\n');
    fprintf('The experiment will start automatically\n\n...\n\n');
    
    %% waiting for TTL
    %while ~d_ttl && ~k_ttl(KbName('ESCAPE'))
    %    [d_ttl,sequenceStart,k_ttl] = KbCheck;
    %end
    %
    %checkEscQuit(k_ttl);
    [k_ttl, d_ttl] = awaitKey(Inf, {pulseKey}, onset, '', logID);
    sequenceStart = onset+d_ttl;
    appendLog(logID, sequenceStart, "test", "sequence-start", ...
              sprintf("Pulse signal: '%s'. Scanner starts right now. For fMRI analyses, "+ ...
                      "subtract the current time from all logged times "+ ...
                      "(first column in this file).", k_ttl));
    
    %% Transition to main experiment
    RestrictKeysForKbCheck(KbName(validKeys)); % Reset to experiment keys
    DrawFormattedText(window, taskStarts, 'center', 'center', 255,[],[],[],[],[],r);
    [onset, ~] = Screen('Flip', window);
    appendLog(logID, onset, "test", "test-starting", taskStarts);
    awaitKey(4 - delay, {}, onset, pulseKey, logID);
    
    %% short 
    RestrictKeysForKbCheck(KbName(validKeys)); % Reset to experiment keys
    [onset, ~] = Screen('Flip', window);
    appendLog(logID, onset, "test", "blank", "blank screen before start for 3000ms");
    awaitKey(4 - delay, {}, onset, pulseKey, logID);

%% ~~~ Main Task ~~~
    
    for trial = 1:size(mainStimuli, 1)
        %% Pause every nBlock trials
        if mod(trial, nBlock) == 1 && trial > 1

            % announce pause
            DrawFormattedText(window, shortPause, 'center', 'center', 255,[],[],[],[],[],r);
            [onset, ~] = Screen('Flip', window);
            appendLog(logID, onset, "test", "short-pause", shortPause);
            awaitKey(pauseSeconds, {}, onset, pulseKey, logID);
            
            % pause is over
            DrawFormattedText(window, taskContinues, 'center', 'center', 255,[],[],[],[],[],r);
            [onset, ~] = Screen('Flip', window);
            appendLog(logID, onset, "test", "pause-over", taskContinues);
            awaitKey(2, {}, onset, pulseKey, logID);

            % short gap after pause is over
            [onset, ~] = Screen('Flip', window);
            appendLog(logID, onset, "test", "blank", "after-pause blank screen for 1500ms");
            awaitKey(1.5, {}, onset, pulseKey, logID);
            
        end

        % Draw fixation star
        Screen('FillPoly', window, 255, star_coordinates);
        [onset, ~] = Screen('Flip', window);
        appendLog(logID, onset, "test", "fixation", "");
        awaitKey(fixationDuration, {}, onset, pulseKey, logID);
        
        % Draw stimuli
        appendLog(logID, GetSecs, "loading", "rendering-stimulus", ...
                  sprintf("trial %d: stim1=""%s"", stim2=""%s""", trial, ...
                          char(mainStimuli.stim1(trial)), ...
                          char(mainStimuli.stim2(trial))));
        fprintf("\nItem %d\n", trial);
        displayStimuli(window, ...
                        mainStimuli.stim1(trial), ...
                        mainStimuli.stim2(trial), ...
                        centerX, centerY, lineHeight,r);
        % DrawFormattedText(window, char(mainStimuli.stim1(trial)), 'center', centerY - lineHeight, 255);
        % DrawFormattedText(window, char(mainStimuli.stim2(trial)), 'center', centerY + lineHeight, 255);
        [onset, ~] = Screen('Flip', window); % Begin presenting the stimuli
        appendLog(logID, onset, "test", "stimulus", ...
                  sprintf("trial %d: ""%s"" vs. ""%s"" of cond=%s", trial, ...
                          strrep(string(mainStimuli.stim1(trial)), ' ', '_'), ...
                          strrep(string(mainStimuli.stim2(trial)), ' ', '_'), ...
                          string(mainStimuli.condition(trial))));
        trialStart = onset - sequenceStart;
        
        % Collect response
        % [responseKey, responseTime] = awaitKey(wait, awaitKeys)
        [rk, rt] = awaitKey(stimulusDuration, validKeys, onset, pulseKey, logID);
        
        % Which key was pressed?
        if isempty(rk)
            rk = 'none';
        end
        fprintf("Key:   ""%s""\n", rk);
        
        % Was the response correct?
        correct = (string(rk) == string(responseKeys(1)) && mainStimuli.stim1_correct(trial)==1) || ...
                  (string(rk) == string(responseKeys(2)) && mainStimuli.stim1_correct(trial)==0) || ...
                  (string(rk) == "none" && mainStimuli.condition(trial)=="null_event");
        
        if ~isnan(rt)
            awaitKey(stimulusDuration, {}, onset, pulseKey, logID); % stimulusDuration - rt ???
        end
        
        % log response button
        appendLog(logID, onset+rt, "test", "response", ...
                  sprintf("pressed '%s' at %dms, correct=%s", ...
                          string(rk), round(rt*1000), string(1==correct)));
        
        % store in stimulus set:
        mainStimuli.responseKey(trial) = {rk};
        mainStimuli.responseTime(trial) = rt;
        mainStimuli.responseCorrect(trial) = correct; % Adjust if correctness can be determined
        mainStimuli.trialStart(trial) = trialStart;
        
        % ISI
        [onset, ~] = Screen('Flip', window);
        appendLog(logID, onset, "test", "blank", ...
                  sprintf("ISI=%dms", mainStimuli.isi(trial)));
        awaitKey(mainStimuli.isi(trial)/1000 - delay, {}, onset, pulseKey, logID);
        
    end
    
    %% Store CSV for test trials:
    appendLog(logID, GetSecs, "loading", "test-csv-storing", ...
              sprintf("attempting to store test file CSV '%s'", strrep(outTestFile,'\','/')));
    writetable(mainStimuli, outTestFile);
    appendLog(logID, GetSecs, "loading", "test-csv-stored", ...
              sprintf("successfully stored test file CSV at '%s'", strrep(outTestFile,'\','/')));
    
    % Final message
    DrawFormattedText(window, taskComplete, 'center', 'center', 255,[],[],[],[],[],r);
    [onset, ~] = Screen('Flip', window);
    appendLog(logID, onset, "test", "task-end", taskComplete);
    awaitKey(5 - delay, {}, onset, pulseKey, logID);
    
    fprintf('\nThe task is over.\n');
    
    %% Clean up Psychtoolbox
    fclose(logID); % close the log file
    ListenChar(0);
    sca; % Close Psychtoolbox screen
    RestrictKeysForKbCheck([]); % Reset key restrictions
    
catch e
    % Error handling
    appendLog(logID, GetSecs, "panic", "error", e.message);
    quitTask(logID);
    ListenChar(0);
    sca;
    RestrictKeysForKbCheck([]);
    % fprintf('Error: %s\n', e.message);
    rethrow(e);
end

end

% Check if escape key was pressed
% Input: key stroke
function checkEscQuit(key)
    keyClass = string(class(key));
    if ((keyClass == "char" || keyClass == "string") && string(key) == "ESCAPE") || ... % (if string)
       (string(class(key)) == "double" && max(size(key)) == 256 && string(KbName(key)) == "ESCAPE") % (if array of double)
       
       error('Task has been forced to quit by ESC key press.');
    end
end



% function for consistend logging: 
% file ID: output from fopen()
% time: timestamp from GetSecs
% phase: "test" or "practice" (for SPM later on).
% action: a short string about what this is "loading" (anything
%         computational) / "fixcross" / "stimulus" / "pause" / ...
% Usage:
% appendLog(logID, GetSecs, "no-phase", "no-action", "no-specifics") 
function appendLog(fid, time, phase, action, specifics) 
    arguments
        fid
        time = GetSecs
        phase = "none"
        action = "none"
        specifics = "no-specifics"
    end

    % create proper strings of values without new lines or tabs:
    regex = '([\n\r\t]+)|(\\n)|(\\t)|(\\r)';
    time = string(time);
    phase = regexprep(char(phase),regex,' ');
    action = regexprep(char(action),regex,' ');
    specifics = regexprep(char(specifics),regex,' ');
    output = sprintf('\n%s\t%s\t%s\t%s', time, phase, action, specifics);
    try
        fprintf(fid, output);
    catch
        fprintf("log file has already been closed but here is the log:\n");
        fprintf(output);
    end
end

% quit the task:
% close the log file and close screen with console message.
function quitTask(fid)
    appendLog(fid, GetSecs, "loading", "quitting-task", " ") 
    try
        fclose(fid);
    catch
        fprintf("log file has no valid identifier. Already closed?\n");
    end
    fprintf("Log file has been closed.\n");
    fprintf("quitTask() has been called.\n");
    RestrictKeysForKbCheck([]);
    Screen('CloseAll');
    ListenChar(0);
    sca;
end

function [responseKey, responseTime] = awaitKey(wait, awaitKeys, onset, pulseKey, logid)
    if nargin < 3 
        onset = GetSecs;
    end
    if nargin < 4
        pulseKey = 'none';
    end
    if nargin < 5
        logid = NaN;
    end

    keyTime = onset + wait;
    waitingForPulse = false;
    if ismember(pulseKey, awaitKeys) 
        waitingForPulse = true;
    end
    responseKey = 'none';
    responseTime = wait;
    oldKeys = RestrictKeysForKbCheck(KbName([awaitKeys pulseKey 'ESCAPE']));
    timeUp = onset + wait;

    minNextLog = onset;
    %keyIsDown = false;
    %keyCode = size(zeros(1, 256));
    try 
        while GetSecs < timeUp
            [keyIsDown, keyTime, keyCode] = KbCheck;
            if keyIsDown
                responseKey = KbName(keyCode);
                responseTime = keyTime - onset;
                isPulseKey = strcmp(responseKey, pulseKey);
                if isPulseKey && keyTime > minNextLog && ~waitingForPulse % Check for pulse
                    minNextLog = keyTime+0.3;
                    responseKey = 'none';
                    % Now log the event:
                    if ~isnan(logid)
                        appendLog(logid, keyTime, "test", "scanner-pulse", "");
                    end
                    fprintf("%d: Detected scanner pulse after %d of onset.\n", keyTime, responseTime);
                elseif ~isPulseKey   % now if it is not the pulse key
                    checkEscQuit(keyCode);
                    break;
                end
            end
        end
        RestrictKeysForKbCheck(oldKeys);
        if responseTime == wait
            responseTime = keyTime - onset;
        end
        % fprintf('Pressed key %s\n', responseKey);
    catch awaitKeyError
        RestrictKeysForKbCheck(oldKeys);
        error(awaitKeyError.message);
    end
end


% display stimuli and correctly handle spacing:
% g(window, mainStimuli.stim1(trial), mainStimuli.stim2(trial), centerX, centerY, lineHeight);
function displayStimuli(win, stim1, stim2, centerX, centerY, line, r) 
    
    stim1 = char(stim1);
    stim2 = char(stim2);
    trimmedStim1 = strtrim(stim1);
    trimmedStim2 = strtrim(stim2);

    bounds = Screen('TextBounds', win, replace(stim1, ' ', '_'));
    fprintf("stim1: ""%s""\n", stim1);
    textOffset = abs(bounds(3) - bounds(1))/2;
    DrawFormattedText(win, trimmedStim1, centerX - textOffset, ... %  + shiftStim2/2
                      centerY - line, 255,[],[],[],[],[],r);
    
    bounds = Screen('TextBounds', win, replace(stim2, ' ', '_'));
    fprintf("stim2: ""%s""\n", stim2);
    textOffset = abs(bounds(3) - bounds(1))/2;
    DrawFormattedText(win, trimmedStim2, centerX - textOffset, ... %  + shiftStim2/2
                      centerY + line, 255,[],[],[],[],[],r);
end



