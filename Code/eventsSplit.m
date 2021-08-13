function [stimuli, responses, blocks, blockends] = eventsSplit(values, timestamps)

%% Function to further split the events extracted from the xml files
%
% USAGE: [stimuli, responses, blocks] = eventsSplit(values, timestamps)
%
% Extracts stimuli events, key press (response) events and block starts
% from the xml file events processed by XMLinfo. Outputs contain the
% timestamps corresponding to each event.
%
% Input(s):
% values    -   "values" output of XMLinfo, a cell array where each cell
%   contains the details of an user event in the pupil data file (e.g. '10,
%   2, 154321.21' - trial number, trial type and timestamp)
% timestamps -  "timestamps" output of XMLinfo, a vector of timestamps
%   corresponding to the events in "values". Same type of timing data as in
%   the raw pupil data file
%
% Output(s):
% stimuli -     2-column matrix, with 1st column containing timestamps, and
%   the 2nd the trial type (stimulus type)
% responses -   1-column matrix, with 1st column containing timestamps for
%   key presses
% blocks -      1-column matrix, with 1st column containing timestamps for
%   block starts
%
%

%% Input checks

if ~iscolumn(values) || ~iscell(values)
    error('Input arg "values" needs to be a column cell array');
end

if ~iscolumn(timestamps) || ~isnumeric(timestamps)
    error('Input arg "timestamps" needs to be a numeric column vector');
end

if ~isequal(size(values), size(timestamps))
    error('Input args "values" and "timestamps" need to have same size');
end


disp([char(10), 'Called eventsSPlit script']);


%% Basics, params, magic numbers

% string identifiers of block and response events
blockStart = 'Start time for';
keyPress = 'Key press at';
lastTrial = '160,';


%% Get block start and response timestamps

blocks = timestamps(contains(values, blockStart));
blockends = timestamps(contains(values,lastTrial));
responses = timestamps(contains(values, keyPress));


%% Get stimulus types and onset timestamps

% delete "values" and "timestamps" cells containing block start 
% or key press events
blocksORresponses = contains(values, blockStart) | contains(values, keyPress);
values(blocksORresponses) = [];
timestamps(blocksORresponses) = [];

% the remaining values can be split into three numeric elements, trial
% number, trial type and timestamp
% for splitting we loop through each cell, split the content, and apply
% str2num to each resulting cell
stimNo = max(size(values));
valueElements = zeros(stimNo, 3);
for stim = 1:stimNo
    valueElements(stim, :) = (cellfun(@str2num, split(values{stim}, ',')))'; % comma delimiter
end

% get stimulus types and timestamps into output variable
stimuli = [timestamps, valueElements(:,2)];

disp(['Extracted block start and response timestamps, ',... 
    char(10), 'also the stimulus types with corresponding timestamps']);


%% End, return

return







