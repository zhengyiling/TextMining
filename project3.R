library(gutenbergr)
library(quanteda)
library(readtext)

#1
grimms <- texts(readtext("http://www.gutenberg.org/files/2591/2591-0.txt"))
View(grimms)

grimms.corpus <- corpus(grimms, docvars = data.frame(party = names(grimms)))
summary(grimms.corpus)
docnames(grimms.corpus) <- c("Grimms' Fairy Tale")
summary(grimms.corpus)

grimms.tokens <- tokens(grimms.corpus, what = "word", 
                           remove_numbers = TRUE, remove_punct = TRUE,
                           remove_symbols = TRUE, remove_hyphens = TRUE)
head(grimms.tokens)
grimms.tokens.st <- tokens_select(grimms.tokens, stopwords('en'), selection = 'remove')
head(grimms.tokens.st[1])

grimms.tokens.dfm <- dfm(grimms.tokens,tolower = F)
textplot_wordcloud(grimms.tokens.dfm, max_words = 200)

grimms_kw <- kwic(grimms.tokens.st, 'fox')
head(grimms_kw, 10)
dim(grimms_kw)

grimms_kw1 <- kwic(grimms.tokens.st, phrase('happy birthday'))
head(grimms_kw1, 10)
dim(grimms_kw1)

library(xtable)
View(grimms_kw)

ngram <- tokens_ngrams(grimms.tokens.st, n = 2)
summary(ngram)
head(ngram[[1]], 10)

grimms_dfm_st <- dfm(grimms.tokens.st)
ndoc(grimms_dfm_st)
nfeat(grimms_dfm_st)
head(grimms_dfm_st)
View(grimms_dfm_st[,1:50])

topfeatures(grimms_dfm_st)
prop_grimms_dfm_st <- dfm_weight(grimms_dfm_st, scheme  = "prop")
topfeatures(prop_grimms_dfm_st)
textplot_wordcloud(grimms_dfm_st, max_words = 10)
textplot_wordcloud(grimms_dfm_st, max_words = 100)

feat <- names(topfeatures(grimms_dfm_st, 50))
size <- log(colSums(dfm_select(grimms_dfm_st, feat)))
textplot_network(grimms_dfm_st, min_freq = 0.8, vertex_size = size / max(size) * 3)

dist <- textstat_dist(grimms_dfm_st)
clust <- hclust(dist)
plot(clust, xlab = "Distance", ylab = NULL)

#meaningless calculation?
tfidf_grimms_dfm_st <- dfm_tfidf(grimms_dfm_st)
topfeatures(tfidf_grimms_dfm_st)
long_grimms_dfm_st <- dfm_select(grimms_dfm_st, min_nchar = 5)
nfeat(long_grimms_dfm_st)
trim_grimms <- dfm_trim(grimms_dfm_st, min_count = 20)
ndoc(trim_grimms)
nfeat(trim_grimms)

hp_grimms <- dfm_trim(grimms_dfm_st, min_docfreq=.5)
nfeat(hp_grimms)
topfeatures((hp_grimms))



#2
emotion <- read.csv(file.choose(), stringsAsFactors = FALSE)
View(emotion)
summary(emotion)
head(emotion)

emotion <- emotion[,1:2]
names(emotion) <- c("Text", "Label")
View(emotion)

emotion.corpus <- corpus(emotion$Text)
str(emotion.corpus)
emotion.corpus$documents$texts
length(which(!complete.cases(emotion)))

emotion$Label <- as.factor(emotion$Label)
table(emotion$Label)
prop.table(table(emotion$Label))

emotion$Text[15]
nchar(emotion$Text[15])
emotion$TextLength <- nchar(emotion.corpus$documents$texts)
summary(emotion$TextLength)

library(ggplot2)
ggplot(emotion, aes(x = emotion$TextLength, fill = Label)) +
  theme_bw() +
  geom_histogram(binwidth = 5) +
  labs(y = "Text Count", x = "Length of Text",
       title = "Distribution of Text Lengths with Class Labels")

library(lattice)
library(ggplot2)
library(caret)

set.seed(32984)
indexes <- createDataPartition(emotion$Label, times = 1,
                               p = 0.7, list = FALSE)

train <- emotion[indexes,]
test <- emotion[-indexes,]
table(train$Label)
prop.table(table(train$Label))
table(test$Label)
prop.table(table(test$Label))

train$Text[21]
train$Text[38]

library(quanteda)
library(readtext)

train.tokens <- tokens(train$Text, what = "word", 
                       remove_numbers = TRUE, remove_punct = TRUE,
                       remove_symbols = TRUE, remove_hyphens = TRUE)
head(train.tokens)
train.tokens <- tokens_tolower(train.tokens)
stopwords()
train.tokens <- tokens_select(train.tokens, stopwords(), 
                              selection = "remove")

train.tokens <- tokens_wordstem(train.tokens, language = "english")
str(train.tokens)

train.tokens.dfm <- dfm(train.tokens, tolower = FALSE)

train_dist <- textstat_dist(train.tokens.dfm)
train_clust <- hclust(train_dist)
plot(train_clust, labels = F)

topfeatures(train.tokens.dfm, 10)
feat <- names(topfeatures(train.tokens.dfm, 10))
size <- log(colSums(dfm_select(train.tokens.dfm, feat)))
textplot_network(train.tokens.dfm, min_freq = 0.95, vertex_size = size / max(size) * 2)

train.tokens.matrix <- as.matrix(train.tokens.dfm)
View(train.tokens.matrix[1:20, 1:100])
dim(train.tokens.matrix)
colnames(train.tokens.matrix)[1:50]

library(tm)
library(wordcloud)
library(RColorBrewer)
topfeatures(train.tokens.dfm, n=10, decreasing = TRUE)
textplot_wordcloud(train.tokens.dfm, max_words = 100)

ggplot(train, aes(x = train$TextLength, fill = Label)) +
  theme_bw() +
  geom_histogram(binwidth = 5) +
  labs(y = "Text Count", x = "Length of Text",
       title = "Distribution of Text Lengths with Class Labels")
summary(train$TextLength)


train.tokens.df <- cbind(Label = train$Label, data.frame(train.tokens.dfm))
names(train.tokens.df) <- make.names(names(train.tokens.df))
names(train.tokens.df)[c(15, 20, 25, 30)]
train.tokens.matrix <- as.matrix(train.tokens.dfm)
View(train.tokens.matrix[1:20, 1:100])
dim(train.tokens.matrix)

set.seed(48743)
cv.folds <- createMultiFolds(train$Label, k = 10, times = 3)
cv.cntrl <- trainControl(method = "repeatedcv", number = 10,
                         repeats = 3, index = cv.folds)

library(foreach)
library(iterators)
library(snow)
library(doSNOW)
start.time <- Sys.time()
cl <- makeCluster(3, type = "SOCK")
registerDoSNOW(cl)
rpart.cv.1 <- train(Label ~ ., data = train.tokens.df, method = "rpart", 
                    trControl = cv.cntrl, tuneLength = 7)
stopCluster(cl)
total.time <- Sys.time() - start.time
total.time
rpart.cv.1

term.frequency <- function(row) {
  row / sum(row)
}

inverse.doc.freq <- function(col) {
  corpus.size <- length(col)
  doc.count <- length(which(col > 0))
  
  log10(corpus.size / doc.count)
}

tf.idf <- function(x, idf) {
  x * idf
}

train.tokens.df <- apply(train.tokens.matrix, 1, term.frequency)
dim(train.tokens.df)
View(train.tokens.df[1:20, 1:100])

train.tokens.idf <- apply(train.tokens.matrix, 2, inverse.doc.freq)
str(train.tokens.idf)

train.tokens.tfidf <-  apply(train.tokens.df, 2, tf.idf, idf = train.tokens.idf)

View(train.tokens.tfidf[1:25, 1:25])


incomplete.cases <- which(!complete.cases(train.tokens.tfidf))
incomplete.cases
train$Text[incomplete.cases]

train.tokens.tfidf[incomplete.cases,] <- rep(0.0, ncol((train.tokens.tfidf)))
dim(train.tokens.tfidf)
View(train.tokens.tfidf[1:25, 1:25])
sum(which(!complete.cases(train.tokens.tfidf)))

train.tokens.tfidf.df <- cbind(Label = train$Label, data.frame(t(train.tokens.tfidf)))
names(train.tokens.tfidf.df) <- make.names(names(train.tokens.tfidf.df))
View(train.tokens.tfidf.df[1:25, 1:25])

start.time <- Sys.time()

cl <- makeCluster(3, type = "SOCK")
registerDoSNOW(cl)

rpart.cv.2 <- train(Label ~ ., data = train.tokens.tfidf.df, method = "rpart", 
                    trControl = cv.cntrl, tuneLength = 7)

stopCluster(cl)

total.time <- Sys.time() - start.time
total.time
rpart.cv.2

train.tokens.tfidf<-as.dfm(t(train.tokens.tfidf))
topfeatures(train.tokens.tfidf,n=10,decreasing = TRUE)
topfeatures(train.tokens.dfm, n=10, decreasing = TRUE)
