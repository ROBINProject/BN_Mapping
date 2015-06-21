# Desarrollo de las redes bayesianas.
library(raster)
library(ggplot2)
source("ROBIN - c�digo reutilizable.R")
dir <- ubica.trabajo(equipo="octavio_conabio")

# sub-directorios de inter�s
dir.mapas <- "/Datos RoBiN/Exp Julian/0 BD-vigente/Mapas_base/"
dir.datos <- "/Datos RoBiN/Exp Julian/0 BD-vigente/"
# Integridad --------------------------------------------------------------
{
  # identifica todos los archivos que cumplen con el "patron"
  integridades <- dir(dir.datos, pattern="DE_ZVS_IS_TAN_O")
  
  # Lee los datos de integridad.
  for (i in 1:length(integridades))
  {
    archivo <- paste(dir$datos, integridades[i], sep="/")
    datos <- read.table(archivo, header=TRUE, sep="\t", colClasses="numeric")
    if (i==1) 
      d.int <- data.frame(datos)
    else
      d.int <- cbind(datos.integridad, datos[, 3])
  }
  names(d.int) <- c("x", "y", integridades)
  return(d.int)
}

# Lee todos los archivos que contengan información de integridad en el 
# directorio indicado por "dir.datos" y que contenga la frase en "pattern"
# en el caso de los modelos de diversidad estructural use el pattern DE_ 
integridades <- dir(dir.datos, pattern="DE_ZV")

# Lee datos integridad. Asumo tienen datos "x=lon", "y=lat" e "int" o algo
# parecido que se quiera graficar y en ese orden.  También asumiré que
# todos los archivos tienen los mismos datos "x", "y" y en el mismo orden.
for (i in 1:length(integridades))
{
  archivo <- paste(dir.datos, integridades[i], sep="/")
  datos <- read.table(archivo, header=TRUE, sep="\t", colClasses="numeric")
  if (i==1) 
    datos.integridad <- data.frame(datos)
  else
    datos.integridad <- cbind(datos.integridad, datos[, 3])
  names(datos.integridad[,i]) <- integridades[i]
}
head(datos.integridad)
names(datos.integridad) <- c("x", "y", integridades)

# Defino a mi tabla de integridades como una base de datos espacial
coordinates(datos.integridad) <- ~ x + y
gridded(datos.integridad)=TRUE

head(datos.integridad)


# Módulo de modelos TAN ---------------------------------------------------
# Asumimos que los datos ya están en "datos.integridad" como Large SpatialPixels...
# los nombres de las variables son idénticos a los de los archivos de orígen.
datos.TAN <- datos.integridad

# para hacer el mapa de alguna de las int_EST.  Uso "imagen" como referencia de mapeo.
imagen <- raster(paste(dir.datos,"raster_base_total_16_05_2014.tif",sep=""))
rast.TAN <- raster(datos.TAN[,"red_TAN_EST_m_2_ZV.txt"])
projection(rast.TAN)<-projection(imagen)
extent(rast.TAN)<-extent(imagen)

# Para compartir con Giseros
# Ahora puedo producir el mapa que quiero ***** CUIDAR LOS NOMBRES DE SALIDA *******
rf <- writeRaster(rast.TAN, filename="Red_estructural_TAN_m2.tif", format="GTiff", overwrite=TRUE)

# Mapa para ilustrar, más bonito y control con ggplot, pero a un precio!!!
# Convertir rasters a dataframes para hacerlo con ggplot
rast.TAN.df <- data.frame(rasterToPoints(rast.TAN))
colnames(rast.TAN.df) <- c("x", "y", "int_EST")
head(rast.TAN.df)

#  Crea vectores para diferenciar el color de las clases
c.1 <- seq(min(rast.TAN.df$int_EST),max(rast.TAN.df$int_EST),length.out=5)

#  Grafica la capa de int_EST con ggplot()
p1 <- ggplot()+
  layer(geom="raster", data=rast.TAN.df, mapping=aes(x, y, fill=int_EST))+
  scale_fill_gradientn(name="Integridad Estructural",
                       colours = rev(terrain.colors(100)), breaks=c.1)+
  scale_x_continuous(name=expression(paste("Longitud"))) +
  scale_y_continuous(name=expression(paste("Latitud"))) +
  theme(axis.text.y = element_text(angle=90, hjust=0.5), 
        legend.position = c(0.90, 0.70)) +
  coord_equal()
print(p1)

# Ahora es re fácil guardarlo en cualquier formato como para texto o ppt (tamaño en pulgadas)
# la extensión del archivo indica el tipo de archivo que se guardará.
ggsave("Red_estructural_TAN_m2.png", dpi=300, width=10, height=7)


