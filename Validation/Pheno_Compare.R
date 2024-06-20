#!/usr/bin/env Rscript
library(ggplot2)

get_density <- function(x, y, ...) {
     dens <- MASS::kde2d(x, y, ...)
     ix <- findInterval(x, dens$x)
     iy <- findInterval(y, dens$y)
     ii <- cbind(ix, iy)
     return(dens$z[ii])
 }

files<-list.files("./xgboost_samples/indv100/", pattern="pheno_*", full.names=FALSE)

for (i in 2:length(files)){
	df<-read.delim(paste0("./xgboost_samples/indv100/",files[i]), sep=",",header=TRUE)

        print(files[i])
	str(df)
	head(df)

	df$density<-get_density(df$GPP, df$FW3, n=100)

	png(paste0("./GPP_FW3_plots/",substr(files[i],1,(nchar(files[i])-4)),"_plot.png"), width=10, height=10, units="in", res=300)
	print(ggplot(df, aes(x=GPP, y=FW3, col=density), alpha=0.5) + geom_point()) 
	dev.off()

}



