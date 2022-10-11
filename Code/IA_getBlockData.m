function IA_getBlockData(subNo,studyNo,base_directory)

pupildir = sprintf('%s/Data/%s/oddball_task/raw_pupils/',base_directory,studyNo);
eventdir = sprintf('%s/Analyses/%s/oddball_task/events/',base_directory,studyNo);
preprocdir = sprintf('%s/Analyses/%s/oddball_task/preprocessed_pupils/',base_directory,studyNo);

% make this an empty string if you don't want it to say '_oddball' (we want
% it to say this when study = study2!
oddballorno = '_oddball';

% get struct of subject data by block
blockData = struct;

% interpolation time for data-refitting
fs = 30;
numtrials = 160;
isi = 1.2;
blockseconds = numtrials*isi;
timesInterp = [0*1000:1000/fs:blockseconds*1000]';

for i=1:length(subNo)
    subnum = str2double(subNo{i}(1:3));
    if length(subNo{i}) > 3
        trial = subNo{i}(4:5);
    else
        trial='';
    end
    rawpupil = [pupildir, num2str(subnum), trial, oddballorno, '_raw.txt'];
    preproc_pupil = [preprocdir,subNo{i}, '_noEB_filt_10_lefteye.txt'];
    eventXml = [eventdir, subNo{i}, oddballorno, '-text.xml'];
    
    %read the pupil files, extract events
    [pupilData, events] = readPupilData(preproc_pupil,rawpupil);
    
    if ~isempty(pupilData)
        [values, timestamps] = XMLinfo(eventXml);

        % quick sanity check
        if max(size(events)) ~= max(size(values))
            error([char(10), char(10),...
                'Number of raw data User Events does not match the number of XML file events for subject ',...
                sub, '!!!', char(10), char(10)]);
        end
        
        [stimuli, responses, blocks, blockends] = eventsSplit(values, timestamps);
        
        while blocks(2) < blockends(1)
            blocks(1) = [];
        end
        if length(blocks) > length(blockends)
            blocks(end) = [];
        end
        
        for j=1:length(blocks)
            dataIdx = pupilData(:, 1) > blocks(j) & pupilData(:, 1) < blockends(j);
            stimIdx = stimuli(:, 1) > blocks(j) & stimuli(:, 1) < blockends(j);
            %currently taking and saving raw data
            data = pupilData(dataIdx,:);
            blockData.(['sub',subNo{i}]).(['block',num2str(j)]).data = data;
            blockData.(['sub',subNo{i}]).(['block',num2str(j)]).events = stimuli(stimIdx,:);
        end
        
    end
    
end

% save the data because this takes forever!!
save(sprintf('%s/Analyses/%s/oddball_task/IA_blockdata.mat',base_directory,studyNo),'blockData')

end