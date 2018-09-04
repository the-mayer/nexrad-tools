unpack_NEXRAD_binary <- function(){
  #Setup
    working.directory<-file.path(path.expand("~"),"BSTAR_NEXRAD")
  #Paths
    filelist <- list.files(path = file.path(working.directory,"compressed"),recursive = T,all.files = F)
  #Show some progress
    pb<- txtProgressBar(min=0,max=length(filelist),style=3)
    setTxtProgressBar(pb,0)      
  #Loop
    for(i in 1:length(filelist)){
      #First unpack the data
        setwd(file.path(working.directory,"compressed"))
        unzip.string <- paste0("gunzip ", filelist[i])
        suppressMessages(system(unzip.string))
      #Next, convert resulting binary data to NetCDF with tool from UCAR  
        filelist.2<-gsub(pattern = ".gz",replacement = "",x = filelist)
        nc.filename<-paste0(basename(filelist.2[i]),".ncdf")
        system.string <- paste0("java -classpath /home/mayer/wct-4.1.0/lib/toolsUI-4.6.11-20171129.020539-22.jar ucar.nc2.FileWriter2 -in ", filelist.2[i],"  -out /home/mayer/BSTAR_NEXRAD/NetCDF/KFWS/",nc.filename)
        system(system.string)
        
      #Update the progress bar
        setTxtProgressBar(pb,i)
    }
    
}