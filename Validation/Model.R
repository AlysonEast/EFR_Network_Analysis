#!/usr/bin/env Rscript

phenoregions<-read.delim("./pheno100_univar.vect.out", sep="|",header=TRUE)
str(phenoregions)
phenoregions<-phenoregions[order(phenoregions$mean), ]

phenoregions

seq(1,100,10) 

files<-list.files("./samples/", pattern="samples_*", full.names=TRUE)

df<-read.delim(files[1], sep=" ",header=FALSE)
#input=MODIS_${p}yr_AUC_wk${week}_${cal_year},${FW},phenology_2000-2016.100.maxmode,minint>./samples/samples_${cal_year}_${p}yr_${week}
colnames(df)<-c("lat","long","GPP","FW3","pheno","minint")
df<-subset(df, FW3>0)
df$file<-files[1]
str(df)
head(df)

df <- df[sample(nrow(df), size=1000000), ]


for (i in 2:length(files)){
	temp<-read.delim(files[i], sep=" ",header=FALSE)
	colnames(temp)<-c("lat","long","GPP","FW3","pheno","minint")
	temp<-subset(temp, FW3>0)
	temp$file<-files[i]
	temp <- temp[sample(nrow(temp), size=1000000), ]

	df<-rbind(df, temp)
	print(files[i])
}

df$year<-as.numeric(substr(df$file, 20, 23))
df$product<-as.numeric(substr(df$file, 25, 25))
df$week<-as.numeric(substr(df$file, 42, nchar(df$file)))
df$week<-(df$week-1)

head(df)
str(df)

table(df$year)
table(df$product)

dim(df)

#df<-df[sample(nrow(df), size=100000), ]

df<-subset(df, GPP>0)

table(df$pheno)

df$pct<-((2020-(df$year-(df$product+1)))/(df$product+1))
df$pct<-ifelse(df$pct<0, paste0(0), paste0(df$pct))
df$pct<-ifelse(df$pct>1, paste0(1), paste0(df$pct))

table(df$pct)
head(df)

lower<-seq(1,100,10)
upper<-seq(10,100,10)

for (i in 1:10) {
	list<-phenoregions[lower[i]:upper[i],1]
	print(list)
	output<-df[df$pheno %in% list,]

	write.csv(output[,c(3,4,5,6,9,10,11)], paste0("./xgboost_samples/chunk10/samples_chunk",i,".csv"), row.names=FALSE)
}


for (i in 1:100) {
	write.csv(subset(df, pheno==i)[,c(3,4,5,6,9,10,11)], paste0("./xgboost_samples/indv100/pheno_",i,".csv"), row.names=FALSE)
}
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

