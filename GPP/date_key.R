#!/usr/bin/env Rscript
#install.packages("lubridate", repos="http://cran.us.r-project.org")
library(lubridate)

args = commandArgs(trailingOnly=TRUE)

df<-read.delim("./tmp", header=FALSE)
df$doy<-substr(df$V1,2,8)
origin=paste0(args[2],"-1-1")
origin
df$date<-as.Date(df$doy, format="%Y%j", origin=origin)
df$date<-format(df$date, "%Y.%m.%d")
df
write.table(df, paste0("./keys/date_key_",args[1],"_",args[2],".txt"), sep="|", row.names=FALSE)
