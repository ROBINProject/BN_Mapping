########################################################################
#                  Rutina para cargar archivos de la Amazonia          #
#                  ELABORAdo POR: Jose L. Alvarez P.                   #
#                  luis.alvarez@inecol.mx                              #
#                  21 de Agosto de 2014                                #
#                  RED: Ambiente y Sustentabilidad                     #
#                  INSTITUTO DE ECOLOGIA, A.C.                         #
#                  WWW.inecol.edu.mx                                   #
########################################################################
##Instala paqueterias
install.packages("spatstat", "maptools", "raster", "rgdal")
install.packages ("plotGoogleMaps")

##carga paqueterias
library("plotGoogleMaps")
library("raster")
library("rgdal")
library("spatstat")
library("maptools")

#dir.trabajo <- "C:/Brasil" # José Luis
#dir.tablas <- "C:/Brasil/Tablas"
#dir.geotiff <- C:/Brasil/Geotifs"

<<<<<<< HEAD
#dir.GD <- "C:/Users/Miguel/Documents/1 Nube/GoogleDrive/"   # Miguel laptop
dir.GD <- "C:/Users/miguel.equihua/Documents/1 Nube/Google Drive/"   # Miguel escritorio Inecol
=======
dir.GD <- "C:/Users/Miguel/Documents/1 Nube/GoogleDrive/"   # Miguel laptop
#dir.GD <- "C:/Users/miguel.equihua/Documents/1 Nube/GoogleDrive/"   # Miguel escritorio Inecol
>>>>>>> 621d459f7008dfe615b34e9ba1721b922179eac6

dir.trabajo <- paste(dir.GD, "2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/Base_de_datos/", sep="")
dir.tablas <- paste(dir.GD,"2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/Base_de_datos/GeoData/tablas/", sep="")
dir.geotiff <- paste(dir.GD, "2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/Base_de_datos/GeoData/GeoTIFF/", sep="")
<<<<<<< HEAD
=======

setwd(dir.trabajo) 

# Muestra Área de Estudio en Google Maps
Area_Estudio <- readOGR("AEBrasilPoly.shp", "AEBrasilPoly")
Area_Estudio
AEGOOGLEMAPS<-plotGoogleMaps(Area_Estudio,zcol="Area",filename='Area de Estudio Brasil.htm', 
                             col= "Green", strokeColor="white")


b.p <- as.data.frame(rasterToPoints(rasterFPAR2005))
coordinates(b.p) <- ~ x + y
gridded(b.p) <- TRUE
projection(b.p) <- projection(rasterFPAR2005)
b<-plotGoogleMaps(b.p, zcol="marks", filename='rasterFPAR2005.htm')
>>>>>>> 621d459f7008dfe615b34e9ba1721b922179eac6

setwd(dir.trabajo) 
red <- readOGR("Redpuntos.shp", "Redpuntos")
red [1:2, 1:11]

setwd(dir.tablas)
write.table(red, file = "Tabla_de_Brasil_para_netica.txt", append = FALSE, quote = TRUE, sep = ",",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"))
setwd(dir.trabajo)

#Tiene proyección?
projection(red)
projection(red) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
#Verifica parametros de proyección
projection(red)
#
Id <- as(red["ID"], "ppp")
Idxy <- as.data.frame(Id)
Idxy[1:10, ]
rasterId <- rasterFromXYZ(Idxy)
projection(rasterId)
projection(rasterId) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterId)
plot(rasterId)
title(main="rasterId", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)

Id <- writeRaster(rasterId, filename=paste(dir.geotiff, "Id.tif", sep=""), format="GTiff", overwrite=TRUE)
#
long <- as(red["X"], "ppp")
longxy <- as.data.frame(long)
longxy [1:2, 1:1]
rasterlong <- rasterFromXYZ(longxy)
projection(rasterlong)
projection(rasterlong) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterlong)
plot(rasterlong)
title(main="Longitud", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
long <- writeRaster(rasterlong, filename=paste(dir.geotiff, "Long_X.tif", sep=""),format="GTiff", overwrite=TRUE)
lat <- as(red["Y"], "ppp")
latxy <- as.data.frame(lat)
latxy [1:2, 1:1]
rasterlat <- rasterFromXYZ(latxy)
projection(rasterlat)
projection(rasterlat) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterlat)
plot(rasterlat)
title(main="Latitud", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
lat <- writeRaster(rasterlat, filename=paste(dir.geotiff, "Lat_Y.tif", sep=""), format="GTiff", overwrite=TRUE)
#
FPAR2005<- as(red["FPAR2005"], "ppp")
FPAR2005 <- as.data.frame(FPAR2005)
FPAR2005
rasterFPAR2005 <- rasterFromXYZ(FPAR2005)
projection(rasterFPAR2005)
projection(rasterFPAR2005) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterFPAR2005)
plot(rasterFPAR2005, col=rainbow(100), axes= TRUE)
title(main="FPAR_2005", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
FPAR2005JLAP <- writeRaster(rasterFPAR2005, filename=paste(dir.geotiff, "FPAR2005.tif", sep=""), format="GTiff", overwrite=TRUE)
FPAR2013<- as(red["FPAR2013"], "ppp")
FPAR2013 <- as.data.frame(FPAR2013)
FPAR2013
rasterFPAR2013 <- rasterFromXYZ(FPAR2013)
projection(rasterFPAR2013)
projection(rasterFPAR2013) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterFPAR2013)
plot(rasterFPAR2013, col=rainbow(100), axes= TRUE)
title(main="FPAR_2013", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
FPAR2013JLAP <- writeRaster(rasterFPAR2013, filename=paste(dir.geotiff, "FPAR2013.tif", sep=""), format="GTiff", overwrite=TRUE)
NDVI2005<- as(red["NDVI2005"], "ppp")
NDVI2005 <- as.data.frame(NDVI2005)
NDVI2005                          
rasterNDVI2005 <- rasterFromXYZ(NDVI2005)
projection(rasterNDVI2005)
projection(rasterNDVI2005) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterNDVI2005)
plot(rasterNDVI2005)
title(main="NDVI_2005", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
NDVI2005JLAP <- writeRaster(rasterNDVI2005, filename=paste(dir.geotiff, "NDVI2005.tif", sep=""), format="GTiff", overwrite=TRUE)
NDVI2013<- as(red["NDVI2013"], "ppp")
NDVI2013 <- as.data.frame(FPAR2013)
NDVI2013                          
rasterNDVI2013 <- rasterFromXYZ(NDVI2013)
projection(rasterNDVI2013)
projection(rasterNDVI2013) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterNDVI2013)
plot(rasterNDVI2013)
title(main="NDVI_2013", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
NDVI2013JLAP <- writeRaster(rasterNDVI2013, filename=paste(dir.geotiff, "NDVI2013.tif", sep=""), format="GTiff", overwrite=TRUE)
LAI2005<- as(red["LAI2005"], "ppp")
LAI2005 <- as.data.frame(LAI2005)
LAI2005                          
rasterLAI2005 <- rasterFromXYZ(LAI2005)
projection(rasterLAI2005)
projection(rasterLAI2005) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterLAI2005)
plot(rasterLAI2005)
title(main="LAI_2005", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
LAI2005JLAP <- writeRaster(rasterLAI2005, filename=paste(dir.geotiff, "LAI2005.tif", sep=""), format="GTiff", overwrite=TRUE)
LAI2013<- as(red["LAI2013"], "ppp")
LAI2013 <- as.data.frame(LAI2013)
LAI2013                          
rasterLAI2013 <- rasterFromXYZ(LAI2013)
projection(rasterLAI2013)
projection(rasterLAI2013) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterLAI2013)
plot(rasterLAI2013)
title(main="LAI_2013", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
LAI2013JLAP <- writeRaster(rasterLAI2013, filename=paste(dir.geotiff, "LAI2013.tif", sep=""), format="GTiff", overwrite=TRUE)
GPP2005<- as(red["GPP2005"], "ppp")
GPP2005 <- as.data.frame(GPP2005)
GPP2005                          
rasterGPP2005 <- rasterFromXYZ(GPP2005)
projection(rasterGPP2005)
projection(rasterGPP2005) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterGPP2005)
plot(rasterGPP2005, col=topo.colors(100), axes= TRUE)
title(main="GPP_2005", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
GPP2005JLAP <- writeRaster(rasterGPP2005, filename=paste(dir.geotiff, "GPP2005.tif", sep=""), format="GTiff", overwrite=TRUE)
GPP2013<- as(red["GPP2013"], "ppp")
GPP2013 <- as.data.frame(GPP2013)
GPP2013                          
rasterGPP2013 <- rasterFromXYZ(GPP2013)
projection(rasterGPP2013)
projection(rasterGPP2013) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterGPP2013)
plot(rasterGPP2013, col=topo.colors(100), axes= TRUE)
box()
title(main="GPP_2013", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
GPP2013JLAP <- writeRaster(rasterGPP2013, filename=paste(dir.geotiff, "GPP2013.tif", sep=""), format="GTiff", overwrite=TRUE)

Brasil <- stack(rasterId, rasterlong, rasterlat, rasterFPAR2005, rasterFPAR2013, rasterNDVI2005, rasterNDVI2013, rasterLAI2005, rasterLAI2013, rasterGPP2005, rasterGPP2013 )
names(Brasil) <- c("ID", "X", "Y", "FPAR2005", "FPAR2013", "NDVI2005", "NDVI2013", "LAI2005", "LAI2013", "GPP2005", "GPP2013")
plot(Brasil)
BrasilJLAP <- writeRaster(Brasil, filename=paste(dir.geotiff, "MultiBandBrasil.tif", sep=""), options="INTERLEAVE=BAND", overwrite=TRUE)

datos <- rasterToPoints(Brasil)
head(datos)

setwd(dir.tablas)
write.table(datos[,c(1:3,6:13)], "brasil_luci.csv", col.names = T, row.names = F, sep=",")
