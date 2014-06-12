# Course Project : Getting and Cleaning Data

This repository is for submission of course project in "Getting and Cleaning Data" (getdata-004) on Coursera.

This project contains an R script, which takes [Human Activity Recognition Using Smartphones Data Set] [1]. The script makes some analysis and transformation on the data set, and outputs a new tidy data set. A codebook for the tidy data set is provided as well.

## How to use

The original data set is not contained in this repository, so you have to download it to reproduce the result. [Zipped version of the original data set] [2] is provided by the course, and the following R script will download and unzip it.

    download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip',
                  destfile='UCI_HAR_Dataset.zip', method='curl')
    unzip('UCI_HAR_Dataset.zip')
  
Note that, the unzipped directory ( UCI HAR Dataset/ ) have to be in the current working directory when you run the script.

After downloading and extracting the data set into the current working directory, you can reproduce the tidy data set, just by executing the R scipt as follows:

    R CMD BATCH /path/to/run_analysis.R

The command produces `tidy_data.tsv` in the current directory. This is a standard tab separated text file, which can be read into R by read.table(). Variables in the file is described in CodeBook.md.

## Contents

This project has following files:

 * README.md  --- this file.
 * run_analysis.R --- analysis script. details are in [Analysis](#analysis) section.
 * CodeBook.md --- codebook of the attributes in the tidy data set.
 

## <a name="analysis" /> Analysis

The run_analysis.R script do some analysis and transformations on the data set. The following is the steps taken in the script to produce the final tidy data set.


1. (After loding original files into R environment, ) Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

On step 2, 3, 4, some judgements have been made to determine the deatils of the process, for example, "Which column shoud be extracted from original?", or "What kind of name should be used to name columns in new data set?", and so on. These judgements are explained in the sections below.

### Extracted mean and standard deviation columns (on Setp 2)

On step 2, some variables about mean and standard deviation have to be extracted from original data set. From the explanation in `features_info.txt` accompanied with original data set, the following rule is devised and used to select appropriate columns.

  1. select columns which have 'mean', 'Mean', 'std', 'Std' in their names.
  2. exclude columns whose name start with 'angle('

The latter rule is to exclude columns like 'angle(tBodyAccMean,gravity)', because these variables are indeed angles, not means nor standard deviations.

### Descriptive activity names (on Step 3)

On this step, activity codes extracted from `y_train.txt` and `y_test.txt` are converted into human readable labels stated in `activity_labels.txt` (all these files are provided with the original data set). Labels are lowered and repleced underscores with whitespaces along the way (resuls in 'walking' or 'walking upstairs', and so on).

### Descriptive variable (column) names (on Setp 4)

On the forth step, variable names are converted into more descriptive ones. In this instance, [Camel Case] [3] is chosen as a naming rule, because original variable names are relatively long, and the 'alllowercase' names are considerd not good for read. Main conversion rules of conversin are the following:

  1. fix some typos in original column names (see code for deatails).
  2. prefixes 't' and 'f' are replaced with 'Time' and 'Freq', respectively.
  3. shorthand forms 'Acc' and 'Mag' are replaced with corresponding longer forms 'Accelaration' and 'Magnitude'.
  4. '-functionName()' and '-X' are converted into 'FunctionName' and 'X', to conform to Camel Case.

[1]: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
[2]: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
[3]: http://en.wikipedia.org/wiki/CamelCase
