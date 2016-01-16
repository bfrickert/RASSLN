name = 'Randy Savage'

library(plyr)
library(dplyr)
library(igraph)
library(tm)
library(lazyeval)
library(caret)
setwd('/home/ubuntu/RASSLN')
#full <- read.table('data/wwe_full.tsv',sep='\t',stringsAsFactors = F, header=T, fill=T, row.names = NULL, quote = "")

evt.win.lose <- read.csv('data/evt.win.lose.csv')
evt.locations <- read.table('data/event.locations.tsv',sep='\t',header=T,stringsAsFactors = F)
wrestlers <- read.table('data/bio.tsv',sep='\t',header = F, stringsAsFactors = F)
names(wrestlers) <- c('wrestler.id', 'name', 'wgt','hgt','trademark.moves','finishers')
full <- merge(evt.win.lose, wrestlers, by.x='winner.id', by.y='wrestler.id')
full <- merge(full, wrestlers, by.x='loser.id', by.y='wrestler.id')
names(full) <- c('winner.id','loser.id', 'evt.id','date', 'winner.name','winner.wgt','winner.hgt',
                 'winner.trademark.moves','winner.finishers','loser.name','loser.wgt','loser.hgt',
                 'loser.trademark.moves', 'loser.finishers')

rm(evt.win.lose);rm(evt.locations);rm(wrestlers)
muraco <- filter(full, winner.name == name | loser.name == name)
net <- graph.data.frame(select(muraco, winner.name, loser.name), directed=T)
#e<-edge.betweenness.community(net)

par(mfrow=c(2,3))
plot(net)
sort(degree(net),decreasing=F)
set.seed(666)

losses <- filter(full, loser.name == name)
wins <- filter(full, winner.name == name)

mean(c(rep(1, nrow(filter(full, winner.name==name))), rep(0, nrow(filter(full, loser.name == name)))))

unlink('tsvs/winner_trademark_moves/*');unlink('tsvs/loser_trademark_moves/*')
sapply(100000:(100000+nrow(losses)), function(i) {write.table(losses[i-100000,8:9], paste('tsvs/winner_trademark_moves/',i,'.tsv',sep=''),sep='\t')})
sapply(100000:(100000+nrow(wins)), function(i) {write.table(wins[i-100000,13:14], paste('tsvs/loser_trademark_moves/',i,'.tsv',sep=''),sep='\t')})

dest <- 'tsvs/winner_trademark_moves'

# create corpus
win.docs <- Corpus(DirSource(dest,pattern="tsv"))
rm(dest)
# remove numbers
win.docs <- tm_map(win.docs, removeNumbers)

win.docs <- tm_map(win.docs, content_transformer(tolower))
win.docs <- tm_map(win.docs, removePunctuation)
win.docs <- tm_map(win.docs, removeWords, stopwords("english"))
library(SnowballC)
win.docs <- tm_map(win.docs, stemDocument)
detach('package:SnowballC')
win.docs <- tm_map(win.docs, stripWhitespace)
#win.tdm <- TermDocumentMatrix(win.docs)
win.dtm <- DocumentTermMatrix(win.docs)   
rm(win.docs)
freq <- colSums(as.matrix(win.dtm))   

ord <- order(freq)   

win.m <- as.matrix(win.dtm)   
#write.csv(win.m, file="win.dtm.csv")
rm(win.dtm)
df.win.dtm <- data.frame(win.m) #read.table("data/win.dtm.csv",sep=',',header=T,stringsAsFactors = F)
rm(win.m)

# most frequent terms
freq[tail(ord,n=25)]

#win.dtms <- removeSparseTerms(win.dtm, 0.3)
#win.dtms

# find terms with higest frequency
# low freq chosen to produce most frequent
findFreqTerms(win.dtm, lowfreq=15)

# find words with high correlation to state
findAssocs(win.dtm,term="clutch", corlimit=0.2)

# make a plot of freq terms with correlation above .6
#plot(win.dtm,terms =findFreqTerms(win.dtm, lowfreq=80))

dest <- 'tsvs/loser_trademark_moves'

# create corpus
lose.docs <- Corpus(DirSource(dest,pattern="tsv"))
#rm(cats)
rm(dest)
# remove numbers
lose.docs <- tm_map(lose.docs, removeNumbers)

lose.docs <- tm_map(lose.docs, content_transformer(tolower))
lose.docs <- tm_map(lose.docs, removePunctuation)
lose.docs <- tm_map(lose.docs, removeWords, stopwords("english"))
library(SnowballC)
lose.docs <- tm_map(lose.docs, stemDocument)
detach('package:SnowballC')
lose.docs <- tm_map(lose.docs, stripWhitespace)
#lose.tdm <- TermDocumentMatrix(lose.docs)
lose.dtm <- DocumentTermMatrix(lose.docs)   
rm(lose.docs)
freq <- colSums(as.matrix(lose.dtm))   

ord <- order(freq)   

lose.m <- as.matrix(lose.dtm)   
#write.csv(lose.m, file="lose.dtm.csv")
rm(lose.dtm)
df.lose.dtm <- data.frame(lose.m) # read.table("lose.dtm.csv",sep=',',header=T,stringsAsFactors = F)
rm(lose.m);

# most frequent terms
freq[tail(ord,n=25)]

#lose.dtms <- removeSparseTerms(lose.dtm, 0.3)
#lose.dtms

# find terms with higest frequency
# low freq chosen to produce most frequent
findFreqTerms(lose.dtm, lowfreq=15)

# find words with high correlation to state
findAssocs(lose.dtm,term="clutch", corlimit=0.2)

# make a plot of freq terms with correlation above .6
#plot(lose.dtm,terms =findFreqTerms(lose.dtm, lowfreq=80))
rm(freq);rm(ord)

names<-intersect(names(df.win.dtm),names(df.lose.dtm))
df.dtm <- rbind(select(df.win.dtm, one_of(names)),select(df.lose.dtm, one_of(names)))
df.dtm$win.loss <- factor(c(rep(0,nrow(df.win.dtm)),rep(1,nrow(df.lose.dtm))))
rm(df.lose.dtm);rm(df.win.dtm);rm(names)


trainIndex <- createDataPartition(df.dtm$win.loss, p = .7, list = FALSE)
train <- df.dtm[trainIndex,]
test <- df.dtm[-trainIndex,]
rm(trainIndex)

myLogit <- glm(win.loss~.,data=train,family=binomial(link='logit'))

# coefs <- data.frame(summary(myLogit)$coef)
# coefs$name <- row.names(coefs)
# names(coefs) <- c('estimate','se','t.val','p.val', 'name')
# prime.coefs <- arrange(filter(coefs, p.val<.05),p.val)
# rm(coefs)
# train <- train[,colnames(train)%in%c('win.loss', prime.coefs$name)]
# test <- test[,colnames(test)%in%c('win.loss', prime.coefs$name)]
# myLogit <- glm(win.loss~.,data=train,family=binomial(link='logit'))

#summary(myLogit)
plot(myLogit)

fitted.results <- predict(myLogit,newdata=select(test, -win.loss),type='response')
fitted.results <- ifelse(fitted.results > 0.5,1,0)

misClasificError <- mean(fitted.results != test$win.loss)
print(paste('Accuracy:',1-misClasificError))
print(paste('Record:', mean(c(rep(1, nrow(filter(full, winner.name==name))), rep(0, nrow(filter(full, loser.name == name)))))))

table(fitted.results,test$win.loss)

library(ROCR)
p <- fitted.results
pr <- prediction(p, test$win.loss)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)

auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc
par(mfrow=c(1,1))
print(paste('People', name, 'wrestles most:'))
sort(degree(net),decreasing=T)[2:5]
print(paste('People', name, 'has beaten most:'))
sort(table(wins$loser.name),decreasing=T)[2:5]
print(paste('People', name, 'has been bested by most:'))
sort(table(losses$winner.name),decreasing=T)[2:5]

coefs <- data.frame(summary(myLogit)$coef)
coefs$name <- row.names(coefs)
names(coefs) <- c('estimate','se','t.val','p.val', 'name')
head(rbind(coefs[1,],arrange(coefs[2:nrow(coefs),],desc(estimate))))
rbind(coefs[1,],tail(arrange(coefs[2:nrow(coefs),],desc(estimate))))

#sort(na.omit(coef(myLogit)),decreasing = T)
rm(list=ls())
gc()
