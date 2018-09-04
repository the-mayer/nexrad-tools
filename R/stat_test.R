stat.test <- function(filter.type){
  #Filter Types: none, dp, no.precip, precip
  #Load Required Packages
  require(data.table)
  require(bit64)
  require(circular)
  require(pastecs)
  
  #Set Working Directory
  working.directory<-file.path(path.expand("~"),"BSTAR_NEXRAD")
  
  #What data? 
  filelist <- list.files(path = file.path(working.directory,"Result"),recursive = T,all.files = F)
  filelist <- data.frame(filelist,stringsAsFactors = F)
  ISDP <- read.csv(file = file.path(working.directory,"Data","ISDP_Values.csv"),header=T)
  info <- read.csv(file = file.path(working.directory,"Data","StudyInfo_2.csv"))
  
  #Add initial system differential phase to file list
  filelist$date.time <- basename(filelist$filelist)
  filelist$date.time <- gsub(pattern = "KFWS",replacement = "",x = filelist$date.time)
  filelist$date.time <- gsub(pattern = "_V06.csv",replacement = "",x = filelist$date.time)
  filelist$date.time <- strptime(x = filelist$date.time,format = "%Y%m%d_%H%M%S",tz = "GMT")
  filelist$Date <- as.character(x = filelist$date.time,format="%Y-%m")
  filelist.ISDP <- merge(filelist, ISDP, all.x=T)
  
  #Show some progress
  pb<- txtProgressBar(min=0,max=nrow(filelist.ISDP),style=3)
  setTxtProgressBar(pb,0)   
  
  #Loop through and perform the requested operations
  for(i in 1:nrow(filelist.ISDP)){
    data<-fread(input = file.path(working.directory,"Result",filelist.ISDP$filelist[i]))
    
    #Subset Dataset
    #Subset Values
    ISDP.min.val <- filelist.ISDP$ISDP[i] + 50
    ISDP.max.val <- 270
    min.alt.val <- 304.8
    #Always Subset
    sub.alt.data<- subset(data, Altitude.m >= min.alt.val)
    sub.elev.data<-subset(sub.alt.data, Elevation.deg >= 1.2 & Elevation.deg <=1.7)
    sub.rf<-subset(sub.elev.data, Differential.Phase > 0)
    sub.data <- sub.rf #Unfiltered dataset
    #Sometimes Subset
    sub.dp.data <- subset(sub.data, Differential.Phase >= ISDP.min.val & Differential.Phase <= ISDP.max.val) #DP filtered dataset
    sub.cc.data <- subset(sub.data, Correlation.Coefficient < 0.7 & Differential.Phase > 0) #Precip removed dataset
    #sub.cc.data_test <- subset(sub.data, Correlation.Coefficient < 0.7) #Precip removed dataset
    sub.cc.data2 <- subset(sub.data, Correlation.Coefficient >= 0.7) #Precip included dataset
    #Which Output?
    ifelse(filter.type == "none",final.subset<-sub.data,ifelse(filter.type=="dp",final.subset<-sub.dp.data,ifelse(filter.type=="no.precip",final.subset<-sub.cc.data,ifelse(filter.type=="precip",final.subset<-sub.cc.data2,print("which filter??")))))
    
    #Circular
    final.subset$Differential.Phase <- circular(x = final.subset$Differential.Phase,type="angles",units="degrees",template="none",modulo="2pi",rotation="clock")
    
    #Stats Check
    
    differential.phase <- format(stat.desc(final.subset$Differential.Phase), scientific = F)
    differential.phase <- data.frame(differential.phase)
    colnames(differential.phase) <- c("differential.phase")
    
    reflectivity <- format(stat.desc(final.subset$Reflectivity), scientific = F)
    reflectivity <- data.frame(reflectivity)
    
    total.biological.reflectivity <- format(stat.desc(final.subset$Total.Biological.Reflectivity), scientific = F)
    total.biological.reflectivity <- data.frame(total.biological.reflectivity)
    
    birds.km3 <- format(stat.desc(final.subset$Birds_km3), scientific = F)
    birds.km3 <- data.frame(birds.km3)
    
    z <- format(stat.desc(final.subset$Z), scientific = F)
    z <- data.frame(z)
    
    stat.test <- cbind(differential.phase,reflectivity, total.biological.reflectivity,birds.km3,z)
    
    #Save it
    filename <- paste0("stat_test_",filter.type,"_",basename(filelist.ISDP$filelist[i]))
    write.csv(x = stat.test,file = file.path(working.directory,"stat_test",filename),row.names = T)
    
    #Update the progress bar
    setTxtProgressBar(pb,i)  
  }
}
