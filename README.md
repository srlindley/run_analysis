run_analysis
============

## Introduction

This README file relates to the run_analysis.R script stored in the srlindley/run_analysis repository on Github.  There is only one script.

## Purpose of the Script

The script uses the data from:  
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip   

A description of this data is here:  
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  

The purpose of the script is to create a tidy data set on a subset of the data which covers mean/ standard deviation measurements.

The final tidy data set calculates mean values for these measures for each unique combination of activity and subject.  
This file describes how to run the script and the logic of how and why it works as it does (including some of the design decisions made).  Further explanation is included in the codebook.md.

## Assumptions

•	The data zip file from the above link  is loaded into the R working directory (not unzipped)  
•	R software is installed to run the script with sufficient system resources available  
•	Necessary packages are installed; default/ standard R packages plus reshape2  
•	The “run_analysis.R” script has been saved into the R working directory  

## How to run the script  

Ensure the data file “getdata-projectfiles-UCI HAR Dataset.zip” from the above source is loaded into the R working directory
If the data file needs to be loaded, then this can be done in R, the code is included in the script but is currently commented out – removing the comment marks at the front (##)  will cause the script to run.
Run the R script by entering the following at the R or R studio command line:
source("run_analysis.R")

The script will run (and should not require any interaction from the user if the above assumptions are correct), and will produce a text file (meanData.txt) of the tidy data set saved in the following subdirectory of the R working directory:
/UCI HAR Dataset

##  Logic and working of the script

The script is written to address 5 requirements:  
requirement 1: Merges the training and the test sets to create one data set.  
requirement 2: Extracts only the measurements on the mean and standard deviation for each measurement.   
requirement 3: Uses descriptive activity names to name the activities in the data set  
requirement 4: Appropriately labels the data set with descriptive variable names.   
requirement 5: Creates a second, independent tidy data set with the average of each variable for each activity and each subject.  

These are referred to in the explanation below as requirements 1 to 5, however the order in which these are carried out is slightly different:  

stage 1: Load and combine the training and test data (delivers requirement 1)  
stage 2: Make a set of valid variable (feature) names and use these to name the columns (delivers requirement 4)  
stage 3: Extract the relevant columns needed (using column names already in place above)  (delivers requirement 2)  
stage 4: Replaces the activity Ids with activity descriptions (delivers requirement 3)  
stage 5: Creates the second data set with averages for each activity and subject combination (delivers requirement 5)  
the logic behind this order and the explanation of the processing is set out below  
this order of processing was agreed acceptable on the course forum see   **https://class.coursera.org/getdata-004/forum/thread?thread_id=365**  

The processing is now described and explained stage by stage and sub section (A, B, C etc), these references are also included in the script to aid its review alongside this README file:   

### Stage 1: Load and combine the training and test data (delivers requirement 1)
A)	Extract data files
At the front of this section are two lines to set the url for the source data zip file and to download it into the R working directory.  These have been commented out (## at the front, as the file is assumed to have already been loaded), if it has not, then these comments can be removed to modify the script to load the file.
The first non comment line of the script unzips the zip file “getdata-projectfiles-UCI HAR Dataset.zip” from the R working directory, using the R “unzip” function.  
If the file has already been unzipped, then this line can be commented out by adding ## to the front of the line. 
Extracted files are stored by the unzipping into the following sub directory of the R working directory:
“/UCI HAR Dataset”  

B)	Load relevant data tables into R

The “read.table” function is used to read the following files from the “/UCI HAR Dataset”  subdirectory where they are held:
“X_test.txt” the X test data stored in the xtest variable  
“X_train.txt” the X training data   
“Y_train.txt” the Y training data  
“Y_test.txt” the Y test data  
“subject_test.txt”   the test subjects
“subject_train.txt” the training subjects

C)	Rename subject table field

Renames the subject test field name to “subjectID” for the test and train subject files.  This is done prior to merging the files to avoid using the existing “V1” field name which already exists in the Y and X test data.  It also contributes to the requirement 4, to have meaningful field names.

D)	Rename label field

Renames the Y test and train data field to “activity”, again to contribute to the requirement 4 at the same time as avoiding duplicate field names once the tables are combined.

E)	Combine data tables

Firstly a combined table of test results is created by binding columns (using the R “cbind” function) to connect subject, activity and variable (xtest) data tables as this adds fields matching the same observations.  Similarly a combined table of training results is created in the same way for the corresponding subject, activity and variable (xtrain) data tables.
Finally the test and train tables are combined using the R function “rbind” as these represent similar tables with different sets of observations. 
This completes requirement 1.

### Stage 2: Make a set of valid variable (feature) names and use these to name the columns (delivers requirement 4)

The variable (feature) names from the existing data set are loaded into R from the “features.txt” file using the “read.table” function.  The first column which is just numbering is then dropped through subsetting [, -1] in order to allow the names to be processed as a vector.

Valid names are then produced from the existing feature names using the “make.names” function with parameter “unique = TRUE” to coerce the existing feature names into valid R field names.  This replaces invalid characters (parentheses and dashes) with full stops.  This produces a list of variables with the structure described in the **codebook.md** file.  The “sapply” function is used to repeat this action across each entry in the list of feature names.
These amended column names are then loaded into the data table using the “names” function.

The reason for carrying out this re- naming at this point is to enable the selection of valid columns to be retained to be made based on the names on the columns rather than on a separate list of names and then have to extract both the names and columns to match each other as separate steps before then loading the names into the correct columns.  
As noted previously, this ordering of the change was agreed as acceptable in the course forum  
https://class.coursera.org/getdata-004/forum/thread?thread_id=365

The rationale for the naming structure is set out in the corresponding codebook.md 
This completed the requirement 4.

### stage 3: Extract the relevant columns needed (using column names already in place above)  (delivers requirement 2)  

A)	Find initial list of columns needed

The “grep” function is used to search for any of the words “subjectID”, “activity”, “mean” or “std” in the names of the data table.  
This produces a list of the column numbers that should be included in the reduced data table which includes only mean or standard deviation measurements.

B)	Create subset of table with required columns

A new datatable is created using subsetting by the above list of column numbers from the full data table.
A list of exclusions (additional columns to be removed) where the previous search term “mean” incorrectly allowed the variables “meanFreq” to be selected is found by using the “grep” function to search for the term “meanFreq” in the new list of data table names.  These columns are then dropped using subsetting.
 This completes the requirement 2.

### stage 4: Replaces the activity Ids with activity descriptions (delivers requirement 3)

The “activity_labels.txt” file is read with the “read.table” function.   
The “merge” function is then used to merge these activity labels with the main data table based on matching by the “activity” column in the main data table and by the activity number (the corresponding activity code number) from the activity labels table field “V1”.    
This creates a new column “V2” with the activity names representing the matching activity ID for each observation (row).   
The original “activity” column entries are then made equal to the values from this “V2” column, after which the “V2” column is no longer needed and is removed by making it “NULL”.
The activity descriptions are now correctly in the “activity” column and hence this completes requirement 3)  

### stage 5: Creates the second data set with averages for each activity and subject combination (delivers requirement 5)

The library “reshape2” is called.  If necessary this needs to be installed first by removing the “##” at the start of the line to install the package – it is assumed to be installed already.

A) Melt the data set  

The data table is melted using the “melt” function with “subjectID” and “activity” as the identity variables and the measure variables as the other columns (specified using the “names” function on the subset of columns 3 to 68).  

B) Cast a table  

The required second dataset “meanData” is then created using the “dcast” function to cast a table from the above melted data with the “activity” and “subjectID” columns plotted against the variables and summarising values using the mean function.
This produces a tidy data set in line with Hadley Wickham “tidy-data.pdf” definition.  With one observation per row and no combination of the identifiers “subjectID and “activity”.  
The result is a table summarising the mean value of each of the variables for each unique combination of activity and subject ID.  
Activity was chosen as the lead variable in the summary as it was considered the most important and for it to be more likely to compare readings within the activity by subject then readings for the same subject across different activities.  If this latter structure was required then the melted data set could be re-cast with the order of the identifier columns reversed.

C)	write the table as a text file  

The final activity is to write the resultant tidy data set to a text file “meanData.txt” in the same subdirectory as the other files “/UCI HAR Dataset”  using the “write.table” function with the “row.names =FALSE” parameter to avoid writing row names for clarity and readability.  

This completes the requirement 5. 









