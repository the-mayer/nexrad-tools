#Load BSTAR data
  setwd("~/BSTAR_NEXRAD/BSTAR_Data")
  filelist<-list.files(pattern="\\.csv$")
  datalist<-lapply(filelist,read.csv)
  data<-rbindlist(datalist)
#Ensure filters are in place
  sub.data<-subset(data, Detections.qty > 1)
  sub.data<-subset(data, AverageAltitude.ft > 1000)  
#Aggregate by GMT day
  sub.data$Start.Time_US.Central<-as.POSIXct(x = sub.data$Start.Time_US.Central,format="%Y-%m-%d %H:%M:%S",tz = "US/Central")
  sub.data$Date.Time.GMT <- format(sub.data$Start.Time_US.Central,tz = "GMT")
  sub.data$GMT.Date<-as.Date(sub.data$Date.Time.GMT)
  sub.data$long.id<-paste0(sub.data$Track, sub.data$RadarTrackNumber)
  
  Track.Count<-setNames(aggregate(sub.data$long.id ~ sub.data$GMT.Date, FUN=length),c("GMT.Date","Track.Count"))
  Avg.Speed<-setNames(aggregate(sub.data$AverageVelocity..mph ~ sub.data$GMT.Date, FUN=mean),c("GMT.Date","Avg.Velocity.MPH"))
  Avg.Biomass<-setNames(aggregate(sub.data$AverageBiomass ~ sub.data$GMT.Date, FUN=mean),c("GMT.Date","Avg.Biomass"))
  test.merge <- merge(Track.Count,Avg.Speed)
  test.merge <- merge(test.merge, Avg.Biomass)  
  