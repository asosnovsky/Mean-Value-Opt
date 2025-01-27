function [ Ret, CoRisk, fStocknames, filData, data, stockNames, P, returns  ] = data_selector( folders, date, sector )
%data_selector This function will select a given partition given a sector,
%date and folder object. Then will filter that data based on variance and
%correlation.
%
%   [Inputs/Outpus]
%   folders         a `structure` that contains the field `data` as the real location of data
%   date            a `string`-cell that contains the requested date, 
%   sector          a `string`-cell that contains the requested sector
%   Ret             a `vector` of the means of the selected data
%   CoRisk          a covariance `matrix` for the selected data
%   fStocknames     a `cell` with the names of all the fitered stocks
%   fillData        a `matrix` with all the filtered data
%   data            a `matrix` with the unfiltered data
%   stockNames      a `cell` with the names of the unfiltered stocks
%   P               a `vector` with the indexes of the filtered stocks inside the unfilterd `data`
%   returns         a `matrix` with the returns of the filtered data
%
%

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
    % (2.1) by correlation
    temp = (sort(diag(CoRisk)));
    temp = temp(1:floor(0.5*length(Ret)));
    P = [];
    for (pot=temp')
        [xx, ~] = find(diag(CoRisk) == pot);
        P = [P xx'];
    end
    P = unique(P);
    
    % (2.2) by variance
    temp = sort(reshape(CoRisk(P,P),[1,numel(P)^2]));
    temp = temp(1:floor(0.5*length(P)));

    P = [];
    for (pot=temp)
        [xx, ~] = find(CoRisk == pot);
        P = [P xx'];
    end
    P = unique(P);
    
    % Saving of fileterd data
    filData = data(:,P);
    returns = returns(:,P);
    Ret     = Ret(P);
    CoRisk = CoRisk(P,P);
    fStocknames = stockNames(P);
end

