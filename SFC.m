%% MATLAB Version 2021b
clear 
close all

%% add FieldTrip toolbox

restoredefaultpath
addpath D:\matlab\fieldtrip-20220104\fieldtrip-20220104
ft_defaults  


%% load FieldTrip-style example data segment

load data_example.mat

%% bandpass filtering in 80-500 Hz
cfg=[];
cfg.bpfilter      = 'yes';
cfg.bpfreq        = [80 500];
cfg.bpfilttype    = 'fir';
cfg.plotfiltresp  = 'yes';
data_high_frequency= ft_preprocessing(cfg,data_example);

% visualize bandpassed data
cfg=[];
cfg.viewmode   = 'vertical';
ft_databrowser(cfg,data_high_frequency);

%% implementation of sequential notch filters for 60 Hz harmonics within 80-500 Hz

% Notice that this is only for illustration since there is no severe
% powerline noise for the example data.
% Round-off errors will happen when further extending the length of filter
% coefficients (e.g., incorporating 60 Hz).
% Available solutions are based on (1) transformed second-order section (SOS)
% filter from zeros, poles, and gain of the filter (2) comb filter design

fs= data_example.fsample;

%% remove harmonics of 60Hz within [80 500]

notch_frequency_sequence=120:60:500;

% initialize filter coefficients
filter_notch_a=1;
filter_notch_b=1;

for count_notch=1:length(notch_frequency_sequence)
    % get current filter coefficients
    wg = [(notch_frequency_sequence(count_notch)-5)*2/fs, (notch_frequency_sequence(count_notch)+5)*2/fs]; % cut-off frequency 5Hz
    [b,a] = butter(2,wg,'stop');
    % combine notch filters by convolution
    filter_notch_a=conv(filter_notch_a,a);
    filter_notch_b=conv(filter_notch_b,b);

end

% plot ampltiude and phase response

figure;
freqz(filter_notch_b, filter_notch_a, 2000, fs);

%% perform notch filtering

current_data=data_high_frequency.trial{1, 1};
[num_channel,num_sample]=size(current_data);
filtered_data=filtfilt(filter_notch_b, filter_notch_a,current_data');

%% extract upper peak envelope with spline interpolation

fl=30; % set 30-sample intervals
envelope_sample=envelope(filtered_data,fl,'peak');


data_high_frequency.trial{1, 1}=envelope_sample';

% visualize signals after envelope extraction
cfg=[];
cfg.viewmode   = 'vertical';
ft_databrowser(cfg,data_high_frequency);

%% calculate skewness with 1 seond epoch

H_skewness=zeros(num_channel,10);


for i=1:10
    current_epoch=envelope_sample(fs*(i-1)+1:fs*i,:);
    H_skewness(:,i)=skewness(current_epoch);

end

figure;
imagesc(H_skewness)

bipolar_label=data_high_frequency.label;

xlabel('time/second')
set(gca,'xtick',1:10,'xticklabels',1:10,'FontSize',12,'FontWeight','bold')
set(gca,'ytick',1:length(bipolar_label),'yticklabels',bipolar_label,'FontSize',12,'FontWeight','bold')

%% calculate connectivity matrix based on rank correlation

connectivity_matrix=corr(H_skewness',H_skewness','type','Spearman');
for count_channel=1:num_channel
    connectivity_matrix(count_channel,count_channel)=0;
end

figure;
imagesc(abs(connectivity_matrix))
colorbar
set(gca,'xtick',1:length(bipolar_label),'xticklabels',bipolar_label,'FontSize',12,'FontWeight','bold')
set(gca,'ytick',1:length(bipolar_label),'yticklabels',bipolar_label,'FontSize',12,'FontWeight','bold')

%% calculate connectivity strength for epileptic tissue localization

connectivity_strength=sum(abs(connectivity_matrix));

connectivity_strength=normalize(connectivity_strength-mean(connectivity_strength),'range');

figure;
imagesc(connectivity_strength')
colorbar
set(gca,'ytick',1:length(bipolar_label),'yticklabels',bipolar_label,'FontSize',12,'FontWeight','bold')
