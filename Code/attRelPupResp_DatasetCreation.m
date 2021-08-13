function attRelPupResp_DatasetCreation(base_dir,study,stim)

    % Sophie Wohltjen, 8/21
    % function to make csvs out of trial-level attention-related pupil
    % responses
    %
    % inputs: 
    % base_dir: '/Users/sophie/Dropbox/IRF_modeling/individual-attention'
    % study: 'study1' or 'study2'
    % stim: 'standard','acc_oddball','novel', or 'omission'
    
    if all(ismember('study1',study))
        subNo = {'107_1','107_2','107_3','107_4','107_5','107_6','107_7','107_9',...
        '108_2','108_3',...
        '109_1','109_2','109_3','109_4','109_5','109_6','109_7','109_8','109_9',...
        '110_1','110_2','110_4','110_5','110_6','110_7','110_8','110_9',...
        '111_1','111_2','111_3','111_5','111_7','111_9',...
        '112_1','112_2','112_3','112_4','112_5','112_6','112_7','112_9',...
        '113_1','113_2','113_3','113_4','113_5','113_6','113_7','113_8','113_9',...
        '114_1','114_3','114_4','114_5','114_7'};
    elseif all(ismember('study2',study))
        subNo = {'001','002','003','005','008','009','010','011','012','013','014','015','016'...
        ,'017','018','021','022','023','027','028','029','030','031','032',...
        '034','036','037','038','039','053','054','055','056','057','058','059',...
        '060','061','063','064','065','067','068','069','070','071','072','073',...
        '075','077','078','079','080','081','082','083','084','086','087','088','089','090',...
        '092','093','094','095','096','097','100','101','102','106'};
    end

    % this is our directory of interest
    wdir = sprintf('%s/Analyses/%s/preprocessed_pupil_epochs',base_dir,study);
    cd(wdir)

    %start counter
    count=1;
    for sub=1:length(subNo)

        %how many files do we have for them?
        subfiles = dir(sprintf('trialData_%s*.mat',subNo{sub}));

        %loop through those files
        for i = 1:length(subfiles)
            load(subfiles(i).name);
            %clean up the response 
            [~,datamean] = epochCleaning(trialData.(stim));
            if ~isnan(datamean)
                %add datamean to a table of all subjects' responses
                subdata(count,:) = datamean;
                %add subs ID to cell array of sub IDS
                %FOR REP IRF
                subIDs{count} = sprintf('sub%s',subfiles(i).name(11:15));
                %FOR REGULAR
    %             subIDs{count} = sprintf('sub%s',subfiles(i).name(11:13));
                count = count+1;
            end
        end
    end

    %now make a table and save it out
    datatable = array2table(subdata');
    datatable.Properties.VariableNames = subIDs;

    writetable(datatable,sprintf('%s/Analyses/%s/IA_%smeans.csv',base_dir,study,stim));
end