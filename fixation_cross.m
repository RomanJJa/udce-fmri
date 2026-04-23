% croix de fixation

%Screen('Preference', 'SkipSyncTests', 1);
%Screen('Preference','VisualDebugLevel', 3);
[w, r_orig] = Screen('OpenWindow', 1, 0);

Screen('TextFont',w, 'Arial');
Screen('TextStyle', w, 0);
Screen('TextSize',w, 60);
vSpacing = 1.5;

DrawFormattedText(w, '+', 'center', 'center', 127);
Screen('Flip',w);


[~, ~, k] = KbCheck;

% Playback loop: Runs until ESCAPE keypress

fprintf('\n\n====================\nPress ESCAPE to stop\n====================\n\n');

while ~k(KbName('ESCAPE'))
    [~, ~, k] = KbCheck;
    WaitSecs(0.05);
end

sca;

