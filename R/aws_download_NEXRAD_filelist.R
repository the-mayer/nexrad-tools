aws_download_NEXRAD_filelist <- function(filelist){
  #Packages
    require(aws.s3)
  #Setup
    working.directory<-file.path(path.expand("~"),"BSTAR_NEXRAD")
    data<-read.csv(file = file.path(working.directory,"Data",filelist))
    data$date.time<-as.POSIXct(data$date.time)
  #Show some progress
    pb<- txtProgressBar(min=0,max=nrow(data),style=3)
    setTxtProgressBar(pb,0)    
  #Loop through date sequence, download along the way
    for(h in 1:nrow(data)){
  #Construct Prefixe
    prefix <- paste0(as.character(data$date.time[h],format="%Y"),"/",as.character(data$date.time[h],format="%m"),"/",as.character(data$date.time[h],format="%d"),"/","KFWS")
  #Find AWS buckets
    bucket<-get_bucket_df(bucket = "noaa-nexrad-level2", key = "", secret = "", region = "us-east-1",prefix = prefix)
  
  #Download specific filename
    bucket.key<-paste0(prefix,"/",data$Filename[h])
    save_object(object = bucket.key, bucket = "noaa-nexrad-level2", key = "", secret = "", region = "us-east-1",file = file.path(working.directory,"compressed",bucket.key))
  #Update the progress bar
    setTxtProgressBar(pb,h)
    }
}