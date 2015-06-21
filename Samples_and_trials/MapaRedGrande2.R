
#packages
library(raster)

# Working directory
setwd("~/2_ROBIN/18 brasil Workshop/finalmaps")

datos <- read.table("TotalDatos.txt",sep="\t",header=TRUE)

datos <- as.data.frame(datos)

dim(datos)

datos <- matrix(1,length(datos),1)-datos

coords <- read.table("C:/Users/pythonxy/Documents/2_ROBIN/18 brasil Workshop/93brasil Workshop/Dados_clip_limite_PARA/muestraTotalFixed.csv",sep=",",header=TRUE)

head(datos)

datoss<- data.frame(X=coords$X,Y=coords$Y,datos)

names(datoss)<-c("X","Y","integridad")

coordinates(datoss)=~X+Y
gridded(datoss)=TRUE
r<-raster(datoss)
plot(r)

writeRaster(r, filename="integridadFinalRedBayes.tif", format="GTiff", overwrite=TRUE)