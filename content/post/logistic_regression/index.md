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
subtitle: Picking between two choices - Which one is it?
summary: Picking between two choices - Which one is it?
tags: [R, models, ml, machine learning]
title: An Intro to Logistic Regression
---



(Logistic Regressions) Overview

In this practical exercise, you'll first run through a logistic
regression exercise on a small, well-known dataset so that you can see
how to use the code to develop a logistic regression model. Let's get
started.

Step 1: Set up R environment for Lecture Example Analysis
=========================================================

First, as usual, set the working directory.

setwd()

Remember, if you can't get the setwd (set working directory) function to
work, try ?setwd to get some additional help.

Since we'll be conducting two different analyses for this practical
exercise (including the take home lab), you'll need to create a new
script file for the class examples. For this week, we will work on
classifications, so let's make a new R file called "LectureExampleData2"
for In-Class lab and "LabExampleData2" for the Take-Home Lab.

This week, we will use the R packages *ggplot2*, *gridExtra*, and
*caret.* You need to install them by using the *install.packages()*
function.

To begin, we will clear our current workspace (get rid of any saved
variables) and load a few packages that we'll use for the example
analysis. Cut and paste the following commands into your new script file
and run them:

    rm(list=ls())  ##clears the environment

    ## Library for An Introduction to Statistical Learning with Applications in R
    library(ISLR)

    ## Warning: package 'ISLR' was built under R version 3.5.3

    ## Libraries for Plotting our Results
    library(ggplot2)

    ## Warning: package 'ggplot2' was built under R version 3.5.1

    ## Warning: As of rlang 0.4.0, dplyr must be at least version 0.8.0.
    ## * dplyr 0.7.6 is too old for rlang 0.4.5.
    ## * Please update dplyr to the latest version.
    ## * Updating packages on Windows requires precautions:
    ##   <https://github.com/jennybc/what-they-forgot/issues/62>

    library(gridExtra)

    ## Warning: package 'gridExtra' was built under R version 3.5.1

    ## Library for confusion matrix
    library(caret)

    ## Loading required package: lattice

Note that if you look in the "Environment" window in your upper right
hand column, all of the objects you created with your previous code have
been erased from memory. You are restarting with a blank slate.

Step 2: Load, Visualize, and Split (Training vs. Test) Data Sets
================================================================

Now, let's bring in the dataset that we'll be working with for the
example. this is a simulated datasheet titled "Default" containing
information on ten-thousand credit customers provided in *ISLR*. We will
use the "Default" dataset to illustrate the concept of classification by
fitting several different machine learning models to the data over the
course of several practical application exercises. For these examples,
we will develop models to "predict whether an individual will default on
his or her credit card payment, on the basis of annual income and
monthly credit card balance." (James et al, 2013, p. 128).

"Default" dataset is in the "ISLR" library.

    ##Load Default (Credit Card Default Data)
    data(Default)

    #Display the first few rows of data
    head(Default)

    ##   default student   balance    income
    ## 1      No      No  729.5265 44361.625
    ## 2      No     Yes  817.1804 12106.135
    ## 3      No      No 1073.5492 31767.139
    ## 4      No      No  529.2506 35704.494
    ## 5      No      No  785.6559 38463.496
    ## 6      No     Yes  919.5885  7491.559

    ## Provide a summary of the data
    summary(Default)

    ##  default    student       balance           income     
    ##  No :9667   No :7056   Min.   :   0.0   Min.   :  772  
    ##  Yes: 333   Yes:2944   1st Qu.: 481.7   1st Qu.:21340  
    ##                        Median : 823.6   Median :34553  
    ##                        Mean   : 835.4   Mean   :33517  
    ##                        3rd Qu.:1166.3   3rd Qu.:43808  
    ##                        Max.   :2654.3   Max.   :73554

Looking at the data, you will see that the response variable stored in
the column "default" which indicates whether or not a person defaulted
on their payment. There is a categorical variable titled "student"
indicating student status and two numeric variables, "balance" and
"income."

Let's plot the data based on the two numeric attributes to get a sense
of what the data looks like using the *ggplot2* package. take careful
note of how we use various aesthetics to change the formatting of the
plot (color, shape, etc.):

    ## Plot the actual data
    plotData <- ggplot(data = Default,
           mapping = aes(x = balance, y = income, color = default, shape = student)) +
        layer(geom = "point", stat = "identity", position = "identity") +
        scale_color_manual(values = c("No" = "blue", "Yes" = "red")) +
        theme_bw() +
        theme(legend.key = element_blank()) +
        labs(title = "Original data")
    plotData

![](Logistic-Regression_files/figure-markdown_strict/unnamed-chunk-4-1.png)

We have seen *ggplot2* before so this should be at least a little
familiar. If you want to know more on *ggplot2*, type "?ggplot2."

We can see in the plot above that there is no "clean break" or simple
rule that divides those that default from those that don't. We will try
several different modeling approaches to find a best policy over the
next few practical application exercises.

Before we begin fitting models, we need to break the data into a train
and a test Dataset. We will split the Default dataset into a training
dataset that includes 9-% of the observations and a test dataset that
includes 20% of our observations. We do this by generating a sample of
index values and then pulling data out of the Default dataframe based on
the sample.

    # Partition of data set into 80% Train and 20% Test datasets
    set.seed(123)  # ensures we all get the sample sample of data for train/test

    sampler <- sample(nrow(Default),trunc(nrow(Default)*.80)) # samples index 

    LectureTrain <- Default[sampler,]
    LectureTest <- Default[-sampler,]

Setp 3: Fit a Logistic Regression Model
=======================================

The code blocks below fit two different logistic regression models. The
first one uses R's shorthand notation of a period for fitting a model
using all features (response variable ~.). The second model uses only
the two numeric predictors, and uses the *scale()* command to center the
scale on the numeric data. The summary command provides a summary of the
model fit (as discussed in the lecture).

Notice that we are using the *glm* function and not the *lm* function,
but to use this, we need to tell the function what type of model we want
to fit. If you set "family" to "gaussian," you would get normal linear
regression.

To use the glm() function for logistic regress, you have to set the
parameter "family = binomial(link="logit")."

    Logit1 <- glm(formula = default ~ .,
                   family  = binomial(link = "logit"),
                   data    = LectureTrain)
    summary(Logit1)

    ## 
    ## Call:
    ## glm(formula = default ~ ., family = binomial(link = "logit"), 
    ##     data = LectureTrain)
    ## 
    ## Deviance Residuals: 
    ##     Min       1Q   Median       3Q      Max  
    ## -2.5837  -0.1364  -0.0507  -0.0179   3.7806  
    ## 
    ## Coefficients:
    ##               Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept) -1.156e+01  5.687e-01 -20.320   <2e-16 ***
    ## studentYes  -4.394e-01  2.672e-01  -1.645    0.100    
    ## balance      5.983e-03  2.692e-04  22.225   <2e-16 ***
    ## income       1.098e-05  9.185e-06   1.195    0.232    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for binomial family taken to be 1)
    ## 
    ##     Null deviance: 2394.2  on 7999  degrees of freedom
    ## Residual deviance: 1239.5  on 7996  degrees of freedom
    ## AIC: 1247.5
    ## 
    ## Number of Fisher Scoring iterations: 8

    ## Fit logistic regression using only scaled numerical predictors
    Logit2 <- glm(formula = default ~ scale(balance) + scale(income),
                   family  = binomial(link = "logit"),
                   data    = LectureTrain)
    summary(Logit2)

    ## 
    ## Call:
    ## glm(formula = default ~ scale(balance) + scale(income), family = binomial(link = "logit"), 
    ##     data = LectureTrain)
    ## 
    ## Deviance Residuals: 
    ##     Min       1Q   Median       3Q      Max  
    ## -2.5842  -0.1374  -0.0519  -0.0182   3.7796  
    ## 
    ## Coefficients:
    ##                Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept)    -6.29438    0.21907 -28.733  < 2e-16 ***
    ## scale(balance)  2.86579    0.12814  22.365  < 2e-16 ***
    ## scale(income)   0.30627    0.07449   4.111 3.93e-05 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for binomial family taken to be 1)
    ## 
    ##     Null deviance: 2394.2  on 7999  degrees of freedom
    ## Residual deviance: 1242.2  on 7997  degrees of freedom
    ## AIC: 1248.2
    ## 
    ## Number of Fisher Scoring iterations: 8

We can see that the first model using all of the predictors provides a
better fit (as we would expect). However, better fit on the training
data often does not necessarily lead to a better model fit on out of
sample test data. Selecting the subset of features that provides the
best model is a large (unsolved) problem in data science, but there are
some algorithmic procedures for doing so that provide some benefit.
We'll use one automated procedure called stepwise modeling below.

Step 4: Stepwise Model Selection (Feature Subsetting)
=====================================================

Please see the section starting at page 205 in *ISLR* (James et al,
2013) for an in-depth discussion of model selection. For this practical
exercise, we'll apply the automated Stepwise model selection approach to
the model that has all of our predictors using the code below.

    # Conduct stepwise model selection
    LogitStep<-step(Logit1, direction = "both")

    ## Start:  AIC=1247.51
    ## default ~ student + balance + income
    ## 
    ##           Df Deviance    AIC
    ## - income   1   1240.9 1246.9
    ## <none>         1239.5 1247.5
    ## - student  1   1242.2 1248.2
    ## - balance  1   2378.6 2384.6
    ## 
    ## Step:  AIC=1246.94
    ## default ~ student + balance
    ## 
    ##           Df Deviance    AIC
    ## <none>         1240.9 1246.9
    ## + income   1   1239.5 1247.5
    ## - student  1   1259.2 1263.2
    ## - balance  1   2382.8 2386.8

    # Summarize the selected model
    summary(LogitStep)

    ## 
    ## Call:
    ## glm(formula = default ~ student + balance, family = binomial(link = "logit"), 
    ##     data = LectureTrain)
    ## 
    ## Deviance Residuals: 
    ##     Min       1Q   Median       3Q      Max  
    ## -2.5455  -0.1354  -0.0506  -0.0178   3.7988  
    ## 
    ## Coefficients:
    ##               Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept) -1.112e+01  4.301e-01  -25.86  < 2e-16 ***
    ## studentYes  -6.885e-01  1.651e-01   -4.17 3.05e-05 ***
    ## balance      5.990e-03  2.691e-04   22.26  < 2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for binomial family taken to be 1)
    ## 
    ##     Null deviance: 2394.2  on 7999  degrees of freedom
    ## Residual deviance: 1240.9  on 7997  degrees of freedom
    ## AIC: 1246.9
    ## 
    ## Number of Fisher Scoring iterations: 8

Once the code runs, you can see that the model selected using The
stepwise procedure uses only two of the predictors variables: student (a
categorical Yes/No variable) and balance (a numeric variable). Now,
let's take a quick look at model performance.

Step 5: Visualization and Performance of Model
==============================================

Now that we've picked a model, let's add the predictions made to our
dataset. We evaluate performance on the "held out" test dataset (i.e.
data that wasn't used to fit the model). The code block below creates a
version of the Test dataset for plotting purposes and adds the resulting
predictions to the dataframe. The column "predProbLogit" adds the
probability calculated by the final logit model for each observation in
the test dataset. The column "predClassLogit" adds the resulting
prediction on the test dataset when the value 0.5 is used as the
classification threshold. We again use the *summary()* command to get a
quick look at the resulting data.

    # Put the predicted probability and class (at 0.5 threshold) at the end of the dataframe
    predProbLogit <- predict(LogitStep, type = "response", newdata = LectureTest)
    predClassLogit <- factor(predict(LogitStep, type = "response", newdata=LectureTest) > 0.5, levels = c(FALSE,TRUE), labels = c("No","Yes"))

    # Create a plotting version of the Default dataset where we will store model predictions
    LectureTestPlotting <- LectureTest

    # Put the predicted probability and class (at 0.5 threshold) at the end of the plotting dataframe
    LectureTestPlotting$predProbLogit <- predProbLogit
    LectureTestPlotting$predClassLogit <- predClassLogit

    summary(LectureTestPlotting)  # look at a summary of the updated data frame

    ##  default    student       balance           income      predProbLogit      
    ##  No :1942   No :1393   Min.   :   0.0   Min.   : 1498   Min.   :0.0000074  
    ##  Yes:  58   Yes: 607   1st Qu.: 474.8   1st Qu.:21334   1st Qu.:0.0002136  
    ##                        Median : 839.1   Median :34277   Median :0.0017802  
    ##                        Mean   : 838.4   Mean   :33235   Mean   :0.0336231  
    ##                        3rd Qu.:1163.1   3rd Qu.:43579   3rd Qu.:0.0118639  
    ##                        Max.   :2461.5   Max.   :70022   Max.   :0.9494902  
    ##  predClassLogit
    ##  No :1971      
    ##  Yes:  29      
    ##                
    ##                
    ##                
    ## 

Now we can make a visualization to take a look at how the model fit the
test data. The top row below shows the actual results in the test
dataset. The second row shows the probabilistic prediction made by the
model. The third row shows the classification made by the model on the
test dataset when 0.5 is used as the classification threshold.

    # Plot the actual test data
    plotTest<-ggplot(data = LectureTestPlotting,
                     mapping = aes(x = balance, y = income, color = default, shape = student)) +
      layer(geom = "point", stat = "identity", position = "identity") +
      scale_color_manual(values = c("No" = "blue", "Yes" = "red")) +
      theme_bw() +
      theme(legend.key = element_blank()) +
      labs(title = "Test Data")

    plotLogit <- ggplot(data = LectureTestPlotting,
                        mapping = aes(x = balance, y = income, color = predProbLogit, shape = student)) +
      layer(geom = "point",stat = "identity", position = "identity") +
      scale_color_gradient(name="Default", low = "blue", high = "red") +
      theme_bw() +
      theme(legend.key = element_blank()) +
      labs(title = "Predicted probability of outcome (Logistic)")

    ## Plot the class using threshold of 0.5
    plotLogitClass <- ggplot(data = LectureTestPlotting,
                             mapping = aes(x = balance, y = income, color = predClassLogit, shape = student)) +
      layer(geom = "point", stat = "identity", position = "identity") +
      scale_color_manual(name="Default", values = c("No" = "blue", "Yes" = "red")) +
      theme_bw() +
      theme(legend.key = element_blank()) +
      labs(title = "Predicted outcome (Logistic; p>0.5)")

    # Plot original data (top row) and predicted probability (bottom row)
    grid.arrange(plotTest, plotLogit, plotLogitClass, nrow = 3)

![](Logistic-Regression_files/figure-markdown_strict/unnamed-chunk-11-1.png)

Finally, let's calculate some performance statistics on the test data.
We can get the full suite of performance statistics based on the
confusion matrix using the *confusionMatrix()* command provided by the
caret packages.

    # Generate a confusion matrix and performance statistics on test dataset
    confusionMatrix(data=predClassLogit, reference=LectureTest$default) 

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction   No  Yes
    ##        No  1928   43
    ##        Yes   14   15
    ##                                           
    ##                Accuracy : 0.9715          
    ##                  95% CI : (0.9632, 0.9783)
    ##     No Information Rate : 0.971           
    ##     P-Value [Acc > NIR] : 0.4817656       
    ##                                           
    ##                   Kappa : 0.3319          
    ##  Mcnemar's Test P-Value : 0.0002083       
    ##                                           
    ##             Sensitivity : 0.9928          
    ##             Specificity : 0.2586          
    ##          Pos Pred Value : 0.9782          
    ##          Neg Pred Value : 0.5172          
    ##              Prevalence : 0.9710          
    ##          Detection Rate : 0.9640          
    ##    Detection Prevalence : 0.9855          
    ##       Balanced Accuracy : 0.6257          
    ##                                           
    ##        'Positive' Class : No              
    ## 

Evaluating the performance of the model on the training dataset above,
we can see that the model does a pretty good job of predicting overall,
but that it isn't very good at identifying when someone is going to
default at the classification threshold of 0.5. The model correctly
predicts only 20 out of 66 of the people who will default at that
threshold. As we will discuss further in the course, we may want to
adjust our threshold depending on our problem and we may want to try to
find a better-performing model (more to follow). However, the exercise
above provides a code example for fitting a logistic regression model
that can be adapted for our practical application problem.

Before moving on, perform the following actions to save your work and
prepare for the practical application:

-   Save your workspace as "LectureExampleData2.RData" (By typing
    save.image(“LectureExampleData1.RData”) function)
-   Save your script to a file named "LectureExampleData2.R"
