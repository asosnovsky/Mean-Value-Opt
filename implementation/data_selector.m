function [ Ret, CoRisk, fStocknames, filData, data, stockNames, P, returns  ] = data_selector( folders, date, sector )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

    % (0) Folder Location
    folders.tmp = strcat(folders.data, date, '/',sector,'.csv');
    fulldataset = importdata(char(folders.tmp));
    stockNames = regexprep(strrep(fulldataset.textdata(1,:),'Close.',''),'["|.]','');
    stockNames = stockNames(2:end);
    data = fulldataset.data;
    % (1) Compute returns
    data(data == 0) = 1E-20;
    returns = (data(2:end,:)-data(1:end-1,:))./data(1:end-1,:);
    Ret = mean(returns);
    CoRisk = cov(returns);

    % (2) Data Reduction
    temp = (sort(diag(CoRisk)));
    temp = temp(1:floor(0.5*length(Ret)));
    P = [];
    for (pot=temp')
        [xx, ~] = find(diag(CoRisk) == pot);
        P = [P xx'];
    end
    P = unique(P);

    temp = sort(reshape(CoRisk(P,P),[1,numel(P)^2]));
    temp = temp(1:floor(0.5*length(P)));

    P = [];
    for (pot=temp)
        [xx, ~] = find(CoRisk == pot);
        P = [P xx'];
    end
    P = unique(P);
    
    filData = data(:,P);
    %returns = returns(:,P);
    Ret     = Ret(P);
    CoRisk = CoRisk(P,P);
    fStocknames = stockNames(P);
end

