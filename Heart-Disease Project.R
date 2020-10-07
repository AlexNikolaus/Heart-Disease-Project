library(tidyverse)
library(caret)
library(magrittr)
library(RANN)
library(bnstruct)
library(cluster)
library(ggfortify)
library(Rtsne)
library(randomForest)

#Set working directory and read file
setwd("D:/R Projects/Heart Disease Project")
Cleveland_Data <- read.table("processed.cleveland.data", sep = ",")
Hungarian_Data <- read.table("processed.hungarian.data", sep = ",")
Switzerland_Data <- read.table("processed.switzerland.data", sep = ",")

#Put NA where there are no measurements
Switzerland_Data <- na_if(Switzerland_Data, "?")
Cleveland_Data <- na_if(Cleveland_Data, "?")
Hungarian_Data <- na_if(Hungarian_Data, "?")

#Set labels
Labels <- c("Age", "Sex", "CpType", "Restbp", "Cholesterol", "Fastingbs", "Restecg", "Thalach", "Exang", "Oldpeak", "Slope", "Ca", "Thal", "Num")
colnames(Cleveland_Data) <- Labels
colnames(Hungarian_Data) <- Labels
colnames(Switzerland_Data) <- Labels

#Merge data frames and set column types
Heart_Data <- merge(merge(Hungarian_Data, Switzerland_Data, all = TRUE), Cleveland_Data, all = TRUE)
colnames(Heart_Data) <- Labels

#Put NA in the Heart dataset if measurements are missing (Here only for Cholesterol)
Heart_Data$Cholesterol <- na_if(Heart_Data$Cholesterol, 0)

#Checking for NA and imputing
anyNA(Heart_Data[,1:3])
Heart_Data <- knn.impute(as.matrix(Heart_Data), k = 5, cat.var = c(6,7,9,11,12,13))
Heart_Data <- as.data.frame(Heart_Data)

#Set appropriate column types
Heart_Data <- Heart_Data %>%
  mutate(Heart_Data, across(c("Age","Restbp","Cholesterol","Thalach", "Oldpeak"), as.numeric))
Heart_Data <- Heart_Data %>%  
  mutate(Heart_Data, across(c("Ca", "Thal"), as.integer))
Heart_Data <- Heart_Data %>%  
  mutate(Heart_Data, across(c("Sex", "CpType", "Ca", "Fastingbs", "Restecg", "Exang", "Slope", "Ca", "Thal", "Num"), as.factor))
str(Heart_Data)

#Set annotation column
Annotation_col <- tibble(Heart_Condition = c("Absence","Mild presence","Moderate presence","High presence","Very high presence"),
                        Num= c(0,1,2,3,4))

#EDA
ggplot(Heart_Data)+
  geom_bar(aes(Num))

ggplot(Heart_Data, aes(x = Num))+
  geom_bar(aes(fill = Sex))

ggplot(Heart_Data, aes(Restbp,Sex))+
  geom_boxplot(aes(fill = Sex))+
  coord_flip()

ggplot(Heart_Data)+
  geom_smooth(aes(Age,Restbp, colour = Sex),method = "lm")

t.test(Heart_Data$Restbp[Heart_Data$Sex ==0], Heart_Data$Restbp[Heart_Data$Sex==1])

summary(lm(Heart_Data$Thalach~Heart_Data$Cholesterol))

prop.table(table(Heart_Data$Num))

ggplot(Heart_Data)+
  geom_bar(aes(as.factor(Age), fill = Num))+
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))

ggplot(Heart_Data)+
  geom_point(aes(Num,Restbp, colour = Heart_Data$CpType))

#Using Gower distance for k-means clustering
Heart_Data_Gower <- daisy(Heart_Data[-14],
                          metric = "gower")
Heart_Data_Gower_Mat <- as.matrix(Heart_Data_Gower)

#Robust K-means using pam
pam_fit <- pam(Heart_Data_Gower_Mat,
               diss = TRUE,
               k = 5)

#t-SNE to view the clustering
tsne_obj <- Rtsne(Heart_Data_Gower_Mat, is_distance = TRUE)
tsne_data <- tsne_obj$Y %>%
  data.frame() %>%
  setNames(c("X", "Y")) %>%
  mutate(cluster = factor(pam_fit$clustering))
ggplot(aes(x = X, y = Y), data = tsne_data) +
  geom_point(aes(color = cluster))

#Creating index and partition the data
index <- createDataPartition(Heart_Data[,14], p = 0.75, list = FALSE)
Heart_Train <- Heart_Data[index,]
Heart_Test <- Heart_Data[-index,]

#Train the Random Forest model
tuneRF(Heart_Train[,-14],Heart_Train[,14])
RandomForest_Fit <- randomForest(x = Heart_Train[,-14],
                                 y = Heart_Train[,14],
                                 ntree = 70000,
                                 mtry = 6,
                                 nodesize = 10)
RandomForest_Pred <- predict(RandomForest_Fit)
confusionMatrix(RandomForest_Pred, Heart_Train[,14])

#Train k-NN with cv
TrainControl <- trainControl(method = "repeatedcv", number = 30, repeats = 10)
Knn_fit <- caret::train(x = Heart_Train[,-14],
              y = Heart_Train[,14],
              method = "knn",
              trControl = TrainControl,
              tuneGrid = data.frame(k = c(5:30)))
Knn_fit$bestTune
Knnfit_Pred <- predict(Knn_fit)
confusionMatrix(Knnfit_Pred, Heart_Train[,14])
