##   Using Exif tool Script

#Use this to find Date and time of each photo in a particular folder
#Install the exiftool application and set the working directory to where it is saved on your computer.

setwd("C:\\Exif")

##reads metadata 
data<-system2("exiftool", args="-common -DateTimeOriginal -FileType -GPS -csv -t -r C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\PhotosforCOralNet\\HowBakPhotos\\Baker",stdout=TRUE)

#Check data
str(data)
head(data)

#Save data
write.csv(data,"C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Baker08\\Bakertimenew.csv")


##   Open dataframe in excel and edit
##  Convert columns to text and clean up columns can save as a new data frame with just the transect photo name and date/time column