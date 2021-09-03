%% IA_finalVarCalculation.m

% This script will take event/behavior data from the oddball task
% and pupillometry data from the oddball task and calculate the following:

% 1. amplitude and tmax (features of attention related pupil response)
% 2. values needed to evaluate dprime (measure of task performance)
% 3. reaction time 
% 4. ISI and DSI entrainment power

% NOTE this script is only used in the calculation of variables for studies
% two and three!

% Sophie Wohltjen, 9/21

%% first, define variables

base_directory = '/Users/sophie/Dropbox/IRF_modeling/individual-attention';

stimtypes = {'acc_oddball','omission','standard','novel'};

subNo = {'001','002','003','005','008','009','010','011','012','013','014','015','016',...
        '017','018','021','022','023','027','028','029','030','031','032',...
        '034','036','037','038','039','053','054','055','056','057','058','059',...
        '060','061','063','064','065','067','068','069','070','071','072','073',...
        '075','077','078','079','080','081','082','083','084','086','087','088','089','090',...
        '092','093','094','095','096','097','100','101','102','106'};
    
datatable = table('Size',[length(subNo)*4 14],...
    'VariableTypes',{'string','string','double','double','double',...
    'double','double','double','double','double','double',...
    'double','double','double'},...
    'VariableNames',{'subject','condition','amplitude','tmax','rt',...
    'n_targets','n_hit','n_miss','n_distractors','n_fa','n_cr',...
    'isi_power','oddball_power','powerSum'});
subjects = repelem({subNo},4);
datatable.subject = [subjects{:}]';
datatable.condition = repelem(stimtypes,length(subNo))';
    
%% calculate amplitude and tmax
amplitudes = [];
tmaxes = [];
for i=1:length(stimtypes)
    IRFs = readtable(sprintf('%s/Analyses/study2/IA_%smeans.csv',base_directory,stimtypes{i}));
    % what was the amplitude of their pupil response?
    amplitude = max(table2array(IRFs),[],1)';
    % what was the time needed to get to their peak response?
    [tmaxr,tmaxc] = find(table2array(IRFs) == max(table2array(IRFs),[],1));
    tmax = (tmaxr - 30)/30 * 1000;
    
    %now save the values to a final array for the datatable
    amplitudes = cat(1,amplitudes,amplitude);
    tmaxes = cat(1,tmaxes,tmax);
end

datatable.amplitude = amplitudes;
datatable.tmax = tmaxes;

%% calculate RT and values needed to evaluate dprime 

for i=1:length(subNo)
    if subNo{i} == '002'
        n_targets(i) = 137;
        n_hit(i) = 131;
        n_miss(i) = n_targets(i) - n_hit(i);
        
        n_distractors(i) = 800 - n_targets(i);
        n_fa(i) = 6;
        n_cr(i) = n_distractors(i) - n_fa(i);
    else
    
        %load data in
        cd(sprintf('%s/Data/study2/experiment_logs/Sub%s_trialn160_blockn5',base_directory,subNo{i}));
        load(sprintf('results_sub%s_block5.mat',subNo{i}));
        load(sprintf('trialTable_%s_160_5.mat',subNo{i}));
        %load trialData in
        fileN = [base_directory,'/Analyses/study2/preprocessed_pupil_epochs/trialData_',... 
            subNo{i},'.mat'];
        load(fileN);

        %format trial & rt data correctly
        trials_long = reshape(trials,160*5,1);
        rt_long = reshape(rt,160*5,1);

        %get all data for d' calculation
        rt_oddball = rt_long(find(trials_long == 2));
        rt_oddball_mean(i) = nanmean(rt_oddball);
        n_targets(i) = length(find(trials_long == 2));
        n_hit(i) = length(find(~isnan(rt_oddball)));
        n_miss(i) = n_targets(i) - n_hit(i);
        
        rt_other = rt_long(find(trials_long ~= 2));
        n_distractors(i) = length(find(trials_long~=2));
        n_fa(i) = length(find(~isnan(rt_other)));
        n_cr(i) = n_distractors(i) - n_fa(i);
    end
end

rts = repelem({rt_oddball_mean},4);
datatable.rt = [rts{:}]';

targets = repelem({n_targets},4);
datatable.n_targets = [targets{:}]';

hits = repelem({n_hit},4);
datatable.n_hit = [hits{:}]';

misses = repelem({n_miss},4);
datatable.n_miss = [misses{:}]';

distractors = repelem({n_distractors},4);
datatable.n_distractors = [distractors{:}]';

fas = repelem({n_fa},4);
datatable.n_fa = [fas{:}]';

crs = repelem({n_cr},4);
datatable.n_cr = [crs{:}]';

%% calculate entrainment power at ISI and DSI

% extracting the block data takes forever, so I've saved it for speed
if ~exist(sprintf('%s/Analyses/study2/IA_blockdata.mat',base_directory))
    IA_getBlockData(subNo,base_directory)
end

% preprocess blocks according to Naber, et al.
load(sprintf('%s/Analyses/study2/IA_blockdata.mat',base_directory))

subs = fields(blockData);
%values for interpolation
pre=10;
post=10;
buffer=2;

for i=1:length(subs)
    blocks = fields(blockData.(subs{i}));
    for j=1:length(blocks)
        block_copy = blockData.(subs{i}).(blocks{j}).data(:,2);
        block_time = blockData.(subs{i}).(blocks{j}).data(:,1);
        block_stims = blockData.(subs{i}).(blocks{j}).events(:,1);
        
        % cubic spline over the blinks
        blinks = block_copy == 0;
        xx = [1:length(blinks)];
        x = xx(blinks == 0);
        splinedata = block_copy(blinks == 0);
        yy = spline(x,splinedata,xx);

        %highpass filter
        block_hpass = highpass(yy,0.11,30);
        %perform fft on data
        samples = length(block_hpass);
        [p,f] = periodogram(yy,hamming(samples),samples,30);
        %save up to 5hz
        powers(i,j,:) = p(1:570);
        
        stimidx = zeros(length(block_stims),1);
        for k=1:length(block_stims)
            [val,idx] = min(abs(block_stims(k)-block_time));
            stimidx(k) = idx;
        end
        
        %add them back into the struct so we can mess around with them
        blockData.(subs{i}).(blocks{j}).data(:,4) = yy;
        blockData.(subs{i}).(blocks{j}).data(:,6) = block_hpass;
        blockData.(subs{i}).(blocks{j}).events(:,3) = stimidx;
    end
end

% zscore power

power_zscore = zeros([size(powers,1),size(powers,3)]);
power_freqband_zscore = zeros([size(powers,1),size(powers,3)]);
power_mean = zeros([size(powers,1),size(powers,3)]);

allpowermean = squeeze(mean(mean(powers)));
freqbands = [0.1:1/10:2];

for sub=1:size(powers,1)
    powermean = squeeze(mean(powers(sub,:,:)));
    powerdiff = powermean - allpowermean;
    powerz = zscore(powermean);
    powerz_freqband = zeros([length(powerz),1]);
    for band=1:length(freqbands)
        freq_idx = find(f > freqbands(band)-0.1 & f < freqbands(band)+0.1);
        freq_z = zscore(powermean(freq_idx));
        powerz_freqband(freq_idx) = freq_z;
    end
    power_zscore(sub,:) = powerz;
    power_freqband_zscore(sub,:) = powerz_freqband;
    power_mean(sub,:) = powermean;
end
power_zscore_short = power_freqband_zscore(:,1:386);

% get power per subject at 0.208 and 0.83hz

isi_power = zeros([1,size(powers,1)]);
oddball_power = zeros([1,size(powers,1)]);

for sub=1:size(powers,1)
    isi_power(sub) = power_freqband_zscore(sub,161);
    oddball_power(sub) = power_freqband_zscore(sub,41);
end

total_power = isi_power+oddball_power;

% add to datatable
isipow = repelem({isi_power},4);
datatable.isi_power = [isipow{:}]';

oddpow = repelem({oddball_power},4);
datatable.oddball_power = [oddpow{:}]';

totpow = repelem({total_power},4);
datatable.powerSum = [totpow{:}]';

%% write everything to a csv for statistics in R
writetable(datatable,sprintf('%s/Analyses/study2/IA_allData.csv',base_directory));
