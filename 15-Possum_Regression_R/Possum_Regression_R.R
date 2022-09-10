###################################################
# POSSUM REGRESSION

# Predict possum skull width using regression.

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
# EXPLORATORY ANALYSIS


# CORRELATION MATRIX VISUALIZATION ------------------

# Visualize Correlation Matrix Method 1: corrplot

library(corrplot)

# create a filter for numeric columns only
numeric_filter <- sapply(trainingData, is.numeric)

# use filter
numeric_cols <- cor(trainingData[,numeric_filter])

numeric_cols

# visualize correlations with color
corrplot(numeric_cols, method = "color")


# Visualize Correlation Matrix Method 2: corrgram

library(corrgram)

corrgram(trainingData)

# visualize with pie diagrams
corrgram(trainingData, 
         order=T, 
         lower.panel=panel.shade,
         upper.panel=panel.pie,
         text.panel=panel.txt)

# Notes: --------------
# Strongest Positive Correlations:
# - earconch & foot
# - head & skull
# - head & belly
# - head & total
# - chest & (total, belly, head, skull)

# Strongest Negative Correlations:
# - earconch & tail
# - site_trapped & (earconch, foot, chest, total)


# DISTRIBUTION VISUALIZATION ------------------

colnames(trainingData)

# continuous feature histograms -------

ggplot(trainingData, 
       aes(x = age)) +
  geom_histogram(binwidth=2,
                 fill="darkgreen",
                 alpha=0.5,
                 color="black")

ggplot(trainingData, 
       aes(x = head_length_mm)) +
  geom_histogram(binwidth=3,
                 fill="darkblue",
                 alpha=0.5,
                 color="black")

ggplot(trainingData, 
       aes(x = skull_width_mm)) +
  geom_histogram(binwidth=3,
                 fill="darkred",
                 alpha=0.5,
                 color="black")

# Note: It seems there are some possums with unusually large skulls.

ggplot(trainingData, 
       aes(x = total_length_cm)) +
  geom_histogram(binwidth=3,
                 fill="purple",
                 alpha=0.5,
                 color="black")

# Note: Total length of possums seem to have two general peaks

ggplot(trainingData, 
       aes(x = tail_length_cm)) +
  geom_histogram(binwidth=2,
                 fill="orange",
                 alpha=0.5,
                 color="black")

ggplot(trainingData, 
       aes(x = foot_length_mm)) +
  geom_histogram(binwidth=2,
                 fill="grey",
                 color="black")

# Note: foot length also seems to have two peaks.

ggplot(trainingData, 
       aes(x = earconch_length_mm)) +
  geom_histogram(binwidth=2,
                 fill="pink",
                 alpha=0.5,
                 color="black")

# Note: Earconch length also seems to have two peaks.

ggplot(trainingData, 
       aes(x = eye_width_mm)) +
  geom_histogram(binwidth=1,
                 fill="coral",
                 alpha=0.5,
                 color="black")

ggplot(trainingData, 
       aes(x = chest_girth_cm)) +
  geom_histogram(binwidth=2,
                 fill="darkolivegreen",
                 alpha=0.5,
                 color="black")

# Note: chest girth seems to be negatively skewed

ggplot(trainingData, 
       aes(x = belly_girth_cm)) +
  geom_histogram(binwidth=2,
                 fill="darkgoldenrod",
                 alpha=0.5,
                 color="black")

# Note: belly girth seems to be positively skewed


# categorical feature histograms -------

ggplot(trainingData, 
       aes(x = site_trapped,
           fill = site_trapped)) +
  geom_bar()

# Note: Sites 1 and 7 trapped the most possums.

ggplot(trainingData, 
       aes(x = sex,
           fill = sex)) +
  geom_bar()

# Note: There are more female possums to male possums.



###########################################
# PREPARE THE DATA FOR MACHINE LEARNING

# One-Hot Encode Categorical Features

# NOTE: With R, one hot encoding might not be necessary


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
# COMPARE REGRESSION MODELS


# Full Model ----
fullModel <- lm(skull_width_mm ~ , 
                data = trainingData)

summary(fullModel)
# Note: R-squared is 0.7195. Overall P-value is below 0.05.



# Backwards Elimination 1 ----  alpha = 0.05
backwards1 <- lm(skull_width_mm ~ chest_girth_cm, data = trainingData)

summary(backwards1)
# Note: R-squared is 0.4023. Overall P-value is below 0.05.
# Note: Removing the other features decreased predictive power by a lot
# Try backwards elimination with alpha level of 0.10



# Backwards Elimination 2 ---- alpha = 0.10
backwards2 <- lm(skull_width_mm ~ chest_girth_cm + eye_width_mm, 
                 data = trainingData)

summary(backwards2)
# Note: R-squared is 0.4506. Overall P-value is below 0.05.
# Note: By increasing alpha, we allowed for eye_width_mm to stay in the model.
# this increased predictive power by about 5%.


########################################################
# EVALUATE OUR MODELS WITH THE TEST SET DATA

# Predict test set data with our model
full_model_predictions <- predict(fullModel, testData)
backwards1_predictions <- predict(backwards1, testData)
backwards2_predictions <- predict(backwards2, testData)

# Put the predictions and actual test points
# side by side to compare
results_full <- cbind(full_model_predictions, testData$skull_width_mm)
results_back1 <- cbind(backwards1_predictions, testData$skull_width_mm)
results_back2 <- cbind(backwards2_predictions, testData$skull_width_mm)

colnames(results_full) <- c("predicted", "actual")
colnames(results_back1) <- c("predicted", "actual")
colnames(results_back2) <- c("predicted", "actual")

results_full <- as.data.frame(results_full)
results_back1 <- as.data.frame(results_back1)
results_back2 <- as.data.frame(results_back2)

head(results_full)
head(results_back1)
head(results_back2)


# TAKE CARE OF NEGATIVE TEST SCORE PREDICTIONS

results$predicted <- ifelse(results$predicted < 0, 0, results$predicted)

# check lowest value has been changed to 0
min(results$predicted)



##########################################
# LOOK AT RESIDUALS
# NOTE: Residuals = error = difference b/w actual and fitted values
# NOTE2: fitted = predicted

# Visualize full model residuals ---------------
res <- residuals(fullModel)

head(res)

# change to dataframe to visualize
res <- as.data.frame(res)
res

# visualize residuals
ggplot(res, aes(res)) + 
  geom_histogram(fill="red", 
                 alpha=0.5,
                 bins=50)

# Visualize backwards model 1 residuals -----------------
res <- residuals(backwards1)

head(res)

# change to dataframe to visualize
res <- as.data.frame(res)
res

# visualize residuals
ggplot(res, aes(res)) + 
  geom_histogram(fill="blue", 
                 alpha=0.5,
                 bins=50)

# Visualize backwards model 2 residuals -----------------
res <- residuals(backwards2)

head(res)

# change to dataframe to visualize
res <- as.data.frame(res)
res

# visualize residuals
ggplot(res, aes(res)) + 
  geom_histogram(fill="green", 
                 alpha=0.5,
                 bins=50)