library(RCurl) 
library(XML) 
yrs <- 1963:2015

get_pages <- function(yr){
  
link <- paste("http://wrestlingdata.com/index.php?befehl=shows&sort=liga&kategorie=1&liga=3&jahr=", yr, "&showart=0&ansicht=0&seite=1", sep='')
html <- getURL(link)

doc <- htmlParse(html, asText=T)
plain.text <- xpathSApply(doc, "//table", xmlValue)

pages <- paste(plain.text[15], collapse = "\n")
pgs <- as.integer(strsplit(gsub("\\n\\n", "", gsub("\\n\\nPage: \\n\\n\\n", "", pages)), ' ')[[1]])
return(sapply(pgs, function(x){paste("http://wrestlingdata.com/index.php?befehl=shows&sort=liga&kategorie=1&liga=3&jahr=", yr, "&showart=0&ansicht=0&seite=",x, sep='')}))
}

wwe.pages <- sapply(yrs,function(x){get_pages(x)})
df <- data.frame(unlist(wwe.pages))
names(df) <- 'url'
write.table(df, "data/year_urls.tsv", sep="\t")

