#!/usr/bin/env Rscript
library("gridExtra")

preds<-read.delim("./model_Seq_10chunk_preds.csv", sep=",",header=TRUE)
str(preds)

preds$file_name<-as.character(preds$file_name)
preds$chunk<-as.numeric(substr(preds$file_name,18,(nchar(preds$file_name)-4)))

table(preds$chunk)

library(viridis)
library(ggplot2)

#plotting metric aggrement with density as the color
get_density <- function(x, y, ...) {
  dens <- MASS::kde2d(x, y, ...)
  ix <- findInterval(x, dens$x)
  iy <- findInterval(y, dens$y)
  ii <- cbind(ix, iy)
  return(dens$z[ii])
}

d<-get_density(preds$y_test, preds$preds, n=500)

#png(file="./scatter_density.png",width=6, height=6, units="in", res=300)
p1<-ggplot(preds) + geom_point(aes(x=y_test, y=preds, color=log(d)), size=0.1, alpha=0.5) + 
  scale_color_viridis() +
  theme_bw() + theme(legend.position = "none") +
  xlab("Actual") + ylab("Predicted") +
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) +
  geom_abline(intercept = 0, slope = 1)
#dev.off()

preds$model_d<-0

for (i in 1:10){
	preds[preds$chunk==i,]$model_d<-get_density(preds[preds$chunk==i,]$y_test, preds[preds$chunk==i,]$preds, n=100)
}

#png(file="./scatter_densityi_wrap.png",width=10, height=4, units="in", res=300)
p2<-ggplot(preds) + geom_point(aes(x=y_test, y=preds, color=log(model_d)), size=0.1, alpha=0.5) + 
  scale_color_viridis() +
  theme_bw() + theme(legend.position = "none") +
  xlab("Actual") + ylab("Predicted") +
  geom_abline(intercept = 0, slope = 1) + 
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) +
  facet_wrap(.~chunk, ncol=1)
#dev.off()

png(file="./scatter_density_full_and_cunks.png",width=10, height=10, units="in", res=300)
grid.arrange(p1,p2,ncol=2)
dev.off()

#print("first two plots done")
#
#df<-preds[,c(2:5)]
#head(df)
#
#
#df2<-preds[,c(2,3)]
#head(df2)
#df2$chunk<-"combined"
#df2$model_d<-get_density(df2$y_test, df2$preds, n=500)
#head(df2)
#
#print("r binding")
#df<-rbind(df,df2)
#
#head(df)
#str(df)
#table(df$chunk)
#
#
#png(file="./scatter_density_full_and_cunks.png",width=10, height=10, units="in", res=300)
#ggplot(df) + geom_point(aes(x=y_test, y=preds, color=log(model_d)), size=0.1, alpha=0.5) + 
#  scale_color_viridis() +
#  theme_bw() + theme(legend.position = "none") +
#  xlab("Actual") + ylab("Predicted") +
#  geom_abline(intercept = 0, slope = 1) + 
#  scale_x_continuous(expand=c(0,0)) +
#  scale_y_continuous(expand=c(0,0)) +
#  facet_wrap(.~chunk, nrow=3)
#dev.off()

