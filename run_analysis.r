installed.packages()[,"Package"]
list.of.packages <- c("reshape2")
summary((list.of.packages %in% installed.packages()[,"Package"]))
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
new.packages
if(length(new.packages)) install.packages(new.packages)

require(reshape2)

file <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(file)){
  URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(URL, file, method="libcurl")
}
if (!file.exists("UCI HAR Dataset")) {
  unzip(file)
}

# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
requiredFeatures <- grep(".*mean.*|.*std.*", features[,2])
requiredFeatures.names <- features[requiredFeatures,2]
requiredFeatures.names = gsub('-mean', 'Mean', requiredFeatures.names)
requiredFeatures.names = gsub('-std', 'Std', requiredFeatures.names)
requiredFeatures.names <- gsub('[-()]', '', requiredFeatures.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[requiredFeatures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[requiredFeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
completeData <- rbind(train, test)
colnames(completeData) <- c("subject", "activity", requiredFeatures.names)

# turn activities & subjects into factors
completeData$activity <- factor(completeData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
completeData$subject <- as.factor(completeData$subject)

completeData.melted <- melt(completeData, id = c("subject", "activity"))
completeData.mean <- dcast(completeData.melted, subject + activity ~ variable, mean)

write.table(completeData.mean, "tidyData.txt", row.names = FALSE, quote = FALSE)