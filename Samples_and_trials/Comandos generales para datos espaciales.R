## Para importar Capas en formato .asc es necesario activar la paquetería Adehabitat y ade4##
library ("adehabitat")

##------- Comando para importar archivos asc -------##

# Función para leer el clip de excel
copia.clip.excel <- function(header=TRUE,...) 
{
  read.table("clipboard",sep="\t",header=header,...)
}

algo <- copia.clip.excel(header=FALSE)
getwd()
Setwd("Directorio")
Nomcapa <- import.asc("Elevation.asc")
##---Visualizar la capa importada---##
image (Nombcapa, main="nombre de la capa")

##Ejemplo##

getwd()
setwd("C:/Ahabitat")
Library ("Adehabitat")
elev <- import.asc("Elevatión.asc")

##-----------------------------Ejemplo datos Isra--------------------------##
getwd()
setwd("C:/Maxlike")
getwd()
##---------------------Cargar librerias adhabitad y maxlike----------------##
library("adehabitat", lib.loc="C:/Users/Jose Luis/Documents/R/win-library/3.0")
library("maxlike", lib.loc="C:/Users/Jose Luis/Documents/R/win-library/3.0")
library("raster", lib.loc="C:/Users/Jose Luis/Documents/R/win-library/3.0")
##----------------------------Importación Ejemplo--------------------------##
capa1 <- import.asc("Bio1.asc")
capa2 <- import.asc("Bio10.asc")
capa3 <- import.asc("Bio11.asc")
capa4 <- import.asc("Bio12.asc")
capa5 <- import.asc("Bio13.asc")

##-----------------------------Visualizar Datos----------------------------##
plot(capa1)
plot(capa2)
plot(capa3)
plot(capa4)
plot(capa5)

##------------------------------Desplegar sus metadatos--------------------##
capa1
capa2
capa3
capa4
capa5

##--------Alinear y extención de los objetos: para desarrollar esta tarea--##
##--------Es necesario cargar la libreria RASTER---------------------------##
r <- raster(capa1)
r
e <- extent(-102.3003, -90.3586, 14.55911, 27.65911)
ae <- alignExtent(e, r)

##--------Conversión de datos raster map class .asc a  Raster Layer--------##
raster1 <- raster(capa1)
raster2 <- raster(capa2)
raster3 <- raster(capa3)
raster4 <- raster(capa4)
raster5 <- raster(capa5)

##----------------------------Visulizar datos raster-----------------------##
image(raster1)
image(raster2)
image(raster3)
image(raster4)
image(raster5)
##------------------------Leer como Data Frame----------------------------##
#El Comando as.data.frame sirve para convertir los datos en el formato citado#

as.data.frame(raster1)
as.data.frame(raster2)
as.data.frame(raster3)
as.data.frame(raster4)
as.data.frame(raster5)

##------Formar grupo de datos para la ejecución del modelo----------------##
capas2 <- stack(raster1, raster2, raster3, raster4, raster5)

##-------------------Convertir como Data.freme---------------------------##

variables <- as.data.frame(capas2)

##------------------- EXtender area de trabajo --------------------------##

e <- extent(-102.3003, -90.3586, 14.55911, 27.65911)
ae <- alignExtent(e, capas2)
e
extent(capas2)
ae

##------------------------------Visualizar datos---------------------------##
plot(capas2)

##----------------------------Visualizar Metadatos-------------------------##
raster1
raster2
raster3
raster4
raster5

##------------------------Comparación de datos Boxplot--------------------###
boxplot(capas2)

##----------------------Metadatos del RasterStack "capas2"-----------------##
capas2

##---------------asignación de nombre para cada una de las capas-----------##
names(capas2) <- c("eleva", "pend", "temp", "humed")

##----------------Visualización de las capas con sus nombres---------------##
plot(capas2)

##--------------------------Metadatos del Stack----------------------------##
variables

##----------------------Importar archivos .csv o dbf-----------------------##
puntos <- read.csv("Presencia4.csv")

##-----------------------Visualizar datos de la tabla----------------------##
presencias <- as.data.frame(puntos)

## Nota:Si solo se quiere visualizar parte de la tabla es necesario poner coorchetes
presencias [1:5, ]

image(capas2)

##---------sobre poner puntos en una capa o convertir tabla en puntos-------##
points(puntos, pch=10) 

##-----------------------------Modelo maxlike------------------------------##
fm2 <- maxlike(~eleva + I(eleva^2) + pend + I(pend^2)+ temp + I(temp^2) + humed + I(humed^2), capas2, presencias,method="BFGS", removeDuplicates=TRUE, savedata=TRUE)

summary(fm2)
confint(fm2)
AIC(fm2)
logLik(fm2)

##------------------------Exportar a formato .asc--------------------------##
export.asc(capa1, "Temperatura.asc")

##------------------------Importar imagen RGB------------------------------##
getwd()
setwd("C:/Landsat")
library("landsat", lib.loc="C:/Program Files/RStudio/R/library")
library("raster", lib.loc="C:/Users/Jose Luis/Documents/R/win-library/3.0")
modis <- rgdal::readGDAL("SatMex.tif")
modisimage <- stack(modis)
modisimage
plotRGB(modisimage)
plotRGB(modisimage, 3, 2, 1)
plotRGB(modisimage, 1, 2, 3)
plotRGB(modisimage, 1, 2, 3, stretch="hist")


# Leer un archivo Shape; Para que se lleve acabo este comando es necesario que las librerías
# rgdal y maptools estén cargadas y activadas.

NwCountiesDF <- readOGR("FiveNWStatesCounties.shp","FiveNWStatesCounties")

