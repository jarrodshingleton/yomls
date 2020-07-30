---
title: "Let's get some INTERESTING data!!"
subtitle: 

authors:
- jarrod
categories: []
date: "2020-07-29T00:00:00Z"
draft: false
featured: false
image:
  caption: ""
  focal_point: ""
lastMod: "2020-07-29T00:00:00Z"
projects: []

summary: Some text manipulation, visualization techniques and analysis. 
tags: [R, models, ml, machine learning, data mining, text analytics, sentiment analysis, word clouds]

---

Last week's sentiment analysis was, to put it bluntly, pretty dern boring. It would be a lot more interesting if we could pull in and evaluate something with a little more....umpf. How about we take a look at anyone that mentions Donald Trump!

The main package for the scraping we will need is called "twitteR." Pretty good name, huh? I didn't make it up, but I appreciate any joke used in the context of R.

```r
library(twitteR)
```

To use this appropriately named package, you first need to have a twitter account. So, go make a twitter account!

Now, if you have a twitter account, you can go here: https://apps.twitter.com, and click on "Create New App." Call it whatever you want. you just want the things from the API, not really anything in the API.

Now, you need four things:

API_key
API_secret_key 
access_token
access_token_secret

No, I am not going to give you mine. Go get your own! It is free! Now we can connect to our API and bring in some tweets! Lets start with 1000 tweets. Trust me, there are going to be MANY more tweets with the name "Trump" in them! notice that I am only going to use "Trump" in my search, as opposed to "Donald Trump" so I might pull in some family stuff, but that is okay.


```r
setup_twitter_oauth(API_key, API_secret_key, access_token, access_token_secret)

twitter <- searchTwitter("Donald Trump",n=1000,lang="en")

```

Great! Now I have a bunch of tweets....but they come in as a JSON. We don't want a JSON. We want a dataframe. Thankfully, there is a function for that.

```r
test1<-twListToDF(twitter)
```

Now take a look at this dataframe.

```r
head(test1)

```

There is a WHOLE BUNCH of stuff that we are not particularly concerned with, but maybe we could use later. We really only want to take a look at the "text" column. Then we can take it through the hoops that we took the boring dataset through last week!

Remember, we need a couple of packages.

```r
library(tm)
library(ggplot2)
library(dplyr)

corpus<-iconv(pdf1)
corpus<-Corpus(VectorSource(corpus))
```

We are going to do a little more extensive cleaning than we did last time with this data. That is because tweets keep a how bunch of stuff (retweets, URLs, stuff). Here we get rid of that stuff.

```r
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
cleanset<-tm_map(corpus, stripWhitespace)
```

Now we are going to turn this into a Term Document Matrix and see what pops out.

```r
tdm<-as.matrix(TermDocumentMatrix(cleanset))
w<-rowSums(tdm)
w<-sort(rowSums(tdm), decreasing=TRUE)
w2<-data.frame(names(w), w)
names(w2)<-c("word","freq")
w2$word <- factor(w2$word, levels = w2$word[order(w2$freq,decreasing=TRUE)])
head(w2)
```


```
##          word freq
## donald donald  747
## trump   trump  704
## now       now   93
## trumps trumps   91
## …           …   91
## must     must   77
```

Okay. That is a bummer so we are also going to supress the words "Donald", "trump", and "trumps" as we already know that is what we are looking at. When you are performing a twitter scrape like this, you may have to go back and remove some of the words after scraping.

```r
corpus<-tm_map(corpus, removeWords, c("trump", "donald", "trumps")) 
cleanset<-tm_map(corpus, stripWhitespace)

tdm<-as.matrix(TermDocumentMatrix(cleanset))
w<-rowSums(tdm)
w<-sort(rowSums(tdm), decreasing=TRUE)
w2<-data.frame(names(w), w)
names(w2)<-c("word","freq")
w2$word <- factor(w2$word, levels = w2$word[order(w2$freq,decreasing=TRUE)])
head(w2)
```

```
##        word freq
## …         …   97
## now     now   93
## must   must   77
## white white   75
## ’s       ’s   72
## like   like   71
```

Well, not perfect and still a little wonky, but it will work for our purposes. Now we can use the same code that we used last week and see what we get!

One more package to load.

```r
library(wordcloud)
```

```r
set.seed(222)
wordcloud(words=w2$word, freq=w2$freq, max.words=50,
          min.freq=2, colors=brewer.pal(8, 'Dark2'),
          scale=c(7, 0.3),
          rot.per=0.3)
```

![](twitterScrape_files/figure-html/cloud1.png)<!-- -->

That is just chalk full of unhappy words. "Corrupted", "fire", "uncle!" Terrible. What does sentiment say about this?

Remember, we need the "syuzhet" package for this part.

```r
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
```

![](twitterScrape_files/figure-html/sentiment1.png)<!-- -->

Hunh. Not at all what I would have thought looking at the word cloud, but not overly negative and "trust" is WAY up there. Well, good for him. Maybe another 4 years IS in the cards?
