library(plyr)
library(dplyr)

df <- read.table('data/bouts.tsv',header=F, sep='\t', stringsAsFactors=F)
names(df) <- c('winner', 'loser','evt.id')

win.frequency<-data.frame(table(unlist(sapply(unlist(df$winner), FUN=function(x) strsplit(as.character(x),',')))), stringsAsFactors=F)
names(win.frequency) <- c('wrestler','freq')
loss.frequency<-data.frame(table(unlist(sapply(unlist(df$loser), FUN=function(x) strsplit(as.character(x),',')))), stringsAsFactors=F)
names(loss.frequency) <- c('wrestler','freq')

flatn.losers <- function(evt.id, losers) {
  u.losers <- as.vector(unlist(strsplit(losers, ',')))
  return(data.frame(cbind(evt.id, u.losers)))
}

get.losers <- function(win.id){
  tryCatch(
    {
      search.str <- paste('(^|,)',win.id,'(,|$)', sep="")
      my.losers <- data.frame(cbind(win.id,select(filter(df, grepl(search.str, winner, perl=T)), evt.id, loser)))
      n <- c('winner','evt.id','losers')
      names(my.losers) <- n
      
      df <- ldply(apply(my.losers, 1, function(x) flatn.losers(x[2],x[3])),data.frame)
      df<-cbind(win.id, df)
      names(df) <- n
      write.table(df, 'data/winners_losers.tsv', sep='\t', append=T, col.names=F)
    },
    
    error = function(cond){
      message("things guckirked!")
      message(win.id)
      message(cond)
      return(NA)
    },
    finally={
      message(paste("processed: ",win.id))
    })
}

lapply(win.frequency$wrestler, get.losers)


