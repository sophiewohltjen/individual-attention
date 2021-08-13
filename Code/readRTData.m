function [rtData, rtEvents] = readRTData(rtfile,eventfile)


if ~exist(rtfile, 'file')
    error('Cannot find datafile');
end

% user message
disp([char(10), 'Running readRTData script on file at:',... 
    char(10), rtfile]);

load(rtfile);
load(eventfile);

rtEvents = reshape(trials,160*5,1);
rtData = reshape(rt,160*5,1);