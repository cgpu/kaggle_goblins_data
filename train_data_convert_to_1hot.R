# Fetch kaggle version train.csv file
URL  <- "http://bit.ly/train_goblins"
train_set <- read.csv(URL)

# Load dependencies
pacman::p_load ( 
                 # CRAN misc utils
                 purrr,
                 utils, 
                 skimr, 
                 devtools,
                 
                 # For EDA
                 dplyr,
                 visdat,
                 DataExplorer,
                 DT,
                 
                 # for rgb conversion from color name
                 grDevices)

# Inspect train.csv
head(train_set, 4)

# Colnames
colnames(train_set)

## One-hot : Translate 1D colour to 4D rgba values

# available in 📦 {grDevices}, the others manually bc they error bc unavail
my_palette <- c("red", "blue", "green", "black", "white") 


# Function call grDevices::col2rgb()
# i: list of colour names
# o: a "matrix" with color names as colnames, rgba as 4 row.names
color2RGBA_df           <- grDevices::col2rgb(my_palette, alpha = TRUE)

# Check class of grDevices::col2rgb() object  
class(color2RGBA_df) #o: [1] "matrix"

# Convert to dataframefor l8r for ggplot2
color2RGBA_df           <- as.data.frame(color2RGBA_df)

# Make sure colnames correspond to selected colors
colnames(color2RGBA_df) <- my_palette

# Check data types of vars
dplyr::glimpse(color2RGBA_df)

# Peculiar color #1
color2RGBA_df$blood <- color2RGBA_df$red

# Peculiar color #2
# could be 255 255 255 0, because closer to white than black
color2RGBA_df$clear <- c(255,255,255,0) 

color2RGBA_df$color <- row.names(color2RGBA_df)
str(color2RGBA_df)
head(color2RGBA_df)

# Transposing mapping dataframe
color2RGBA_df.T <- as.data.frame(t(color2RGBA_df))
head(color2RGBA_df.T, 2)

#https://stackoverflow.com/questions/43789278/convert-all-columns-to-characters-in-a-data-frame 
color2RGBA_df.T[,] <- lapply(color2RGBA_df.T[,], as.factor)

head(color2RGBA_df.T) 
cat("\n")
dplyr::glimpse(color2RGBA_df.T)

# Merge train with converted to rbga colors
train_rgba <- merge(train_set, color2RGBA_df.T,
                    all     = T, 
                    by      = "color" ,  
                    no.dups = TRUE,
                    sort    = FALSE)

head(train_rgba)
train_rgba_class_name <- train_rgba


# Convert to numeric for sending it GridSearch
train_rgba$type <- unclass(as.factor(train_rgba$type))
head(train_rgba, 2)


# Set path of (i)output directory (ii) filename:
devtools::source_url("http://bit.ly/souRceRy")
savedir    = paste0( souRcery(), "Dropbox/")

savedir
FILE = paste0(savedir,  'goblins_kaggle/TRAIN_DATA/train_rgba_with_class_name', '.csv')

# Write dataframe into .csv file
write.table( train_rgba_class_name ,  
file      = FILE,
append    = FALSE, 
quote     = FALSE, 
sep       = ",",
row.names = F,
col.names = T)


# Reload the file to check column names and all are good:
temp_df <- read.csv(FILE, 
header           = TRUE, 
stringsAsFactors = FALSE, 
check.names      = FALSE); 

# check dimensions of csv file // This should be `TRUE`: dim(temp_df) == dim(my_fav_df)
dim(temp_df)

# Preview dataframe, check if written correctly 
# Common suspects for trouble: header not written, header converted to row, first column converted to rownames, etc/
head(temp_df)

