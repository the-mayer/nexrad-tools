#NEXRAD Process
  nexrad<-read.csv("~/BSTAR_NEXRAD/Data/StudyInfo_2.csv")
  nexrad<-data.frame(nexrad$Filenames)
  nexrad$Date.Time <- gsub(pattern = "KFWS",replacement = "",x = nexrad$nexrad.Filenames)
  nexrad$Date.Time <- gsub(pattern = "_V06.ncdf",replacement = "",x = nexrad$Date.Time)
  nexrad$Date.Time <- as.POSIXct(x = nexrad$Date.Time,format="%Y%m%d_%H%M%S",tz="GMT")
  nexrad$GMT.Date <- as.Date(nexrad$Date.Time)

#BSTAR Process
  setwd("~/BSTAR_NEXRAD/BSTAR_Data")
  bstar.filelist<-list.files()
  bstar.filelist<-data.frame(bstar.filelist)
  bstar.filelist$Date.Time <- sub("-.*", "", bstar.filelist$bstar.filelist)
  bstar.filelist$Date.Time<-gsub(pattern = "Processed_BIRD_",replacement = "",x = bstar.filelist$Date.Time)
  bstar.filelist$Date.Time<-as.POSIXct(x = bstar.filelist$Date.Time,format="%Y.%m.%d_%H%M%S",tz = "US/Central")
  bstar.filelist$Date.Time.GMT <- format(bstar.filelist$Date.Time,tz = "GMT")
  bstar.filelist$GMT.Date<-as.Date(bstar.filelist$Date.Time.GMT)
  
#Merge
  test.merge <- merge(nexrad,bstar.filelist,all.x=T,by = "GMT.Date")
  setwd("~/BSTAR_NEXRAD")
  write.csv(x = test.merge,file = "nex.bstar.data.match.csv",row.names = F)
  