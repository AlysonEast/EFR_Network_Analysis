#!/usr/bin/env Rscript
library(ggplot2)

df_2020<-read.delim("./Compare_2020", sep=" ",header=FALSE)
colnames(df_2020)<-c("lat","long","GPP","FW3","NLCD","Pheno")
df_2020$NLCD<-as.factor(df_2020$NLCD)
df_2020<-subset(df_2020, NLCD!=0 & NLCD !=11 & NLCD!=12 & GPP!=0 & FW3!=0)

df_2021<-read.delim("./Compare_2021", sep=" ",header=FALSE)
colnames(df_2021)<-c("lat","long","GPP","FW3","NLCD","Pheno")
df_2021$NLCD<-as.factor(df_2021$NLCD)
df_2021<-subset(df_2021, NLCD!=0 & NLCD !=11 & NLCD!=12 & GPP!=0 & FW3!=0)

df_2022<-read.delim("./Compare_2022", sep=" ",header=FALSE)
colnames(df_2022)<-c("lat","long","GPP","FW3","NLCD","Pheno")
df_2022$NLCD<-as.factor(df_2022$NLCD)
df_2022<-subset(df_2022, NLCD!=0 & NLCD !=11 & NLCD!=12 & GPP!=0 & FW3!=0)

set.seed(123)
df<-df_2020[sample(1:nrow(df_2020), 100000),]
df<-rbind(df, df_2021[sample(1:nrow(df_2021), 100000),])
df<-rbind(df, df_2022[sample(1:nrow(df_2022), 100000),])

head(df)

df$NLCD<-as.factor(df$NLCD)
df<-subset(df, NLCD!=0 & NLCD !=11 & NLCD!=12 & GPP!=0 & FW3!=0)

print("fine to here")

m<-lm(data=df, GPP~FW3+I(FW3^2)+NLCD*(FW3+I(FW3^2)))
summary(m)

#df_2020$pred<-predict(m, newdata=df_2020)
#df_2020$diff<-df_2020$pred-df_2020$GPP

#df_2021$pred<-predict(m, newdata=df_2021)
#df_2021$diff<-df_2021$pred-df_2021$GPP

#df_2022$pred<-predict(m, newdata=df_2022)
#df_2022$diff<-df_2022$pred-df_2022$GPP

#write.csv(df_2020, "./diff_2020.csv")
#write.csv(df_2021, "./diff_2021.csv")
#write.csv(df_2022, "./diff_2022.csv")

#png(file="./figures/GLM_NLCD.png", width=10, height=11, units = "in", res=300)
#ggplot(df, aes(y=FW3, x=GPP)) + 
#	geom_point(alpha=0.5, aes(color=NLCD)) + 
#	geom_smooth(method=lm, formula=y~x+I(x^2), se=TRUE) +
#	facet_wrap(.~NLCD) + 
#	scale_color_manual(values=c("#dec5c5","#d99282","#eb0000","#ab0000","#b3ac9f","#68ab5f",
#				"#1c5f2c","#b5c58f","#ccb879","#dfdfc2","#dcd939","#ab6c28","#b8d9eb","#6c9fb8"),
#			  labels=c("Developed - open","Developed - low","Developed - med","Developed - high",
#			     	   "Barren","Deciduous Forest","Evergreen Forest","Mixed Forest",
#				   "Shrub/scrub","Grassland","Pasture/hay","Cultivated","Woody Wetland","Wetland"),
#			   name="NLCD Class")
#dev.off()
