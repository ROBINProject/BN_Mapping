# Lectura de los datos que envió Maggie en formato dbf
library("foreign")
library(shapefiles)

# Lee y prepara el paquete de herramientas ROBIN
source("ROBIN - código reutilizable.R")
dir <- ubica.trabajo(equipo="miguel_tab")
dir.goo <- substr(dir$base,1, regexpr("/Datos", dir$base)[[1]])
datos.maggie <- "Datos RoBiN/Brasil/Maggie" 
carpeta <- file.path(dir.goo, datos.maggie)
dbf <- file.path(carpeta, "DadosFinais.dbf")

datos.brasil <- read.dbf(file=dbf)
str(datos.brasil)
summary(datos.brasil)
head(datos.brasil)

extremos.brasil <- apply(datos.brasil[,c(2:38)], 2, range)
row.names(extremos.brasil) <- c("min", "max") 
t(extremos.brasil)
