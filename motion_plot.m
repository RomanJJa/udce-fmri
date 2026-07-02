% Create a motion plot:
% @argument funcFile: the path and filename towards the raw functional NIfTI
function motion_plot(funcFile)
    [path, ~, ~] = fileparts(funcFile);
    rp_file = spm_select('FPList', path, ['^rp_.*' spm_file(funcFile,'basename') '.*\.txt$']);
    if ~isempty(rp_file)
        rp = load(rp_file);
        figure; 
        subplot(2,1,1); plot(rp(:,1:3)); title('Translation (mm)'); legend('x','y','z');
        subplot(2,1,2); plot(rp(:,4:6)*180/pi); title('Rotation (deg)'); legend('pitch','roll','yaw');
        [~, funcName, ~] = fileparts(funcFile);
        saveas(gcf, fullfile(spm_file(funcFile,'path'), ['motion_' funcName '.png']));
        fprintf('Motion plot generated and saved.\n');
    else
        warning('Motion TXT file not found:\n%s\n', rp_file);
    end
end