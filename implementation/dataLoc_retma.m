function [ folders, dates, sectors ] = dataLoc_retma( wd )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

% Read data source
folders.working = wd;
folders.data = strcat(folders.working,'data_mining/filtered_stocks/');

% Set working directory
cd(folders.working);

% Get date list
tmp = ls(folders.data);
for i=3:size(tmp,1)
    dates{i-2} = strtrim(tmp(i,:));
end
% Get Sector list
tmp = char(strcat(folders.data,dates(1)));
tmp = ls(tmp);
for i=3:size(tmp,1)
    sectors{i-2} = strrep(strtrim(tmp(i,:)),'.csv','');
end

end

