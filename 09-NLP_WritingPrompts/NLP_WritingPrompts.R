###################################################
# NLP - WritingPrompts


# Libraries -------------------------------

#to create and work with corpora
library(tm)

#for LDA topic models
library(topicmodels)

# other useful packages
library(tidyverse)
library(tidytext)
library(stringr)

# dplyr must be placed below data.table
library(data.table)
library(dplyr)


# Setup Directory -------------------------

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

# data <- read.csv("WritingPrompts_data.csv",
#                  header = T,
#                  stringsAsFactors = F,
#                  encoding = "utf-8")

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
title_df <- select(data, id, title, score, num_comments, url, created)

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

prompt_df <- select(title_df, id, prompt, score, num_comments, url, created)

head(prompt_df)
tail(prompt_df)



##############################################################
# CREATE CORPUS ------------------------------

# CREATE DOCUMENT ID -------------------

# note: for some reason this is quotes sensitive, 
# use double quotes
names(prompt_df)[names(prompt_df)=="id"] <- "doc_id"
prompt_df$id <- as.character(prompt_df$id)

names(prompt_df)[names(prompt_df)=="prompt"] <- "text"
colnames(prompt_df)


# CREATE CORPUS ------------------------------


# calling DataframeSource to save metadata,
# if you don't want to save metadata, just call VSource()
prompt_source <- DataframeSource(prompt_df)
prompt_corpus <- VCorpus(prompt_source)

prompt_corpus

# Looking at document number 10 (it can be any number)
prompt_corpus[[10]]
prompt_corpus[[10]][1] # the text of document 10
prompt_corpus[[10]][2] # the metadata of document 10



# CLEANING CORPUS ----------------------

# Remove punctuation
prompt_cleaned <- tm_map(prompt_corpus, removePunctuation)

# Remove numbers
prompt_cleaned <- tm_map(prompt_cleaned, removeNumbers)

# Make lowercase
prompt_cleaned <- tm_map(prompt_cleaned, content_transformer(tolower))

# Remove stop words
my_stops <- c(stopwords("en"))

prompt_cleaned <- tm_map(prompt_cleaned, removeWords, my_stops)

# Remove white space
prompt_cleaned <- tm_map(prompt_cleaned, stripWhitespace)


# Checking the 3rd document's uncleaned text
prompt_corpus[[3]][1]

# Checking the 3rd document's cleaned text
prompt_cleaned[[3]][1]





###################################################
###################################################
# TOPIC MODELING (DOCUMENT TERM MATRIX)

prompt_dtm <- DocumentTermMatrix(prompt_cleaned)
prompt_dtm

# Sparse entries are 0's, so a specific term does 
# not occur in that document.
# There are about 30,613 unique words across our documents.
# They don't appear in every document.

# a little more cleaning to remove empty rows
# keep only indexes of unique words
unique_indexes <- unique(prompt_dtm$i)
prompt_dtm <- prompt_dtm[unique_indexes,]
prompt_dtm

# turn our unique words into the
# tidy format of the tidyverse packages
prompt_dtm_tidy <- tidy(prompt_dtm)
prompt_dtm_tidy 


# LDA ANALYSIS ------------
# k is the number of topics we want
# (like k means clustering?)

k <- 5

# NOTE: Optimal k varies, so you'll need to experiment
# with which k value is best.

prompt_lda <- LDA(prompt_dtm, 
                 k = k, 
                 control = list(seed=42)) 
prompt_lda
# NOTE: seed keeps randomization consistent

# get the words out of our LDA
prompt_lda_words <- terms(prompt_lda, 5)
prompt_lda_words

# NOTE: at this stage you may want to go back 
# and add some stop words to your posts based
# on the results you got from LDA.
# Remove words that don't add any meaning
# to the analysis.



# Save LDA words as CSV --------------

# need a matrix format to be written to csv
prompt_lda_topics <- as.matrix(prompt_lda_words)

# write.csv(prompt_lda_topics,
#           file = paste("prompt_LDA_", 
#                        k, 
#                        ".csv",
#                        sep = ""))

# NOTE: k variable is helpful here when you run many LDAs
# with different k's



head(prompt_lda_topics)

# turn our LDA into the
# tidy format of the tidyverse packages
prompt_lda_tidy <- tidy(prompt_lda)

# Beta shows how much each term 
# contributes to each topic
# NOTE: Typically list 8 terms when topic modelling
top_terms <- prompt_lda_tidy %>%
  group_by(topic) %>%
  top_n(8, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
head(top_terms, 10)

# visualize with ggplot
# NOTE: We want to treat the topics as categorical,
# so turn it to a factor first.
# NOTE: Don't show legend because it's not helpful.
top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, 
             beta, 
             fill = factor(topic))) +
  geom_col(show.legend=FALSE) +
  facet_wrap( ~ topic, scales="free") +
  coord_flip()


# Create a Function that is Portable to other places ---

get_LDA_topics_terms_by_topic <- 
  function(input_corpus, 
           plot = TRUE, 
           number_of_topics = 5, # = creates default value
           number_of_words = 5, 
           path = getwd())
  {
    my_dtm <- DocumentTermMatrix(input_corpus)
    
    unique_indexes <- unique(my_dtm$i)
    
    my_dtm <- my_dtm[unique_indexes,]
    
    my_lda <- LDA(my_dtm, 
                  k = number_of_topics, 
                  control = list(seed=42))
    
    my_topics <- tidy(my_lda, matrix="beta")
    
    my_lda_words <- terms(my_lda, number_of_words)
    
    my_lda_topics <- as.matrix(my_lda_words)
    
    write.csv(my_lda_topics, file=paste(path,
                                        "/lda_topics_k_",
                                        number_of_topics,
                                        ".csv",
                                        sep = ""))
    
    my_top_terms <- my_topics %>%
      group_by(topic) %>%
      top_n(number_of_words, beta) %>%
      ungroup() %>%
      arrange(topic, -beta)
    
    if(plot==TRUE){
      my_top_terms %>%
        mutate(term = reorder(term, beta)) %>%
        ggplot(aes(term, beta, fill=factor(topic))) +
        geom_col(show.legend=FALSE) +
        facet_wrap(~ topic, scales = "free")+
        coord_flip()
    }
    
    else{
      return(my_top_terms)
    }
  }

# # use function to conduct LDA quickly with 
# # different numbers of topics and words
# get_LDA_topics_terms_by_topic(prompt_cleaned,
#                               number_of_topics = 4,
#                               number_of_words = 4)


# GAMMA -------------
# How much does each topic contribute to each document?
# --> Use GAMMA statistic
# (As opposed to how much each word contributes 
# to each topic, which is beta)

prompt_lda_document_topics <- tidy(prompt_lda, 
                                  matrix="gamma")

head(prompt_lda_document_topics)

# write.csv(prompt_lda_document_topics,
#           file = paste("prompt_LDA_document_topics_",
#                        k,
#                        ".csv",
#                        sep = ""))

# same as nrow() and ncol()
dim(prompt_lda_document_topics)

# Have each topic as a different column
# Ex: topic1, topic2, topic3
# As opposed to one topic column
# NOTE: gamma values are to fill in the new columns
prompt_lda_document <- spread(prompt_lda_document_topics, 
                             topic, # the col to spread 
                             gamma) # fill in the new cols with gamma
dim(prompt_lda_document)
head(prompt_lda_document)


# create column for the topic that has the
# greatest contribution to that document

prompt_lda_document$max_topic <- 
  colnames(prompt_lda_document[2:6])[apply(X=prompt_lda_document,
                                          MARGIN=1,
                                          FUN=which.max)]

# join tables together
dt1 <- data.table(prompt_lda_document, 
                  key = "document")
dt2 <- data.table(prompt_df, 
                  key = "doc_id")

prompt_merged <- dt1[dt2]
dim(prompt_merged)
colnames(prompt_merged)


# select only the columns you want to work with
prompt_analyze <- select(prompt_merged,
                         c(document,
                           text,
                           score,
                           num_comments,
                           url,
                           created))
head(prompt_analyze)






###################################################
###################################################
# Sentiment Analysis

# for sentiments
library(topicmodels)
sentiments

# textdata and nrc may need package installations
library("textdata")
get_sentiments("afinn")
get_sentiments("nrc")
get_sentiments("bing")


# convert csv data into a format 
# the tidyverse library can work with
tidy_prompts <- prompt_df %>%
  ungroup() %>%
  unnest_tokens(word, prompt)

# from the conversion above, 
# we have a new column called "word"
summary(tidy_prompts)

head(tidy_prompts)
colnames(tidy_prompts)

# Get all the "joy" sentiment words
# from the nrc dictionary
nrc_sent <- get_sentiments("nrc") %>%
  filter(sentiment == "joy")

# --> Which words do top writing prompts express joy with
# inner join nrc_sent with prompts
tidy_prompts %>%
  inner_join(nrc_sent) %>%
  dplyr::count(word, sort = TRUE) # important to specify dplyer's count


# --> Difference of positive and negative words in each prompt
# ex: if one is lots of negative words, we get a negative score
# ex: if one is lots of positive words, we get a positive score
prompts_sentiment <- tidy_prompts %>%
  inner_join(get_sentiments("bing")) %>%
  dplyr::count(doc_id, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

head(prompts_sentiment)

# visualize positive words vs negative words in prompt
ggplot(prompts_sentiment, aes(negative, positive)) +
  geom_point(show.legend = FALSE,
             size = 15,
             shape = "square",
             alpha = 0.1)

# the mean sentiment analysis of all bowie lyrics together
all_prompts_sentiment <- mean(prompts_sentiment$sentiment)
all_prompts_sentiment
