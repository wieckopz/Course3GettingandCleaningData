setwd('C:/Users/pwieckowski/Documents/R/Course 3 Getting and Cleaning Data Week 4 Assignment')
path <- getwd()

fUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
if(!file.exists(path)){dir.create(path)} 
download.file(fUrl,file.path(path, "Dataset.zip")) 
funzip(zipfile="./Dataset.zip",exdir=path) 

path0 <- file.path(path, "UCI HAR Dataset")
list.files(path0, recursive = TRUE)

#Read in all the test and train fiels
dataSubjTrain <- read.table(file.path(path0, "train", "subject_train.txt"),header = FALSE)
dataSubjTest <- read.table(file.path(path0, "test", "subject_test.txt"),header = FALSE)
dataActTrain <- read.table(file.path(path0, "train", "Y_train.txt"),header = FALSE) 
dataActTest <- read.table(file.path(path0, "test" , "Y_test.txt" ),header = FALSE) 
dataFeatTrain <- read.table(file.path(path0, "train" , "X_train.txt" ),header = FALSE) 
dataFeatTest <- read.table(file.path(path0, "test" , "X_test.txt" ),header = FALSE) 
dataFeatNames <- read.table(file.path(path0, "features.txt"),head=FALSE) 

dataSubj <- rbind(dataSubjTrain, dataSubjTest) 
dataAct<- rbind(dataActTrain, dataActTest) 
dataFeat<- rbind(dataFeatTrain, dataFeatTest) 

names(dataSubj)<-c("Subject") 
names(dataAct)<- c("Activity") 
names(dataFeat)<- dataFeatNames$V2 
 
#Merge the Subject and Activity data sets
dataMerge <- cbind(dataSubj, dataAct) 
subData1 <- cbind(dataFeat, dataMerge) 

#Subset only mean and standard deviation
dataFeatNames2<-dataFeatNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeatNames$V2)] 

#Label Subject and Activity
validNames<-c(as.character(dataFeatNames2), "Subject", "Activity" ) 
subData1<-subset(subData1,select=validNames) 

#Read in the names of all activities
activityNames <- read.table(file.path(path0, "activity_labels.txt"),header = FALSE)

#Rename Data Set Variables
names(subData1)<-gsub("^t", "Time", names(subData1)) 
names(subData1)<-gsub("^f", "Freq", names(subData1)) 
names(subData1)<-gsub("Acc", "Accelerometer", names(subData1)) 
names(subData1)<-gsub("Gyro", "Gyroscope", names(subData1)) 
names(subData1)<-gsub("Mag", "Magnitude", names(subData1))


#Create Independent Tidy data set
library(plyr); 
Tidy<-aggregate(. ~Subject + Activity, subData1, mean) 
Tidy<-Tidy[order(Tidy$Subject,Tidy$Activity),] 
write.table(Tidy, file = "TidyData.txt",row.name=FALSE) 


#Create Codebook
library(knitr)
knit("TidyData.txt", output = "codebook.md", encoding = "ISO8859-1", quiet = TRUE)
knit2html("codebook.md")





