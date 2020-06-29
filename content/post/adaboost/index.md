
---
authors:
- jarrod
categories: []
date: "2020-02-05T00:00:00Z"
draft: false
featured: false
image:
  caption: ""
  focal_point: ""
lastMod: "2020-09-05T00:00:00Z"
projects: []
subtitle: Using ADABoost to make your Random Forest models better
summary: Using ADABoost to make your Random Forest models better
tags: [randomforests, models, ml, machine learning]
title: Practical Application of ADABoost
---

Random Forest Modeling Overview
===============================

In this practical application exercise, you will:

-   Review on fitting a classification tree for the lecture (Default)
    dataset using provided code
-   Fit a random forest model to the same dataset using provided code

Step 1: Set Up R Environment for Lecture Example Analysis
=========================================================

Let’s begin by setting up our environment to continue with our lecture
examples. First, make sure you have all the needed packages loaded and
add some new ones for fitting Classification and Regression Trees
(CART), Random Forest Models, and for making some pretty pictures (note
- the standard way to do this in the R community is to always put the
needed libraries at the very top of your script, so adjust your script
file accordingly):

    ### Load needed libraries
    library(e1071)
    library(ISLR)

    ## Warning: package 'ISLR' was built under R version 3.5.3

    library(ggplot2)

    ## Warning: package 'ggplot2' was built under R version 3.5.1

    ## Warning: As of rlang 0.4.0, dplyr must be at least version 0.8.0.
    ## * dplyr 0.7.6 is too old for rlang 0.4.5.
    ## * Please update dplyr to the latest version.
    ## * Updating packages on Windows requires precautions:
    ##   <https://github.com/jennybc/what-they-forgot/issues/62>

    library(gridExtra)

    ## Warning: package 'gridExtra' was built under R version 3.5.1

    library(caret)

    # New model libraries
    library(rpart) # new library for CART modeling
    library(randomForest) # new library added for random forests and bagging

    # New package for making pretty pictures of CART trees
    library(rpart.plot)

    ## Warning: package 'rpart.plot' was built under R version 3.5.2

Step 2: Confirm Datasets Loaded and Visualize
=============================================

As a reminder of the data we are working with for the lecture examples,
here is a quick summary and plot of the “Default” dataset containing all
the data (this isn’t split into training and test datasets).

    # Partition of data set into 80% Train and 20% Test datasets
    set.seed(123)  # ensures we all get the sample sample of data for train/test

    sampler <- sample(nrow(Default),trunc(nrow(Default)*.80)) # samples index 

    LectureTrain <- Default[sampler,]
    LectureTest <- Default[-sampler,]

    # Create a plotting version of the Default dataset where we will store model predictions
    LectureTestPlotting <- LectureTest

    # Testing data summary
    summary(LectureTest)

    ##  default    student       balance           income     
    ##  No :1942   No :1393   Min.   :   0.0   Min.   : 1498  
    ##  Yes:  58   Yes: 607   1st Qu.: 474.8   1st Qu.:21334  
    ##                        Median : 839.1   Median :34277  
    ##                        Mean   : 838.4   Mean   :33235  
    ##                        3rd Qu.:1163.1   3rd Qu.:43579  
    ##                        Max.   :2461.5   Max.   :70022

    ## Plot Lecture Train Data
    plotTrain <- ggplot(data = LectureTrain,
                       mapping = aes(x = balance, y = income, color = default, shape = student)) +
      layer(geom = "point", stat = "identity", position = "identity") +
      scale_color_manual(values = c("No" = "blue", "Yes" = "red")) +
      theme_bw() +
      theme(legend.key = element_blank()) +
      labs(title = "Lecture Training Data")

    # Plot Lecture Test Data
    plotTest <- ggplot(data = LectureTest,
                        mapping = aes(x = balance, y = income, color = default, shape = student)) +
      layer(geom = "point", stat = "identity", position = "identity") +
      scale_color_manual(values = c("No" = "blue", "Yes" = "red")) +
      theme_bw() +
      theme(legend.key = element_blank()) +
      labs(title = "Lecture Test Data")
    grid.arrange(plotTrain, plotTest, nrow = 2)

![](ADABoost_files/figure-markdown_strict/Plotting%20Default%20Data-1.png)

Recall: CART model
==================

Step 3: Build a Classification Tree
-----------------------------------

As discussed in the lecture, random forest models are an extended
application of classification trees. Therefore, before fitting random
forest models, let’s fit a classification tree to our data and see how
we do (this will also allow us to see if extending to a random forest
model improves our performance). The code block below fits a
classification tree using the rpart package and then visualizes it using
the prp() function from the rpart.plot package.

    CART <- rpart(default ~., data=LectureTrain)
    summary(CART)

    ## Call:
    ## rpart(formula = default ~ ., data = LectureTrain)
    ##   n= 8000 
    ## 
    ##           CP nsplit rel error    xerror       xstd
    ## 1 0.13818182      0 1.0000000 1.0000000 0.05925676
    ## 2 0.06909091      1 0.8618182 0.8836364 0.05581775
    ## 3 0.04727273      2 0.7927273 0.8290909 0.05411979
    ## 4 0.01000000      3 0.7454545 0.8000000 0.05318920
    ## 
    ## Variable importance
    ## balance  income student 
    ##      93       4       3 
    ## 
    ## Node number 1: 8000 observations,    complexity param=0.1381818
    ##   predicted class=No   expected loss=0.034375  P(node) =1
    ##     class counts:  7725   275
    ##    probabilities: 0.966 0.034 
    ##   left son=2 (7758 obs) right son=3 (242 obs)
    ##   Primary splits:
    ##       balance < 1788.349 to the left,  improve=147.7756000, (0 missing)
    ##       student splits as  LR,           improve=  0.7963764, (0 missing)
    ##       income  < 19655.99 to the right, improve=  0.6427058, (0 missing)
    ## 
    ## Node number 2: 7758 observations
    ##   predicted class=No   expected loss=0.01740139  P(node) =0.96975
    ##     class counts:  7623   135
    ##    probabilities: 0.983 0.017 
    ## 
    ## Node number 3: 242 observations,    complexity param=0.06909091
    ##   predicted class=Yes  expected loss=0.4214876  P(node) =0.03025
    ##     class counts:   102   140
    ##    probabilities: 0.421 0.579 
    ##   left son=6 (145 obs) right son=7 (97 obs)
    ##   Primary splits:
    ##       balance < 1971.915 to the left,  improve=15.008780, (0 missing)
    ##       income  < 27777.45 to the left,  improve= 6.082185, (0 missing)
    ##       student splits as  RL,           improve= 3.300105, (0 missing)
    ##   Surrogate splits:
    ##       income < 49827.29 to the left,  agree=0.612, adj=0.031, (0 split)
    ## 
    ## Node number 6: 145 observations,    complexity param=0.04727273
    ##   predicted class=No   expected loss=0.4344828  P(node) =0.018125
    ##     class counts:    82    63
    ##    probabilities: 0.566 0.434 
    ##   left son=12 (84 obs) right son=13 (61 obs)
    ##   Primary splits:
    ##       income  < 27874.34 to the left,  improve=6.235656, (0 missing)
    ##       student splits as  RL,           improve=3.959527, (0 missing)
    ##       balance < 1890.639 to the left,  improve=2.831309, (0 missing)
    ##   Surrogate splits:
    ##       student splits as  RL,           agree=0.924, adj=0.820, (0 split)
    ##       balance < 1968.003 to the left,  agree=0.586, adj=0.016, (0 split)
    ## 
    ## Node number 7: 97 observations
    ##   predicted class=Yes  expected loss=0.2061856  P(node) =0.012125
    ##     class counts:    20    77
    ##    probabilities: 0.206 0.794 
    ## 
    ## Node number 12: 84 observations
    ##   predicted class=No   expected loss=0.3095238  P(node) =0.0105
    ##     class counts:    58    26
    ##    probabilities: 0.690 0.310 
    ## 
    ## Node number 13: 61 observations
    ##   predicted class=Yes  expected loss=0.3934426  P(node) =0.007625
    ##     class counts:    24    37
    ##    probabilities: 0.393 0.607

    # Make a plot of the classification tree rules
    prp(CART)

![](ADABoost_files/figure-markdown_strict/unnamed-chunk-2-1.png)

Look at that. You now have a visual summary of how the CART model (in
this case a classification model) is going to make a decision about
whether or not someone is going to default. CART models offer maximum
explainability. We have found that one of the great benefits to using
random forest models is that it is relatively easy to explain to people
how a random forest model works if you show them a CART output first
(hence this portion of the practical exercise). Let’s see how this model
performs on the test dataset:

    # Summarize and plot the performance of the classification tree

    # Get the probability classes for CART model applied to test dataset
    predClassCART <- predict(CART, newdata = LectureTest, type = "class")

    # Add to our plotting dataframe
    LectureTestPlotting$predClassCART <- predClassCART

    ## Plot the CART class
    plotClassCART <- ggplot(data = LectureTestPlotting,
                           mapping = aes(x = balance, y = income, color = predClassCART, shape = student)) +
      layer(geom = "point", stat = "identity", position = "identity") +
      scale_color_manual(values = c("No" = "blue", "Yes" = "red")) +
      theme_bw() +
      theme(legend.key = element_blank()) +
      labs(title = "Predicted class for CART Model")
    grid.arrange(plotTest, plotClassCART, nrow = 2)

![](ADABoost_files/figure-markdown_strict/unnamed-chunk-3-1.png)

    # Report confusion matrix from on the test dataset
    confusionMatrix(predClassCART, LectureTest$default)

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction   No  Yes
    ##        No  1926   39
    ##        Yes   16   19
    ##                                           
    ##                Accuracy : 0.9725          
    ##                  95% CI : (0.9644, 0.9792)
    ##     No Information Rate : 0.971           
    ##     P-Value [Acc > NIR] : 0.376621        
    ##                                           
    ##                   Kappa : 0.3954          
    ##  Mcnemar's Test P-Value : 0.003012        
    ##                                           
    ##             Sensitivity : 0.9918          
    ##             Specificity : 0.3276          
    ##          Pos Pred Value : 0.9802          
    ##          Neg Pred Value : 0.5429          
    ##              Prevalence : 0.9710          
    ##          Detection Rate : 0.9630          
    ##    Detection Prevalence : 0.9825          
    ##       Balanced Accuracy : 0.6597          
    ##                                           
    ##        'Positive' Class : No              
    ## 

Random Forest
=============

Step 4: Build a Random Forest Model
-----------------------------------

Fitting a random forest model in R using the randomForest package is a
simple extension of the syntax we’ve been using for all of the model
fitting. As an aside, for each of these models, you can learn about the
models by typing a question mark into the command line followed by the
command you want to investigate. For example, type the following into
your command line: ?randomForest.

You will see that in the lower right window of your RStudio instance,
you get a report that tells you about all of the parameters you can
adjust for your models. In this course, we are not going in depth into
the tuning of the models we are fitting (this is just an overview
course), but to become truly proficient in data science you should
understand all of these parameters and how to adjust them appropriately.

For this example, we are going to accept the package defaults, get
information about the predictor variable importance (importance = TRUE),
and fit 500 trees (ntrees = 500).

    # Applyrandom forests model having default target and rest as predictors
    RandomForest <- randomForest(default ~ ., data=LectureTrain, importance = TRUE, ntrees = 500)
    summary(RandomForest)

    ##                 Length Class  Mode     
    ## call                5  -none- call     
    ## type                1  -none- character
    ## predicted        8000  factor numeric  
    ## err.rate         1500  -none- numeric  
    ## confusion           6  -none- numeric  
    ## votes           16000  matrix numeric  
    ## oob.times        8000  -none- numeric  
    ## classes             2  -none- character
    ## importance         12  -none- numeric  
    ## importanceSD        9  -none- numeric  
    ## localImportance     0  -none- NULL     
    ## proximity           0  -none- NULL     
    ## ntree               1  -none- numeric  
    ## mtry                1  -none- numeric  
    ## forest             14  -none- list     
    ## y                8000  factor numeric  
    ## test                0  -none- NULL     
    ## inbag               0  -none- NULL     
    ## terms               3  terms  call

Now, let’s do the performance summaries on the test dataset that are
becoming standard (visualization and confusion matrix statistics).

    # Summarize and plot the performance of the random forest model

    # Get the probability of "yes" for default from second column
    predProbRF <- predict(RandomForest, newdata = LectureTest, type = "prob")[,2]

    # Get the predicted class
    predClassRF <- predict(RandomForest, newdata = LectureTest, type = "response")


    # Add to our plotting dataframe
    LectureTestPlotting$predProbRF <- predProbRF
    LectureTestPlotting$predClassRF <- predClassRF

    ## Plot the RF Probability
    plotProbRF <- ggplot(data = LectureTestPlotting,
                          mapping = aes(x = balance, y = income, color = predProbRF, shape = student)) +
      layer(geom = "point", stat = "identity", position = "identity") +
      scale_color_gradient(low = "blue", high = "red") +
      theme_bw() +
      theme(legend.key = element_blank()) +
      labs(title = "Predicted Probability for RF Model")

    # Plot the RF Class
    plotClassRF <- ggplot(data = LectureTestPlotting,
                            mapping = aes(x = balance, y = income, color = predClassRF, shape = student)) +
      layer(geom = "point", stat = "identity", position = "identity") +
      scale_color_manual(values = c("No" = "blue", "Yes" = "red")) +
      theme_bw() +
      theme(legend.key = element_blank()) +
      labs(title = "Predicted Class for RF Model")

    # Standard Performance Plot
    grid.arrange(plotTest, plotProbRF, plotClassRF, nrow = 3)

![](ADABoost_files/figure-markdown_strict/unnamed-chunk-6-1.png)

    # Report confusion matrix from on the test dataset
    confusionMatrix(predClassRF , LectureTest$default)

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction   No  Yes
    ##        No  1931   43
    ##        Yes   11   15
    ##                                           
    ##                Accuracy : 0.973           
    ##                  95% CI : (0.9649, 0.9797)
    ##     No Information Rate : 0.971           
    ##     P-Value [Acc > NIR] : 0.3264          
    ##                                           
    ##                   Kappa : 0.3454          
    ##  Mcnemar's Test P-Value : 2.459e-05       
    ##                                           
    ##             Sensitivity : 0.9943          
    ##             Specificity : 0.2586          
    ##          Pos Pred Value : 0.9782          
    ##          Neg Pred Value : 0.5769          
    ##              Prevalence : 0.9710          
    ##          Detection Rate : 0.9655          
    ##    Detection Prevalence : 0.9870          
    ##       Balanced Accuracy : 0.6265          
    ##                                           
    ##        'Positive' Class : No              
    ## 

Save your stuff!
