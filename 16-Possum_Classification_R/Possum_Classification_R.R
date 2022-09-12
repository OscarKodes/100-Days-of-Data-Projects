###################################################
# POSSUM Classification

# Predict possum sex with classification.

###################################################
# SETUP 

# useful package for everything
library(tidyverse)

# Clear R's memory.
rm(list=ls())

# Set working directory
setwd("C:/Users/Oscar Ko/Desktop/100-Days-of-Data-Projects/15-Simple_ML_with_R")

# Check current working directory
getwd()


###################################################
# IMPORT DATA 

# Faster way to import CSV with "vroom" package
library(vroom)
data <- vroom("possum.csv")


###################################################
# CHECK THE DATA 

# check number of rows and columns
nrow(data)
ncol(data)

# check column names
colnames(data)


###########################################
# RENAME COLUMNS


colnames(data) <- c("id",
                    "site_trapped",
                    "population_name",
                    "sex",
                    "age",
                    "head_length_mm",
                    "skull_width_mm",
                    "total_length_cm",
                    "tail_length_cm",
                    "foot_length_mm",
                    "earconch_length_mm",
                    "eye_width_mm",
                    "chest_girth_cm",
                    "belly_girth_cm")

data$population_name <- NULL

# convert to categorical factors

data$site_trapped <- factor(data$site_trapped)

###########################################
# TRAIN-TEST SPLIT

library(caTools)

set.seed(42)

# Split up sample (training and test data)
sample <- sample.split(data$skull_width_mm, SplitRatio = 0.7)

# 70% of the data will be used to train the model
trainingData <- subset(data, sample == T)

# 30% of the data will be used to test the model
testData <- subset(data, sample == F)


###########################################
# CHECK TRAINING DATA

head(trainingData) 
tail(trainingData) 
str(trainingData) 
summary(trainingData) 


###########################################
# CHECK FOR MISSING VALUES
any(is.na(trainingData))

# Amelia package for visualizing missing data
library(Amelia)

missmap(trainingData, 
        main = "Missing Map",
        col = c("red", "black"),
        legend = T)

# Only one case in the training set with missing values, Remove it

trainingData <- na.omit(trainingData) 

any(is.na(trainingData))

# Every change we make to the training data, 
# we must do to the test data
testData <- na.omit(testData)




###########################################
# PREPARE THE DATA FOR MACHINE LEARNING

# One-Hot Encode Categorical Features

# NOTE: With R, one hot encoding might not be necessary

trainingData$sex <- ifelse(trainingData$sex == "m", 0, 1)
testData$sex <- ifelse(testData$sex == "m", 0, 1)

# Feature Scale Continuous Variables - Standardization

scale_numeric_cols <- function(df) {
  numeric_cols <- select(df,
                         -id,
                         -site_trapped,
                         -sex)
  
  scaled_cols <- scale(numeric_cols)
  
  categorical_cols <- select(df,
                             id,
                             site_trapped,
                             sex)
  
  return (cbind(categorical_cols, scaled_cols))
}

trainingData <- scale_numeric_cols(trainingData)

testData <- scale_numeric_cols(testData)



#####################################################
# LOGISTIC REGRESSION

logistic_model <- glm(sex ~ ., 
                  family = binomial(link = "logit"),
                  data = trainingData)
summary(logistic_model)

# Note: It seems most features have above 0.05 p-value.
# what if we built a model with features only of below 0.10 p-value?

logistic_model2 <- glm(sex ~ head_length_mm + total_length_cm, 
                       family = binomial(link = "logit"),
                       data = trainingData)
summary(logistic_model2)


# Accuracy: Full Model ------------------

outcome_odds_ratio <- predict(logistic_model, 
                              testData, 
                              type = "response")

predicted_results <- ifelse(outcome_odds_ratio > 0.5, 1, 0)

prediction_accuracy <- mean(predicted_results == testData$sex)

prediction_accuracy

# CONFUSION MATRIX (Actual data vs Predicted data)
table(testData$sex, predicted_results)

# ACCURACY for Full Logistic Regression Model = 0.53


# Accuracy: Model 2 ------------------

outcome_odds_ratio <- predict(logistic_model2, 
                              testData, 
                              type = "response")

predicted_results <- ifelse(outcome_odds_ratio > 0.5, 1, 0)

prediction_accuracy <- mean(predicted_results == testData$sex)

prediction_accuracy

# CONFUSION MATRIX (Actual data vs Predicted data)
table(testData$sex, predicted_results)

# ACCURACY for Full Logistic Regression Model = 0.66

