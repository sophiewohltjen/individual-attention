function pupilGlue(subNo)

%% Function to glue together pupil data processing scripts
%
% USAGE: pupilGlue(subNo)
% 
% The script invokes various pupil (pre-)processing functions on a range of
% subjects, as provided by the input argument
% This description is vague because the script is expected to be edited
% frequently.
%
% Input(s):
% subNo -   vector of subject numbers
%
% Output(s):
% Saves out results into a trialData_(subject number).mat file for each
% subject.
% Check the output folder before using the script.
%


%% Input checks

if ~isvector(subNo)
   error('Input arg "subNo" needs to be a vector of subject numbers');
end

% we need a row vector
if iscolumn(subNo)
    subNo = subNo';
end


%% Baiscs, magic numbers, params

%change if project folder changes
base_directory = '/Users/sophie/Dropbox/IRF_modeling/individual-attention';
study = 'study1';

% epoching temporal boundaries in secs, relative to stimulus onset
pre = 1; % baseline
post = 3; % trial data length following stimulus onset

% folder for result mat files
folder = sprintf('%s/Analyses/%s/preprocessed_pupil_epochs/',base_directory,study);


%% Loop through subjects

for sub = subNo
    
    sub = cell2mat(sub);

    disp([char(10), char(10), 'Processing steps for subject ', sub]);
    
    % save file
    %saveF = [folder, 'trialData_', sub, '_',num2str(pre),'_',num2str(post),'.mat'];
    saveF = [folder, 'trialData_', sub,'.mat'];
    
    
    %% filenames, loading data
    if ~all(ismember('study1',study))
        %for anything else: 
        [rawTime, rawPupil, eventXml] = getFileNames(str2double(sub(1:3)),0,base_directory,study);
    else
        %for repIRF:
        [rawTime, rawPupil, eventXml] = getFileNames(str2double(sub(1:3)),str2double(sub(5)),base_directory,study);
    end

    %[pupilData, events] = readPupilData(rawPupil);
    % with preprocessed data
    [pupilData, events] = readPupilData(rawPupil,rawTime);

    if ~isempty(pupilData)
        [values, timestamps] = XMLinfo(eventXml);

        % quick sanity check
        if max(size(events)) ~= max(size(values))
            warning([char(10), char(10),...
                'Number of raw data User Events does not match the number of XML file events for subject ',...
                sub, '!!!', char(10), char(10)]);
        end




        %% get event details

        [stimuli, responses, blocks] = eventsSplit(values, timestamps); % responses and blocks are not used at the moment, left them in for later variations


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%% PLACE FOR PREPROCESSING STEPS ON pupilData BEFORE EPOCHING ??  %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %% epoching

        trialData = stimData(pupilData, stimuli, pre, post,responses);


        %% save epoch data

        save(saveF, 'trialData');

        disp([char(10), 'Finished with subject ', sub, char(10)]);
    end
    
    
end
    
    
    

