function [res] = create_contrasts(conditions) 
    % conditions = MainConditions
    nConditions = max(size(conditions));
    
    % larger than 0:
    contrast1_gr = eye(nConditions);
    names1_gr    = strcat(conditions, ' > 0');
    
    % smaller than 0:
    contrast1_sm = -eye(nConditions);
    names1_sm = strcat(conditions, ' < 0');
    
    % comparison contrasts:
    contrast2 = zeros(1, length(conditions));
    contrast2(1,1) = -1;
    contrast2(1,2) = 1;
    contrast2 = flipud(unique(perms(contrast2), 'rows'));
    names2 = repmat({''},1, height(contrast2));
    for i=1:length(names2)
        % i=1;
        C = strcat([conditions(contrast2(i,:)==1), ' > ', conditions(contrast2(i,:)==-1)]);
        names2(1,i) = { [C{:}] };
    end
    
    % Now create SPM object:
    res = {};
    contrasts = [contrast1_gr; contrast1_sm; contrast2];
    names     = [names1_gr names1_sm names2];
    for i = 1:length(names)
        res{i}.tcon.name = char(names(1,i));
        res{i}.tcon.weights = contrasts(i,:);
    end
end
