
fulldataset = importdata('C:\Users\Admin\Documents\GitHub\Mean-Value-Opt\data_mining\filtered_data\2008\Financial.csv');
stockNames = strrep(strrep(fulldataset.textdata(1,:),'Close.',''),'"','');
stockData = fulldataset.data;