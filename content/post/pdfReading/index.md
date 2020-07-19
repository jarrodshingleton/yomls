---
authors:
- jarrod
categories: []
date: "2020-07-13T00:00:00Z"
draft: false
featured: false
image:
  caption: ""
  focal_point: ""
lastMod: "2020-07-13T00:00:00Z"
projects: []
subtitle: PDF Schmeedf. I can read from that! No Problem...right?
summary: PDF Schmeedf. I can read from that! No Problem...right?
tags: [R, models, ml, machine learning, data mining]
title: Reading Just a Bit from the Dastardly PDF.
---

Last week, one of my coworkers was asked to analyse some survey data. Unfortunately, much of that survey data was in the form of the dreaded pdf (portable document format, if you were ever curious). Now, sometimes pdf is not that difficult to deal with, when it is a small amount, like just one table. But, what is you have multiple pages and tables and things to take out of the pdf in question? That is what we are going to cover here.

Okay, first, I need a pdf to read. For this example, we are going to be reading in a file called [sample.pdf](https://github.com/jarrodshingleton/yomls/blob/master/content/post/pdfReading/samplePDF.pdf) I downloaded from http://www.africau.edu/. It is a very uncomplicated pdf that will serve nicely for this demonstration.

As with everything that we do in a programming language, there is an app for that. And this app (or package, in this case) is called **pdftools**. In addition, we will pull in **dplyr**, as it is one of my all time favorite packages.


```r
library(pdftools)
```

```
## Warning: package 'pdftools' was built under R version 3.6.2
```

```r
library(dplyr)
```

Now that we have our package, let's read in the pdf and see how terrible the format is to work with.


```r
pdf1<-pdf_text('samplePDF.pdf')
head(pdf1)
```

```
## [1] "A Simple PDF File\nThis is a small demonstration .pdf file -\njust for use in the Virtual Mechanics tutorials. More text. And more\ntext. And more text. And more text. And more text.\nAnd more text. And more text. And more text. And more text. And more\ntext. And more text. Boring, zzzzz. And more text. And more text. And\nmore text. And more text. And more text. And more text. And more text.\nAnd more text. And more text.\nAnd more text. And more text. And more text. And more text. And more\ntext. And more text. And more text. Even more. Continued on page 2 ...\n"
## [2] "Simple PDF File 2\n...continued from page 1. Yet more text. And more text. And more text.\nAnd more text. And more text. And more text. And more text. And more\ntext. Oh, how boring typing this stuff. But not as boring as watching\npaint dry. And more text. And more text. And more text. And more text.\nBoring. More, a little more text. The end, and just as well.\n"
```

The first thing you should notice (if you took a look at the pdf before this) is that each page is an item in a vector and the second thing is that there are these odd "\n" things all over the place. Those are the carriage returns in your pdf document and they are a good place to break up the document. Here I am going to do that.


```r
pdf1<-strsplit(pdf1, split="\n")
str(pdf1)
```

```
## List of 2
##  $ : chr [1:10] "A Simple PDF File" "This is a small demonstration .pdf file -" "just for use in the Virtual Mechanics tutorials. More text. And more" "text. And more text. And more text. And more text." ...
##  $ : chr [1:6] "Simple PDF File 2" "...continued from page 1. Yet more text. And more text. And more text." "And more text. And more text. And more text. And more text. And more" "text. Oh, how boring typing this stuff. But not as boring as watching" ...
```

```r
head(pdf1)
```

```
## [[1]]
##  [1] "A Simple PDF File"                                                     
##  [2] "This is a small demonstration .pdf file -"                             
##  [3] "just for use in the Virtual Mechanics tutorials. More text. And more"  
##  [4] "text. And more text. And more text. And more text."                    
##  [5] "And more text. And more text. And more text. And more text. And more"  
##  [6] "text. And more text. Boring, zzzzz. And more text. And more text. And" 
##  [7] "more text. And more text. And more text. And more text. And more text."
##  [8] "And more text. And more text."                                         
##  [9] "And more text. And more text. And more text. And more text. And more"  
## [10] "text. And more text. And more text. Even more. Continued on page 2 ..."
## 
## [[2]]
## [1] "Simple PDF File 2"                                                     
## [2] "...continued from page 1. Yet more text. And more text. And more text."
## [3] "And more text. And more text. And more text. And more text. And more"  
## [4] "text. Oh, how boring typing this stuff. But not as boring as watching" 
## [5] "paint dry. And more text. And more text. And more text. And more text."
## [6] "Boring. More, a little more text. The end, and just as well."
```

This splits the text up into more manageable bites, but puts them into a list. Lists are good and bad in R, but we will cover those more later. For now, you have the tool to pull in pdfs to R. Hooray!

**Warning**: This will not work for pdfs that are images. Those are the devil.
