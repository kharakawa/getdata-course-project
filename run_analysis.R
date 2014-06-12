# run_analysis.R
# 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

#######################################################################
# 0. load data
#######################################################################

library(data.table)

DATA_DIR <- 'UCI HAR Dataset'

features <- read.table(file.path(DATA_DIR, 'features.txt'),
                       colClasses=c("integer", "character"), col.names=c("Id", "Label"))

subject_train <- read.table(file.path(DATA_DIR, 'train', 'subject_train.txt'))

X_train <- read.table(file.path(DATA_DIR, 'train', 'X_train.txt'),
                      quote="", colClasses="numeric", comment.char="")
y_train <- read.table(file.path(DATA_DIR, 'train', 'y_train.txt'))

subject_test <- read.table(file.path(DATA_DIR, 'test', 'subject_test.txt'))

X_test <- read.table(file.path(DATA_DIR, 'test', 'X_test.txt'),
                     quote="", colClasses="numeric", comment.char="")
y_test <- read.table(file.path(DATA_DIR, 'test', 'y_test.txt'))

activity_labels <- read.table(file.path(DATA_DIR, 'activity_labels.txt'),
                              colClasses=c("integer", "character"), col.names=c("Id", "Label"))

#######################################################################
# 1. Merges the training and the test sets to create one data set.
#######################################################################

# merge train/test data into one big data frame
merged_data <- rbind(cbind(X_train, y_train, subject_train),
                     cbind(X_test, y_test, subject_test))

# set temporary column names, for the ease of latter operations
colnames(merged_data) <- c(as.character(features$Label), 'ActivityCode', 'SubjectId')

#######################################################################
# 2. Extracts only the measurements on the mean and standard deviation 
#    for each measurement. 
#######################################################################

# find indices of columns on mean and standard deviation, 
# as well as activity and subject columns, but angle() variables.
mean_std_names <- grep('[Ss]td|[Mm]ean|ActivityCode|SubjectId', value=T,
                       grep('^angle', invert=T, value=T,
                            colnames(merged_data)))
mean_std_cols = colnames(merged_data) %in% mean_std_names

# extract corresponding columns / labels
selected_data <- merged_data[, mean_std_cols]

#######################################################################
# 3. Uses descriptive activity names to name the activities
#    in the data set
#######################################################################

# utility function to make readable activity labels
lower_split_label <- function(x) {
  # lower the string, split by underscore, concatenate them again with single whitespace.
  paste(strsplit(tolower(x), "_")[[1]], collapse=" ")
}

# transform labels
activity_labels <- transform(activity_labels,
                             Label=factor(sapply(Label, lower_split_label)))

# merge labels with data set.
# to restore column order, original column names are saved beforehand.
original_cols = colnames(selected_data)

# rename column
original_cols[original_cols == 'ActivityCode'] <- 'Activity'

# merge
selected_data <- merge(selected_data, activity_labels,
                      by.x='ActivityCode', by.y='Id', sort=F, all.x=T)

# set readable activity label in 'Activity' column, then reorder whole columns.
selected_data[,'Activity'] <- selected_data[, 'Label']
selected_data <- selected_data[original_cols]

#######################################################################
# 4. Appropriately labels the data set with descriptive variable names. 
#######################################################################

# convert original name into a kind of CamelCase.

# 1st rule
colnames(selected_data) <- 
  gsub('BodyBody', 'Body',       # BodyBody -> Body
       gsub('),', ',',           # other typo
            colnames(selected_data)))
     
# 2nd rule
colnames(selected_data) <- 
  gsub('(^|\\()f', '\\1Freq',         # f... -> Freq...
       gsub('(^|\\()t', '\\1Time',    # t... -> Time...
            colnames(selected_data)))

# 3rd rule
colnames(selected_data) <- 
  gsub('Mag', 'Magnitude',             # Mag  -> Magnitude
       gsub('Acc', 'Accelaration',     # Acc  -> Accelaration
            colnames(selected_data)))

# 4th rule
colnames(selected_data) <- 
  gsub('-mean(.*?)\\()', 'Mean\\1',            # -mean...() -> Mean...
       gsub('-std(.*?)\\()', 'Stddev\\1',      # -std...() -> Stddev...
            gsub('-([XYZ])', '\\1',    # -{X,Y,Z} -> {X,Y,Z}
                 colnames(selected_data))))


#######################################################################
# 5. Creates a second, independent tidy data set with the average 
#    of each variable for each activity and each subject.
#######################################################################

selected_data = data.table(selected_data)
average_data = selected_data[, lapply(.SD, mean), by=c('Activity', 'SubjectId')]

write.table(average_data, 'tidy_data.tsv', sep='\t')
