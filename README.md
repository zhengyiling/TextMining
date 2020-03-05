# TextMining
Text Data Analysis

# Introduction
This project will analyze two data sets for text mining analysis. One is the book 'Grimms’ Fairy Tale' by Jacob Grimm and Wilhelm Grimm, and the another is 'Judge Emotions about Nuclear Energy from Twitter', which are both csv. document I got from online resource. 
The former is from the website (http://www.gutenberg.org/ebooks/2591). I didn’t download the text document of the book, but directly used the link (http://www.gutenberg.org/files/2591/2591-0.txt) in my R code for importing. For the data of 'Judge Emotions about Nuclear Energy from Twitter', I found it from the website called “Figure Eight” (https://www.figure-eight.com/data-for-everyone/) which is a collection of tweets related to nuclear energy along with the crowd’s evaluation of the tweet’s sentiment.
Coding reference: https://quanteda.io/
# Background
-The book Grimms’ Fairy Tale is a collection of fairy tales first published on 20th December, 1812, by the Grimm brothers, Jacob and Wilhelm. They collected 209 tales into this book, and the translators who translated the book into English are Edgar Taylor and Marin Edwardes. This text data of the book was produced by Emma Dudding, John Bickers, and Dagny.
-The data of 'Judge Emotions about Nuclear Energy from Twitter' contains 190 observations and 3 variables. The first variable is the text content of tweet, and the second variable is the sentiment. The possible sentiment categories are: “positive”, “negative”, “neutral/author is just sharing information”, “tweet not related to nuclear energy”, “I can’t tell”. The third variable is the estimation of the crowds’ confidence which can be used to identify tweets whose sentiment may be nuclear. 
# Method
Import the datasets, create corpus, then token them, breaking the sentences into chunks;
Use kwic() find the keywords;
Use dfm() and textplot_wordcloud() create the word cloud picture;
Use topfeatures() show out the top words in the dataset; 
Generate N-grams;
Calculate the term frequence and document frequence;
Shrink data, train and test datasets.

# Summary 
By analyzing these two data sets, I understood the basic operation of text mining, like create corpus, token the dataset, generate the document frequency matrix, find the keywords, and plot the word cloud picture and network between them.
The statistical and sentiment analysis of text mining are very useful to help people quickly get the information from the texts.
