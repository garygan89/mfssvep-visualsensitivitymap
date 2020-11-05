function EEGOUT = feature_extract(EEGIN)
    EEG = EEGIN;
    freq = file2freq(EEG.type);
    if length(freq)==0
       return
    end
       
    [ch_num,sample_num,epoch_num] = size(EEG);
    r = [];
    B = [];
    U = [];
    W = [];

    for epochIdx=1:epoch_num
        eegData = EEG.data(:,:,epochIdx)'; 
        [AOUT,BOUT,rOUT,UOUT,VOUT] = CCA_feaext(eegData,EEG.srate,freq);  
        r = cat(3,r,rOUT);
        B = cat(3,B,BOUT);
        U = cat(3,U,UOUT');
        if ch_num ~=1
           W =  cat(3,W,AOUT);
        end
    end
    if ch_num ~=1
        EEG.Weight = permute(W,[1,4,3,2]);
    end        
    EEG.FeaCor = r;
    EEG.FeaBeta = B;
    
    EEGOUT = EEG;


function EEGOUT = feature_extract_ORI(EEGIN)
    option_num = length(EEGIN);
    list = SbjMapping(EEGIN);
    EEGOUT = EEGIN;
    for option  = 1:option_num
       tmp_dataset = EEGIN{option}.dataset;
       file_num = length(tmp_dataset);
       for file = 1:file_num
           EEG = tmp_dataset{file};
           freq = file2freq(EEG.type);
           if length(freq)==0
               continue
           end
           EEG = CCA_extraction(EEGIN,EEG,list);
           EEGOUT{option}.dataset{file} = EEG;
       end
    end
  
    
%% CCA feature extraction mathod applied on enhanced and unenhanced signal 
function EEG = CCA_extraction(EEGIN,EEG,list)
    fieldName = fieldnames(EEG);
    DataIndex = find(contains(fieldName, 'data'));
    EnhanceMethodNum = length(DataIndex);
    freq = file2freq(EEG.type);
    name = [EEG.subject{1}, '_', EEG.group];
    if isfield(list,name)
        baseinf = list.(name);
        BaseData = EEGIN{baseinf{1}}.dataset{baseinf{2}}.data;
    else
        BaseData = [];
    end    
    for method = 1 :EnhanceMethodNum
        tmp_EEG = EEG.(fieldName{DataIndex(method)});
        if length(tmp_EEG) == 0
            continue
        end
        [ch_num,sample_num,epoch_num] = size(tmp_EEG);
        r = [];
        B = [];
        U = [];
        W = [];
        
        for epoch = 1:epoch_num
            eeg = tmp_EEG(:,:,epoch)'; 
            [AOUT,BOUT,rOUT,UOUT,VOUT] = CCA_feaext(eeg,EEG.srate,freq);  
            r = cat(3,r,rOUT);
            B = cat(3,B,BOUT);
            U = cat(3,U,UOUT');
            if ch_num ~=1
               W =  cat(3,W,AOUT);
            end
        end
        if ch_num ~=1
            EEG.Weight = permute(W,[1,4,3,2]);
        end        
        EEG.([erase(fieldName{DataIndex(method)},'data') 'FeaCor']) = r;
        EEG.([erase(fieldName{DataIndex(method)},'data') 'FeaBeta']) = B;
    end
    
%% CCA sinusoidal reference feature extraction function 
function  [AOUT,BOUT,rOUT,UOUT,VOUT] = CCA_feaext(eeg,fs,freq) 
    sample_num = size(eeg,1);  % Length of signal 
    YRef = SinRef(sample_num,fs,freq);
    [~,~,freq_num] = size(YRef);
    AOUT = [];
    BOUT = [];
    rOUT = [];
    UOUT = [];
    VOUT = [];
    for freq = 1:freq_num
        Y = YRef(:,:,freq);
        [A, B, r, U, V] = canoncorr(eeg,Y); %% this function input the data X, reference Y, output the CCA result      
        AOUT = cat(2,AOUT,A(:,1));
        BOUT = cat(2,BOUT,B(:,1));
        rOUT = cat(2,rOUT,r(:,1));
        UOUT = cat(2,UOUT,U(:,1));
        VOUT = cat(2,VOUT,V(:,1));
    end
    

    
    
%% CCA sinusoidal reference feature extraction function 
function  [AOUT,BOUT,rOUT,UOUT,VOUT] = CCA_feaext_ORI(eeg,fs,freq) 
    sample_num = size(eeg,1);  % Length of signal 
    YRef = SinRef(sample_num,fs,freq);
    [~,~,freq_num] = size(YRef);
    AOUT = [];
    BOUT = [];
    rOUT = [];
    UOUT = [];
    VOUT = [];
    for freq = 1:freq_num
        Y = YRef(:,:,freq);
        [A, B, r, U, V] = canoncorr(eeg,Y); %% this function input the data X, reference Y, output the CCA result      
        AOUT = cat(2,AOUT,A(:,1));
        BOUT = cat(2,BOUT,B(:,1));
        rOUT = cat(2,rOUT,r(:,1));
        UOUT = cat(2,UOUT,U(:,1));
        VOUT = cat(2,VOUT,V(:,1));
    end

%% sinusoidal reference 
function YRef = SinRef(sample_num,fs,freq)
    harmonic = 2;
    T = 1/fs;
    t = (0:sample_num-1)*T;
    freq_num = length(freq);
    freq = reshape(freq,1,1,freq_num);
    YRef=[];
    for i=1:harmonic                
        y1 = sin(2*i*pi*bsxfun(@times,freq,t'));
        y2 = cos(2*i*pi*bsxfun(@times,freq,t'));
        YRef = [YRef y1 y2];
    end      
