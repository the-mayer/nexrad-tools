
#Load Required Packages
  require(ncdf4)
  require(data.table)
  require(bit64)
#Set Working Directory
  working.directory<-file.path(path.expand("~"),"BSTAR_NEXRAD")
#What data? 
  filelist <- list.files(path = file.path(working.directory,"NetCDF"),recursive = T,all.files = F)
#Read it  
  datalist<-lapply(X = filelist,FUN = nc_open)  
#Grab global attributes
  attrlist<-lapply(X = datalist,FUN = ncatt_get,varid = 0)
#Bind into dataframe
  data<-rbindlist(attrlist)
#Add filenames
  data$Filenames <- basename(filelist)
#Pull elevation data
  elevlist<-lapply(X = datalist, FUN = ncvar_get, raw_datavals = F, varid = "elevationP_HI")
#Get dimensions to determine if high res
  dimlist<-lapply(elevlist, dim)
#Store dimension info as a data frame  
  dimdatalist<-lapply(dimlist, data.frame,row.names = c("Qty.Azimuth","Qty.Elevation"))
#Transpose the data frame
  tdimdatalist<-lapply(dimdatalist,t)
  t2dimdatalist<-lapply(tdimdatalist,data.frame)
#Bind elevation info together again
  elev.final<-rbindlist(t2dimdatalist)
#Combine with previous
  final<-cbind(data,elev.final)
  