library(RCurl) 
library(XML)
library(dplyr)

events <- read.table('data/event.links.tsv',header=T, sep='\t', stringsAsFactors=F)

get.locations <- function(x){
  html <- getURL(paste('http://wrestlingdata.com', x, sep=''))
  
  doc <- htmlParse(html, asText=T)
  plain.text <- xpathSApply(doc, "//table//tr//td//a", xmlValue)
  date <- plain.text[40]
  venue <- plain.text[41]
  city <- plain.text[42]
  state <- plain.text[43]
  country <- plain.text[44]
  id <- gsub("/index.php?befehl=shows&show=", "", x, fixed=T)
  df <- data.frame(c(id, date,venue,city,state,country), stringsAsFactors=F)
  
  return(df)
}

event.locations <- as.vector(sapply(events$url, get.locations))

df <- data.frame(matrix(unlist(event.locations),nrow=length(event.locations),byrow=T), stringsAsFactors=F)
names(df) <- c('id','date','venue','city','state','country')
df <- filter(df, country!='Show Archive: WWE')
df <- filter(df, country!='Show Archive: SPW')
df <- filter(df, country!='Show Archive: Misc.')
df <- filter(df, country!='Show Archive: USWA')
df <- filter(df, country!='Show Archive: WWA')
df <- filter(df, state!='Show Archive: WWE')
df <- filter(df, city!='Show Archive: WWE')
df <- filter(df, venue!='Show Archive: WWE')
write.table(df, 'data/event.locations.tsv', sep='\t',row.names=F)

false.venues <- df[df$date=="Login or Register",]$venue
false.city <- df[df$date=="Login or Register",]$city
false.state <- df[df$date=="Login or Register",]$state
false.country <- df[df$date=="Login or Register",]$country

df[df$date=="Login or Register",]$venue <- false.city
df[df$date=="Login or Register",]$city <- false.state
df[df$date=="Login or Register",]$state <- false.country
df[df$date=="Login or Register",]$country <- 'NONE'
df[df$date=="Login or Register",]$date <- false.venues

write.table(df, 'data/event.locations.tsv', sep='\t', row.names=F)
