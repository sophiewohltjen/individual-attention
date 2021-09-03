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

%for study 2, subNo is:
% subNo = {'001','002','003','005','006','008','009','010','011','012','013',...
% '014','015','016','017','018','021','022','023','027','028','029','030','031',...
% '032','033','034','036','037','038','039','053','054','055','056','057','058',...
% '059','060','061','062','063','064','065','066','067','068','069','070','071',...
% '072','073','074','075','076','077','078','079','080','081','082','083','084',...
% '086','087','088','089','090','091','092','093','094','095','096','097','098','100',...
% '101','102','103','105','106'};
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
study = 'study2';

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
    
    
    

