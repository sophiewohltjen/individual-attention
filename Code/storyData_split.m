%% storyData_split.m

% script to separate pupil time series into separate time series for 
% individual stories. output is 4 separate story files per subject, with 3
% data columns: 

% column 1 = time (starting from zero, not from however long the eye
% tracker had been recording up to that point)
% column 2 = mean-centered pupil time series
% column 3 = true size pupil time series (values in mm)

%% step 1. grab files

filedir = '/Users/sophie/Dropbox/IRF_modeling/data/preprocessed/listen';
eventdir = '/Users/sophie/Dropbox/IRF_modeling/data/events/listen';
timedir = '/Users/sophie/Dropbox/IRF_modeling/data/raw/listen';
storydir = '/Users/sophie/Dropbox/IRF_modeling/data/listen_indivTrials/scriptTest';
files = dir(sprintf('%s/*',filedir));
filenames = {files(4:end).name};

for file=1:length(filenames)
    
    sub = filenames{file}(1:3);
    
    %use raw pupil file to get timestamps from SMI
    timefile = sprintf('%s/%s_listen_raw.txt',timedir,sub);
    %preprocessed pupil data file name
    datafile = sprintf('%s/%s',filedir,filenames{file});
    
    % read in pupil data and events from raw data
    [pupilData, rawEvents] = readPupilData(datafile,timefile);
    
    % read in events file from preprocessing script
    events = load(sprintf('%s/%s_listenevents.txt',eventdir,sub));
    
    % read in events from SMI xml file 
    [values, timestamps] = XMLinfo(sprintf('%s/%s_listen-text.xml',eventdir,sub));
    
    % quick sanity check
    if ~isequal(length(events),length(timestamps),length(rawEvents))
        error([char(10), char(10),...
            'Number of raw data User Events does not match the number of XML file events for subject ',...
            sub, '!!!', char(10), char(10)]);
    end
    
    % get details from xml data
    [starts,ends] = eventsSplit_listen(values, timestamps);
    
    % make sure we have starts and ends for all stories
    if size(starts,1) ~= size(ends,1)
        missingstarts = find(~ismember(ends(:,2),starts(:,2)));
        missingends = find(~ismember(starts(:,2),ends(:,2)));
        fprintf('Subject %d is missing %d story starts and %d story ends.',...
            sub,len(missingstarts),len(missingends))
        
        % chop the starts/ends that aren't complete
        if missingends
            starts(starts(:,2) == missingends,:) = [];
        end
        if missingstarts
            ends(ends(:,2) == missingstarts,:) = [];
        end
    end
    
    [story3, story15, story16, story17] = getStories(starts,ends,pupilData,sub);
    
    % here add time vector and mean-centered pupil diameter and output to
    % a new text file!
    if ~isempty(story3)
        writeStory(story3,3,sub,storydir);
    end
    if ~isempty(story15)
        writeStory(story15,15,sub,storydir);
    end
    if ~isempty(story16)
        writeStory(story16,16,sub,storydir);
    end
    if ~isempty(story17)
        writeStory(story17,17,sub,storydir);
    end

    
end

