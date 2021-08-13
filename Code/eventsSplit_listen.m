function [starts,ends] = eventsSplit_listen(values, timestamps)

%% Function to further split the events extracted from the xml files

%% Input checks

if ~iscolumn(values) || ~iscell(values)
    error('Input arg "values" needs to be a column cell array');
end

if ~iscolumn(timestamps) || ~isnumeric(timestamps)
    error('Input arg "timestamps" needs to be a numeric column vector');
end

if ~isequal(size(values), size(timestamps))
    error('Input args "values" and "timestamps" need to have same size');
end


disp([char(10), 'Called eventsSPlit script']);

%% check to make sure there aren't more timestamps than expected
starttype = cellfun(@(x) str2num(x(22)),values,'UniformOutput',false);
endtype = cellfun(@(x) str2num(x(20)),values,'UniformOutput',false);

% if subject perhaps listened to a story more than once (in the case of the
% experiment crashing)
if length(values) > 8
    disp([char(10), 'Subject may have listened to some stories more than once. Deleting duplicates']);
    
    %convert story numbers to vectors
    allstarts = cell2mat(starttype(~cellfun('isempty',starttype)));
    allends = cell2mat(endtype(~cellfun('isempty',endtype)));
    
    %identify duplicates by finding ones that don't occur in ascending
    %order (story 1->2->3->4)
    startdiff = diff(allstarts);
    enddiff = diff(allends);
    
    delidx_start = find(startdiff<1);
    delidx_end = find(enddiff<1);
    
    %depending on the condition, create story matrix
    if isempty(delidx_start)
        storyType = [allstarts,allends(delidx_end(end)+1:end)];
    elseif isempty(delidx_end)
        storyType = [allstarts(delidx_start(end)+1:end),allends];
    else
        storyType = [allstarts(delidx_start(end)+1:end),allends(delidx_end(end)+1:end)];
    end
else
    %if subject didn't listen to all stories, or didn't finish listening
    %to one
    if length(values) < 8 && mod(length(values),2) ==1
        disp([char(10), 'Subject didnt listen to all stories. Making sure there are starts and ends for all.']);
        allstarts = cell2mat(starttype(~cellfun('isempty',starttype)));
        allends = cell2mat(endtype(~cellfun('isempty',endtype)));
        
        delidx_start = find(~ismember(allstarts,allends));
        delidx_end = find(~ismember(allends,allstarts));
        if isempty(delidx_start)
            storyType = [allstarts,allends(1:delidx_end(1)-1)];
        elseif isempty(delidx_end)
            storyType = [allstarts(1:delidx_start(1)-1),allends];
        else
            storyType = [allstarts(1:delidx_start(1)-1),allends(1:delidx_end(1)-1)];
        end
    else
        storyType = cell2mat([starttype(~cellfun('isempty',starttype)), endtype(~cellfun('isempty',endtype))]);
    end
    
end

%% Basics, params, magic numbers

% string identifiers of block and response events
storyStart = 'Start time for';
storyEnd = 'End time for';

%% Get story start and end timestamps

starttimes = timestamps(contains(values, storyStart));
endtimes = timestamps(contains(values, storyEnd));

% if stories have been repeated, here is where we take out those timestamps
if length(starttimes) > 4
    starttimes(1:delidx_start(end)) = [];
elseif length(starttimes) < 4 && length(starttimes) ~= length(endtimes)
    endtimes(delidx_end(1:end)) = [];
end
if length(endtimes) > 4
    endtimes(1:delidx_end(end)) = [];
elseif length(endtimes) < 4 && length(starttimes) ~= length(endtimes)
    starttimes(delidx_start(1:end)) = [];
end

%% Get stimulus types and onset timestamps

% get stimulus types and timestamps into output variable
starts = [starttimes, storyType(:,1)];
ends = [endtimes, storyType(:,2)];

disp([char(10), 'Extracted story start and end timestamps.']);


%% End, return

return