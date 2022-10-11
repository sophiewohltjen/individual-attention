function pupilGlue(subNo,pre,post)

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
% pre - number of seconds before stimulus onset (for main analysis, this is 1)
% post - number of seconds after stimulus onset (for main analysis, this is 3)

%for study 1, subNo is: 
% subNo = {'107_1','107_2','107_3','107_4','107_5','107_6','107_7','107_9',...
%     '108_2','108_3','108_7','108_8','109_1','109_2','109_3','109_4','109_5',...
%     '109_6','109_7','109_8','109_9','110_1','110_2','110_4','110_5',...
%     '110_6','110_7','110_8','110_9','111_1','111_2','111_3','111_4','111_5',...
%     '111_6','111_7','111_9','112_1','112_2','112_3','112_4','112_5','112_6',...
%     '112_7','112_9','113_1','113_2','113_3','113_4','113_5','113_6','113_7',...
%     '113_8','113_9','114_1','114_2','114_3','114_4','114_5','114_6','114_7'};

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



% folder for result mat files
folder = sprintf('%s/Analyses/%s/oddball_task/preprocessed_pupil_epochs/',base_directory,study);




%% Loop through subjects

for sub = subNo
    
    sub = cell2mat(sub);

    disp([char(10), char(10), 'Processing steps for subject ', sub]);
    
    % save file
    saveF = [folder, 'trialData_', sub, '_',num2str(pre),'spre_',num2str(post),'spost.mat'];
    
    
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

        trialData = stimData(pupilData, stimuli, pre, post, responses);


        %% save epoch data

        save(saveF, 'trialData');

        disp([char(10), 'Finished with subject ', sub, char(10)]);
    end
    
    
end
    
    
    

