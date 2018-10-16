#Load BSTAR data
  setwd("~/BSTAR_NEXRAD/BSTAR_Data")
  filelist<-list.files(pattern="\\.csv$")
  datalist<-lapply(filelist,read.csv)
  data<-rbindlist(datalist)
#Ensure filters are in place
  sub.data<-subset(data, Detections.qty > 1)
  sub.data<-subset(data, AverageAltitude.ft > 1000)  
#Aggregate by GMT day  
  