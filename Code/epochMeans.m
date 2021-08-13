
%% Script for loading epoched pupil data and plotting across-subject means
%
% This is more of a sketchbook than a proper script. We simply load data,
% appply various processing steps and plot the group-level results.
%


%% Basics

% title for specifying what we do in current iteration
% CHECK THIS!
%titleText = 'Rejection of values < 2, zscored, baselined';

% baseline length in time (sec)
pre = 1; 
% trial data length after stimulus onset (epoch length), time in secs
post = 3;
% sampling frequency 
sampRate = 30;
% epoch length
epochL = pre*sampRate + post*sampRate + 1;
epochTimesInterp = [-pre*1000:1000/sampRate:post*1000]';

% if you're only doing a single subject, which one is it?
subj = '039';
%titleText = sprintf('%s Rejection of values < 2, zscored, baselined',subj);

% subjects we can load (we have epoched data for)
subjects = str2double(subj(1:3));
trial=0;
if contains(subj,'_')
    trial = str2double(subj(5));
end
% subjects = [1,3,5,8:18,21:23,27:32,34,36:39,53:61,63:65,67:73,75,77:80,...
%     82,83,86:90,92:97,100:102,106];

%are we getting means from the whole sample or a single subject?
group =0;

subNo = max(size(subjects));
% trial (stimulus) types
fields = {'standard', 'oddball', 'omission', 'novel','rt_onset','acc_oddball'};

% values for data rejection (turning them into nan)
% CHECK THIS!
minPupil = 2;
maxPupil = 10;

% preallocate results struct
subjectMeans = struct;
for field = 1:length(fields)
    trialMean.(fields{field}) = zeros(subNo, epochL);
end


%% Loop through subjects

subCounter = 0;
studytype = 'IRF';
for sub = subjects

    subCounter = subCounter+1;
    
    % load subject data file
    if trial == 0
        fileN = ['/Users/sophie/Dropbox/IRF_modeling/data/epochs/',studytype,'/trialData_',... 
            subj,'.mat'];
                %num2str(sub), '_3_3.mat'];
    else
        % for repIRF
        fileN = ['/Users/sophie/Dropbox/IRF_modeling/data/epochs/',studytype,'/trialData_',... 
                num2str(sub),'_', num2str(trial), '.mat'];
    end
    load(fileN);
    
    % get number of samples to take from each subject based on how many
    % omission trials there are
    ntrials = size(trialData.omission,1);
    %do we want to take a random sample?
    randsamp=0;
   
    
    %% Loop through stimulus (trial) type
    for field = 1:length(fields)
    
        % get mean values for each stimulus type with very minimal processing
        data = trialData.(fields{field});
        
        % get rid of very low values?
        data(data<minPupil) = nan;
%         
%         % get rid of very high values?
%         data(data>maxPupil) = nan;
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       DO NOT APPLY HERE (?) BUT BEFORE EOPCHING (ALSO NEED TO REJECT
%       BLINK / LOW VALUE FRAMES BEFOREHAND THEN) 
        % z-score?
        trialNo = size(data, 1);
        for trial = 1:trialNo
            data(trial, :) = (data(trial, :)-nanmean(data(trial, :)))/nanstd(data(trial, :)) ;
        end      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % subtract baseline? CURRENTLY SUBTRACTING BASELINE OF 30 SECS
        % PRIOR ONLY
        trialNo = size(data, 1);

        for trial = 1:trialNo
            %baseline_half = nanmean(data(trial, 1:((pre*sampRate)-(pre*sampRate/2)+1)));
            baseline_whole = nanmean(data(trial, 1:((pre*sampRate)+1)));
            data(trial, :) = data(trial, :) - baseline_whole;
        end
        % take random sample 
        if randsamp == 1
            data = datasample(data,ntrials,'Replace',false);
        end
        
        %calculate percentage of data missing
        nancount = length(find(isnan(data)));
        %disp(nancount)
        %let us know if more than 50% of trial data is missing
        if nancount > (size(data,1)*size(data,2))/2
            disp(nancount/(size(data,1)*size(data,2)))
            disp(size(data,1) - length(find(any(isnan(data),2))));
            disp([fields{field},' data is more than 50% missing!'])
        end
        
        % mean
        subjectMeans.(fields{field})(subCounter, :) = nanmean(data, 1);
        
        allTrials.(fields{field}) = data;
        
    end
    
end

%% do we want individual or group level means?

if group==1       
    % group-level means and SE        

    m = subjectMeans; se = subjectMeans;

    for field = 1:length(fields)

        m.(fields{field}) = nanmean(subjectMeans.(fields{field}), 1);
        se.(fields{field}) = nanstd(subjectMeans.(fields{field}), 1)/(subNo^0.5);
    end
else
    m = subjectMeans; se = allTrials;

    for field = 1:length(fields)

        m.(fields{field}) = nanmean(subjectMeans.(fields{field}), 1);
        se.(fields{field}) = nanstd(allTrials.(fields{field}), 1)/(size(allTrials.(fields{field}),1)^0.5);
    end
end


%% Plotting
% plot all stimulus (trial) types with SE ribbons on the same figure

% common time axis for all parts
% NOTE that due to the slight interpolation step performed in stimData.m 
% the very first and last frames can be relatively extreme, we do not want
% to see them
% Same applies to the pupil data vectors (see below)
x = epochTimesInterp(2:end-1)'; 

% figure handle, background
hf = figure('DefaultAxesFontSize',15); % Open figure and keep handle
hf=colordef(hf,'white'); % Set color scheme
hf.Color='w'; % Set background color of figure window

% plot standard
p1 = plot(x, m.standard(2:end-1), 'b-', 'LineWidth', 2); 
hold on;
patchSE = [m.standard(2:end-1)-se.standard(2:end-1); m.standard(2:end-1)+se.standard(2:end-1)];
pStandard = patch([x, fliplr(x)], [patchSE(1, :), fliplr(patchSE(2, :))], [0.2, 0.2, 0.8]);
pStandard.FaceVertexAlphaData = 0.2; % make it transparent
pStandard.FaceAlpha = 'flat' ; % make it transparent

% plot oddball
% p2 = plot(x, m.oddball(2:end-1), 'r-', 'LineWidth', 2);
% hold on;
% patchSE = [m.oddball(2:end-1)-se.oddball(2:end-1); m.oddball(2:end-1)+se.oddball(2:end-1)];
% pOddball = patch([x, fliplr(x)], [patchSE(1, :), fliplr(patchSE(2, :))], [0.8, 0.2, 0.2]);
% pOddball.FaceVertexAlphaData = 0.2;
% pOddball.FaceAlpha = 'flat' ;

% % plot omission
p4 = plot(x, m.omission(2:end-1), 'g-', 'LineWidth', 2);
patchSE = [m.omission(2:end-1)-se.omission(2:end-1); m.omission(2:end-1)+se.omission(2:end-1)];
pOmission = patch([x, fliplr(x)], [patchSE(1, :), fliplr(patchSE(2, :))], [0.2, 0.8, 0.2]);
pOmission.FaceVertexAlphaData = 0.2;
pOmission.FaceAlpha = 'flat' ;
% % 
% % % plot novel
p5 = plot(x, m.novel(2:end-1), 'k-', 'LineWidth', 2);
patchSE = [m.novel(2:end-1)-se.novel(2:end-1); m.novel(2:end-1)+se.novel(2:end-1)];
pNovel = patch([x, fliplr(x)], [patchSE(1, :), fliplr(patchSE(2, :))], [0.8, 0.8, 0.8]);
pNovel.FaceVertexAlphaData = 0.2;
pNovel.FaceAlpha = 'flat' ;

% % plot rt_onset
% p5 = plot(x, m.rt_onset(2:end-1), 'c-', 'LineWidth', 2);
% patchSE = [m.rt_onset(2:end-1)-se.rt_onset(2:end-1); m.rt_onset(2:end-1)+se.rt_onset(2:end-1)];
% prt = patch([x, fliplr(x)], [patchSE(1, :), fliplr(patchSE(2, :))], [0.2, 0.8, 0.8]);
% prt.FaceVertexAlphaData = 0.2;
% prt.FaceAlpha = 'flat' ;

% plot acc_oddball
p6 = plot(x, m.acc_oddball(2:end-1), 'r-', 'LineWidth', 2);
patchSE = [m.acc_oddball(2:end-1)-se.acc_oddball(2:end-1); m.acc_oddball(2:end-1)+se.acc_oddball(2:end-1)];
pNovel = patch([x, fliplr(x)], [patchSE(1, :), fliplr(patchSE(2, :))], [0.8, 0.2, 0.2]);
pNovel.FaceVertexAlphaData = 0.2;
pNovel.FaceAlpha = 'flat' ;

% plot details
%legend([p1, p2, p3, p4, p5], 'standard', 'oddball', 'omission', 'novel', 'rt onset', 'Location', 'northwest');
legend([p1,p4, p5, p6], 'standard','omission', 'novel', 'oddball - accurate responses','Location', 'northwest');
legend([p1, p6], 'Standard','Deviant','Location', 'northeast');
legend boxoff
box off
ylabel('Standardized left pupil diameter','FontSize',20);
xlabel('Time relative to stimulus onset (ms)','FontSize',20);
% titleText = "Standard Trials";
% title(titleText);
hold off;
        
%% save n and tmax and width values for pupils

% oddball
% time when stimulus was presented 
stimOnset = find(epochTimesInterp == min(abs(epochTimesInterp)));
% indices + time of start of dilation
tFirst_ind  = find(subjectMeans.omission(stimOnset:end) > 0,1,'first')+(stimOnset-1);
tFirst = epochTimesInterp(tFirst_ind);
% indices + time of end of dilation
tLast_ind  = find(subjectMeans.omission(tFirst_ind:end) < 0,1,'first')+(tFirst_ind-1);
%tLast_ind = length(subjectMeans.oddball);
tLast = epochTimesInterp(tLast_ind);
% indices of peak pupil dilation
tMax_ind  = find(subjectMeans.omission(tFirst_ind:tLast_ind) == max(subjectMeans.omission(tFirst_ind:tLast_ind)))+(tFirst_ind-1);
% amplitude of dilation
n = subjectMeans.omission(tMax_ind);
% time to peak
tMax = epochTimesInterp(tMax_ind);
% full time of dilation
t = tLast-tFirst;

        
        
        