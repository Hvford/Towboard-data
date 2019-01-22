
setwd("C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\GIS_Work\\NOAA metadata\\TowedDiver_PRIA_SWA\\Tow\\towed_diver.gdb")

library(spdep)
library(rgdal)
library(ggplot2)
library(dplyr)

##### Not necessary to do after already saved divepoints as a csv - need to subset by different years and merge with phototimes from different islands/years
# The input file geodatabase
#fgdb <- "C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\GIS_Work\\NOAA metadata\\NOAAmetagdb.gdb"
# List all feature classes in a file geodatabase
#subset(ogrDrivers(), grepl("GDB", name))
#fc_list <- ogrListLayers(fgdb)
#print(fc_list)

#read the feature class
#fc <- readOGR(dsn=fgdb,layer="Divepoints1")

#divepoints<-as.data.frame(fc)

#write.csv(divepoints, "C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\GIS_Work\\NOAA metadata\\Divepoints.csv")

#READ IN CSV instead of from geodatabase feature files

divepoints<-read.csv("C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\GIS_Work\\NOAA metadata\\Divepoints.csv")

##subset by diveyear and island
Island<-divepoints[divepoints$Island %in% "HOW" & divepoints$DiveYear %in% "2008", ] ##CHANGE HERE DEPENDING ON ISLAND/YEAR##
head(Island)

##drop unwanted columns

drops <- c("BenthicTemperature","BenthicDepth","GEOREGION","BIOGEO","GEOREG_NUM","ExceptionType","ExceptionComment","UploadDate","UploadPerson","FishTemperature","FishDepth","ScriptVersion","ErrorCheck")
Island<-Island[ , !(names(Island) %in% drops)]

#write.csv(Island,"C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Howland08\\HOW08Divepoints.csv")

#read in for each island/year the phototimestamp file and the csv just created from the divepoints
Island<-read.csv("C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Baker08\\Baker08Divepoints.csv", stringsAsFactors = F)##CHANGE HERE
phototime<-read.csv("C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Baker08\\Bakertimenew.csv", stringsAsFactors = F)##CHANGE HERE


#Phototime must have a "FileName" and "DateTimeOriginal" columns - this csv file is obtained by the Exiftool_phototimes.R script and then is cleaned in Excel by converting text to columns

#create factor in time format in each dataframe

Island$POSIXct<-as.POSIXct(Island$GMTime)
phototime$POSIXct<-as.POSIXct(phototime$DateTimeOriginal, format = "%Y:%m:%d %H:%M:%S")

#order by date
Island <- Island[order(Island$POSIXct, decreasing = F), ]

#merge datasets by the common time column

both <- merge(Island, phototime, by = "POSIXct", all = T)

#check dataframes

head(phototime)
nrow(phototime)

head(Island)

#If else statements that assign the closest time from divepoints to the time of the image - creating a new column called photoid with all images for the closet timestamp in the divepoint

both$indabove <- ifelse(as.numeric(rownames(both)) - 1 > 0, as.numeric(rownames(both)) - 1, NA) #create column of index of previous rows
both$timeabove <- as.POSIXct(ifelse(is.na(both$SegmentID), as.character(both$POSIXct[both$indabove]), NA)) #Assign the time above if segment ID is NA
both$timebelow <- as.POSIXct(ifelse(is.na(both$SegmentID), as.character(both$POSIXct[as.numeric(rownames(both))+1]), NA)) #Assign time below if segment ID is NA

both$diffabove <- difftime(both$POSIXct, both$timeabove, units = "secs") 
both$diffbelow <- difftime(both$timebelow, both$POSIXct, units = "secs")
both$assignabove <- ifelse(both$diffabove > both$diffbelow, FALSE, TRUE)
indassignabove <- ifelse(both$assignabove == T, both$indabove, NA)
indassignabove <- indassignabove[!is.na(indassignabove)]
indassignbelow <- ifelse(both$assignabove == F, as.numeric(rownames(both))+1, NA)
indassignbelow <- indassignbelow[!is.na(indassignbelow)]

both$photoid <- ifelse(!is.na(both$BoatPoint) & !is.na(both$FileName), both$FileName, #must have columns from both Island and Phototime datasets here to say that if both are not NA then give the filename value
                       ifelse(rownames(both) %in% indassignabove, both$FileName[as.numeric(rownames(both))+1],
                       ifelse(rownames(both) %in% indassignbelow, both$FileName[both$indabove], NA)))

#subset by getting rid of rows with NA in photoid - left with only rows needed

both1<-both[!is.na(both$photoid),]

#get rid of unused columns
drops<-c("Island.y","FileName", "coords.x1", "coords.x2", "FileSize", "assignabove", "diffabove", "diffbelow", "timebelow", "indabove", "timeabove", "DateTimeOriginal", "Model", "Transect")
both<-both1[ , !(names(both1) %in% drops)]

#save output and then will need to subset by depth

tail(both)

#search for a transect within the data and subset - this was previously missing data
missingdata<-both[grepl( "BAK_020808_3" , both$photoid ),]

write.csv(both,"C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Baker08\\Bak08newmetajoin.csv")##CHANGE HERE

####NARROW DOWN BY DEPTH AND SAVE OUTPUT
##read in csv/use above

#both<-read.csv("C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Baker08\\Baker08Divepointandphotojoin.csv")##CHANGE HERE 


both<-both[both$CombinedDepth < -8 & both$CombinedDepth > -20,]


##Save another depth constrained version

#write.csv(both,"C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Baker 08\\Baker08META8_20.csv")##CHANGE HERE TO SAVE


##GET RID OF NAs and blank spaces and change column names according to CORAL net metadata uploads 

#rename photoid column to name
colnames(both)[16]<-"Name"


#need to subset to alternate photos
#oddsandeven<-read.csv("C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Howland08\\HOW08META8_20.csv")##CHANGE HERE

oddsandeven<-both

str(oddsandeven)

#subset using logical index
even<-oddsandeven[ c(FALSE,TRUE), ] 

write.csv(even, "C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Baker08\\NEWalternate8_20.csv")




