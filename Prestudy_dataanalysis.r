---
  title: "Statistical_analysis_prestudy"
author: "Marie Tzschaschel"
date: "09.07.2020"
output: pdf_document
---
  ```{r setup, include=FALSE}
install.packages("lme4")
library(lme4)
```
Goal of this analysis is to examine whether the similarity values of the similar dataset
(tuples containing two nouns that have the same animacy, e.g. animate and inanimte or 
inanimte and inanimate) have significantly higher similarity values compared to the
contrast dataset (tuples containing two nouns with different animacy, animate and inanimate).


In the first block the data is uploaded into the r envirenmnent.
The data is stored in a csv file, the variables are separated by ',' and the first row is
the name of the columns (therefore header=TRUE).
The head() function shows the first rows of the dataset, such that we can see its structure.
```{r}
#load data
simval_data<-read.csv(file = "df_simval.csv", header = TRUE, sep = ',')
head(simval_data)
```

In the next block we extract the similarity values of the similar and the contrast data. 

These values are stored in the third column of the simval_data. With the square brackets after the variable
we can access the different rows and columns. The first entry within the square brackets is
always the row, the second the column. If we let the row entry empty (as in our case), we
take the whole row. Since we need to access the third column we write three after the comma.

We do the same for the contrast data, that is stored in the fifth column.

After having extracted the two groups out of the simval_data we hist the two distributions
of the similarity values.

```{r}
#Extract the similarity values and check how they are distributed by plotting the histogram

simval_similar<-simval_data[,3]
simval_contrast<-simval_data[,5]
hist(simval_similar)
hist(simval_contrast)
```

  
```{r}
# Check the mean and sd for both groups
mean_similar<-mean(simval_similar)
mean_similar

mean_contrast<-mean(simval_contrast)
mean_contrast

sd_similar<-sd(simval_similar)
sd_similar

sd_contrast<-sd(simval_contrast)
sd_contrast
# the two distributions have approximately the same sd

delta<-mean_similar-mean_contrast
delta #delta is even higher for this dataset (last one was 0.06)

#power analysis: 86%
#one.sample since our data is dependant row by row
power.t.test(delta = delta, n=74, sd=sd_similar, type="one.sample", alternative="two.sided")
```

In the next block, do a one sample t-test (paired), create a data frame 
and fit a linear model with varying intercept for items. The similar condition is coded as 1
the contrast condition as -1.

Lets start with the t-tests
```{r}
#One sample (paired) t-test. The assumption is that each row is dependent.
diff<-simval_similar-simval_contrast
t.test(diff)
#this is the same t-test
t.test(simval_similar,simval_contrast, paired = TRUE)
```

We fit a linear mixed effects model with varying intercepts for items. 
We will then check the residual assumption of that model.

For that purpuse we create a dataframe containing
- the item ID
- the condition (sum contrast coding)
- a vector with all similarity values (first similarity values corresponding to the similar 
                                       tuples, then those corresponding to the contrast tuples)
For the sum contrast conding, we need a vector containing the condition (-1 and 1)
as many times as we have observations in each group (73 for each group). 
Since we have the two groups together in one vector, we need to create an item ID that counts
from one to the length of the similar dataset and starts at one again for the contrast
dataset.

```{r}
#dataframe for linear mixed models

#Item ID

len_sim<-length(simval_similar)
len_con<-length(simval_contrast)
#the similar and the contrast group are equal in their length

Item_ID<-rep(1:len_sim,2)

#Condition (sum contrast coding). Similar group +1, contrast group -1.

condition<-c(rep(1,len_sim),rep(-1,len_con))

similarity_values<-c(simval_similar,simval_contrast)

dataframe<-data.frame(ID=Item_ID,condition=condition,similarity_values=similarity_values)
head(dataframe)
```

```
#Varying intercepts for items 
m0<-lmer(similarity_values~condition + (1|Item_ID),dataframe,REML=FALSE)
summary(m0)
#significant


Check for the residuals of the model.

```{r}
acf(residuals(m0))
```
