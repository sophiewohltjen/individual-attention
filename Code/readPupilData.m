function [pupilData, events] = readPupilData(datafile,timefile)
%function [pupilData, events] = readPupilData(datafile)

%% Function to read in raw pupil data file
%
% USAGE: 
% [pupilData, events] = readPupilData(datafile)
%
% Reads in the raw pupiil data files.
%
% Input(s):
% datafile  -   path to file, where file is a tab-delimited file with
%       columns (among others) 'Pupil_Diameter_Left_0x5Bmm0x5D',
%       'RecordingTime_0x5Bms0x5D' and 'Category_Binocular'
%
% Output(s):
% pupilData -   2-column matrix, with 1st column containing timestamps, and
%       the 2nd the left pupil diameter size
% events    -   2-column matrix, with 1st column containing timestamps, and
%       the 2nd the frame numbers of user events in the original data file
%


%% Input check, basics

if ~exist(datafile, 'file')
    error('Cannot find datafile');
end

% magic numbers, params
pupilField = 'Pupil_Diameter_Left_0x5Bmm0x5D';
timeField = 'RecordingTime_0x5Bms0x5D';
eventIdField = 'Category_Binocular';
eventId = 'User Event';

% user message
disp([char(10), 'Running readPupilData script on file at:',... 
    char(10), datafile]);


%% Read in data

%dataStruct = tdfread(datafile, '\t');
%for preprocessed data
dataStruct = tdfread(timefile, '\t');
preproc = load(datafile);

% check for necessary fields
% if ~isfield(dataStruct, pupilField) || ~isfield(dataStruct, timeField)
%     error('Data file does not contain the necessary pupil size or timestamps columns');
% end
%for preprocessed data
if ~isfield(dataStruct, timeField)
    error('Data file does not contain the necessary timestamps column');
end

% user message
disp('Read in pupil data');

%% Extract event timestamps and frame numbers
% frame numbers are quite unreliable as the frame numbers in the pupil data
% vector will change with the removal of event frames
% nevertheless, they are in the output in case one needs to find user
% events in the raw data

% frame numbers of user events
eventIds = find(contains(cellstr(dataStruct.(eventIdField)), eventId));
% corresponding timestamps
eventTimes = dataStruct.(timeField)(eventIds);
% put the two arrays into one matrix
events = [eventTimes, eventIds];

% user message
disp('Extracted user event frame ids with timestamps');

%% Extract pupil data with timestamps 

% preallocate
dataSize = max(size(dataStruct.(pupilField)));
%pupilData = zeros(dataSize, 2);
%if preprocessed
pupilData = zeros(dataSize, 3);

% copy timestamps into pupilData
pupilData(:, 1) = dataStruct.(timeField);

% create numeric array from pupil diameters, into
% pupilData matrix
% sadly, conversion to numeric is one string at a time
%start counter if doing preprocessed data
count=1;
for row = 1:dataSize
    % there is only a numeric value for non - User Event frames
    if ~contains(dataStruct.(eventIdField)(row, :), eventId)
        if length(preproc) < count
            pupilData(row, 2) = str2num(dataStruct.(pupilField)(row, :));
        else
            pupilData(row, 2) = str2num(dataStruct.(pupilField)(row, :));
            pupilData(row, 3) = preproc(count);
            count=count+1;
        end
    end
end
if ~isempty(pupilData)
    % user message
    disp('Extracted pupil data with timestamps');


    %% Extract event timestamps and frame numbers
    % % frame numbers are quite unreliable as the frame numbers in the pupil data
    % % vector will change with the removal of event frames
    % % nevertheless, they are in the output in case one needs to find user
    % % events in the raw data
    % 
    % % frame numbers of user events
    % eventIds = find(contains(cellstr(dataStruct.(eventIdField)), eventId));
    % % corresponding timestamps
    % eventTimes = dataStruct.(timeField)(eventIds);
    % % put the two arrays into one matrix
    % events = [eventTimes, eventIds];
    % 
    % % user message
    % disp('Extracted user event frame ids with timestamps');


    %% Delete user events from pupil data matrix

    pupilData(eventIds, :) = [];

    % user message
    disp('Deleted user event frames from pupil data matrix');

end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Whole-data preprocessing steps to be added here (?) %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% End, return

return
    
    
    


