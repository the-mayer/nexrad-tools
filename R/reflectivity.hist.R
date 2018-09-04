#Required Packages
  require(data.table)
  require(bit64)

#Set Working Directory
  working.directory<-file.path(path.expand("~"),"BSTAR_NEXRAD")

#What data? 
  filelist <- list.files(path = file.path(working.directory,"Result"),recursive = T,all.files = F)
  filelist<-data.frame(filelist)
  filelist$filelist <- as.character(filelist$filelist)
  filelist$datetime <- gsub(pattern = "KFWS/KFWS",replacement = "",x = filelist$filelist)
  filelist$datetime <- gsub(pattern = "_V06.csv",replacement = "",x = filelist$datetime)
  filelist$datetime <- as.POSIXct(x = filelist$datetime,tz = "GMT",format="%Y%m%d_%H%M%S")
  filelist$year <- cut(filelist$datetime,breaks = "year")
  
  sub.filelist <- subset(filelist, as.integer(year) == 1)
  
  setwd(file.path(working.directory,"Result"))
  datalist <- lapply(X = sub.filelist$filelist,FUN = fread) #All the memories
  nex.data <- rbindlist(datalist)
  
  sub.nex.data<- subset(nex.data, Differential.Phase > 0) #remove range folding
  sub.nex.data<- subset(sub.nex.data, Elevation.deg >= 1.2 & Elevation.deg <= 1.7) #nearest 1.5 degrees elevation angle
  sub.nex.data<- subset(sub.nex.data, Altitude.m >= 304.8) # above 1000 ft
  
  sub.nex.data$Update.Time.GMT <- as.POSIXct(x = sub.nex.data$Update.Time.GMT,tz = "GMT") #time fix
  
  #isdp
  ISDP <- read.csv(file = file.path(working.directory,"Data","ISDP_Values.csv"),header=T)
  ISDP$Date <- as.character(ISDP$Date)
  sub.nex.data.ISDP <- merge(sub.nex.data, ISDP, all.x = T,by = "Date")
  rm(sub.nex.data)
  
  sub.nex.data.ISDP$min.ISDP <- sub.nex.data.ISDP$ISDP + 50
  sub.nex.data.ISDP$max.ISDP <- 270
  
  sub.nex.data.ISDP$Bird <- ifelse(sub.nex.data.ISDP$Differential.Phase >= sub.nex.data.ISDP$min.ISDP & sub.nex.data.ISDP$Differential.Phase <= sub.nex.data.ISDP$max.ISDP, 1,0)
  
  #Classify
  sub.nex.data.ISDP$Filter.Type <- "No Filter"
  
  #Filter
  dp <- subset(sub.nex.data.ISDP, Bird == 1)
  dp$Filter.Type <- "Differential Phase [ISDP + 50, 270]"
  
  no.precip <- subset(sub.nex.data.ISDP, Correlation.Coefficient < 0.7)  
  no.precip$Filter.Type <- "Correlation Coefficient < 0.7"  

  precip <- subset(sub.nex.data.ISDP, Correlation.Coefficient >= 0.7)  
  precip$Filter.Type <- "Correlation Coefficient >= 0.7"  
  
  #Combine
  combined <- rbind(sub.nex.data.ISDP, dp, no.precip, precip)
  
  #Factor Levels
  combined$Filter.Type<-factor(x = combined$Filter.Type,levels = c("No Filter","Correlation Coefficient >= 0.7","Correlation Coefficient < 0.7","Differential Phase [ISDP + 50, 270]"))
  
  #Means
  agg.data <- setNames(aggregate(combined$Reflectivity ~ combined$Filter.Type, FUN=mean, na.rm=T),c("Filter.Type","Avg.Reflectivity"))
  
  
  #Plot
  hist <- ggplot(data = combined, aes(x=Reflectivity,fill=Filter.Type)) +
    geom_histogram(binwidth = 0.5, position = "dodge",color="black") +
    geom_vline(data = agg.data, aes(xintercept = Avg.Reflectivity),color="blue",linetype="dashed",size=1)
  hist.1 <- hist + scale_fill_hue(l=40) + facet_wrap(~Filter.Type,nrow=4) + 
    xlab("Reflectivity (dBZ)") + ylab("Frequency") + theme_gdocs() +
    theme(legend.position = "none") + 
    theme(axis.text.x=element_text(colour="black"),axis.title.x = element_text(color = "black",size = 14)) + 
    theme(axis.text.y=element_text(colour="black"),axis.title.y = element_text(color = "black",size = 14)) +
    theme(strip.text = element_text(colour = "black",size = 16)) +
    scale_x_continuous(breaks = seq(-25,50,5),minor_breaks = seq(-25,50,1)) +
    theme(panel.grid.major = element_line(colour="dark grey", size=0.75)) + 
    theme(panel.grid.minor = element_line(colour="light grey", size=0.5))
  ggsave(filename = "reflectivity.histogram_1.pdf",plot = hist.1,width = 11,height = 8.5,units = "in",dpi = 300)
  
  
  
  