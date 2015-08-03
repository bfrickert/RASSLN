library(plyr)
library(dplyr)
library(lubridate)
bio <- read.table('data/bio.tsv',header=F, sep='\t', stringsAsFactors=F)
names(bio) <- c('wrestler.id','name', 'wgt.kg', 'hgt.m', 'trademark.moves','finisher')


with(bio, plot(wgt.kg,hgt.m))
abline(lm(hgt.m ~ wgt.kg, data=bio))
filter(bio, wgt.kg > 250)$name
filter(bio, wgt.kg < 50)$name
filter(bio, hgt.m > 2.2)$name

fit <- lm(hgt.m ~ wgt.kg, data=bio)
summary(fit)
par(mfrow=c(2,2))
plot(fit)
summary(influence.measures(fit))

mean(bio$hgt.m, na.rm=T)
mean(bio$wgt.kg, na.rm=T)


events <- read.table('data/event.locations.tsv',header=T, sep='\t', stringsAsFactors=F)
winners.losers <- read.table('data/winners_losers.tsv',header=F, sep='\t', stringsAsFactors=F)
names(winners.losers) <- c('index','winner.id','evt.id', 'loser.id')

write.table(select(bio, wrestler.id, name), 'data/wrestlers.csv', sep=',', col.names=T, row.names=F)

evt.win.lose <- select(merge( winners.losers, events,by.x='evt.id', by.y='id'), evt.id, date, winner.id, loser.id)
evt.win.lose$date <- parse_date_time(evt.win.lose$date, "%Y/%m/%d")
evt.win.lose <- filter(evt.win.lose, !is.na(loser.id))

write.table(evt.win.lose, 'data/evt.win.lose.csv', sep=",", col.names=T, row.names=F)

