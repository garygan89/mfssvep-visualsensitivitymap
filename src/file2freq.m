%% get the related frequency from type    
function freq = file2freq(type)
    if strcmp(type,'b')
       freq = [8,8.4,8.8,9.2,9.6,10,10.6,11,11.4,11.8];
    elseif strcmp(type,'a')
       freq = [8.2,8.6,9,9.4,9.8,10.2,10.4,10.8,11.2,11.6]; 
    else 
        freq = [];
    end
    