###################################################
# NLP - WritingPrompts

# Clear R's memory.
rm(list=ls())

# Set working directory
setwd("C:/Users/Oscar Ko/Desktop/100-Days-of-Data-Projects/9-NLP_WritingPrompts")

# Check current working directory
getwd()

# Lists files in current working directory
list.files()


###################################################
# IMPORT DATA 

# Faster way to import CSV with "vroom" package
library(vroom)
data <- vroom("WritingPrompts_data.csv")

###################################################
# CHECK THE DATA 

head(data) 
tail(data) 
str(data) 
summary(data) 

# check number of rows and columns
nrow(data)
ncol(data)

# check column names
colnames(data)

# check for missing values
any(is.na(data))

# Amelia package for visualizing missing data
library(Amelia)

missmap(data, 
        main = "Missing Map",
        col = c("red", "black"),
        legend = T)


# -----------------------------------------
# Remove all columns except Title

library(tidyverse)
title_df <- select(data, title)

missmap(title_df, 
        main = "Missing Map",
        col = c("red", "black"),
        legend = T)

head(title_df)
tail


# ----------------------------------------
# Seperate all prompt tags and titles

tags <- c()
prompts <- c()

for (txt in title_df$title) {
  
  split_txt = strsplit(txt, "]")

  tag = substring(split_txt[[1]][1], 2)
  prompt = split_txt[[1]][2]

  tags <- c(tags, tag)
  prompts <- c(prompts, prompt)
}

# prompt_df <- cbind(tags, prompts)
# head(prompt_df)
title_df$tag <- tags

title_df$prompt <- prompts

head(title_df)

unique(title_df$tag)

# -----------------------------------
# Clean the data

error_tag <- " man who sees ghosts checks himself into a mental institution, oblivious to the fact that the facility has been closed for almost thirty years. [WP"

title_df[title_df$tag == error_tag, ]$title

the_title <- "[WP] A man who sees ghosts checks himself into a mental institution, oblivious to the fact that the facility has been closed for almost thirty years."

the_tag <- "WP"

the_prompt <- "A man who sees ghosts checks himself into a mental institution, oblivious to the fact that the facility has been closed for almost thirty years." 

title_df <- title_df[title_df$tag != error_tag, ]

title_df <- rbind(title_df, c(the_title, the_tag, the_prompt))

tail(title_df)

# Keep only standard [WP] posts. Filter out everything else.

unique(title_df$tag)

title_df <- title_df[title_df$tag %in% c("WP", "Wp", " WP "), ]

unique(title_df$tag)

nrow(title_df)

# ---------------------------------------------------
# Create dataframe of only prompts 

prompt_df <- select(title_df, prompt)

head(prompt_df)
tail(prompt_df)
