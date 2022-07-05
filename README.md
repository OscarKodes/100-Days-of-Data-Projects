# 100 Days of Data Projects

This is a daily goal where I will work on data projects for 100 days. 

The purpose is to practice data analysis, machine learning, creating dashboards, and communicating data insights to a general audience.

I aim to do at least one of the following each day:

- Data collection/scraping

- Data cleaning and preparation

- Exploratory Data Analysis

- Machine Learning (supervised/unsupervised)

- Dashboard visualization

- Video presentation of analysis

---

### Day 1 - June 30th, 2022

**Tasks Done**

- Decided on two research topics

	- Classification: Given a Pokemon's features of base stats, experience requirements, catch rate, height, weight, and generation number, could we reliably classify if a Pokemon is a Dragon Type?
	
	- Regression: Can we create a regression model that predicts a Pokemon's HP stat?

- Cleaned and prepared Pokemon data

---

### Day 2 - July 1st, 2022

**Tasks Done**

- Exploratory Data Analysis with Visualization

- Pricipal Component Analysis (Unsupervised)

    - For analysis and dimensionality reduction

- Gradient Boosted Decision Tree (Supervised Classification)

    - Model testing and feature selection (using feature importance)
    
- Decision Tree (Supervised Classification)

- GridSearchCV

    - Optimized model parameters with grid search, but decided to remove them after realizing the optimized models where only predicting "0" for isDragon.
    
    - Must be careful with datasets that are imbalanced. Models might just end up guessing for the majority class to get "accurate" guesses.
    
    - Avoid by checking the prediction results and making sure that more than one class is being outputted.
    
---

### Day 3 - July 2nd, 2022

**Tasks Done**

- Built more classification models

    - KNN, Random Forest, Linear SVM, Kernel SVM, Logistic Regression
    
- Optimized parameters with GridSearchCV

- Compared models with Confusion Matrices and Evaluation Metrics

- Selected the best model

- Visualized the test set results and model predictions

---

### Day 4 - July 3rd, 2022

**Tasks Done**

- Prepared Pokemon data for Pokemon HP Regression

- Exploratory Data Analysis for Pokemon HP Regression
    
- Experimented with Linear Regression, Ridge Regression, and Lasso Regression to predict Pokemon HP

    - Conducted GridSearchCV on Ridge and Lasso to find the best parameters.

    - The best regression model was Ridge with alpha = 20. 
    
    - Test set accuracy of 0.52. 

---

### Day 5 - 6 - July 4th - 5th, 2022

**Tasks Done**

- Prepared slides for presenting Pokemon classification and regression.

- Recorded and uploaded presentation.

    - https://www.youtube.com/watch?v=bC76RKInAc8
