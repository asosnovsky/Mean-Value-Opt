% Clear all
clear
clc
% Set working directory (not neccessary)
cd('C:\Users\VapriPC\Google Drive\Notability\M4143\Project');
%%
data = getRandomStockData(10,'Close','12-01-2012','01-01-2013');

%%
if ~exist('yahoonames.xlsx','file')
    filetmp = websave('temp.zip','http://investexcel.net/wp-content/uploads/2013/12/Yahoo-Ticker-Symbols-Jan-2015.zip');
    filename = strcat(strrep(filetmp,'temp.zip',''),unzip(filetmp));
    movefile(char(filename),'yahoonames.xlsx');
    delete(filetmp);
    clear filetmp filename
end