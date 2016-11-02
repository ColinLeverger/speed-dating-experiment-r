setwd("/Users/colinleverger/Documents/Experiments/kaggle/speed-dating-experiment")

#### Load packages ####
library(dplyr)
library(reshape2)
library(ggplot2)      # Data visualization
library(RColorBrewer) # Colors on plots
library(readr)        # CSV file I/O, e.g. the read_csv function
library(dataQualityR) # Generate the DQR

#### Color palettes for plots
cbPalette  <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

#### Read data ####
missing.types <- c("NA", "")
df <- read.csv("input/Speed Dating Data.csv", na.strings = missing.types, stringsAsFactors = F)
# Income, tuition and mn_sat should be read as numerics
df$income  <- as.numeric(gsub(",", "", df$income))
df$tuition <- as.numeric(gsub(",", "", df$tuition))
df$mn_sat  <- as.numeric(gsub(",", "", df$mn_sat))

#### Generate DQR, before feature engineering ####
checkDataQuality(
  df,
  out.file.num = "DQR_cont-before.csv",
  out.file.cat = "DQR_cat-before.csv"
)

### Read DQR on the disk ###
dqr.cont.bef <- read.csv("DQR_cont-before.csv")
dqr.cat.bef  <- read.csv("DQR_cat-before.csv")

### Classify features in function of their missingness for better analysis ###
feat.cont.missing20_100 <- dqr.cont.bef[dqr.cont.bef$missing.percent > 20,]
feat.cont.missing20     <- dqr.cont.bef[dqr.cont.bef$missing.percent <= 20 & dqr.cont.bef$missing.percent > 0,]

#### Investigations on the data ####
### Investigate: why is there so much 79 missing values (cf. dqr.cont var)? What can rapproach those missing values? ###
val1 <- feat.cont.missing20[feat.cont.missing20$missing == 79,]$X
# View(df[is.na(df$imprelig),])
# Nothing very interesting here...

### Investigate with missing age_o/race_o ###
missing.age_o.pid <- unique(df[is.na(df$age_o),]$pid)
missing.race_o.pid <- unique(df[is.na(df$race_o),]$pid)
# View(subset(df, iid %in% missing.age_o.pid))
# Nothing very interesting here too...

### Deal with missing id ###
# Find the iid of the only missing id
iid <- df[is.na(df$id),]$iid
# Assign this iid' id to the missing iid...
df[is.na(df$id),]$id <- head(df[df$iid == iid,]$id, 1)
# Note to myself: it is not usefull to make the process generic, the data won't change anyway...
 
### Deal with missing pid ###
# View(df[is.na(df$pid),])
# View(df[df$wave == 5 & df$id == 7,])
df[is.na(df$pid),]$pid <- 128

### Work on field feature ###
## Raw field ##
df$field <- tolower(df$field)
barplot(
  table(df$field),
  main = "Careers"
)
unique(df$field)
## Coded field ##
ordered(unique(df$field_cd))

### Work on career feature ###
## Raw career ##
df$career <- tolower(df$career)
barplot(
  table(df$career),
  main = "Careers"
)
unique(df$career)
## Coded career ##
ordered(unique(df$career_c))

### Work on zipcodes ###
df[df$zipcode == 0 & !is.na(df$zipcode),]$zipcode <- NA
ordered(unique(df$zipcode))

### Standardize wave > 5 and < 10 ###
# View(df[df$wave >5 & df$wave < 10,])
# View(df[df$wave == 3,])

### Change Male and Female attributes ###
df[df$gender == 0,]$gender <- "F"
df[df$gender == 1,]$gender <- "M"

#### Generate DQR, after feature engineering ####
checkDataQuality(
  df,
  out.file.num = "DQR_cont-after.csv",
  out.file.cat = "DQR_cat-after.csv"
)

### Read DQR on the disk ###
dqr.cont.aft <- read.csv("DQR_cont-after.csv")
dqr.cat.aft  <- read.csv("DQR_cat-after.csv")

#### Analyse the data ####
### Gender analysis ###
gender.rep.over.waves <- subset(df, !duplicated(df[, 1])) %>%
  group_by(wave, gender) %>%
  summarise(n = n()) %>%
  melt(id.vars = c("gender", "wave"))

# Plot gender repartition in waves
ggplot(gender.rep.over.waves, aes(x = wave, y = value, fill = factor(gender))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_discrete(name = "Gender") +
  xlab("Wave") + ylab("Population") + 
  scale_fill_manual(values = cbPalette)

### Age analysis ###
age.rep.over.waves <- subset(df, !duplicated(df[, 1])) %>%
  filter(!is.na(age)) %>%
  group_by(wave, gender) %>%
  summarise(m = mean(age)) %>%
  melt(id.vars = c("gender", "wave"))

# Plot age repartition in waves
ggplot(age.rep.over.waves, aes(x = wave, y = value, fill = factor(gender))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_discrete(name = "Gender") +
  xlab("Wave") + ylab("Mean age") +
  scale_fill_manual(values = cbPalette)

# What are the extremums?
print(paste0("Minimum age in all the dataset is: ", min(df[!is.na(df$age),]$age)))
print(paste0("Max age in all the dataset is: ", max(df[!is.na(df$age),]$age)))
print(paste0("Mean age in all the dataset is: ", mean(df[!is.na(df$age),]$age)))

### Matches analysis ###
# Dummie analysis on Matches
barplot(
  table(df$match),
  main = "Matches proportion",
  col = "black"
)

## Match by gender analysis ##
match.by.gender <- df %>%
  group_by(gender) %>%
  summarise(
    NbMatches = sum(match == 1),
    NbFails = sum(match == 0)
  ) %>% 
  melt(id.vars = "gender")

# Plot for both men and women
ggplot(match.by.gender, aes(x = variable, y = value, fill = factor(gender))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_discrete(name = "Gender") +
  xlab("Gender") + ylab("Matches")

## Isolate matches
matches <- df[df$match == 1,]

## What 



  
