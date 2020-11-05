%% CCA simulated enhancement  with quardarture turn
function EEGOUT = CCA_enhancement_quadra(EEGIN)
    EEGOUT = EEGIN;
    option_num = length(EEGIN);
    for option = 1:option_num
       tmp_dataset = EEGIN{option}.dataset;
       file_num = length(tmp_dataset);
       for file = 1: file_num
           EEG = tmp_dataset{file};
           EEG = CCASimFun(EEG);
           EEGOUT{option}.dataset{file} = EEG;
       end
    end

%% enhancement function   
function EEG = CCASimFun(EEG)
    fr = 60; % refresh rate
    [~,~,epoch_num] = size(EEG.data); 
    freq = file2freq(EEG.type);
    if length(freq)==0
        return 
    end
    tmp_data = [];
    tmp_r = [];
    tmp_weight = [];
    
    eeg = EEG.data;
    [ch_num,smp_num,epoch_num] = size(eeg);    
    for epoch = 1: epoch_num
        eeg = EEG.data(:,:,epoch)';
        [A,B,r,U,V] = CCA_sim(eeg,EEG.srate,fr,freq) ; 
        tmp_data = cat(3,tmp_data,U(:,1)');
        tmp_r(end+1) = r(:,1);
        tmp_weight = cat(3,tmp_weight,A(:,1));
    end
    EEG.CCAQuadSimWeight = tmp_weight./std(tmp_data,[],2);
    tmp_data = (tmp_data-mean(tmp_data,2));    
    EEG.CCAQuadSimdata = tmp_data;
    EEG.CCAQuadSimEnhanCor = tmp_r;
    
%% CCA simulated reference function 
function [A,B,r,U,V] = CCA_sim(eeg,fs,fr,freq)  
    sample_num = size(eeg,1);  % Length of signal 
    YRef = SimRefQuar(fr,fs,sample_num,freq);
    [A, B, r, U, V] = canoncorr(eeg, YRef); %% this function input the data X, reference Y, output the CCA result  

%% simulation signal generation function 
function ySample = SimRefQuar(fr,fs,sample_num,freq)  %paper reference: HR-SSVEP BCI, Visual Stimulus Design (Wang+Jung+ 2010)
    % fr: refresh frequency
    % fs: sample rate
    % freq: stimulated frequency
    % y: output 
    period_num = sample_num/fs;
    quar_delay = floor(fs./freq/4);
    tRefresh = (0:1:fr*period_num)/fr;
    tSample = (0:1:sample_num-1)/fs;
    mapping = bsxfun(@lt,tSample,tRefresh(2:end)') & bsxfun(@ge,tSample,tRefresh(1:end-1)');
    [index,~] = find(mapping==1);
    tSample = tRefresh(index);
    tSample = 2*pi*bsxfun(@times,freq,tSample') + pi/2;    
    ySample = square(tSample);
    y_quar = ySample;
    for i = 1:length(quar_delay)
       y_quar(:,i) = [ySample(quar_delay(i)+1:end,i) ; ySample(1:quar_delay(i),i)];
    end
    ySample = [ySample y_quar];