aws_download_NEXRAD <- function(start.date = "2016-01-01", end.date = "2016-12-31", station.id){
  #Packages
    require(aws.s3)
  #Setup
    working.directory<-file.path(path.expand("~"),"NEXRAD")
    start.date <- as.Date(start.date)
    end.date <- as.Date(end.date)
    seq<-seq.Date(from = start.date,to = end.date,by = "day")
  #Show some progress
    pb<- txtProgressBar(min=0,max=length(seq),style=3)
    setTxtProgressBar(pb,0)    
  #Loop through date sequence, download along the way
    for(h in 1:length(seq)){
  #Construct Prefixe
    prefix <- paste0(as.character(seq[h],format="%Y"),"/",as.character(seq[h],format="%m"),"/",as.character(seq[h],format="%d"),"/",station.id)
  #Find AWS buckets
    bucket<-get_bucket_df(bucket = "noaa-nexrad-level2", key = "", secret = "", region = "us-east-1",prefix = prefix)
  
  #Loop through the available files in the bucket and download
    for(i in 1:nrow(bucket)){
      save_object(object = bucket$Key[i], bucket = "noaa-nexrad-level2", key = "", secret = "", region = "us-east-1",file = file.path(working.directory,"compressed",bucket$Key[i]))
    }
    #Update the progress bar
    setTxtProgressBar(pb,h)
    }
}