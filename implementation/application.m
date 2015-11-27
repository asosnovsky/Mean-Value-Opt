%% % (1) Main Setup (folder handling)
clear
clc

folders.working = 'F:/Mean-Value-Opt/';
cd(folders.working);
% Add Functions
addpath('analysis');
addpath('implementation');

[folders, dates, sectors] = dataLoc_retma( folders.working );

% Inputs
RFR = [0.0365    0.0117    0.0143    0.0169    0.0100 ];
PortfolioLimit = 10;

% % (2) Analysis
clc
for sector = sectors
    disp(sector);
    tic
    DATA = [1000];
    date = dates(1);
    % Get Data
    [ Ret, CoRisk, fstockNames, Fdata, Odata  ] = data_selector( folders, date, sector );
    % Optimize
    [ Wp, P ] = optimizeSelect( Ret, CoRisk, RFR(1), PortfolioLimit );
    % Store
    tmpData = struct('Wp',Wp,'P',P,'optPlot',Wp'*Fdata(:,P)');
    tmpData.stockNames = cellstr(fstockNames(P));
    tmpData.original = Odata;
    data.(char(strcat('y',date))).(char(strrep(sector,' ','_'))) = tmpData;
    % Loop future
    for date=dates(2:end)
        % Get Data
        [ Ret, CoRisk, fstockNames, Fdata, ~, stockNames, ~, returns  ] = data_selector( folders, date, sector );
        % Apply Past Prices
        [foundP, foundI] = findlocSubstrings(stockNames,tmpData.stockNames);
        DATA = [DATA (DATA(end)+cumsum(Wp(foundI)'*returns(:,foundP)'))];
        % Optimize
        [ Wp, P ] = optimizeSelect( Ret, CoRisk, RFR(1), PortfolioLimit );
        % Store
        tmpData = struct('Wp',Wp,'P',P,'optPlot',Wp'*Fdata(:,P)');
        tmpData.original = Odata;
        tmpData.stockNames = cellstr(fstockNames(P));
        data.(char(strcat('y',date))).(char(strrep(sector,' ','_'))) = tmpData;
    end
    % Plot
    data.(char(strrep(sector,' ','_'))) = DATA;
    toc
    figure('Name',char(sector));
    plot(DATA);
    xlabel('Time');
    ylabel('Portfolio Price');
end

% Save Matlab Structure
save(strcat(folders.working,'implementation/sorted-data.mat'), 'data');

%% % (3) Main-Folder-Storing
clear
clc
% Set-Up
    folders.working = 'F:/Mean-Value-Opt/';
    cd(folders.working);
    % Add Functions
    addpath('analysis');
    addpath('implementation');
    [folders, dates, sectors] = dataLoc_retma( folders.working );
    folders.fuData = strcat(folders.working,'implementation/future-data/');
    
% Data Retrieval
    load(strcat(folders.working,'implementation/sorted-data.mat'), 'data');

% CSV Saving
for sector=sectors
    csvwrite(char(strcat(folders.fuData,sector,'.csv')),data.(char(strrep(sector,' ','_'))));
end

%% (4.1) Plotting Future Prices
clear
clc
% Set-Up
    folders.working = 'F:/Mean-Value-Opt/';
    cd(folders.working);
    % Add Functions
    addpath('analysis');
    addpath('implementation');
    [folders, dates, sectors] = dataLoc_retma( folders.working );

% Data Retrieval
    load(strcat(folders.working,'implementation/sorted-data.mat'), 'data');

% Plot
    for sector=sectors
        figure('Name',char(sector));
        plot(data.(char(strrep(sector,' ','_'))));
        xlabel('Time');
        ylabel('Portfolio Price');
    end

%% (4.2) Plotting Past Prices
clear
clc
% Set-Up
    folders.working = 'F:/Mean-Value-Opt/';
    cd(folders.working);
    % Add Functions
    addpath('analysis');
    addpath('implementation');
    [folders, dates, sectors] = dataLoc_retma( folders.working );

% Data Retrieval
    load(strcat(folders.working,'implementation/sorted-data.mat'), 'data');

% <<< WIP >> %