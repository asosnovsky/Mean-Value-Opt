%% % (1) Main Setup (folder handling)
clear
clc

% Read data source
folders.working = 'F:/Mean-Value-Opt/';
folders.data = strcat(folders.working,'data_mining/filtered_stocks/');

% Set working directory
cd(folders.working);

% Add Functions
addpath('analysis');

% Get date list
tmp = ls(folders.data);
for i=3:size(tmp,1)
    dates{i-2} = strtrim(tmp(i,:));
end
clear tmp

% Get Sector list
folders.tmp = char(strcat(folders.data,dates(1)));
tmp = ls(folders.tmp);
for i=3:size(tmp,1)
    sectors{i-2} = strrep(strtrim(tmp(i,:)),'.csv','');
end
clear tmp

% Inputs
RiskFreeRate = 0;
PortfolioLimit = 10;

% Containers
data.Ps = zeros(length(dates),PortfolioLimit);
data.Wps = zeros(length(dates),PortfolioLimit);
%% % (2) Get Data and Analyze it
clc
tic
%for(sector=sectors)
sector = sectors(1);
%for(date=dates)
date = dates(2);
folders.tmp = strcat(folders.data, date, '/',sector,'.csv');
fulldataset = importdata(char(folders.tmp));
anData.stockNames = regexprep(strrep(fulldataset.textdata(1,:),'Close.',''),'["|.]','');
anData.data = fulldataset.data;
anData.data(anData.data == 0) = 1E-20;% add a rounding error to avoid infinites
anData.returns = (anData.data(2:end,:)-anData.data(1:end-1,:))./anData.data(1:end-1,:);
anData.Ret = mean(anData.returns);
anData.CoRisk = cov(anData.returns);
%

[sharpe, P, Wp, sharpes, mps, risks] = optimizeSharpPort( anData.Ret(1:10), anData.CoRisk(1:10,1:10), RiskFreeRate, PortfolioLimit );
toc

data.(strrep(sectors{1},' ','_')).(strcat('y',char(date))) = anData;
data.Ps(1,:) = P;
data.Wps(1,:) = Wp;
toc

% Ploting

tmp = anData.data(:,P)*Wp;
sel = anData.data(:,P);

plot(tmp);
hold on
plot(sel)