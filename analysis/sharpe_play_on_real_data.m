%% % (1) Data Fetching
clear
clc
% Read data source
dataFolder = 'F:\data\data\time_series\2008-2012\';
sectors = char(ls(dataFolder));sectors = sectors(3:end,:);
sector = sectors(1,:);
stocks = ls(strcat(dataFolder,sector));stocks = stocks(3:end,:);

% Set limits and containers
stockLim = 50;

nStock = 0;cnt = 0;
% Load data
while nStock < stockLim
    %disp(cnt);
    try
        stock = strrep(stocks(ceil(length(stocks)*rand(1)),:),'.csv','');
        stockNames{nStock+1} = stock;
        stockLoc = strcat(dataFolder,sector,'\',stock,'.csv');
        fulldataset = importdata(stockLoc);
        closing = (fulldataset.data(:,4));
        closing(closing==0) = 1E-7;
        closings{nStock+1} = closing;
        returns{nStock+1} = (closing(2:end)-closing(1:end-1))./closing(1:end-1);
        if(length(returns{nStock+1}) > 365*4*0.75)
            disp(stock);
            nStock = nStock + 1;
        else
            disp(length(returns{nStock}));
            fprintf('       [[[%d%%  Done]]]\n',round( (100*length(returns)/stockLim),2) );
        end
    catch ME
        disp(ME.message);
        disp(ME.cause);
    end
    cnt = cnt+1;
end
clc
if(size(returns,2) == stockLim)
    disp('Stocks loaded succesfully!');
else
    disp('Something went wrong with stock return');
end

% Data Cleanup
minPeriod = min(cellfun('length',returns));
data = cellfun(@(x) x(1:minPeriod),returns,'UniformOutput',false);
data = cat(2, data{:});

% Meaningful variables
% stockNames == all stocknames
% data == stock information after first order differencing

% % (2) Data Analysis
Ret = mean(data);
CoRisk = cov(data);
%
clc
tic
[sharpe, P, Wp, sharpes, mps, risks] = optimizeSharpPort( Ret, CoRisk, 0.01, 10 );
toc

% Plot
figure('Name','Sharpe Ratio Optimization');
X = [mps',risks',sharpes'];
Y = sortrows(X);
plot3(Y(:,1),Y(:,2),Y(:,3));
xlabel('Returns');
ylabel('Risks');
zlabel('Sharpe');

