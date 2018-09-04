#packages
require(ggplot2)
require(ggthemes)

#Data Prep
dp.filter <- read.csv(file = "result_dp_4.csv", header = T)
dp.filter$Filter <- "Differential Phase [ISDP + 50, 270]"
dp.filter$Date.Time<-as.POSIXct(dp.filter$Date.Time,tz = "GMT")
dp.filter$Year <- cut(dp.filter$Date.Time, breaks="year")

no.filter <- read.csv(file = "result_none_4.csv", header = T)
no.filter$Filter <- "No Filter"
no.filter$Date.Time<-as.POSIXct(no.filter$Date.Time,tz = "GMT")
no.filter$Year <- cut(no.filter$Date.Time, breaks="year")

no.precip.filter <- read.csv(file = "result_no.precip_4.csv", header = T)
no.precip.filter$Filter <- "Correlation Coefficient < 0.7"
no.precip.filter$Date.Time<-as.POSIXct(no.precip.filter$Date.Time,tz = "GMT")
no.precip.filter$Year <- cut(no.precip.filter$Date.Time, breaks="year")

precip.filter <-read.csv(file = "result_precip_4.csv", header = T)
precip.filter$Filter <- "Correlation Coefficient >= 0.7"
precip.filter$Date.Time<-as.POSIXct(precip.filter$Date.Time,tz = "GMT")
precip.filter$Year <- cut(precip.filter$Date.Time, breaks="year")

data<-rbind(dp.filter,no.filter,no.precip.filter,precip.filter)

#Factor Levels
data$Filter<-factor(x = data$Filter,levels = c("No Filter","Correlation Coefficient >= 0.7","Differential Phase [ISDP + 50, 270]","Correlation Coefficient < 0.7"))
data$Year<-factor(x = data$Year,labels = c("2014","2015","2016"))

#Plots

#Surviving Pixels
res <- ggplot(data = data, aes(x=Date.Time,y=Surviving.Res.Cell,color=Filter)) + geom_line() + facet_wrap(~Year,nrow = 3,scales = "free_x") 
res.1 <- res + geom_point(shape=21, size=1,fill="white") + scale_colour_hue(l=40)
res.final <- res.1 + xlab("Date") + ylab("Qty Surviving Resolution Cells") + ggtitle(label = "Quantity of Surviving Resolution Cells",subtitle = "KFWS") + theme_gdocs()  + theme(strip.background = element_rect(fill="purple"))
ggsave(filename = "surviving.res.cell.png",plot = res.final,width = 18,height = 8.5,units = "in")

#Reflectivity Graphs (Z)
ref <- ggplot(data = data, aes(x=Date.Time,y=Z.Mean,color=Filter)) + geom_line() + facet_wrap(Year~Filter,nrow = 3,scales = "free") 
ref.1 <- ref + geom_point(shape=21, size=1,fill="white") + scale_color_hue(l=40)
ref.2 <- ref.1 + geom_errorbar(aes(ymin = Z.Mean - Z.StdError, ymax = Z.Mean + Z.StdError),color="black")
ref.final <- ref.2 + xlab("Date") + ylab("Average Z") + ggtitle(label = "Average Z",subtitle = "KFWS") + theme_gdocs()
ggsave(filename = "average.z.png",plot = ref.final,width = 18,height = 8.5,units = "in")

#Total Biological Reflectivity
tbr <- ggplot(data = data, aes(x=Date.Time,y=Total.Biological.Reflectivity,color=Filter)) + geom_line() + facet_wrap(Year~Filter,nrow = 3,scales = "free")
tbr.1 <- tbr + geom_point(shape=21, size=1,fill="white") + scale_color_hue(l=40)
tbr.2 <- tbr.1 + geom_errorbar(aes(ymin = Total.Biological.Reflectivity - Total.Biological.Reflectivity.Stdev, ymax = Total.Biological.Reflectivity + Total.Biological.Reflectivity.Stdev),color="black")
tbr.final <- tbr.2 + xlab("Date") + ylab("Total Biological Reflectivity (cm^2/km^3)") + ggtitle(label = "Total Biological Reflectivity (cm^2/km^3)",subtitle = "KFWS") + theme_gdocs()  + theme(strip.background = element_rect(fill="yellow"))
ggsave(filename = "tbr.png",plot = tbr.final,width = 18,height = 8.5,units = "in")

#Average Differential Phase
dp<-ggplot(data = data, aes(x=Date.Time,y=Circular.Differential.Phase.Mean,color=Filter)) + geom_line()  + facet_wrap(Year~Filter,nrow = 3,scales = "free") 
dp.1 <- dp + geom_point(shape=21, size=1,fill="white") + scale_color_hue(l=40)
dp.2 <- dp.1 + geom_errorbar(aes(ymin=Circular.Differential.Phase.Mean - Circular.Differential.Phase.StdError,ymax=Circular.Differential.Phase.Mean + Circular.Differential.Phase.StdError),color="black")
dp.final <- dp.2 + xlab("Date") + ylab("Average Surviving Differential Phase (deg)") + ggtitle(label = "Average Surviving Differential Phase",subtitle = "KFWS") + theme_gdocs()  + theme(strip.background = element_rect(fill="light blue"))
ggsave(filename = "average.dp.png",plot = dp.final,width = 18,height = 8.5,units = "in")

#Birds per cubic kilometer
birds.km3 <- ggplot(data = data, aes(x=Date.Time,y=Birds.km3.Mean,color=Filter)) + geom_line()  + facet_wrap(Year~Filter,nrow = 3,scales = "free") 
birds.km3.1 <- birds.km3 + geom_point(shape=21, size=1,fill="white") + scale_color_hue(l=40)
birds.km3.2 <- birds.km3.1+ geom_errorbar(aes(ymin = Birds.km3.Mean - Birds.km3.StdError,ymax = Birds.km3.Mean + Birds.km3.StdError),color="black")
birds.km3.final <- birds.km3.2 + xlab("Date") + ylab("Birds per km^3") + ggtitle(label = "Birds per Cubic Kilometer",subtitle = "KFWS") + theme_gdocs()  + theme(strip.background = element_rect(fill="light grey"))
ggsave(filename = "birds.km3.png",plot = birds.km3.final,width = 18,height = 8.5,units = "in")
