#!/usr/bin/env Rscript
library(ggplot2)

df<-read.delim("./Compare", sep=" ",header=FALSE)

colnames(df)<-c("lat","long","GPP","FW3","NLCD")

df$NLCD<-as.factor(df$NLCD)
df<-subset(df, NLCD!=0 & NLCD !=11 & NLCD!=12 & GPP!=0 & FW3!=0)

m1<-lm(data=df, GPP~FW3*NLCD)
summary(m1)

m2<-lm(data=df, GPP~FW3 + I(FW3^2) + NLCD*(FW3 + I(FW3^2)))
summary(m2)

AIC(m1, m2)

png(file="./figures/GLM_NLCD.png", width=10, height=11, units = "in", res=300)
ggplot(df, aes(x=FW3, y=GPP))+
	geom_point(alpha=0.5, aes(color=NLCD)) + geom_smooth(method=lm, formula=y~x+I(x^2), se=TRUE) +
	facet_wrap(.~NLCD) + 
	scale_color_manual(values=c("#dec5c5","#d99282","#eb0000","#ab0000","#b3ac9f","#68ab5f",
				"#1c5f2c","#b5c58f","#ccb879","#dfdfc2","#dcd939","#ab6c28","#b8d9eb","#6c9fb8"),
			  labels=c("Developed - open","Developed - low","Developed - med","Developed - high",
			     	   "Barren","Deciduous Forest","Evergreen Forest","Mixed Forest",
				   "Shrub/scrub","Grassland","Pasture/hay","Cultivated","Woody Wetland","Wetland"),
			   name="NLCD Class")

dev.off()
