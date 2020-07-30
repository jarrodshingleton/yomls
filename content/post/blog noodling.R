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


