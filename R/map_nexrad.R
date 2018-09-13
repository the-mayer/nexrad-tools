#What do we need to do the job?
  require(raster) #Probably not the best solution
  require(ncdf4) #Needed if you want to extract the site location from NetCDF
  require(tidyverse) #useful
  require(sf) #Used to normalize the grid to a raster
  require(maps) #ggmap works better
  require(ggmap)
  require(sp) #probably don't need to explicitly load this
  require(geosphere)
  require(circular)
  require(broom) #the new fortify? fortify still works...

#Test site location. Can also calculate or simply extract from NetCDF  
  KFWS<-c(-97.30306,32.57306)

#Subset... above 1000ft and closest to 1.5 degree elevation angle: "Bird Layer"
#Remove Range folded values
  sub.alt.data<- subset(nex, Altitude.m >= 304.8)
  sub.elev.data<-subset(sub.alt.data, Elevation.deg >= 1.2 & Elevation.deg <=1.7)
  sub.rf<-subset(sub.elev.data, Differential.Phase > 0)
  sub.data<-sub.rf
#Add the row number as an identifier
  sub.data <-rowid_to_column(sub.data, "ID") #tidyverse
#Classify azimuth data as circular
  sub.data$Azimuth.deg <-circular(x = sub.data$Azimuth.deg,type="angles",units="degrees",template="none",modulo="2pi",rotation="clock")
  
#calculate radar resolution cell polygon corners
#Better approach, don't need to normalize to a regular grid, no averaging or information loss.  
  bottom.left <- destPoint(p = KFWS,b = sub.data$Azimuth.deg - 0.25,d = sub.data$Ground.Range.m - 125)
  bottom.right <- destPoint(p = KFWS,b = sub.data$Azimuth.deg + 0.25,d = sub.data$Ground.Range.m - 125)
  top.left <- destPoint(p = KFWS,b = sub.data$Azimuth.deg -0.25,d = sub.data$Ground.Range.m + 125)
  top.right <- destPoint(p = KFWS,b = sub.data$Azimuth.deg + 0.25,d = sub.data$Ground.Range.m + 125)
#Bind all of the corners into a data frame. Don't forget to close the polygon
  polys.pt <- cbind(bottom.left,top.left,top.right,bottom.right,bottom.left)

#Create a spatial polygons data frame with the polygon info. Add an ID to merge resolution cell data later  
  ID <- as.character(sub.data$ID)
  polys <- SpatialPolygons(mapply(function(poly, id){
      xy <- matrix(poly, ncol=2, byrow=TRUE)
      Polygons(list(Polygon(xy)), ID=id)}, 
    split(polys.pt, row(polys.pt)), ID),proj4string=CRS("+proj=longlat +datum=WGS84"))
#Test how it looks
  plot(polys)
#Make it pretty with ggmap
  map<-get_map(location = KFWS,zoom = 7,maptype = "terrain")
  p<-ggmap(map, extent = "normal", maprange = FALSE) + geom_polygon(data = fortify(polys),
                 aes(long, lat, group = group),
                 fill = "orange", colour = "blue", alpha = 0.2) + theme_bw()





#Test... rasterize data, which involves some less than ideal calculations, averaging resolution cells to get a normal grid, then plot
  #coords = data.frame(lat = nex.data$Latitude, lon = nex.data$Longitude)
  #spPoints <- SpatialPointsDataFrame(coords, data = data.frame(data = nex.data$Differential.Phase), proj4string = CRS("+proj=longlat +datum=WGS84"))
  #polys = as(SpatialPixelsDataFrame(spPoints, spPoints@data, tolerance = 0.149842),"SpatialPolygonsDataFrame")
  spdf<-SpatialPointsDataFrame( data.frame( x = sub.data$Longitude , y = sub.data$Latitude ) , data = data.frame( z = sub.data$Reflectivity ) )
  e<-extent(spdf)
  ratio <- ( e@xmax - e@xmin ) / ( e@ymax - e@ymin )
  r <- raster( nrows = 500 , ncols = floor( 500 * ratio ) , ext = extent(spdf) )
  rf <- rasterize( spdf , r , field = "z" , fun = mean )
  rdf <- data.frame( rasterToPoints( rf ) )  
  #ggplot( NULL ) + geom_raster( data = rdf , aes( x , y , fill = layer ) )
  ggmap(map) + geom_tile( data = rdf , aes( x , y , fill = layer ),alpha = 0.5 )
