#!/usr/bin/env Rscript

files<-list.files("./samples/", pattern="samples_*", full.names=TRUE)

df<-read.delim(files[1], sep=" ",header=FALSE)
colnames(df)<-c("lat","long","GPP","FW3","pheno")
df<-subset(df, FW3>0)
df$file<-files[1]
str(df)
head(df)

for (i in 2:length(files)){
	temp<-read.delim(files[i], sep=" ",header=FALSE)
	colnames(temp)<-c("lat","long","GPP","FW3","pheno")
	temp<-subset(temp, FW3>0)
	temp$file<-files[i]

	df<-rbind(df, temp)
	print(files[i])
}

df$year<-as.numeric(substr(df$file, 20, 23))
df$product<-as.numeric(substr(df$file, 25, 25))
df$date<-substr(df$file, 29, nchar(df$file))

head(df)
str(df)

table(df$year)
table(df$product)

dim(df)

#df<-df[sample(nrow(df), size=100000), ]

df<-subset(df, GPP>0)

df$pct<-


write.csv(df[,c(3,4,5,7,8)], "./samples_wnc.csv", row.names=FALSE)


library(ggplot2)

#png("./rplot.png", width=9, height=9, units="in", res=300)
#ggplot(df, aes(x=GPP, y=FW3)) + geom_point() + facet_wrap(.~pheno)
#dev.off()

#install.packages("rlang", repos="http://cran.us.r-project.org")
#install.packages("caret", repos="http://cran.us.r-project.org")

#library(caret)

#dt <- sort(sample(nrow(df), nrow(df)*.7))
#train<-df[dt,]
#test<-df[-dt,]

#fitControl <- trainControl(method="repeatedcv", number=10, repeats=10, savePredictions="all")
#mtry <- sqrt(ncol(train))
#tunegrid <- expand.grid(.mtry=mtry)

#set.seed(5678)


#m1<- train(GPP ~ FW3+pheno+product+year, data = train, method = "rf", trControl = fitControl,verbose=T, tuneGrid=tunegrid, metric="Rsquared")

#m1$results
#max(m1$results$Rsquared)

#save(m1, file="./wncRF.Rdata")


#Error_importance982 <- varImp(error98_fitgrid)
#ggplot(Error_importance982) + ggtitle("Variable Loadings error in rh98")  +
#  theme(text = element_text(size=15))

