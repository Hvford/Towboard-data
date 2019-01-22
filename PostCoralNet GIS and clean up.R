##After Coral Net get benthic percentage covers output and join with metadata from same island - see how things change by transect?

library("reshape2")

setwd("C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Kingman 08")

covers<-read.csv("C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Kingman 08\\Final_dataframes\\Kingmancovers_08.csv") #Join metadata

meta<-read.csv("C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Kingman 08\\Metadata\\META.csv") # Join percentage covers

#merge data

df<-merge(covers, meta, by="Name")
#covers_meta<-merge(df, spec, by.x="variable", by.y="Code")

## save df and join in GIS with Gridcells
write.csv(df, "C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Kingman 08\\Final_dataframes\\Kinnmetacover_08.csv")

#check dataframe
tail(df)


#Upload and join into grid format in GIS


################################################# POST GIS ############################################################

data<-read.csv("C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Kingman 08\\Final_dataframes\\PostGISKIN08.csv")

nrow(data)#How many grid cells?

#subset GIS output to minimum count of 4 in each gridcell
data<-data[data$Count_>3,]

#take out standard deviation columns
#data<-data[ , !grepl( "SD_" , names(data ) ) ] ##Average percentage cover


#For all dataframes recalculate same variables 

#Merge Favia submassive and favia stelligera etc, montipora plating and montipora foliose, porites plating and encrusting plating

data<-data %>% rowwise() %>% mutate(Avg_favSM=sum(c(Avg_FavSub, Avg_FavSt), na.rm=T))
data<-data %>% rowwise() %>% mutate(Avg_montipl=sum(c(Avg_MontiF, Avg_MontiP), na.rm=T))
data<-data %>% rowwise() %>% mutate(Avg_porpl=sum(c(Avg_PorEnP, Avg_PorPla), na.rm=T))
drops<-c("Avg_FavSub","Avg_FavSt", "Avg_MontiF", "Avg_MontiP", "Avg_PorEnP", "Avg_PorPla","Avg_MobF", "Avg_Unk")
data<-data[ , !(names(data) %in% drops)]
data<-data[order(data$GRID_ID),]
data<-as.data.frame(data)

#drop unwanted levels
drops<-c("ï..FID","FID_1","Avg_Field1","SD_Field1","SD_DIVEYEA*","Shape","FID_inters","Id","BUFF_DIST","ORIG_FID","FID_simpli","FID_p2pl_p","Id_1","FID_p2pl_1","Id_12","F_AREA")
data<-data[ , !(names(data) %in% drops)]

#rename levels in variable by getting rid of avg bit


write.csv(data,"C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Kingman 08\\Final_dataframes\\WideKIN08.csv")
#################################### FOR LONG FORMATS ###############################################

names(data)

#transpose dataframe keeping site data in id.vars and species data as measure.var
tdata<-melt(data, id.vars=c(1,2,85:89), measure.vars = c(3:84,90:92))

#Rename variables
tdata$variable<-sub("Avg_", "", tdata$variable)

#drop levels with o
tdata<-tdata[!rowSums(tdata[-c(1:2)]==0)>=1,]

#read in species labels
spec<-read.csv("C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Kingman 08\\Species_codes_update.csv")

#Merge with species labels
gridcoverlabel<-merge(tdata, spec, by.x="variable", by.y="R_code")
head(gridcoverlabel)
str(gridcoverlabel)


write.csv(gridcoverlabel,"C:\\Users\\Helen\\Documents\\PHD\\Data_Analysis\\Kingman 08\\Final_dataframes\\longKIN08.csv")



