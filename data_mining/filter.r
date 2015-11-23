rm(list=ls())
library(chron) #used for creating date vector
library(dplyr)
library(timeSeries)
library(zoo)

#set home directory if needed
#setwd("F:/Mean-Value-Opt/data_mining")

getDateVector <- function(d1,d2,format="%Y%m%d") {
  dates <-seq.Date(to = as.Date(d2,format=format),
                   from = as.Date(d1,format=format),
                   by = 1)
  return(as.Date(dates[!is.weekend(dates)]))
}

# get titles
sector_html_titles <- gsub("[\r\n]", "", read.csv(file = "sector_html_titles.csv")$x);

partitions_year = rbind(c("20080101","20081231"),
                        c("20090101","20091231"),
                        c("20100101","20101231"),
                        c("20110101","20111231"),
                        c("20120101","20121231"))

#for (sector in sector_html_titles)
sector = sector_html_titles[1];
{
  stock_dir <- paste0("time_series/2008-2012/",sector)
  stock_list <- gsub(".csv","",dir(stock_dir))
  dir.create("filtered_stocks/",showWarnings = FALSE)

    #for(part in 1:length(partitions_year[,1]))
    part = 1
    {
      # create general date vector
      merged_data <- data.frame(Index=getDateVector(partitions_year[part,1],partitions_year[part,2]))
      
      year <- substr(partitions_year[part,1],1,4)
      
      #create directory name data/filtered_stocks/YEAR
      merged_data_directory <- paste0("filtered_stocks/",year)
      dir.create(merged_data_directory,showWarnings = FALSE)
      
      #create file name data/filtered_stocks/YEAR/SECTOR.csv
      merged_data_file <- paste0(merged_data_directory,"/",sector,".csv")
      
      for (stock in stock_list)
      {
        data <- read.csv(paste0(stock_dir,"/",stock,".csv"))
        data[,1] <- as.Date(data[,1]);
        # filter data by year
        data_year <- dplyr::filter(data,grepl(year,Index))
        
        # coerce index to date and close prices to numeric
        data_year$Index <- as.Date(data_year$Index)
        data_year$Close <- as.numeric(data_year$Close)
        
        # rename col.names to specific stock
        data_year_short <- data_year[c("Index","Close")]
        colnames(data_year_short) <- c("Index",paste0("Close.",stock))
        
        if (nrow(data_year) > nrow(merged_data)*.85) #if the stock has more than 85% of time data we keep it
        {
          merged_data <- merge(merged_data,data_year_short,by.x = "Index",by.y = "Index",all.x = TRUE)
          # determine if last column of merged_data had NA values if so replace with previous open price. 
          
          last.na = 0;
          for (naInd in which(is.na(merged_data[,ncol(merged_data)])) ) {
            possibs = which(data[,1] < merged_data[naInd,1]);
            if( length(possibs) > 0 ) {
              merged_data[naInd,ncol(merged_data)] = data[max(possibs),4];
            } else {
              merged_data[naInd,ncol(merged_data)] = data[min(which(data[,1] >= merged_data[naInd,1])),2];
            }
          }
          
        }
        print(paste0(round(which(stock_list == stock)/length(stock_list)*100,2),'% Done'));
        write.csv(merged_data,file = merged_data_file,row.names = FALSE)
      }
      
    }
}
