###################################################
# NLP - SUBREDDIT ASIAN AMERICAN


###################################################
# IMPORT LIBRARIES

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


###################################################
# SETUP DIRECTORY

# Clear R's memory.
rm(list=ls())

# Set working directory
setwd("C:/Users/Oscar Ko/Desktop/100-Days-of-Data-Projects/19-NLP_Subreddit_AsianAmerican")

# Check current working directory
getwd()

# Lists files in current working directory
list.files()


###################################################
# IMPORT DATA 


# Faster way to import CSV with "vroom" package
library(vroom)
comments <- vroom("data/AsianAmerican_comments.csv")
posts <- vroom("data/AsianAmerican_posts.csv")


###################################################
# Combine comment text with original post 

colnames(comments)
colnames(posts)

# Join dfs on post_id and id
# keep comment body
# Keep post title (& text if exists)

df <- data.frame(matrix(ncol = 2, nrow = 0))
column_names <- c("post_id", "post_and_comments")
colnames(df) <- columns

for (id in posts$id) {
  
  post_title = c(posts[posts$id == id,]$title)
  
  all_comments = comments[comments$post_id == id,]$body
  
  all_text_vector = c(post_title, all_comments)
  
  text_string = paste(all_text_vector, collapse = ' ')

  row = data.frame(
    post_id = id,
    post_and_comments = text_string
    )
  
  df = rbind(df, row)
}


###################################################
# CHECK THE DATA 

head(df)
str(df)
summary(df) 

# check number of rows and columns
nrow(df)
ncol(df)

# check column names
colnames(df)

# check for missing values
any(is.na(df))





##############################################################
##############################################################
# NLP SECTIONS


##############################################################
# CREATE CORPUS


# create document id -------------------

# note: for some reason this is quotes sensitive,
# use double quotes
names(df)[names(df)=="post_id"] <- "doc_id"
df$id <- as.character(df$id)

names(df)[names(df)=="post_and_comments"] <- "text"
colnames(df)


# create corpus ------------------------------


# calling DataframeSource to save metadata,
# if you don't want to save metadata, just call VSource()
source <- DataframeSource(df)
corpus <- VCorpus(source)

corpus

# Looking at document number 10 (it can be any number)
corpus[[10]]
corpus[[10]][1] # the text of document 10
corpus[[10]][2] # the metadata of document 10


# clean the corpus ----------------------

# Remove punctuation
cleaned <- tm_map(corpus, removePunctuation)

# Remove numbers
cleaned <- tm_map(cleaned, removeNumbers)

# Make lowercase
cleaned <- tm_map(cleaned, content_transformer(tolower))

# Remove stop words
my_stops <- c(stopwords("en"), 
              "asian",
              "asians",
              "people",
              "like",
              "just",
              "removed",
              "dont",
              "think",
              "even",
              "can",
              "one",
              "get",
              "see",
              "know",
              "also",
              "really",
              "will")

cleaned <- tm_map(cleaned, removeWords, my_stops)

# Remove white space
cleaned <- tm_map(cleaned, stripWhitespace)


# Checking the 3rd document's uncleaned text
corpus[[3]][1]

# Checking the 3rd document's cleaned text
cleaned[[3]][1]






#########################################################################
# TOPIC MODELING (DOCUMENT TERM MATRIX)

dtm <- DocumentTermMatrix(cleaned)
dtm

# Sparse entries are 0's, so a specific term does
# not occur in that document.
# There are about 5,853 unique words across our documents.
# They don't appear in every document.

# a little more cleaning to remove empty rows
# keep only indexes of unique words
unique_indexes <- unique(dtm$i)
dtm <- dtm[unique_indexes,]
dtm

# turn our unique words into the
# tidy format of the tidyverse packages
dtm_tidy <- tidy(dtm)
dtm_tidy


# LDA ANALYSIS ------------------------------------

# k is the number of topics we want
# (like k means clustering?)

k <- 4

# NOTE: Optimal k varies, so you'll need to experiment
# with which k value is best.

lda <- LDA(dtm,
           k = k,
           control = list(seed=42))
lda

# NOTE: seed keeps randomization consistent

# get the words out of our LDA
lda_words <- terms(lda, 5)
lda_words

# NOTE: at this stage you may want to go back
# and add some stop words to your posts based
# on the results you got from LDA.
# Remove words that don't add any meaning
# to the analysis.



# Save LDA words as CSV --------------

# need a matrix format to be written to csv
lda_topics <- as.matrix(lda_words)

# write.csv(lda_topics,
#           file = paste("(new)LDA_",
#                        k,
#                        ".csv",
#                        sep = ""))

# NOTE: k variable is helpful here when you run many LDAs
# with different k's



# Examine the topics  --------------

head(lda_topics)

# turn our LDA into the
# tidy format of the tidyverse packages
lda_tidy <- tidy(lda)

# Beta shows how much each term
# contributes to each topic
# NOTE: Typically list 8 terms when topic modelling
top_terms <- lda_tidy %>%
  group_by(topic) %>%
  top_n(8, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
head(top_terms, 10)


# Export to CSV
#
# write.csv(top_terms,
#           file = paste("(new)01-LDA_",
#                        k,
#                        ".csv",
#                        sep = ""))
#


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


##########################################################
##########################################################
##########################################################
##########################################################
##########################################################
##########################################################
##########################################################

# 
# # GAMMA -------------
# 
# # How much does each topic contribute to each document?
# # --> Use GAMMA statistic
# # (As opposed to how much each word contributes
# # to each topic, which is beta)
# 
# lda_document_topics <- tidy(lda,
#                                   matrix="gamma")
# 
# head(lda_document_topics)
# tail(lda_document_topics)
# 
# # write.csv(lda_document_topics,
# #           file = paste("(new)topic_gamma_match",
# #                        k,
# #                        ".csv",
# #                        sep = ""))
# 
# # same as nrow() and ncol()
# dim(lda_document_topics)
# 
# 
# # Have each topic as a different column --------------
# 
# # Ex: topic1, topic2, topic3
# # As opposed to one topic column
# # NOTE: gamma values are to fill in the new columns
# lda_document <- spread(lda_document_topics,
#                              topic, # the col to spread
#                              gamma) # fill in the new cols with gamma
# dim(lda_document)
# head(lda_document)
# 
# 
# # Best Topic Match ----------------------------------
# 
# # create column for the topic that has the
# # greatest contribution to that document
# 
# lda_document$max_topic <-
#   colnames(lda_document[2:4])[apply(X=lda_document,
#                                           MARGIN=1,
#                                           FUN=which.max)]
# 
# 
# # join tables together --------------------------------
# 
# dt1 <- data.table(lda_document,
#                   key = "document")
# dt2 <- data.table(df,
#                   key = "doc_id")
# 
# merged <- dt1[dt2]
# dim(merged)
# colnames(merged)
# 
# 
# # select only the columns you want to work with
# analyze <- select(merged,
#                          c(document,
#                            text,
#                            score,
#                            num_comments,
#                            url,
#                            created))
# head(analyze)
# 
# 
# 
# 
# 
# 
# ###################################################
# ###################################################
# # Sentiment Analysis
# 
# # for sentiments
# library(topicmodels)
# sentiments
# 
# # textdata and nrc may need package installations
# library("textdata")
# get_sentiments("afinn")
# get_sentiments("nrc")
# get_sentiments("bing")
# 
# 
# # convert csv data into a format
# # the tidyverse library can work with
# colnames(df)
# 
# tidy_prompts <- df %>%
#   ungroup() %>%
#   unnest_tokens(word, text)
# 
# # from the conversion above,
# # we have a new column called "word"
# summary(tidy_prompts)
# 
# head(tidy_prompts)
# colnames(tidy_prompts)
# 
# # Get all the "joy" sentiment words
# # from the nrc dictionary
# nrc_sent <- get_sentiments("nrc") %>%
#   filter(sentiment == "joy")
# 
# 
# # --> Which words do top writing prompts express joy with -------------
# # inner join nrc_sent with prompts
# joy_words <- tidy_prompts %>%
#             inner_join(nrc_sent) %>%
#             dplyr::count(word, sort = TRUE) # important to specify dplyer's count
# joy_words
# 
# 
# # --> Difference of positive and negative words in each prompt ------
# # ex: if one is lots of negative words, we get a negative score
# # ex: if one is lots of positive words, we get a positive score
# prompts_sentiment <- tidy_prompts %>%
#   inner_join(get_sentiments("bing")) %>%
#   dplyr::count(doc_id, sentiment) %>%
#   spread(sentiment, n, fill = 0) %>%
#   mutate(sentiment = positive - negative)
# 
# head(prompts_sentiment)
# 
# 
# # # Get all bing sentiments ---------------------------------------
# #
# # write.csv(get_sentiments("bing"),
# #           file = paste("bing_sentiments",
# #                        k,
# #                        ".csv",
# #                        sep = ""))
# 
# 
# # # Export CSV sentiment values ---------------------------------------
# #
# # write.csv(prompts_sentiment,
# #           file = paste("prompts_sentiments",
# #                        k,
# #                        ".csv",
# #                        sep = ""))
# 
# 
# # visualize positive words vs negative words in prompt -------------
# ggplot(prompts_sentiment, aes(negative, positive)) +
#   geom_point(show.legend = FALSE,
#              size = 15,
#              shape = "square",
#              alpha = 0.1)
# 
# # the mean sentiment analysis of all bowie lyrics together ---------
# all_prompts_sentiment <- mean(prompts_sentiment$sentiment)
# all_prompts_sentiment
