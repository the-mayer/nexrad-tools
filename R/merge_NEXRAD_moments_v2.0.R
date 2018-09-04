merge_nexrad_moments <- function(){
#Load Required Packages
  require(ncdf4)
  #require(raster)
  require(geosphere)
  #require(plyr)
  #require(foreach)
  require(data.table)
  require(bit64)
  require(reshape2)

#Set Working Directory
  working.directory<-file.path(path.expand("~"),"BSTAR_NEXRAD")
  
#################### <MODIFY ME> ##################### 
  #NEXRAD bin altitude calculation  
    Re <- 6371000 #Radius of Earth in m 
    theta <- 0.925 #Normalized Nexrad Beamwidth Degrees
    PHI <- 3.95 #Nexrad Elevation Angle
    IR <- 1.21 #Refractive Index
  #Total biological reflectivity
    lambda <- 0.107 #constant used in determining total biological reflectivity
    km2 <- 0.93 #Chilson Rayleigh approximation, derrived from complex refractive index
    ref.bird <- 12 #Size of a reference bird in cm^2
  
  #az.seq <- seq(0.25,359.75,0.5)
  #max.dist <- 230000 +125
  #slant.range.seq <- seq(2000+125,max.dist,250)
#################### </MODIFY ME> #####################
  
#What data? 
  filelist <- list.files(path = file.path(working.directory,"NetCDF"),recursive = T,all.files = F)
#Spatial Filter (DFW... soemtimes useful, othertimes not)
  ULC <- c(-97.19234,33.0067)
  LRC <- c(-96.892012, 32.764)
#Show some progress
  pb<- txtProgressBar(min=0,max=length(filelist),style=3)
  setTxtProgressBar(pb,0)      
#Loop through the files, merge, save
for(i in 1:length(filelist)){
#Load the file
  nexrad.data <- nc_open(file.path(working.directory,"NetCDF",filelist[i]))

#Available Variables
  # names(nexrad.data$var)
  # ncatt_get(nc = nexrad.data,varid = "DifferentialPhase_HI")
#Administrivia
  #Load up all the NEXRAD Stations
    nexrads<-read.csv(file.path(working.directory,"Data/nexrad-stations.csv"),header=T)
  #Find the one we're working with
    sub.nexrads<-subset(nexrads, ICAO == substr(filelist[i],1,4))
  #NEXRAD Location
    nex.center<-c(sub.nexrads$LON, sub.nexrads$LAT)
  #Date
    date.time<-substr(filelist[i],10,17)
    date.GMT<-as.POSIXct(date.time, format="%Y%m%d",tz = "GMT")
#Extract Variables
  ref.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "Reflectivity_HI",signedbyte = F)               #Level II Reflectivity
  r.v.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "RadialVelocity_HI",signedbyte = F)             #Level II Radial Velocity
  s.w.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "SpectrumWidth_HI",signedbyte = F)              #Level II Spectrum Width... you can't stop me from including it!
  d.r.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "DifferentialReflectivity_HI",signedbyte = F)   #Level II Differential Reflectivity
  c.c.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "CorrelationCoefficient_HI",signedbyte = F)     #Level II Correlation Coefficient
  d.p.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "DifferentialPhase_HI",signedbyte = F)          #Level II Differential Phase
  
  #Additional Reflectivity
    time_ref.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "timeR_HI") 
    elev_ref.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "elevationR_HI") 
    azim_ref.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "azimuthR_HI") 
    dist_ref.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "distanceR_HI") 
  #Additional Radial Velocity
    time_r.v.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "timeV_HI") 
    elev_r.v.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "elevationV_HI") 
    azim_r.v.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "azimuthV_HI") 
    dist_r.v.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "distanceV_HI")
  #Additional Spectrum Width
    time_s.w.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "timeV_HI") 
    elev_s.w.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "elevationV_HI") 
    azim_s.w.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "azimuthV_HI") 
    dist_s.w.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "distanceV_HI")
  #Additional Differential Reflectivity
    time_d.r.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "timeD_HI") 
    elev_d.r.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "elevationD_HI") 
    azim_d.r.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "azimuthD_HI") 
    dist_d.r.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "distanceD_HI") 
  #Additional Correlation Coefficient
    time_c.c.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "timeC_HI") 
    elev_c.c.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "elevationC_HI") 
    azim_c.c.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "azimuthC_HI") 
    dist_c.c.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "distanceC_HI") 
  #Additional Differential Phase
    time_d.p.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "timeP_HI") 
    elev_d.p.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "elevationP_HI") 
    azim_d.p.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "azimuthP_HI") 
    dist_d.p.HI <- ncvar_get(nc = nexrad.data, raw_datavals = F, varid = "distanceP_HI")   

#Data.Frames ###USE MELT FOR NEXT VERSION. SO MUCH FASTER
##########################################################################################    
  #Reflectivity
    #df_ref.HI <- adply(.data = ref.HI,.margins = c(1,2,3),.parallel = T)
    df_ref.HI <- melt(ref.HI)
    colnames(df_ref.HI) <- c("dist","radial","elev","ref.value")
    #df_ref.HI <- melt(ref.HI)
  #Azimuth
    #df_azim_ref.HI <- adply(.data = azim_ref.HI,.margins = c(1,2),.parallel = T)
    df_azim_ref.HI <- melt(azim_ref.HI)
    colnames(df_azim_ref.HI) <- c("radial","elev","azimuth.deg")
  #Elevation
    #df_elev_ref.HI <- adply(.data = elev_ref.HI,.margins = c(1,2),.parallel = T)
    df_elev_ref.HI <- melt(elev_ref.HI)
    colnames(df_elev_ref.HI) <- c("radial","elev","elev.deg")
  #Distance
    #df_dist_ref.HI <- adply(.data = dist_ref.HI,.margins = c(1),.parallel = T)
    df_dist_ref.HI <- melt(dist_ref.HI)
    colnames(df_dist_ref.HI) <- c("dist","Range.from.Radar.m")
  #Time
    #df_time_ref.HI <- adply(.data = time_ref.HI,.margins = c(1,2),.parallel = T)
    df_time_ref.HI <- melt(time_ref.HI)
    colnames(df_time_ref.HI) <- c("radial","elev","time")
  #Data.Tables    
    #Reflectivity
      dt_ref.HI <- data.table(df_ref.HI)
    #Azimuth
      dt_azim_ref.HI <- data.table(df_azim_ref.HI)
    #Elevation
      dt_elev_ref.HI <- data.table(df_elev_ref.HI)
    #Distance
      dt_dist_ref.HI <- data.table(df_dist_ref.HI)
    #Time
      dt_time_ref.HI <- data.table(df_time_ref.HI)

##########################################################################################    
  #Radial Velocity
    #df_r.v.HI <- adply(.data = r.v.HI,.margins = c(1,2,3),.parallel = T)
    df_r.v.HI <- melt(r.v.HI)
    colnames(df_r.v.HI) <- c("dist","radial","elev","r.v.value")
  #Azimuth
    #df_azim_r.v.HI <- adply(.data = azim_r.v.HI,.margins = c(1,2),.parallel = T)
    df_azim_r.v.HI <- melt(azim_r.v.HI)
    colnames(df_azim_r.v.HI) <- c("radial","elev","azimuth.deg")
  #Elevation
    #df_elev_r.v.HI <- adply(.data = elev_r.v.HI,.margins = c(1,2),.parallel = T)
    df_elev_r.v.HI <- melt(elev_r.v.HI)
    colnames(df_elev_r.v.HI) <- c("radial","elev","elev.deg")
  #Distance
    #df_dist_r.v.HI <- adply(.data = dist_r.v.HI,.margins = c(1),.parallel = T)
    df_dist_r.v.HI <- melt(dist_r.v.HI)
    colnames(df_dist_r.v.HI) <- c("dist","Range.from.Radar.m")
  #Time
    #df_time_r.v.HI <- adply(.data = time_r.v.HI,.margins = c(1,2),.parallel = T)
    df_time_r.v.HI <- melt(time_r.v.HI)
    colnames(df_time_r.v.HI) <- c("radial","elev","time")
  #Data.Tables    
      #Radial Velocity
        dt_r.v.HI <- data.table(df_r.v.HI)
      #Azimuth
        dt_azim_r.v.HI <- data.table(df_azim_r.v.HI)
      #Elevation
        dt_elev_r.v.HI <- data.table(df_elev_r.v.HI)
      #Distance
        dt_dist_r.v.HI <- data.table(df_dist_r.v.HI)
      #Time
        dt_time_r.v.HI <- data.table(df_time_r.v.HI)    
      
##########################################################################################    
  #Spectrum Width
    #df_s.w.HI <- adply(.data = s.w.HI,.margins = c(1,2,3),.parallel = T)
    df_s.w.HI <- melt(s.w.HI)
    colnames(df_s.w.HI) <- c("dist","radial","elev","s.w.value")
  #Azimuth
    #df_azim_s.w.HI <- adply(.data = azim_s.w.HI,.margins = c(1,2),.parallel = T)
    df_azim_s.w.HI <- melt(azim_s.w.HI)
    colnames(df_azim_s.w.HI) <- c("radial","elev","azimuth.deg")
  #Elevation
    #df_elev_s.w.HI <- adply(.data = elev_s.w.HI,.margins = c(1,2),.parallel = T)
    df_elev_s.w.HI <- melt(elev_s.w.HI)
    colnames(df_elev_s.w.HI) <- c("radial","elev","elev.deg")
  #Distance
    #df_dist_s.w.HI <- adply(.data = dist_s.w.HI,.margins = c(1),.parallel = T)
    df_dist_s.w.HI <- melt(dist_s.w.HI)
    colnames(df_dist_s.w.HI) <- c("dist","Range.from.Radar.m")
  #Time
    #df_time_s.w.HI <- adply(.data = time_s.w.HI,.margins = c(1,2),.parallel = T)
    df_time_s.w.HI <- melt(time_s.w.HI)
    colnames(df_time_s.w.HI) <- c("radial","elev","time")
  #Data.Tables    
      #Radial Velocity
        dt_s.w.HI <- data.table(df_s.w.HI)
      #Azimuth
        dt_azim_s.w.HI <- data.table(df_azim_s.w.HI)
      #Elevation
        dt_elev_s.w.HI <- data.table(df_elev_s.w.HI)
      #Distance
        dt_dist_s.w.HI <- data.table(df_dist_s.w.HI)
      #Time
        dt_time_s.w.HI <- data.table(df_time_s.w.HI)
        
##########################################################################################        
  #Differential Reflectivity
    #df_d.r.HI <- adply(.data = d.r.HI,.margins = c(1,2,3),.parallel = T)
    df_d.r.HI <- melt(d.r.HI)
    colnames(df_d.r.HI) <- c("dist","radial","elev","d.r.value")
  #Azimuth
    #df_azim_d.r.HI <- adply(.data = azim_d.r.HI,.margins = c(1,2),.parallel = T)
    df_azim_d.r.HI <- melt(azim_d.r.HI)
    colnames(df_azim_d.r.HI) <- c("radial","elev","azimuth.deg")
  #Elevation
    #df_elev_d.r.HI <- adply(.data = elev_d.r.HI,.margins = c(1,2),.parallel = T)
    df_elev_d.r.HI <- melt(elev_d.r.HI)
    colnames(df_elev_d.r.HI) <- c("radial","elev","elev.deg")
  #Distance
    #df_dist_d.r.HI <- adply(.data = dist_d.r.HI,.margins = c(1),.parallel = T)
    df_dist_d.r.HI <- melt(dist_d.r.HI)
    colnames(df_dist_d.r.HI) <- c("dist","Range.from.Radar.m")
  #Time
    #df_time_d.r.HI <- adply(.data = time_d.r.HI,.margins = c(1,2),.parallel = T)
    df_time_d.r.HI <- melt(time_d.r.HI)
    colnames(df_time_d.r.HI) <- c("radial","elev","time")
    #Data.Tables    
      #Radial Velocity
        dt_d.r.HI <- data.table(df_d.r.HI)
      #Azimuth
        dt_azim_d.r.HI <- data.table(df_azim_d.r.HI)
      #Elevation
        dt_elev_d.r.HI <- data.table(df_elev_d.r.HI)
      #Distance
        dt_dist_d.r.HI <- data.table(df_dist_d.r.HI)
      #Time
        dt_time_d.r.HI <- data.table(df_time_d.r.HI)
      
##########################################################################################
  #Correlation Coefficient
    #df_c.c.HI <- adply(.data = c.c.HI,.margins = c(1,2,3),.parallel = T)
    df_c.c.HI <- melt(c.c.HI)
    colnames(df_c.c.HI) <- c("dist","radial","elev","c.c.value")
  #Azimuth
    #df_azim_c.c.HI <- adply(.data = azim_c.c.HI,.margins = c(1,2),.parallel = T)
    df_azim_c.c.HI <- melt(azim_c.c.HI)
    colnames(df_azim_c.c.HI) <- c("radial","elev","azimuth.deg")
  #Elevation
    #df_elev_c.c.HI <- adply(.data = elev_c.c.HI,.margins = c(1,2),.parallel = T)
    df_elev_c.c.HI <- melt(elev_c.c.HI)
    colnames(df_elev_c.c.HI) <- c("radial","elev","elev.deg")
  #Distance
    #df_dist_c.c.HI <- adply(.data = dist_c.c.HI,.margins = c(1),.parallel = T)
    df_dist_c.c.HI <- melt(dist_c.c.HI)
    colnames(df_dist_c.c.HI) <- c("dist","Range.from.Radar.m")
  #Time
    #df_time_c.c.HI <- adply(.data = time_c.c.HI,.margins = c(1,2),.parallel = T)
    df_time_c.c.HI <- melt(time_c.c.HI)
    colnames(df_time_c.c.HI) <- c("radial","elev","time")
    #Data.Tables    
      #Radial Velocity
        dt_c.c.HI <- data.table(df_c.c.HI)
      #Azimuth
        dt_azim_c.c.HI <- data.table(df_azim_c.c.HI)
      #Elevation
        dt_elev_c.c.HI <- data.table(df_elev_c.c.HI)
      #Distance
        dt_dist_c.c.HI <- data.table(df_dist_c.c.HI)
      #Time
        dt_time_c.c.HI <- data.table(df_time_c.c.HI)
        
##########################################################################################           
  #Differential Phase
    #df_d.p.HI <- adply(.data = d.p.HI,.margins = c(1,2,3),.parallel = T)
    df_d.p.HI <- melt(d.p.HI)
    colnames(df_d.p.HI) <- c("dist","radial","elev","d.p.value")
  #Azimuth
    #df_azim_d.p.HI <- adply(.data = azim_d.p.HI,.margins = c(1,2),.parallel = T)
    df_azim_d.p.HI <- melt(azim_d.p.HI)
    colnames(df_azim_d.p.HI) <- c("radial","elev","azimuth.deg")
  #Elevation
    #df_elev_d.p.HI <- adply(.data = elev_d.p.HI,.margins = c(1,2),.parallel = T)
    df_elev_d.p.HI <- melt(elev_d.p.HI)
    colnames(df_elev_d.p.HI) <- c("radial","elev","elev.deg")
  #Distance
    #df_dist_d.p.HI <- adply(.data = dist_d.p.HI,.margins = c(1),.parallel = T)
    df_dist_d.p.HI <- melt(dist_d.p.HI)
    colnames(df_dist_d.p.HI) <- c("dist","Range.from.Radar.m")
  #Time
    #df_time_d.p.HI <- adply(.data = time_d.p.HI,.margins = c(1,2),.parallel = T)
    df_time_d.p.HI <- melt(time_d.p.HI)
    colnames(df_time_d.p.HI) <- c("radial","elev","time")
  #Data.Tables    
    #Differential Phase
      dt_d.p.HI <- data.table(df_d.p.HI)
    #Azimuth
      dt_azim_d.p.HI <- data.table(df_azim_d.p.HI)
    #Elevation
      dt_elev_d.p.HI <- data.table(df_elev_d.p.HI)
    #Distance
      dt_dist_d.p.HI <- data.table(df_dist_d.p.HI)
    #Time
      dt_time_d.p.HI <- data.table(df_time_d.p.HI)

##########################################################################################     
#Merge
  #Reflectivity
    ref.HI_merge<-merge(dt_ref.HI, dt_time_ref.HI, by=c("radial","elev"))
    ref.HI_merge$time.GMT<-as.POSIXct(x = ref.HI_merge$time * 0.001, format="%S",tz = "GMT",origin=date.GMT) #Time from milliseconds from GMT day start to human readable.
    ref.HI_merge<-merge(ref.HI_merge,dt_azim_ref.HI, by=c("radial","elev"))
    ref.HI_merge<-merge(ref.HI_merge,dt_elev_ref.HI, by=c("radial","elev"))
    ref.HI_merge<-merge(ref.HI_merge,dt_dist_ref.HI, by=c("dist"))
    
  #Radial Velocity
    r.v.HI_merge<-merge(dt_r.v.HI, dt_time_r.v.HI, by=c("radial","elev"))
    r.v.HI_merge$time.GMT<-as.POSIXct(x = r.v.HI_merge$time * 0.001, format="%S",tz = "GMT",origin=date.GMT) #Time from milliseconds from GMT day start to human readable.
    r.v.HI_merge<-merge(r.v.HI_merge,dt_azim_r.v.HI, by=c("radial","elev"))
    r.v.HI_merge<-merge(r.v.HI_merge,dt_elev_r.v.HI, by=c("radial","elev"))
    r.v.HI_merge<-merge(r.v.HI_merge,dt_dist_r.v.HI, by=c("dist"))
    
  #Spectrum Width
    s.w.HI_merge<-merge(dt_s.w.HI, dt_time_s.w.HI, by=c("radial","elev"))
    s.w.HI_merge$time.GMT<-as.POSIXct(x = s.w.HI_merge$time * 0.001, format="%S",tz = "GMT",origin=date.GMT) #Time from milliseconds from GMT day start to human readable.
    s.w.HI_merge<-merge(s.w.HI_merge,dt_azim_s.w.HI, by=c("radial","elev"))
    s.w.HI_merge<-merge(s.w.HI_merge,dt_elev_s.w.HI, by=c("radial","elev"))
    s.w.HI_merge<-merge(s.w.HI_merge,dt_dist_s.w.HI, by=c("dist"))  
    
  #Differential Reflectivity
    d.r.HI_merge<-merge(dt_d.r.HI, dt_time_d.r.HI, by=c("radial","elev"))
    d.r.HI_merge$time.GMT<-as.POSIXct(x = d.r.HI_merge$time * 0.001, format="%S",tz = "GMT",origin=date.GMT) #Time from milliseconds from GMT day start to human readable.
    d.r.HI_merge<-merge(d.r.HI_merge,dt_azim_d.r.HI, by=c("radial","elev"))
    d.r.HI_merge<-merge(d.r.HI_merge,dt_elev_d.r.HI, by=c("radial","elev"))
    d.r.HI_merge<-merge(d.r.HI_merge,dt_dist_d.r.HI, by=c("dist"))
    
  #Correlation Coefficient
    c.c.HI_merge<-merge(dt_c.c.HI, dt_time_c.c.HI, by=c("radial","elev"))
    c.c.HI_merge$time.GMT<-as.POSIXct(x = c.c.HI_merge$time * 0.001, format="%S",tz = "GMT",origin=date.GMT) #Time from milliseconds from GMT day start to human readable.
    c.c.HI_merge<-merge(c.c.HI_merge,dt_azim_c.c.HI, by=c("radial","elev"))
    c.c.HI_merge<-merge(c.c.HI_merge,dt_elev_c.c.HI, by=c("radial","elev"))
    c.c.HI_merge<-merge(c.c.HI_merge,dt_dist_c.c.HI, by=c("dist"))
    
  #Differential Phase
    d.p.HI_merge<-merge(dt_d.p.HI, dt_time_d.p.HI, by=c("radial","elev"))
    d.p.HI_merge$time.GMT<-as.POSIXct(x = d.p.HI_merge$time * 0.001, format="%S",tz = "GMT",origin=date.GMT) #Time from milliseconds from GMT day start to human readable.
    d.p.HI_merge<-merge(d.p.HI_merge,dt_azim_d.p.HI, by=c("radial","elev"))
    d.p.HI_merge<-merge(d.p.HI_merge,dt_elev_d.p.HI, by=c("radial","elev"))
    d.p.HI_merge<-merge(d.p.HI_merge,dt_dist_d.p.HI, by=c("dist"))
    
  #Final Merge (order of operations sorta important here, will re-arrange later)
    #all.moments<-merge(ref.HI_merge, d.r.HI_merge, by=c("dist","radial","elev","time"), all.x=T) #Reflectivity and Differential reflectivity
    all.moments<-merge(ref.HI_merge,d.r.HI_merge, by=c("Range.from.Radar.m","azimuth.deg","elev.deg","time.GMT"),all.x=T)
      all.moments$dist.x<-NULL
      all.moments$dist.y<-NULL
      all.moments$elev.x<-NULL
      all.moments$elev.y<-NULL
      all.moments$radial.x<-NULL
      all.moments$radial.y<-NULL
      all.moments$time.x<-NULL
      all.moments$time.y<-NULL
      
    all.moments<-merge(all.moments, c.c.HI_merge, by=c("Range.from.Radar.m","azimuth.deg","elev.deg","time.GMT"), all.x=T)  #Add Correlation Coefficient  
      all.moments$dist<-NULL
      all.moments$radial<-NULL
      all.moments$elev<-NULL
      all.moments$time<-NULL
      
    all.moments<-merge(all.moments, d.p.HI_merge, by=c("Range.from.Radar.m","azimuth.deg","elev.deg","time.GMT"), all.x=T)  #Add Differential Phase 
      all.moments$dist<-NULL
      all.moments$radial<-NULL
      all.moments$elev<-NULL
      all.moments$time<-NULL
    
    all.moments<-merge(all.moments, r.v.HI_merge, by=c("Range.from.Radar.m","azimuth.deg","elev.deg","time.GMT"), all.x=T)         #Add Radial Velocity
      all.moments$dist<-NULL
      all.moments$radial<-NULL
      all.moments$elev<-NULL
      all.moments$time<-NULL
      
    all.moments<-merge(all.moments, s.w.HI_merge, by=c("Range.from.Radar.m","azimuth.deg","elev.deg","time.GMT"), all.x=T)          #Add Spectrum Width  
      all.moments$dist<-NULL
      all.moments$radial<-NULL
      all.moments$elev<-NULL
      all.moments$time<-NULL
        
  #Arrange the final product, calculate ground range, add lon lat
    final<-data.frame(all.moments$time.GMT,all.moments$azimuth.deg,all.moments$elev.deg,all.moments$Range.from.Radar.m,all.moments$ref.value,all.moments$r.v.value,all.moments$s.w.value,all.moments$d.r.value,all.moments$c.c.value,all.moments$d.p.value)
    colnames(final)<-c("Update.Time.GMT","Azimuth.deg","Elevation.deg","Range.from.Radar.m","Reflectivity","Radial.Velocity","Spectrum.Width","Differential.Reflectivity","Correlation.Coefficient","Differential.Phase")
    final$Ground.Range.m <- cos(final$Elevation.deg * pi/180) * final$Range.from.Radar.m
    lonlat<-destPoint(p = nex.center,b = final$Azimuth.deg,d = final$Ground.Range.m)
    final$lon<-lonlat[,1]
    final$lat<-lonlat[,2]
  #NOAA Altitude Calculation  
    #final$Altitude.m<- tan(final$Elevation.deg * pi/180) * final$Ground.Range.m
    final$Altitude.m <- (final$Range.from.Radar.m)*sin(final$Elevation.deg*pi/180) + (final$Range.from.Radar.m)^2/(2*IR*Re)
  #Z and Birds per km^3
    final$Z<- 10^(final$Reflectivity/10)
    final$tbr <- (pi^5)/(lambda^4)*km2*final$Z/100000
    final$birds.km3 <- final$tbr/ref.bird
    
  #Organize, sort, save
    final.2<-data.frame(final$Update.Time.GMT,final$lon,final$lat,final$Altitude.m,final$Azimuth.deg,final$Elevation.deg,final$Range.from.Radar.m,final$Ground.Range.m,final$Reflectivity,final$Z,final$tbr,final$Radial.Velocity,final$Spectrum.Width,final$Differential.Reflectivity,final$Correlation.Coefficient,final$Differential.Phase,final$birds.km3)
    colnames(final.2) <- c("Update.Time.GMT","Longitude","Latitude","Altitude.m","Azimuth.deg","Elevation.deg","Range.from.Radar.m","Ground.Range.m","Reflectivity","Z","Total.Biological.Reflectivity","Radial.Velocity","Spectrum.Width","Differential.Reflectivity","Correlation.Coefficient","Differential.Phase","Birds_km3")
    final.3 <- final.2[order(final.2$Update.Time.GMT),]
    final.3 <- subset(final.3, is.na(final.3$Reflectivity) != T) #Remove empty resolution cells
    csv.filename<-gsub(pattern = ".ncdf",replacement = ".csv",x = filelist[i])
    write.csv(x = final.3,file = file.path(working.directory,"Result",csv.filename),row.names = F)
  #Spatial filter
    #sub.final.3 <- subset(final.3, Longitude >= ULC[1] & Longitude <= LRC[1])
    #sub.final.3 <- subset(sub.final.3, Latitude >= LRC[2] & Latitude <= ULC[2])
    #csv.filename.2 <- paste0("sub_",csv.filename)    
    #write.csv(x = sub.final.3,file = file.path(working.directory,"Result",csv.filename.2),row.names = F)
  #Update the progress bar
    setTxtProgressBar(pb,i)
  }
}
    