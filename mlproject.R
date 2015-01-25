## script for ML project

## Load the appropriate libraries
library(caret)

## Read the training data
trainFile <-read.csv('pml-training.csv', header=TRUE)

# break into up training and test files
set.seed(12345)
inTrain <- createDataPartition(y=trainFile$classe, p=0.6, list=FALSE)

training <- trainFile[inTrain,]
testing <- trainFile[-inTrain,]

rownames(training)<-NULL
rownames(testing)<-NULL

# Try tree as it's similar problem to iris data
modFit<-train(classe ~ ., method="rpart", data=training)
prediction <- predict(modFit,newdata=testing)

test the prediction
confusionMatrix(prediction,testing$classe)

#results are poor so we'll try a more sophisticated method - randomForest
set.seed(6789)
modFit<-train(classe ~ ., method="rf", data=training,prox=TRUE)
prediction <- predict(modFit,newdata=testing)

# Test the new prediction
confusionMatrix(prediction,testing$classe)



errorRate <- sum(prediction == testing$classe)/length(prediction)
errorRate

# Seems to work well, so run it against the actual test data

finalTest<-read.csv('pml-testing.csv', header=TRUE)
prediction <- predict(modFit,newdata=finalTest)
prediction


