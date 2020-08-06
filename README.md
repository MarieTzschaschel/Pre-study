# Pre-study
Code corresponding to the pre-study "Deeper understanding of the relation between the similarity scores of word2vec and the concept of animacy"

# Abstract
In the study "Deeper understanding of the relation between the similarity scores of word2vec and the concept of animacy" we examine whether the objective similarity measurement of Word2Vec is distinguishing noun pairs that have either the same or different animacy statement. If word2vec is computing significantly different similarity values for nouns with the same animacy (two animate or two inanimate nouns) compared to nouns with different animacy (one animate and one inanimate noun) it is an appropriate method to distinguish nouns by means of their animacy by giving a numerical (computer readable) output.
This question is examined by comparing the similarity values between noun pairs with the same animacy with noun pairs with different animacy.
The result shows a highly significant difference between the two groups. Nouns with the same animacy are rated significantly more similar compared to nouns with different animacy.

# Two main projects
In the python project (prestudy_item_ceration) the noun pairs are created and their corresponding similarity values are calculated. The output is a dataframe (df_simval) containing the noun pairs of both groups (noun pairs with the same animacy: similar group, noun pairs with different animacy: contrast group) and a similarity value for each word pair.
The prestudy_dataanalysis is the statistical analysis that compares the similarity values of both groups. A linear mixed model with varying intercepts for items is fitted.
