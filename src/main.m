clear all; clc;

% An analysis pipeline to generate Visual Sensitivity Map from mfSSVEP
% Collab between nGoggle and MiiS, use in Demo 11/13.
% Each function accept a single EEG struct, iterating dataset is done in
% main.m, instead of within the function to make it more general
% Author: Kevin Xu <xu3850711@gmail.com>, Gary Gan <garygan0701@gmail.com>

% Start from a preprocessed .mat file
DATASET_PATH=['inputdata/MiiS-DiB-EEG.mat'];
disp( ['Loading dataset from ' DATASET_PATH ]);
load(DATASET_PATH);

SEP = '--------------------------------------------';

for i=1:length(EEG)
    disp( ['Processing EEG set num=' num2str(i)] );
    
    disp('Stage 1/3: Signal Enhancement');
    EEG{i} = CCA_enhancement_quadra(EEG{i});
    
    disp('Stage 2/3: Feature Extraction');
    EEG{i} = feature_extract(EEG{i});
    
    disp('Stage 3/3: PLS Model Prediction');
    % ...
    
    disp('Stage 4/4: Visual Sensitivity Map Generation');
    % ...
    
    disp(SEP);
end