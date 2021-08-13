function [values, timestamps] = XMLinfo(xmlfile)

%% Function edited from readXMLinfo.m, also extracting timestamps
%
% USAGE: [values, timestamps] = XMLinfo(xmlfile)
%
% Sophie's script, with a small added functionality. The output variable
% timestamps contains the same type of timestamps we have for pupil frames
% in the raw data tsv.
%
% This function will read a given xml file and save the important annotation
% info from it
%

%% Reading in xml with xml2struct

disp([char(10), 'Called XMLinfo script with input file:',...
    char(10), xmlfile]);

%read in xmlfile
XML = xml2struct(xmlfile);


%% Extracting the Value and Timestamp fields

% get length, preallocate
dataSize = length(XML.TextDataChronicle.TextData);
values = cell(dataSize,1);
timestamps = zeros(dataSize, 1); % simple numeric

%start a counter
count=0;

% save appropriate info in a loop - the "Value" field contains the details
% of the user event in a string, while the "Timestamp" field contains the
% timing according ot the same convention as in the pupil data file
for line=1:dataSize
    if ~isempty(XML.TextDataChronicle.TextData{line}.Attributes)
        count=count+1;
        values{count} = XML.TextDataChronicle.TextData{line}.Attributes.Value;
        timestamps(count) = str2num(XML.TextDataChronicle.TextData{line}.Attributes.Timestamp);
    end
end

disp('Extracted event details (values) and corresponding timestamps')


%% End, return

return