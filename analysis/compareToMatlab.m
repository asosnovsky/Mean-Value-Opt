clear; 
clc;
% This will run our function to get a maximum sharpe ratio and compare it 
% to the maximum sharpe ratio given by Matlab using Financial Toolbox

%Parameters: 
sLim = 20; %number of stocks to fetch from the data
mp = 0.01;  %The expected Return 
portlim = 5; %The number of assets you want in the portfolio
rfr = 0.005; %Risk free interest

%% % (1) Data Fetching
clc
% Read data source
dataFolder = 'C:\Users\Kosal\Desktop\data\data\time_series\2008-2012\';
sectors = char(ls(dataFolder));sectors = sectors(3:end,:);
sector = sectors(1,:);
stocks = ls(strcat(dataFolder,sector));stocks = stocks(3:end,:);

% Set limits and containers
stockLim = sLim;

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
        returns{nStock+1} = (closing(2:end)-closing(1:end-1))./closing(1:end-1);
        if(length(returns{nStock+1}) > 365*4*0.75)
            disp(stock);
            nStock = nStock + 1;
        else
            disp(length(returns{nStock}));
        end
    catch ME
        %disp(ME.message);
        %disp(ME.cause);
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
clc
minPeriod = min(cellfun('length',returns));
data = cellfun(@(x) x(1:minPeriod),returns,'UniformOutput',false);
data = cat(2, data{:});

% Meaningful variables
% stockNames == all stocknames
% data == stock information after first order differencing

%%
Ret = mean(data);
CoRisk = cov(data);
        
%%
choice = questdlg('Would you allow the weight to be negative?', 'Portfolio Weight', 'Yes', 'No', 'Yes');
switch choice
    case 'Yes'
        NegOrPos = -1;
    case 'No'
        NegOrPos = 1;
end
% NegOrPos = input(prompt1);
% Run our function
[sharpe, P, Wp] = optimizeSharpPortee( Ret, CoRisk, rfr, portlim, NegOrPos);
     
% Run Matlab function
        dataP = data(:,P);
        RetP = mean(dataP);
        CoRiskP = cov(dataP);

    if NegOrPos == 1
        %Positive weight only
            p = Portfolio('AssetMean', RetP, 'AssetCovar', CoRiskP, 'RiskFreeRate', rfr );
            p = p.setDefaultConstraints;
    else 
        %Allow Negative weight
            p = Portfolio('AssetMean', RetP, 'AssetCovar', CoRiskP, 'RiskFreeRate', rfr, ...
            'NumAssets', length(P), 'LowerBound', -1, 'UpperBound', ...
            1, 'Budget', 1);
    end    
    
    MatWp = estimateMaxSharpeRatio(p);
    RetMatSharpe = RetP*MatWp;
    matsharpe = (RetMatSharpe-rfr)/(MatWp'*CoRiskP*MatWp)^0.5;
    
%% display result
fprintf(' Port    >>> Our Result --- Matlab Result <<< \n');
for i = 1:length(Wp)
fprintf('  %.0f \t\t% .5f     |     % .5f \n',P(i), Wp(i), MatWp(i));
end 
fprintf('\n');
fprintf('   >>> Our Sharpe ratio --- Matlab Sharpe Ratio <<< \n');
fprintf('\t\t\t %.5f     |     % .5f \n', sharpe, matsharpe);

