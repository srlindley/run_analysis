## Script to produce tidy data file from smartphone sensor data
## Please read the corresponding README.md file for explanation in github repository srlindley/run_analysis
## the corresponding codebook describing the variables is also in the same repository
## source data is https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
## source information about this data set: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
## script achieves the following 5 requireents (these relate to comment headings in the attached script)
## requirement 1: Merges the training and the test sets to create one data set.
## requirement 2: Extracts only the measurements on the mean and standard deviation for each measurement. 
## requirement 3: Uses descriptive activity names to name the activities in the data set
## requirement 4: Appropriately labels the data set with descriptive variable names. 
## requirement 5: Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

## The script processes these results in the following order:

## stage 1: Load and combine the training and test data (delivers requirement 1)
## stage 2: Make a set of valid variable (feature) names and use these to name the columns (delivers requirement 4)
## stage 3: Extract the relevant columns needed (using column names already in place above)  (delivers requirement 2)
## stage 4: Replaces the activity Ids with activity descriptions (delivers requirement 3)
## stage 5: Creates the second data set with averages for each activity and subject combination (delivers requirement 5)

## the logic behind this order and the explanation of the processing is in the corresponding README.md file
## this order of processing was agreed acceptable on the course forum see https://class.coursera.org/getdata-004/forum/thread?thread_id=365


## stage 1: Load and combine the training and test data (delivers requirement 1)

## A) Extract data files
## assumed per instructions that data is already in users working directory, and that needs to be unzipped
## the following two lines can be uncommented to load the data if necessary
## fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
## download.file(fileurl, destfile ="getdata-projectfiles-UCI HAR Dataset.zip")

## following line unzips the data in the R working data, this can be removed or commented out if file already unzipped
unzip("./getdata-projectfiles-UCI HAR Dataset.zip") ## unzip and extract files to data subdirectory

## B) load relevant data tables into R (leaving out intertial data as not needed in final output)
xtest <- read.table("./UCI HAR Dataset/test/X_test.txt")
xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt") 
subjectTest<- read.table("./UCI HAR Dataset/test/subject_test.txt") ## read test subjects
subjectTrain<- read.table("./UCI HAR Dataset/train/subject_train.txt") ## read training subjects
ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt") 
ytest <- read.table("./UCI HAR Dataset/test/y_test.txt")

## C) Rename subject table field to avoid duplicate field names 
names(subjectTest) <- "subjectID"
names(subjectTrain) <- "subjectID"
## D) Rename label field
names(ytrain) <- "activity"
names(ytest) <- "activity"

## E) combine datatables
## First bind subjects to activities to data sets
testTable <- cbind(subjectTest, ytest, xtest)
trainTable <- cbind(subjectTrain, ytrain, xtrain)
## second bind train and test data sets
data <- rbind(trainTable, testTable)

## stage 2: Make a set of valid variable (feature) names and use these to name the columns (delivers requirement 4)

## load the table of features
features <- read.table("./UCI HAR Dataset/features.txt")
features <-features[,-1]
validFeatures <- sapply(features, make.names, unique = TRUE) ## create valid R names from the activity names provided
ndata <- data # create ndata to hold new data and names
names(ndata)[3:563] <- validFeatures ## replace the names for ndata with the valid names

## Note on format - by creating R valid names created "."s to replace invalid characters - parantheses and dashes
## decision made not to remove these "."s as spacing provides readability to identify X, Y, Z or none
## also this coding provides ready comparibility and understandability to those familiar with prior naming
## finally naming approach is reproducible and consistent for any future changes in source data names (not subjective)



## stage 3: Extract the relevant columns needed (using column names already in place above)  (delivers requirement 2)
## A) Find initial list of columns needed
cols <- grep("subjectID|activity|mean|std", names(ndata)) ## search for column names want..

## B) create subset of ndata table with required columns

shortdata <- ndata[,cols] ## subsetting ndata table by the required columns
## removing meanFreq entries found in names(shortdata)

excl <-grep("meanFreq", names(shortdata)) ## find columns where mean is meanFreq to be excluded
shortdata <- shortdata[,-excl] ## remove columns to be excluded

## stage 4: Replaces the activity Ids with activity descriptions (delivers requirement 3)
## replace activity ids with activity name
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt") ## read table of activity names 
labelData <- merge(shortdata, activityLabels, by.x="activity", by.y="V1", all=TRUE) ## merge activity labels table against datatable
labelData$activity <- labelData$V2
labelData[,"V2"]  <- NULL ## remove the V2 column now

## stage 5: Creates the second data set with averages for each activity and subject combination (delivers requirement 5)
## install.packages("reshape2") ## install package if not already installed
library(reshape2)
## A) Melt the data set
melted <- melt(labelData, id.vars=c("subjectID", "activity"), measure.vars = names(labelData[,3:68]))
## B) Cast a table 
meanData <- dcast(melted, activity + subjectID ~ variable, mean)
## C) write the table as a text file 
write.table(meanData, "./UCI HAR Dataset/meanData.txt", row.names = FALSE)
