setwd("F:/data")
rm(list=ls())
stock_dir = "F:/data/data/time_series/2008-2012/Basic Materials"
stock_list = gsub(".csv","",dir(stock_dir));

stock_name = stock_list[floor(runif(1)*length(stock_list))];
data <- read.csv(paste0(stock_dir,"/",stock_name,".csv"));
dates <- data[,1];
data <- as.numeric(data[,4]);
returns <- (data[2:length(data)]-data[1:length(data)-1])/data[1:length(data)-1];
normalized_returns <- returns-min(returns);
plot(data, x=dates, type='l', main=stock_name)
plot(normalized_returns, x=dates[2:length(dates)], type='l')
plot(log(normalized_returns), x=dates[2:length(dates)], type='l')

