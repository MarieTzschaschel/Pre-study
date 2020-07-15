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
hist(simval_similar,1000)
hist(simval_contrast,1000)

#Here it would be nice to plot both distributions one above the other such that one can 
#better see the difference between the two.
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

#power analysis: 98%
power.t.test(delta = delta, n=150, sd=sd_similar, type="two.sample", alternative="two.sided")
```
Here I chose to take the two.sample t.test. It assumes the data to be independent.
With the last dataset we had the problem that within the groups we had a lot of dependencies
the we could not correctly group (or aggregate) together.
This problem is solved with this data.
But we have a new problem here: We have nouns in the similar group that are also in the
contrast group. They are combined differently (because in the similar group we need nouns
of the same animacy and in the contrast group we need nouns with different animacy), but 
they are appearing in both groups.

The problem is that the one sample t-test or paired t-test assumes that the data is dependent
row by row. This means that the first row of the similar dataset would be dependent with
the first row of the contrast dataset. This is not the case. 
I do not know how to treat the dependencies of the data within my two groups and I would
need help.

In the next block, we nevertheless, do a one and two sample t-test, create a data frame 
and fit linear mixed models. We ignore for a moment the dependencies between the data in the two groups.
For the linear mixed models we do sum contrast coding. The similar condition is coded as 1
the contrast condition as -1.

Lets start with the t-tests
```{r}
#Two sample t-test. Assumes that the data is completely independant, which is not true
# Would be significant: t = 4.2667, df = 296, p-value = 2.673e-05
t.test(dataframe2$simval_similar,dataframe2$simval_contrast,var.equal=TRUE)

#One sample (paired) t-test. The assumption is that each row of the two columns are
#dependent. This is actually not the case...
#would be significant too: t = 4.4417, df = 148, p-value = 1.737e-05
diff<-dataframe2$simval_similar-dataframe2$simval_contrast
t.test(diff)

```

Creation of a dataframe for the linear mixed models.
In the dataframe we need one vector containing all the similarity values of both groups. At
first we will have all the similarity values of the similar group, next, all the values of
the contrast group.
To do the sum contrast conding, we need a vector containing the condition, so we need as
many ones as we have similarity values for the similar group (length of simval_similar) and
as many minus ones as we have entries for the contrast group (length of simval_contrast).
Since we have the two groups together in one vector, we need to create an item ID that counts
from one to the length of the similar dataset and starts at one again when the contrast
dataset begins.

```{r}
#dataframe for linear mixed models

#Item ID

len<-length(simval_similar)
#the similar and the contrast group are equal in their length, therefore just one vector 
#is necessary here
Item_ID<-rep(1:len,2)

#Condition (sum contrast coding). Similar group +1, contrast group -1.

condition<-c(rep(1,len),rep(-1,len))

dataframe<-data.frame(ID=Item_ID,condition=condition,similarity_values=similarity_values)
head(dataframe)
```
Fitting the linear mixed models

```
#Varying intercepts only
m0<-lmer(similarity_values~condition + (1|Item_ID),dataframe,REML=FALSE)
summary(m0)
#significant

#Varying intercepts and varying slopes with no correlation
m1<-lmer(similarity_values~condition + (1+condition||Item_ID),dataframe)
summary(m1)
#Warning message: Model is unidentifiable, large eigenvalue ratio

#varying intercepts with correlation
m2<-lmer(similarity_values~condition+(1|Item_ID),dataframe)
summary(m2)
#significant
```

Check for the residuals of the model.

```{r}
acf(residuals(m2))
#looks good this time...
```

Do the anova test for the model selection

```{r}
anova(m0,m1)
anova(m1,m2)
anova(m0,m2)
#model 2 is the best model
```

Conduct the null model test with model 2

```{r}
#likelihood ratio test
m2NULL<-lmer(similarity_values~ 1 + (1|Item_ID),dataframe)
anova(m2NULL,m2)
#significant in favour for m2
```

