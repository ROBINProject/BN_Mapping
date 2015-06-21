#---------------------------------------------
# @author Miguel Equihua 
# contact: equihuam@gmail.com
# Institution: Inecol
#---------------------------------------------

library (ggplot2)
library(reshape)
library(maptools)

# Lee y prepara el paquete de herramientas ROBIN
setwd("C:/Users/Miguel/Documents/0 Versiones/2 Proyectos/I+ROBIN/Interp y redes (R)/Exp-Juls")
source("ROBIN - código reutilizable.R")
dir <- ubica.trabajo(equipo="miguel_tab")

# lee tipología directamente
tipologia <- raster("C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/Brasil9sep2014/DatosBase/tipologia/w001001.adf")
plot(tipologia)
plot(wrld_simpl, add=TRUE)

# La convierto en una capa como categórica
tipologia.char <- c("Af1", "Af2", "Af3", "Am1", "Am2", 
                    "Am3", "Am4", "Aw3", "Aw4", "Aw5")
tip <- as.factor(tipologia)
is.factor(tip)
tip.cod <- levels(tip)[[1]]
tip.cod$code <- tipologia.char
levels(tip) <- tip.cod
tipologia <- tip
tipologia
plot(tipologia, type = )
rr <- writeRaster(tipologia, 'test.tif', format="GTiff", overwrite=TRUE)

slope <- raster("C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/base_de_datos/DatosBase/Raster_formato.GRD/slope_al/w001001x.adf")
projection(slope)
extent(slope)
res(slope)
plot(slope)

prpanual <- raster("C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/base_de_datos/DatosBase/prpanual/w001000x.adf")
projection(prpanual)
extent(prpanual)
res(prpanual)
plot(prpanual)

# Igualar las capas en cuanto a proyección, extensión y resolución
pr.temp.2 <- projectRaster (from=slope, to=prpanual)
projection(pr.temp)
extent(pr.temp)
res(pr.temp)


pr.temp.2 <- projectExtent()


setwd("C:/Users/Miguel/Documents/0 Versiones/2 Proyectos/I+ROBIN/Interp y redes (R)/Exp-Juls")
dir(dir$GIS.in, pattern="^bra")
map.ref <- raster(paste(dir$GIS.in,"brasil-FPAR2013.tif",sep="/"))
plot(map.ref)

# Lee datos de Potencial de Biodiversidad
dir(dir$datos, "^Bra")
bra.int <- lee.integridades(dir$datos, patron="^Bra")
head(bra.int)
names(bra.int) <- c("x", "y", "bio2", "bio4")

# Lee datos de variables indicadoras
arch.dat <- "C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/Brasil9sep2014/Tablas/Tabla_de_Brasil_para_netica.csv"
datos <- read.table(arch.dat, sep=",", header = T)
datos$bio.pot <- bra.int$bio2
datos$bio.pot.4 <- bra.int$bio4
head (datos)

# guarda la base de datos aumentada con BioPot
arch.dat <- "C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/Brasil9sep2014/Tablas/Brasil_Luci_netica.csv"
write.csv(datos, arch.dat, row.names=F)

# Correlaciones de BioPot dentro de cada tipologia climática
bra.cor.4 <- data.frame(sapply(1:10, function (i) cor(datos[datos$Tipologia==i,c(4:11, 13:15)])[,11]))
names(bra.cor.4) <- paste("Tipo_", 1:10, sep="")
bra.cor.4$indic <- row.names(bra.cor.4)
bra.cor.4 <- bra.cor.4[1:10,]
bra.cor.4.m <- melt(bra.cor.4, variable_name = "Tipologia")
graf.4 <- ggplot(bra.cor.4.m, aes(indic, Tipologia)) + 
  geom_tile(aes(fill = value), colour = "white") + 
  scale_fill_gradient(low = "yellow", high = "red", guide = "colourbar")+
  labs(x = "", y = "", title="Correlations BioPot (4)") +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) + 
  theme_grey(base_size = 10) + 
  theme(legend.position = "right", axis.ticks = element_blank(), 
        axis.text.x = element_text(size = 10 * 0.8, angle = 310, 
                                   hjust = 0, colour = "grey50"))
graf.4

bra.cor.2 <- data.frame(sapply(1:10, function (i) cor(datos[datos$Tipologia==i,c(4:11, 13:15)])[,10]))
names(bra.cor.2) <- paste("Tipo_", 1:10, sep="")
bra.cor.2$indic <- row.names(bra.cor.2)
bra.cor.2 <- bra.cor.2[c(1:9,11),]
bra.cor.2.m <- melt(bra.cor.2, variable_name = "Tipologia")
graf.2 <- ggplot(bra.cor.2.m, aes(indic, Tipologia)) + 
            geom_tile(aes(fill = value), colour = "white") + 
            scale_fill_gradient(low = "yellow", high = "red")+
            labs(x = "", y = "", title="Correlations BioPot (2)") +
            scale_x_discrete(expand = c(0, 0)) +
            scale_y_discrete(expand = c(0, 0)) + 
              theme_grey(base_size = 10) + 
              theme(legend.position = "right", axis.ticks = element_blank(), 
                    axis.text.x = element_text(size = 10 * 0.8, angle = 310, 
                                               hjust = 0, colour = "grey50"))
graf.2

# 
#map.ref.spa <- data.frame(rasterToPoints(map.ref))
#head(map.ref.spa)

# Genera estructura espacial a partir de los datos de integridad leidos
coordinates(bra.int) <- ~ x + y
gridded(bra.int) <- FALSE
head(bra.int)
bra.int$bio <- 100 - bra.int$bio

# Genera el mapa de integridad
bra.int.ras <- rasterize(x=bra.int, y=map.ref, field="bio4", fun="last")
projection(bra.int.ras) <- projection(map.ref)
plot(bra.int.ras, main="BioPot")
bra.int.ras
arch.tif <- "C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/Brasil9sep2014/Geotifs/Brasil_Luci_netica4.tif"
tif <- writeRaster(bra.int.ras, filename=arch.tif, format="GTiff", overwrite=TRUE)

# Mapeo con la biblioteca ggplot con buena calidad y estética
bra.int.ras.map <- mapa.ggplot(bra.int.ras, etiqueta="BioPot", c(0.95,0.15))
print(bra.int.ras.map)

arch.map <- "C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/Brasil9sep2014/Brasil_Luci_netica4.pdf"
ggsave(plot = bra.int.ras.map, filename = arch.map)

