library(dplyr)
library(RCurl) 
library(XML)
wwe.pages <- read.csv('data/year_urls.tsv',sep='\t', header=T)

get.event.urls <- function(x){
  html <- getURL(x)
  
  doc <- htmlParse(html, asText=T)
  plain.text <- xpathSApply(doc, "//table//tr//td//a", xmlGetAttr, 'href')
  df <- data.frame(plain.text, stringsAsFactors=F)
  names(df) <- 'url'
  
  return(df$url[grepl("index.php\\?befehl=shows&show=\\d*$",df$url)])
  
}

event.links<-as.vector(sapply(wwe.pages$url, get.event.urls))
df <- data.frame(as.vector(unlist(event.links)))
names(df) <- 'url'
write.table(df, 'data/event.links.tsv', sep='\t')
