library(pdftools)

pdf1<-pdf_text('samplePDF.pdf')

pdf1<-unlist(strsplit(pdf1, split="\n"))
pdf1<-unlist(pdf1)


library(tm)

##clean the corpus  

corpus<-iconv(pdf1)
corpus<-Corpus(VectorSource(corpus))
corpus<-tm_map(corpus, tolower)
corpus<-tm_map(corpus, removePunctuation)
corpus<-tm_map(corpus, removeNumbers)
corpus<-tm_map(corpus, removeWords, stopwords('english'))  ##stopwords where are spanish!

cleanset<-tm_map(corpus, stripWhitespace)

tdm<-as.matrix(TermDocumentMatrix(cleanset))

w<-rowSums(tdm)
w<-sort(rowSums(tdm), decreasing=TRUE)
w2<-data.frame(names(w), w)
names(w2)<-c("word","freq")
w2$word <- factor(w2$word, levels = w2$word[order(w2$freq,decreasing=TRUE)])
head(w2)


set.seed(222)
wordcloud(words=w2$word, freq=w2$freq, max.words=50,
          min.freq=2, colors=brewer.pal(8, 'Dark2'),
          scale=c(7, 0.3),
          rot.per=0.3)

wordvect<-rep(w2$word, w2$freq)
wordvect<-as.character(wordvect)

s<-get_nrc_sentiment(wordvect, language="english")

head(s)

test1<-as.data.frame(colSums(s))
names(test1)<-"Count"
test1$names<-rownames(test1)
test1$names<-as.factor(test1$names)
test1$names<-factor(test1$names, levels=c("anger","anticipation" ,"disgust"  ,    "fear"      ,   "joy"     ,     "sadness"  ,    "surprise",
                                          "trust","negative"  ,   "positive" ))
g<-ggplot(test1)+geom_bar(aes(x=names, y=Count), stat="identity")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  xlab("")+
  ylab("")
g

#TWITTER SCRAPING

library(twitteR)


API_key <- "L7oKkOZiakiR9Pjo8JJwdB5s4"
API_secret_key <- "CfERHt7LNYp26rN1K0I6dfqw0rrtdOElnDKklwqd23vT43Zq17"
access_token <- "3308105699-HnRqWwEwWShMCBUvReUxeXX2odw4IyC5mUhcavM"
access_token_secret <- "yxKMrcmCr6jrL9VPfNgNv2PY1HMQhsoVFrk5526KnT4Sq"

setup_twitter_oauth(API_key, API_secret_key, access_token, access_token_secret)

twitter <- searchTwitter("Donald Trump",n=1000,lang="en")


twitter<-fn_twitter


library(tm)

test1<-twListToDF(twitter)

library(tm)
library(ggplot2)
library(dplyr)

corpus<-iconv(test1$text)
corpus<-Corpus(VectorSource(corpus))



removeURL<-function(x) gsub(" ?(f|ht)tp(s?)://(.*)[.][a-z]+", "", x) ##remove URL
removeEmo<-function(x) gsub("<.*>", "", x) ## remove emojis
removeAmp<-function(x) gsub("&amp;", "", x) ## remove &
removeRetweets<-function(x) gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", x)
## remove retweet entities
removeAts<-function(x) gsub("@\\w+", "", x) ## remove at people
##clean the corpus
corpus<-tm_map(corpus, tolower)
corpus<-tm_map(corpus, content_transformer(removeEmo))
corpus<-tm_map(corpus, content_transformer(removeURL))
corpus<-tm_map(corpus, content_transformer(removeAmp))
corpus<-tm_map(corpus, content_transformer(removeRetweets))
corpus<-tm_map(corpus, content_transformer(removeAts))
corpus<-tm_map(corpus, removePunctuation)
corpus<-tm_map(corpus, removeNumbers)
corpus<-tm_map(corpus, removeWords, stopwords('english')) 

corpus<-tm_map(corpus, removeWords, c("trump", "donald", "trumps")) 
cleanset<-tm_map(corpus, stripWhitespace)

tdm<-as.matrix(TermDocumentMatrix(cleanset))
w<-rowSums(tdm)
w<-sort(rowSums(tdm), decreasing=TRUE)
w2<-data.frame(names(w), w)
names(w2)<-c("word","freq")
w2$word <- factor(w2$word, levels = w2$word[order(w2$freq,decreasing=TRUE)])
head(w2)



library(wordcloud)

set.seed(222)
wordcloud(words=w2$word, freq=w2$freq, max.words=100,
          min.freq=2, colors=brewer.pal(8, 'Dark2'),
          scale=c(5, 0.3),
          rot.per=0.3)


library(syuzhet)

wordvect<-rep(w2$word, w2$freq)
wordvect<-as.character(wordvect)

s<-get_nrc_sentiment(wordvect, language="english") #this package has sentiment
##for multiple languages!!

test1<-as.data.frame(colSums(s))
names(test1)<-"Count"
test1$names<-rownames(test1)
test1$names<-as.factor(test1$names)
test1$names<-factor(test1$names, levels=c("anger","anticipation" ,"disgust"  ,    "fear"      ,   "joy"     ,     "sadness"  ,    "surprise",
                                          "trust","negative"  ,   "positive" ))
g<-ggplot(test1)+geom_bar(aes(x=names, y=Count), stat="identity")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  xlab("")+
  ylab("")
g
