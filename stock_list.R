rm(list = ls())
library(httr)
library(rvest)
library(magrittr)

yahoo <- html_session("http://biz.yahoo.com/p/")
sector_html <- yahoo %>%
html_nodes(xpath = "//td//td//a/@href") %>%
html_text()
sector_html_titles <- yahoo %>%
  html_nodes("td td a font") %>%
  html_text()
write.csv(gsub("[\r\n]", "",sector_html_titles),file = "sector_html_titles.csv",row.names = FALSE)

base <- "http://biz.yahoo.com/p/"
html_pages <- paste(base,sector_html,sep = "")
write.csv(html_pages,file = "html_links/sector_html.csv",row.names = FALSE)
yahoo_industry <- html_session(html_pages[1])
industry_html <- yahoo_industry %>%
  html_nodes(xpath = "//td//td//a[contains(@href,'conameu')]/@href") %>%
  html_text()
titles_text <- paste("html_links/",gsub("[\r\n]", "",sector_html_titles),".csv",sep = "")
#length(html_pages)
for (i in 1:length(html_pages))
{
  yahoo_industry <- html_session(html_pages[i])
  industry_html <- yahoo_industry %>%
    html_nodes(xpath = "//td//td//a[contains(@href,'conameu')]/@href") %>%
    html_text()
  for (j in 1:length(industry_html))
  {
    sector_html_url <- paste(base,industry_html,sep = "")
    yahoo_industry_stock <- html_session(sector_html_url[j])
    industry_stock_html <- yahoo_industry_stock %>%
      html_nodes("td td a+ a") %>%
      html_text()
    write.table(industry_stock_html, file = titles_text[i],append = "TRUE",sep = ",",row.names = FALSE)
    
  }
}


