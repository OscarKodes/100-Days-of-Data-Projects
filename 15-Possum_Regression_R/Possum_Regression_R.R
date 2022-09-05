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

ggplot(trainingData, 
       aes(x = tail_length_cm)) +
  geom_histogram(binwidth=2,
                 fill="darkgreen",
                 alpha=0.5)

ggplot(trainingData, 
       aes(x = population_name,
           fill = population_name)) +
  geom_bar(binwidth=2)

# continuous
# age, head, skull, total
# tail, foot, earconch, eye, chest, belly

# categorical 
# site_trapped, population_name, sex


