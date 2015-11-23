#setwd("C:/Users/VapriPC/Google Drive/Notability/M4143/Project/data")
rm(list = ls())
require(TTR)
require(zoo)

# get titles
sector_html_titles <- gsub("[\r\n]", "", read.csv(file = "sector_html_titles.csv")$x);

dir.create("data");
dir.create("data/time_series");
partitions = rbind(c("20080101","20121231"),c("20080101","20101231"),c("20101231","20121231"));

for( iPart in 1:length(partitions[,1]) ) {
  partMSG = sprintf("Partition %s-%s",substr(partitions[iPart,1],1,4),substr(partitions[iPart,2],1,4));
  print(partMSG)
  #iPart = 1;
  sector_dir <- paste0("time_series/", substr(partitions[iPart,1],1,4),"-",substr(partitions[iPart,2],1,4));
  dir.create(sector_dir);
  for(sector in sector_html_titles) {
    #sector = sector_html_titles[1];
    sub_sector_dir <- paste0(sector_dir,"/",sector);
    print(paste0(partMSG,"> (",which(sector_html_titles==sector),") ", sector))
    dir.create(sub_sector_dir);
    
    stock_symbols <- read.csv(paste0("html_links/", sector,".csv"))$x
    yahoo_stocks = new.env()
    for(stock in as.character(stock_symbols)){
      #stock = as.character(stock_symbols)[1]
      tryCatch({
        yahoo_stocks[[stock]] = getYahooData(symbol=stock, start = partitions[iPart,1], end = partitions[iPart,2])
        if(!is.null(yahoo_stocks[[stock]])) {
          title_time_series <- paste0(sub_sector_dir,"/",stock,".csv")
          write.zoo(yahoo_stocks[[stock]],file=title_time_series,sep=",")
        }
      }, error=function(e){
        
      })
      print(paste0(partMSG,"> (",which(sector_html_titles==sector),") ", sector, "> (", which(as.character(stock_symbols)==stock),"/", length(as.character(stock_symbols)), ") ", stock ))
    }
  }
}