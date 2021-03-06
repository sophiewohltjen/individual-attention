function [rawTime, rawPupil, eventXml] = getFileNames(subNo,trial,base_directory,study)
%function [rawPupil, eventXml] = getFileNames(subNo)

%% Function to get file paths for a given subject number
%
% USAGE: [rawPupil, eventXml] = getFileNames(subNo)
%
% Input(s):
% subNo     -   subject number, single integer
%
% Output(s):
% rawPupil -    file path to the tab-delimited file containing the raw
%       pupil data (to be processed by readPupilData script)
% eventXml -    file path to the event xml file containing the details
%       of all user events (to be processed by XMLinfo script)
%
%


%% Base folders

%pupilBaseFolder = '/Users/sophie/Dropbox/IRF_modeling/data/raw/';
% uncomment if you want to use already preprocessed data
pupilBaseFolder = sprintf('%s/Analyses/%s/preprocessed_pupils/',base_directory,study);
timeBaseFolder = sprintf('%s/Data/%s/raw_pupils/',base_directory,study);
eventBaseFolder = sprintf('%s/Analyses/%s/events/',base_directory,study);

if all(ismember('study2',study))
    oddballorno = '_oddball';
else
    oddballorno = '';
end
%% Get file paths

% raw pupil data
% rawPupil = [pupilBaseFolder, num2str(subNo), '_oddball_raw.txt'];

if trial == 0

    % if you want the already preprocessed data
    if subNo > 99
        rawPupil = [pupilBaseFolder, num2str(subNo), '_noEB_filt_10_lefteye.txt'];
    elseif subNo > 9 && subNo < 100
        rawPupil = [pupilBaseFolder, '0', num2str(subNo), '_noEB_filt_10_lefteye.txt'];
    elseif subNo < 10
        rawPupil = [pupilBaseFolder, '00', num2str(subNo), '_noEB_filt_10_lefteye.txt'];
    end
    %for timestamps
    rawTime = [timeBaseFolder, num2str(subNo), oddballorno, '_raw.txt'];
    
    if subNo > 99
        eventXml = [eventBaseFolder, num2str(subNo), oddballorno, '-text.xml'];
    elseif subNo > 9 && subNo < 100
        eventXml = [eventBaseFolder, '0', num2str(subNo), oddballorno, '-text.xml'];
    elseif subNo < 10
        eventXml = [eventBaseFolder, '00', num2str(subNo), oddballorno, '-text.xml'];
    end
else
    % if you want the already preprocessed data
    if subNo > 99
        rawPupil = [pupilBaseFolder, num2str(subNo), '_', num2str(trial), '_noEB_filt_10_lefteye.txt'];
    elseif subNo > 9 && subNo < 100
        rawPupil = [pupilBaseFolder, '0', num2str(subNo), '_', num2str(trial), '_noEB_filt_10_lefteye.txt'];
    elseif subNo < 10
        rawPupil = [pupilBaseFolder, '00', num2str(subNo), '_', num2str(trial), '_noEB_filt_10_lefteye.txt'];
    end
    %for timestamps
    rawTime = [timeBaseFolder, num2str(subNo), '_',num2str(trial), oddballorno, '_raw.txt'];

    if subNo > 99
        eventXml = [eventBaseFolder, num2str(subNo), '_', num2str(trial), oddballorno, '-text.xml'];
    elseif subNo > 9 && subNo < 100
        eventXml = [eventBaseFolder, '0', num2str(subNo), '_', num2str(trial), oddballorno, '-text.xml'];
    elseif subNo < 10
        eventXml = [eventBaseFolder, '00', num2str(subNo), '_', num2str(trial), oddballorno, '-text.xml'];
    end
    
end

%% Sanity checks

if ~exist(rawPupil, 'file') || ~exist(eventXml, 'file')
    error('Cannot find the pupil or event file - check the path details in getFileNames.m!');
end


%% End, return

return