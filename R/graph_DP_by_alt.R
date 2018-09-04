

sub.elev<-subset(data, Elevation.deg > 4)
sub.elev.dp<-subset(sub.elev, Differential.Phase >= 110 & Differential.Phase <= 270)


p<-ggplot(data=sub.elev.dp,aes(x=Differential.Phase, y=Altitude.m,color=Reflectivity)) + geom_point() + scale_color_gradient(low="yellow",high="purple")
q <- p + theme_dark() + xlab("Differential Phase [110,270]") + ylab("Altitude (m) \nElevation > 4 degrees") + ggtitle(label = "Differential Phase by Altitude for KLCH",subtitle = "May 11, 2018 01:13:11 GMT") + scale_y_continuous(breaks = seq(0,3400,by=100)) + scale_x_continuous(breaks = seq(100,280, by=20))
ggsave(filename = "KLCH_DP_by_Altitude_Bird_.pdf",plot = q,width = 12,height = 12, units = "in")

m<-ggplot(sub.elev.dp, aes(x=Reflectivity)) + geom_histogram(binwidth = 1,color="black",fill="purple") + theme_dark() 
n<-m + scale_x_continuous(breaks = seq(-100,40, by=10)) + scale_y_continuous(breaks = seq(0,4500, by=500)) + ylab("Frequency") + xlab("Reflectivity (dBsm)") + ggtitle("KLCH Reflectivity (dBsm) Histogram\nMay 11, 2018 01:13:11 GMT",subtitle = "Differential Phase [110-270]\nElevation Angle > 4")
ggsave(filename = "KLCH_reflectivity_hist_140919.png",plot = n,width = 10,height = 10,units = "in")
