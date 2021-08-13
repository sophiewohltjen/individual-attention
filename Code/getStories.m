function [story3,story15,story16,story17] = getStories(starts,ends,data,sub)

% function that takes full timeseries of pupil data and splices it into
% individual stories.

% because of counterbalancing, story 1, 2, 3, and 4 in the event files 
% do not always correspond to the same narrative! This script uses the
% timing of each story to determine which narrative was occurring

% the output matrices contain the true story numbers, corresponding to
% which narrative was being heard (3, 15, 16, or 17)

story3=[];
story15=[];
story16=[];
story17=[];

%how long each story lasts, in seconds
storytimes = [81,121,191,227];

% a function to splice a given dataset
for i=1:size(starts,1)
    bounds = [starts(i,1), ends(i,1)];
    dataIdx = data(:, 1) >= bounds(1) & data(:, 1) <= bounds(2);
    story = data(dataIdx,:);
    
    % the stories are all different lengths, and we'll determine which is
    % which based on that
    
    %compare story lengths to find which story it is
    storyfind = abs(length(story)-(storytimes*30));
    whichstory = find(storyfind == min(storyfind));
    
    if whichstory == 1 && isempty(story3)
        story3 = story;
    elseif whichstory == 2 && isempty(story15)
        story15 = story;
    elseif whichstory == 3 && isempty(story16)
        story16 = story;
    elseif whichstory== 4 && isempty(story17)
        story17 = story;
    else
        error(['Story timings for subject' sub 'may be off!!'])
    end
            
    
end