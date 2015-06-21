# @author Julián Equihua 
# contact: julian.equihua@conabio.gob.mx
# Institution: CONABIO
# Modificado por
#   @author Miguel Equihua 
#   contact: equihuam@gmail.com
#   Institution: Inecol

# Lee y prepara el paquete de herramientas ROBIN
source("ROBIN - código reutilizable.R")
dir <- ubica.trabajo(equipo="miguel_tab")

# Lectura de un Geo-TIFF para futura referencia ---------------------------

# Leo y grafico el tiff deseado. En este caso altura de fustes
dir(dir$GIS.in, pattern="^rf")
imagen <- raster(paste(dir$GIS.in,"rf_afust.tif",sep="/"))
extent(imagen)
projection (imagen)
plot(imagen)

# Procesamiento datos de integridad y mapeo -----------------------------
dir(dir$datos, "^DVH18_ZVS_IS_N")
datos.integridad <- lee.integridades(dir$datos, patron="^DVH18_ZVS_IS_N")
head(datos.integridad)
names(datos.integridad)

# Esto está más dificil de generalizar, pero sirva como para coleccionar
# ejemplos de lo que se puede hacer una vez que se tienen los datos en R

# Esto aplica sólo para el caso de delta vp, para normalizarla entre 0 y 1
datos.integridad[,3] <- 1 - datos.integridad[,3] / 18
# enorme <- data.frame(read.table(file=paste(dir$datos,"Base_Enorme_cc.csv", sep="/"), header=T, sep=","))
# corrs <-cor(cbind(datos.integridad[, 3:32], enorme$delt_vp_norm))
# write.table(corrs, "corrs.csv",sep=",", col.names=T)
# corrs[31,]

#excel.copia.clip_desde_R(correlaciones)

# Defino mi tabla de integridades como una base de datos espacial
coordinates(datos.integridad) <- ~ x + y
gridded(datos.integridad) <- TRUE
head(datos.integridad)

# Genera los mapas en GeoTIFF y los guarda en el directorio indicado
for (i in 1)
{
  rast_es <- raster(datos.integridad[,i])
  projection(rast_es) <- projection(imagen)

  # Generar un Geo-tiff compacto, para uso en GIS
  map.arch <-paste(dir$GIS.out, names(datos.integridad)[i], sep="/")
  rf <- writeRaster(rast_es, filename=map.arch, format="GTiff", overwrite=TRUE)
}

# Arma una pila de mapas -------------------------------

rast_es  <- raster(datos.integridad)
dim(rast_es)
for (i in 2:30) rast_es <- stack(rast_es, raster(datos.integridad[,i]))
nlayers(rast_es)
projection(rast_es) <- projection(imagen)

# Ahora puedo producir el mapa que quiero sencillamente así
plot(rast_es[[1]], main="Integrity")
names(rast_es)

# Mapeo con la biblioteca ggplot con buena calidad y estética
pa1 <- mapa.ggplot(rast_es[[1]], etiqueta="Integridad")
print(pa1)

# Guardarlo en cualquier formato como para texto o ppt. 
# El formato lo especifica directamente la extensión usada:
# eps/ps, tex (pictex), pdf, jpeg, tiff, png, bmp, svg and wmf (windows only)
ggsave(paste(dir$GIS.out, "DVH18_ZVS_IS_NAIVE_M_1.jpg", sep="/"), dpi=300, units="cm",  width=25, height=18)

# Desplegar sobrepuesto en google earth -----------------------------------

# Conversión a la proyección apropiada para Google Earth
rlatlong <- projectRaster(rast_es$DVH_ZVS_IS_NAIVE_M_1.txt, crs=CRS("+proj=longlat +datum=WGS84"))

# write as KML
# KML es muy simplede usar pero no logro hacer fondo transparente
KML(rlatlong, filename='mapa_miguel.kml',maxpixels=2000000, 
    overwrite=TRUE, colNA=NA)

# La biblioteca "plotKML" sí lo hace pero hay que instalar varias 
# cosas para que funcione eficientemente.
plotKML(rast_es[[1]], colour="DVH_ZVS_IS_NAIVE_M_1.txt", filename='mapa_miguel.kml', 
        colour_scale=rev(terrain.colors(255)))

# despliega el mapa sobrepuesto en google maps
library(dismo)
delme <- gmap(x = rast_es[[1]], type = "satellite", zoom = 4)
rf.gm <- projectRaster(from = rlatlong, crs = crs(delme))
range(rf.gm)
# rf.gm[rf.gm < 0] <- 0
# rf.gm[rf.gm > 1] <- 1

plot(delme)
plot(rf.gm, add = T, legend = F, col = rev(rainbow(10, alpha = 0.4)))
library(Cairo)

# Uso de biblioteca bnlearn -----------------------------------------------

read.net(paste(dir$datos, "Base_Enorme_DVH_ZVS_IS_NAIVE_M.dne", sep="/"))

# Ganado y agricultura ----------------------------------------------------
dir$bovino <- paste(dir$datos,"/../bovino", sep="")
ganado <- raster(paste(dir$bovino,"/bov_km2.tif",sep=""))
plot(ganado)

