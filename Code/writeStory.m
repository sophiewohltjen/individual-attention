function writeStory(storydata,storynum,sub,storydir)

% function that takes a story matrix and writes it to a file 
% file includes the following columns:
% timestamps from zero
% timestamps taken from the raw pupil file
% raw pupil data
% preprocessed pupil data
% mean-centered preprocessed pupil data

%create time from zero vector
time = 0:1/30:(length(storydata)/30);

%mean-center the pupil data
baseline = mean(storydata(:,3));
norm = (storydata(:,3)-baseline)/baseline;

%create table for all data
alldata = cat(2,time(1:length(storydata))',storydata,norm);

%labels for final table
labels = {'time','time_smi','raw_pupil','preproc_pupil','meancent_pupil'};

dtable = array2table(alldata,'VariableNames',labels);

writetable(dtable,sprintf('%s/%s_story%d.txt',storydir,sub,storynum));

