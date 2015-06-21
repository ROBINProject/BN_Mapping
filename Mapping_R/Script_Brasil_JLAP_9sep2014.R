########################################################################
#                  Rutina para cargar archivos de la Amazonia          #
#                  ELABORAdo POR: Jose L. Alvarez P.                   #
#                  luis.alvarez@inecol.mx                              #
#                  9 de Septiembre de 2014                                #
#                  RED: Ambiente y Sustentabilidad                     #
#                  INSTITUTO DE ECOLOGIA, A.C.                         #
#                  WWW.inecol.edu.mx                                   #
########################################################################
##Instala paqueterias
install.packages("spatstat", "maptools", "raster", "rgdal", "plotGoogleMaps")

##carga paqueterias
library("raster")
library("rgdal")
library("maptools")
library("spatstat")
library("plotGoogleMaps")
#
goog.dr <- "C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/"
setwd(paste(goog.dr, "Brasil9sep2014", sep=""))
red <- readOGR("Puntosred.shp", "Puntosred")
red[1:2, 1:11]
plot(red)
  
dir.create(paste(goog.dr, "Brasil9sep2014/Tablas", sep=""))
setwd(paste(goog.dr, "Brasil9sep2014/Tablas", sep=""))
write.table(red, file = "Tabla_de_Brasil_para_netica.txt", append = FALSE, quote = TRUE, sep = ",",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"))
#Muestra Área de Estudio en Google Maps
setwd(paste(goog.dr, "Brasil9sep2014", sep=""))
Area_Estudio <- readOGR("AEBrasilPoly.shp", "AEBrasilPoly")
Area_Estudio
AEGOOGLEMAPS<-plotGoogleMaps(Area_Estudio,zcol="Area",filename='Area de Estudio Brasil.htm', 
                             col= "Green", strokeColor="white")
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

rasterId.pnt <- rasterToPoints(rasterId)

title(main="rasterId", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
dir.create("C:/Brasil9sep2014/Geotifs")
Id <- writeRaster(rasterId, filename="C:/Brasil9sep2014/Geotifs/Id.tif", format="GTiff", overwrite=TRUE)
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
long <- writeRaster(rasterlong, filename="C:/Brasil9sep2014/Geotifs/Long_X.tif", format="GTiff", overwrite=TRUE)
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
lat <- writeRaster(rasterlat, filename="C:/Brasil9sep2014/Geotifs/Lat_Y.tif", format="GTiff", overwrite=TRUE)
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
FPAR2005JLAP <- writeRaster(rasterFPAR2005, filename="C:/Brasil9sep2014/Geotifs/FPAR2005.tif", format="GTiff", overwrite=TRUE)
#
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
FPAR2013JLAP <- writeRaster(rasterFPAR2013, filename="C:/Brasil9sep2014/Geotifs/FPAR2013.tif", format="GTiff", overwrite=TRUE)
#
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
NDVI2005JLAP <- writeRaster(rasterNDVI2005, filename="C:/Brasil9sep2014/Geotifs/NDVI2005.tif", format="GTiff", overwrite=TRUE)
#
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
NDVI2013JLAP <- writeRaster(rasterNDVI2013, filename="C:/Brasil9sep2014/Geotifs/NDVI2013.tif", format="GTiff", overwrite=TRUE)
#
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
LAI2005JLAP <- writeRaster(rasterLAI2005, filename="C:/Brasil9sep2014/Geotifs/LAI2005.tif", format="GTiff", overwrite=TRUE)
#
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
LAI2013JLAP <- writeRaster(rasterLAI2013, filename="C:/Brasil9sep2014/Geotifs/LAI2013.tif", format="GTiff", overwrite=TRUE)
#
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
GPP2005JLAP <- writeRaster(rasterGPP2005, filename="C:/Brasil9sep2014/Geotifs/GPP2005.tif", format="GTiff", overwrite=TRUE)
#
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
GPP2013JLAP <- writeRaster(rasterGPP2013, filename="C:/Brasil9sep2014/Geotifs/GPP2013.tif", format="GTiff", overwrite=TRUE)
#
Tipologia <- as(red["Tipologia"], "ppp")
Tipologia <- as.data.frame(Tipologia)
Tipologia                          
rasterTipologia <- rasterFromXYZ(Tipologia)
projection(rasterTipologia)
projection(rasterTipologia) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterTipologia)
plot(rasterTipologia, col=topo.colors(100), axes= TRUE)
title(main="Tipologia", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
TipologiaJLAP <- writeRaster(rasterTipologia, filename="C:/Brasil9sep2014/Geotifs/Tipologia.tif", format="GTiff", overwrite=TRUE)
#
Prpanual <- as(red["Prpanual"], "ppp")
Prpanual <- as.data.frame(Prpanual)
Prpanual                          
rasterPrpanual <- rasterFromXYZ(Prpanual)
projection(rasterPrpanual)
projection(rasterPrpanual) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
projection(rasterPrpanual)
plot(rasterPrpanual, col=topo.colors(100), axes= TRUE)
title(main="Prpanual", font.main = 6)
mtext("Jose L. Alvarez", side=2, line=2, at=2, cex=0.9, font=3)
GPP2005JLAP <- writeRaster(rasterPrpanual, filename="C:/Brasil9sep2014/Geotifs/Prpanual.tif", format="GTiff", overwrite=TRUE)
#
Brasil <- stack(rasterId, rasterFPAR2005, rasterFPAR2013, rasterNDVI2005, rasterNDVI2013, 
                rasterLAI2005, rasterLAI2013, rasterGPP2005, rasterGPP2013, rasterTipologia, rasterPrpanual)
names(Brasil) <- c("ID", "FPAR2005", "FPAR2013", "NDVI2005", "NDVI2013", "LAI2005", "LAI2013", "GPP2005", "GPP2013", "Tipologia", "Prpanual")
plot(Brasil[[2:11]])
BrasilJLAP <- writeRaster(Brasil, filename="C:/Brasil9sep2014/Geotifs/MultiBandBrasil.tif", options="INTERLEAVE=BAND", overwrite=TRUE)

Brasil.pnt <- data.frame(rasterToPoints(Brasil))
Brasil.pnt <- Brasil.pnt[complete.cases(Brasil.pnt),]
Brasil.pnt$Tipologia <- as.integer(Brasil.pnt$Tipologia)
head(Brasil.pnt)
write.table(Brasil.pnt, "./Tablas/Tabla_de_Brasil_para_netica.csv", sep=",", col.names=T, row.names=F)

br <- rasterFromXYZ(Brasil.pnt)
plot(br)
