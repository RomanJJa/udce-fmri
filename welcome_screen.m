rgScreen('Preference','VisualDebugLevel',0);
Screen('Preference', 'SkipSyncTests', 1);

KbName('UnifyKeyNames');

[w, r_orig] = Screen('OpenWindow', 1, 0);


% rotations de l'affichage pour stim IRM
Screen('glPushMatrix', w);
Screen('glTranslate', w, r_orig(3)/2, r_orig(4)/2, 0 );
Screen('glScale', w, -1, 1, 1);
Screen('glTranslate', w, -r_orig(3)/2, -r_orig(4)/2, 0 );

r = [480 435 1440 975];

Screen('FillRect', w, [0 30 10], r);
Screen('Flip', w);
WaitSecs(2);
Screen('FillRect', w, [0 30 10], r);
Screen('TextFont',w, 'Arial');
Screen('TextSize', w, 80);
for i = 1 : 4
color = [255 0 0; 0 255 255; 0 0 255; 255 0 255];
rdigit = [r(1) r(2) r(1)+45 r(2)+57;
         r(3)-45 r(2) r(3) r(2)+57;
         r(1) r(4)-57 r(1)+45 r(4);
         r(3)-45 r(4)-57 r(3) r(4)]
[~, ~, textbounds] = DrawFormattedText(w, num2str(i), 'center', 'center', color(i,:),[], [], [], [], [], rdigit(i,:));

% disp(textbounds);
end
Screen('TextSize', w, 50);
DrawFormattedText(w, 'Bonjour,\nvoyez-vous les 4 coins ?', 'center', 'center', 255,[], [], [], [], [], r);
Screen('Flip',w);

 [d, ~, k] = KbCheck;

    fprintf('\n\n====================\nPress ESCAPE to stop\n====================\n\n');
    
   while ~k(KbName('ESCAPE'))
       [d, ~, k] = KbCheck;
       WaitSecs(0.05);
       if d
           c = KbName(k);
           if ~iscell(c)
          fprintf('Appui : ''%s''\n', c);
           else
               fprintf('Appui : ''%s''\n', c{1});
           end
       end
   end


sca