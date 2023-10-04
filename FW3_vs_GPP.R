#!/usr/bin/env Rscript
#install.packages("viridis", repos="http://cran.us.r-project.org")
library(viridis)
library(ggplot2)

df<-read.delim("./compare_tmp", sep=" ",header=FALSE)
colnames(df)<-c("lat","long","GPP","FW3")
dim(df)
df<-df[sample(nrow(df), size=10000000), ]

#plotting metric aggrement with density as the color
get_density <- function(x, y, ...) {
  dens <- MASS::kde2d(x, y, ...)
  ix <- findInterval(x, dens$x)
  iy <- findInterval(y, dens$y)
  ii <- cbind(ix, iy)
  return(dens$z[ii])
}

d<-get_density(df$GPP, df$FW3, n=100)

png(file="./scatter_density.png",width=6, height=6, units="in", res=300)
ggplot(df) + geom_point(aes(x=GPP, y=FW3, color=d), size=0.1, alpha=0.5) + 
  scale_color_viridis() +
  theme_bw() + theme(legend.position = "none") 
dev.off()
