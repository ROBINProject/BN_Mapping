
# cargar paquetes
library("raster")
library("dismo")
library("randomForest")

# carpeta de trabajo
setwd("E:/datos")

# cargar y visualizar imagen RapidEye
re <- raster("1crop.tif")
plot(re)

# read data
datos <- read.table("dat.csv",sep=",",header=TRUE)
datos <- as.data.frame(datos)

# cabeza de sus datos
head(datos)

# Sacar 20% de los datos para prueba
indices <- 1:nrow(datos)
indicesEntrenamiento <- sample(indices,round(0.80*nrow(datos),0))
datosEntrenamiento <- datos[indicesEntrenamiento,]
datosPrueba <- datos[-indicesEntrenamiento,]

# los datos de entrenamiento tienen la misma estructura
# que los datos originales
head(datosEntrenamiento)

# modelo lineal prueba
modelo <- lm(promAltura ~ bh+alos+canopy+asar,data=datosEntrenamiento)

# analisis de residuales
plot(modelo)

# prediccion sobre los datos de prueba para validar
prediccion <- predict(modelo,datosPrueba)

# correlacion entre pronosticado y real
cor(prediccion,datosPrueba$promAltura)

# error cuadrático medio
sum((prediccion-datosPrueba$promAltura)^2)/nrow(datos)

# datos de toda la region
region <- read.table("COV1.txt",sep="\t",header=TRUE)
plot(region$X,region$Y,pch=".",col="red")
plot(datosEntrenamiento$X,datosEntrenamiento$Y,pch=".")



# pronostico sobre toda el area
prediccion <- predict(modelo,newdata=region,se.fit=TRUE)

names(prediccion)

# visualizacion
mapa <- data.frame(prediccion$fit,X=region$X,Y=region$Y)

# rasterizar
coordinates(mapa)=~X+Y
gridded(mapa)=TRUE
r <- raster(mapa)
plot(r)

# modelo random forest

?randomForest
modelo <- randomForest(promAltura ~ bh+alos+canopy+asar,data=datosEntrenamiento)
plot(modelo)

# pronostico sobre toda el area
prediccion <- predict(modelo,region)

names(prediccion)

# visualizacion
mapa <- data.frame(prediccion,X=region$X,Y=region$Y)

# rasterizar
coordinates(mapa)=~X+Y
gridded(mapa)=TRUE
r <- raster(mapa)
plot(r)