renamer <- function(){
  library(data.table)
  library(bit64)
  setwd(dir = "~/BSTAR_NEXRAD/Sort/Filtered")
  filelist <- list.files()
  for(i in 1:length(filelist)){
    data<-fread(filelist[i],header = T,stringsAsFactors = F)
    data$V1<-NULL #Don't need this
    if(nchar(data$Start.Time_US.Central[1])==14){
    data$Start.Time_US.Central<-as.POSIXct(x = data$Start.Time_US.Central,format="%m/%d/%Y %H:%M",tz = "US/Central")
    data$End.time_US.Central<-as.POSIXct(x = data$End.time_US.Central,format="%m/%d/%Y %H:%M",tz = "US/Central")
    } else{data$Start.Time_US.Central<-as.POSIXct(x = data$Start.Time_US.Central,format="%Y-%m-%d %H:%M:%S",tz = "US/Central")
      data$End.time_US.Central<-as.POSIXct(x = data$End.time_US.Central,format="%Y-%m-%d %H:%M:%S",tz = "US/Central")
    }
    min.time <- min(data$Start.Time_US.Central)
    min.char <- as.character(min.time,format="%Y.%m.%d_%H%M%S")
    max.time <- max(data$End.time_US.Central)
    max.char <- as.character(max.time,format="%Y.%m.%d_%H%M%S")
    filename <- paste0("Processed_BIRD_",min.char,"-",max.char,".csv")
    write.csv(x = data,file = file.path("~/BSTAR_NEXRAD/Sort/Filtered/renamed",filename),row.names = F)
  }
}