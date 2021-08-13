function trialData = stimData(pupilData, stimuli, pre, post, responses)

%% Function to extract pupil data for each trial (epoching)
%
% USAGE: trialData = stimData(pupilData, stimuli, pre, post)
%
% For each stimulus, pupil data is extracted from the whole, continuous
% data set. "Pre" and "post" determine the time window for pupil data
% relative to stimulus onset (baseline and pupil response window). 
%
% Input(s):
% pupilData     -   2-column matrix, with 1st column containing timestamps,
%       and the 2nd the left pupil diameter size
% stimuli       -   2-column matrix, with 1st column containing timestamps,
%       and the 2nd stimulus (trial) type
% pre           -   baseline length in time (sec)
% post          -   trial data length after stimulus onset (epoch length)
%       in time (secs)
%
% Output(s):
% trialData     -   struct with separate fields for all stimulus types 
%       (standard, oddball, omission and novel). Each field is a 2D matrix
%       with a separate row of pupil data for each trial.
%
% 


%% Input checks

% if ~isnumeric(pupilData) || size(pupilData, 2) ~= 2
%     error('Input arg "pupilData" needs to be a frames-by-2 matrix');
% end
%for preprocessed data
if ~isnumeric(pupilData) || size(pupilData, 2) ~= 3
    error('Input arg "pupilData" needs to be a frames-by-3 matrix');
end
if ~isnumeric(stimuli) || size(stimuli, 2) ~= 2
    error('Input arg "stimuli" needs to be a frames-by-2 matrix');
end
if ~isnumeric(pre) || ~isnumeric(post) || ~isequal(size(pre), [1, 1]) || ~isequal(size(pre), [1, 1])
    error('Input args "pre" and "post" need to be single numeric values');
end

disp([char(10), 'Called stimData script for epoching pupil data']);


%% Basics, params

% sampling frequency 
sampRate = 30;

% indices of different stimulus types
idx = struct;
idx.standard = find(stimuli(:, 2)==1);
idx.oddball = find(stimuli(:, 2)==2);
idx.omission = find(stimuli(:, 2)==3);
idx.novel = find(stimuli(:, 2)>3);

% epoch length
% the extra two is due to the interpolation done later:
% since stimulus is not fixed relative to sampling times,
% and sampling rate is not perfectly 30 Hz,
% we have sometimes 120, sometimes 121 datapoints for epochs. We do
% pievewise shape-preserving cubic interpolation to get all data on the same
% time-grid
epochL = pre*sampRate + post*sampRate + 1;
epochTimesInterp = [-pre*1000:1000/sampRate:post*1000]';

% output variables definition
trialData = struct;
fields = fieldnames(idx); % get field names from idx, see above
for fieldNo = 1:length(fields) % for each field name, create the same field in the output variables
    trialData.(fields{fieldNo}) = zeros(max(size(idx.(fields{fieldNo}))), epochL);
end
trialData.rt_onset = zeros(max(size(idx.(fields{fieldNo}))), epochL);
trialData.acc_oddball = zeros(max(size(idx.(fields{fieldNo}))), epochL);

%% Loop through stimulus types

for fieldNo = 1:length(fields)
    
    disp(['Going through ', fields{fieldNo}, ' trials']);
    
    % get the number of stimuli for given category
    stimNo = max(size(idx.(fields{fieldNo})));

    
    %% Loop through stimuli
    for stim = 1:stimNo
    
        % stimulus index in pupil data for given stimulus (trial) type and
        % stimulus number
        stimIdx = idx.(fields{fieldNo})(stim);
        
        % temporal bounds around the stimulus onset
        bounds = [stimuli(stimIdx, 1)-pre*1000, stimuli(stimIdx, 1)+post*1000];
        
        % pupil data indices corresponding to the temporal bounds around stimulus
        % onset
        dataIdx = pupilData(:, 1) > bounds(1) & pupilData(:, 1) < bounds(2);
%         epochData = pupilData(dataIdx, 2);
        % if using preprocessed data
        epochData = pupilData(dataIdx, 3);
        
        % timestamps of the pupil data extracted for the trial, relative to
        % stimulus onset
        epochTimes = pupilData(dataIdx, 1)-stimuli(stimIdx, 1);
        
        % we need to interpolate, see the reasoning above, at the epoch
        % length part in Basics
        epochDataInterp = interp1(epochTimes, epochData, epochTimesInterp, 'pchip');
        
        % save data into output vvariable
        trialData.(fields{fieldNo})(stim, :) = epochDataInterp';
                        
    end
    
end

%now collect pupil responses for times when subjects pushed the space bar,
%timed around their reaction rather than stimulus onset

disp('Going through reaction-oriented trials');
for response = 1:length(responses)
    
    % temporal bounds around the stimulus onset
    bounds = [responses(response)-pre*1000, responses(response, 1)+post*1000];
    
    % pupil data indices corresponding to the temporal bounds around stimulus
    % onset
    dataIdx = pupilData(:, 1) > bounds(1) & pupilData(:, 1) < bounds(2);
    
    % if using preprocessed data
    epochData = pupilData(dataIdx, 3);
    
    % timestamps of the pupil data extracted for the trial, relative to
    % stimulus onset
    epochTimes = pupilData(dataIdx, 1)-responses(response, 1);
    
    % we need to interpolate, see the reasoning above, at the epoch
    % length part in Basics
    epochDataInterp = interp1(epochTimes, epochData, epochTimesInterp, 'pchip');
    
    % save data into output vvariable
    trialData.rt_onset(response, :) = epochDataInterp';
end

%NOW collect pupil responses for times when subjects pushed the space bar,
%for an oddball, timed around stimulus onset

disp('Going through accurate oddball trials');

%find all the stimulus onsets where subjects reacted and pressed the space
%bar
allonsets = interp1(unique(stimuli(:,1)),unique(stimuli(:,1)),responses,'previous');
%contingency for if an oddball was the last trial
if isnan(allonsets(end))
    allonsets(end) = stimuli(end,1);
end
%contingency for if allonsets contains duplicates
allonsets = unique(allonsets);
%add the trial type information for later comparison
allonsets(:,2) = stimuli(find(ismember(stimuli(:,1),allonsets)),2);
%extract only the oddball trials with a reaction
acc_oddball_onsets = allonsets(allonsets(:,2) == 2,1);

for onset = 1:length(acc_oddball_onsets)
    
    % temporal bounds around the stimulus onset
    bounds = [acc_oddball_onsets(onset)-pre*1000, acc_oddball_onsets(onset, 1)+post*1000];
    
    % pupil data indices corresponding to the temporal bounds around stimulus
    % onset
    dataIdx = pupilData(:, 1) > bounds(1) & pupilData(:, 1) < bounds(2);
    
    % if using preprocessed data
    epochData = pupilData(dataIdx, 3);
    
    % timestamps of the pupil data extracted for the trial, relative to
    % stimulus onset
    epochTimes = pupilData(dataIdx, 1)-acc_oddball_onsets(onset, 1);
    
    % we need to interpolate, see the reasoning above, at the epoch
    % length part in Basics
    epochDataInterp = interp1(epochTimes, epochData, epochTimesInterp, 'pchip');
    
    % save data into output vvariable
    trialData.acc_oddball(onset, :) = epochDataInterp';
end

%% End, return
disp('Finished with all trial types');

return










