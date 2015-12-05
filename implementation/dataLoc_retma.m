function [ folders, dates, sectors ] = dataLoc_retma( wd )
%dataLoc_retma working directory and general data setter
%   [Inputs/Outputs]
%   wd      a `string` with the working directory location
%   folders a `str` with all the needed folders
%   dates   a `cell` with all the avaible dates
%   sectors a `cell` with all the avaible sectors

% Read data source
folders.working = wd;
folders.data = strcat(folders.working,'data_mining/filtered_stocks/');

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

