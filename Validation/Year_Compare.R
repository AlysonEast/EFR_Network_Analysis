#!/usr/bin/env Rscript

files<-list.files("./wholeyears/", pattern="*_compare", full.names=TRUE)

df<-read.delim(files[1], sep=" ",header=TRUE)
df<-subset(df, FW3>0)
df$file<-files[1]
str(df)
head(df)
df<-df[sample(nrow(df), size=100000), ]

for (i in 2:length(files)){
	temp<-read.delim(files[i], sep=" ",header=TRUE)
	temp<-subset(temp, FW3>0)
	temp$file<-files[i]
	temp<-temp[sample(nrow(temp), size=100000), ]
	
	df<-rbind(df, temp)
	print(files[i])
}

df$year<-as.numeric(substr(df$file, 15, 19))

head(df)
str(df)

table(df$year)

dim(df)

library(ggplot2)

get_density <- function(x, y, ...) {
     dens <- MASS::kde2d(x, y, ...)
     ix <- findInterval(x, dens$x)
     iy <- findInterval(y, dens$y)
     ii <- cbind(ix, iy)
     return(dens$z[ii])
 }

df$density<-get_density(df$GPP, df$FW3, n=100)

png("./rplot.png", width=12, height=9, units="in", res=300)
ggplot(df, aes(x=GPP, y=FW3, col=density), alpha=0.5) + geom_point() 
dev.off()

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

