function [cleandata,datamean] = epochCleaning(data)
% a function to output cleaned data for a given stimulus type

% baseline length in time (sec)
pre = 1; 
% trial data length after stimulus onset (epoch length), time in secs
post = 3;
% sampling frequency 
sampRate = 30;
% epoch length
epochL = pre*sampRate + post*sampRate + 1;
epochTimesInterp = [-pre*1000:1000/sampRate:post*1000]';
% values for data rejection (turning them into nan)
minPupil = 2;
%maxPupil = 10;

% get rid of very low values?
data(data<minPupil) = nan;
%         
%         % get rid of very high values?
%         data(data>maxPupil) = nan;
% 

% z-score
trialNo = size(data, 1);
for trial = 1:trialNo
    data(trial, :) = (data(trial, :)-nanmean(data(trial, :)))/nanstd(data(trial, :)) ;
end      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% subtract baseline?
trialNo = size(data, 1);
for trial = 1:trialNo
    baseline_100ms = nanmean(data(trial, 1:((pre*sampRate)-3)));
    %baseline_whole = nanmean(data(trial, 1:pre*sampRate+1));
    data(trial, :) = data(trial, :) - baseline_100ms;
end

%calculate percentage of data missing
nancount = length(find(isnan(data)));
%let us know if more than 50% of trial data is missing
if nancount > (size(data,1)*size(data,2))/2
    cleandata = NaN;
    datamean = NaN;
else
    %output the whole dataset
    cleandata =data;
    %output the data mean
    datamean = nanmean(data,1);
end


end