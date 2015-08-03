library(RCurl) 
library(XML)
library(plyr)
library(dplyr)
library(stringr)

winners.losers <- read.table('data/winners_losers.tsv',header=F, sep='\t', stringsAsFactors=F)
wrestlers <- c(winners.losers$V2, winners.losers$V4)
wrestlers <- as.integer(unique(wrestlers))

get.bio <- function(wrestler.id) {
  html <- getURL(paste('http://wrestlingdata.com/index.php?befehl=bios&wrestler=', wrestler.id, sep=''))
  doc <- htmlParse(html, asText=T)
  plain.text <- xpathSApply(doc, "//table//tr//td//table[3]//tr//td", xmlValue)
  name = gsub("\n", "", plain.text[3])
  
  plain.text <- xpathSApply(doc, "//table//tr//td//table[4]//tr//td",xmlValue)
  s <- str_match_all(plain.text[4],"Weight and Height\n\n\n\\d+ lbs. \\((\\d+) kg\\) at \\d+'\\d+'' \\((\\d.\\d+) m\\)")[[1]]
  wgt.kg <- s[2]
  hgt.m <- s[3]
  
  plain.text <- xpathSApply(doc, "//table//tr//td", xmlValue)
  s <- str_match_all(plain.text[48],"Trademark Moves[\n]*(.*)[\n]*")[[1]]
  s2 <- str_match_all(plain.text[50],"Trademark Moves[\n]*(.*)[\n]*")[[1]]
  if (is.na(s[2]) ) {  trademark.moves <- s2[2] } else {  trademark.moves <- s[2] }
  s <- str_match_all(plain.text[48],"Finisher[\n]*(.*)[\n]*")[[1]]
  s2 <- str_match_all(plain.text[50],"Finisher[\n]*(.*)[\n]*")[[1]]
  if (is.na(s[2]) ) {  finishers <- s2[2] } else {  finishers <- s[2] }
  bio <- cbind(wrestler.id, name, wgt.kg, hgt.m, trademark.moves, finishers)
  
  write.table(bio, "data/bio.tsv", append=T, sep="\t", col.names=F, row.names=F)
}

lapply(wrestlers, get.bio)
