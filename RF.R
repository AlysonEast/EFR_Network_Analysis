#!/usr/bin/env Rscript
#install.packages("randomForest", repos="http://cran.us.r-project.org")
#urlPackage <- "https://cran.r-project.org/src/contrib/Archive/randomForest/randomForest_4.6-12.tar.gz"
#install.packages(urlPackage, type="source")
library(ggplot2)
library(randomForest)

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

test<-df[,c(3:6)]
head(test)
#Generate RF Model..
rf<-randomForest(GPP ~ ., data = test, mtry = 3, do.trace=TRUE,
                 importance = TRUE, na.action = na.omit)
summary(rf)
print(rf)

#Generate Predictions based on RF
df_2020$pred<-predict(m, newdata=df_2020)
df_2020$diff<-df_2020$pred-df_2020$GPP

df_2021$pred<-predict(m, newdata=df_2021)
df_2021$diff<-df_2021$pred-df_2021$GPP

df_2022$pred<-predict(m, newdata=df_2022)
df_2022$diff<-df_2022$pred-df_2022$GPP

write.csv(df_2020, "./diff_rf_2020.csv")
write.csv(df_2021, "./diff_rf_2021.csv")
write.csv(df_2022, "./diff_rf_2022.csv")
