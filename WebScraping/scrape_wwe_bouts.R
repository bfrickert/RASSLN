library(RCurl) 
library(XML)
library(plyr)
library(dplyr)


locations <- read.table('data/event.locations.tsv',header=T, sep='\t', stringsAsFactors=F)
events <- read.table('data/event.links2007.tsv',header=T, sep='\t', stringsAsFactors=F)

get.nums <- function(l) {
  r <- "wrestler=([\\d]+)"
  nums <- lapply(l, function(x) regmatches(as(x,"character"),gregexpr(r,as(x,"character"),perl=T))[[1]])
  
  nums <- lapply(nums, function(x) paste(x,collapse=','))
  return(gsub('wrestler=','',nums))
}

get.bouts <- function(url){
  results <- tryCatch(
{
  html <- getURL(paste('http://wrestlingdata.com', url, sep=''))
  
  doc <- htmlParse(html, asText=T)
  plain.text <- xpathSApply(doc, "//table//tr//td", xmlValue)
  start <- which(plain.text=="1")
  end <- which(grepl('^Average age of the wrestlers:', plain.text)) - 1
  if (length(end)==0){ end <- which(grepl('\nWrestlingdata.com ©', plain.text)) -1}
  id <- gsub("/index.php?befehl=shows&show=", "", url, fixed=T)
  
  plain.text <- xpathSApply(doc, "//table//tr//td")
  matches.html <- plain.text[start:end]
  
  matches.html.def <- lapply(matches.html, function(x) strsplit(as(x,"character"),"defeated"))
  
  winners <- lapply(matches.html.def, function(x) lapply(x[[1]][1], function(x) x))
  losers <- lapply(matches.html.def, function(x) lapply(x[[1]][2], function(x) x))
  
  win.nums <- get.nums(winners)
  lose.nums <- get.nums(losers)
  wrestle.nums <- cbind(win.nums,lose.nums)
  
  df <- data.frame(matrix(wrestle.nums,ncol=2), stringsAsFactors=F)
  
  df$id <- id
  names(df) <- c('winners','losers','id')
  #return(filter(df,winners!='' | losers!=''))
  write.table(filter(df,winners!='' | losers!=''),'data/bouts2007.tsv',append=T, row.names=F,col.names=F, sep="\t",quote=F)
},
  
  error = function(cond){
    message("things guckirked!")
    message(url)
    message(cond)
    return(NA)
  },
  finally={
    message(paste("processed: ",url))
  })
  return(results)
  }


lapply(filter(events, url != '/index.php?befehl=shows&show=68318')$url, FUN=get.bouts)



