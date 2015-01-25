---
title: "Practical Machine Learning Project"
output: html_document
---
## Objective
The objective of this project is to use data collected from personal activity monitors when doing bicep curls and to determine the manner in which the test subjects did the activities.  It will be one of the following, as specificed at the site http://groupware.les.inf.puc-rio.br/har:

* Class A - exactly according to the specification
* Class B - throwing the elbows to the front 
* Class C - lifting the dumbbell only halfway 
* Class D - lowering the dumbbell only halfway
* Class E -  throwing the hips to the front 

### Cleaning / Processing Data

The original data for training the model is located here: https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv
The final test data is located here: https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv

Both were downloaded locally

In both sets of data this is a large number of columns that are either empty or contain very little data.  Additionally, there is some data that is considered to be not relevant to training the model. Examples include an index, the user names, several timestamps, etc. These were most easily removed using Microsoft Excel. Though could have also been removed using R scripts.

Next, the required packages were loaded into R

    library(caret)
    Loading required package: lattice
    Loading required package: ggplot2

The training data set was then loaded into R and split into a training and test set (60% and 40% respectively).  the row.names column was removed from each data set as well.

    set.seed(12345)
    inTrain <- createDataPartition(y=trainFile$classe, p=0.6, list=FALSE)

    training <- trainFile[inTrain,]
    testing <- trainFile[-inTrain,]

    rownames(training)<-NULL
    rownames(testing)<-NULL

### Training the Model - First attempt
This problem seemed to be very similar to the classification of flower types, as presented in class.  The most straightforward solution to attempt on this type of problem was to use a basic tree model.

    modFit<-train(classe ~ ., method="rpart", data=training)
    prediction <- predict(modFit,newdata=testing)

Next is to cross-validate with the testing data set aside

    confusionMatrix(prediction,testing$classe)
    Confusion Matrix and Statistics

          Reference
    Prediction    A    B    C    D    E
         A 2008  635  219  420   95
         B    0    0    0    0    0
         C  216  883 1149  803  471
         D    0    0    0    0    0
         E    8    0    0   63  876

    Overall Statistics
                                          
               Accuracy : 0.514           
                 95% CI : (0.5029, 0.5251)
    No Information Rate : 0.2845          
    P-Value [Acc > NIR] : < 2.2e-16       
                                          
                    Kappa : 0.3746          
    Mcnemar's Test P-Value : NA              

    Statistics by Class:

                         Class: A Class: B Class: C Class: D Class: E
    Sensitivity            0.8996   0.0000   0.8399   0.0000   0.6075
    Specificity            0.7561   1.0000   0.6337   1.0000   0.9889
    Pos Pred Value         0.5946      NaN   0.3262      NaN   0.9250
    Neg Pred Value         0.9499   0.8065   0.9494   0.8361   0.9180
    Prevalence             0.2845   0.1935   0.1744   0.1639   0.1838
    Detection Rate         0.2559   0.0000   0.1464   0.0000   0.1116
    Detection Prevalence   0.4304   0.0000   0.4489   0.0000   0.1207
    Balanced Accuracy      0.8279   0.5000   0.7368   0.5000   0.7982

The accuracy of this model was just over 50% which is too long to be of value. So this model was discarded.

### Training the Model - Second attempt

The next classification model that makes sense to try is Random Forest, which is a more complex and sophisticated model. It took several hours to run, which in an real world example, might make it a poor choice. Similar to the situation described with the NetFlix prize.

    modFit<-train(classe ~ ., method="rf", data=training,prox=TRUE)


Next we test the new prediction based on Random Forest and cross validate it with the testing data

    prediction <- predict(modFit,newdata=testing)
    confusionMatrix(prediction,testing$classe)


    11776 samples
    58 predictor
    5 classes: 'A', 'B', 'C', 'D', 'E' 

    No pre-processing
    Resampling: Bootstrapped (25 reps) 

    Summary of sample sizes: 11776, 11776, 11776, 11776, 11776, 11776, ... 

    Resampling results across tuning parameters:

    mtry  Accuracy   Kappa      Accuracy SD  Kappa SD   
    2     0.8915904  0.8629230  0.004374073  0.005573202
    5     0.8828649  0.8518852  0.005618502  0.007111276
    8     0.8694659  0.8349281  0.006326890  0.007923058


    Reference
    Prediction    A    B    C    D    E
         A 2160   40   19   10   17
         B   26 1377   54   20   41
         C   25   54 1244   73   29
         D   17    4   39 1166   33
         E    4   43   12   17 1322

    Overall Statistics
                                          
               Accuracy : 0.9265          
                 95% CI : (0.9205, 0.9321)
    No Information Rate : 0.2845          
    P-Value [Acc > NIR] : < 2.2e-16       
                                          
                  Kappa : 0.907           
    Mcnemar's Test P-Value : 1.003e-06       

    Statistics by Class:

                        Class: A Class: B Class: C Class: D Class: E
    Sensitivity            0.9677   0.9071   0.9094   0.9067   0.9168
    Specificity            0.9847   0.9777   0.9721   0.9858   0.9881
    Pos Pred Value         0.9617   0.9071   0.8730   0.9261   0.9456
    Neg Pred Value         0.9871   0.9777   0.9807   0.9818   0.9814
    Prevalence             0.2845   0.1935   0.1744   0.1639   0.1838
    Detection Rate         0.2753   0.1755   0.1586   0.1486   0.1685
    Detection Prevalence   0.2863   0.1935   0.1816   0.1605   0.1782
    Balanced Accuracy      0.9762   0.9424   0.9407   0.9463   0.9525

Now check the out of sample error rate, which gives us an expected error of approximately 7%, within an acceptable range

    sampleError <- sum(prediction == testing$classe)/length(prediction)
    sampleError
    [1] 0.9234005

## Conclusion
Looking at the predicted values gave us the following list of values. It did correctly predict all 20 correctly and seems to have performed better than expected

    finalTest<-read.csv('pml-testing.csv', header=TRUE)
    prediction <- predict(modFit,newdata=finalTest)
    prediction
    [1]A A C A A C C C A A C C C A C C A A A C
    Levels: A B C D E

========================


