#!/usr/bin/env Rscript
#install.packages("lubridate", repos="http://cran.us.r-project.org")
library(lubridate)

args = commandArgs(trailingOnly=TRUE)

aqua<-read.delim(paste0("./keys/date_key_aqua_",args[1],".txt"),sep="|")
terra<-read.delim(paste0("./keys/date_key_terra_",args[1],".txt"),sep="|")

df<-rbind(terra,aqua)
df<-df[!duplicated(df),]

df<-df[order(df$doy),]

write.table(df, paste0("./keys/date_key_",args[1],".txt"), sep="|", row.names=FALSE)
