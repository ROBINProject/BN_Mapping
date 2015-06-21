

# Working directory
setwd("~/2_ROBIN/18 brasil Workshop/93brasil Workshop/Dados_clip_limite_PARA")

# paquetes
library(randomForest)
library(raster)

# datos
datos <- read.table("muestra30000Fixed.csv",sep=",",header=TRUE)

modelo <- randomForest(y=datos[,14],x=datos[,1:11],ntree=800,corr.bias=TRUE)

plot(modelo)

# save model
save(modelo,file = "modeloFinal.RData")

# remove datos to free space
remove(datos)

datos <- read.table("muestraTotalFixed.csv",sep=",",header=TRUE)

integ <- predict(modelo,datos)

names(datos)

datos <- data.frame(X=datos$X,Y=datos$Y,integridad=integ)

coordinates(datos)=~X+Y
gridded(datos)=TRUE
r<-raster(datos)
plot(r)

# create gtif with proper projection
baseimage <- raster("UsoAntropicoIBGE.tif")
proj <- projection(baseimage)
projection(r) <- proj

head(r)

dim(datos)

writeRaster(r, filename="integridadFinal.tif", format="GTiff", overwrite=TRUE)

coord <- data.matrix(as.matrix(coordinates(datos)))

extent(r)


