library (raster)
library(ggplot2)
library(rgdal)

# Ubicación de los archivos
dir.ArcGis <- "C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Brasil/Luci/Tipologia_climatica/tipologia"
dir.maggi <- "C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Brasil/Maggi"

# Lectura de archivos de ArcGis en su formato raster "adf"
p <- paste (dir.ArcGis, "w001001.adf", sep="/")
x <- new("GDALReadOnlyDataset",p)
image(x[])

p <- paste (dir.ArcGis, "tipologia/w001001x.adf", sep="/")
x2<- new("GDALReadOnlyDataset",p)
image(x2[])

summary(x)
spplot(x2)
GDAL.close(x)
x
x.im <- x

x <- raster(p)
extent(x)
gridded(x)
projection(x)
plot(x)
head(coordinates(x))

# Resultados de Integridad para Brasil
a.int <- lee.integridades(dir.maggi, patron="dade).txt$")
names(a.int) <- c("x", "y", "IE")

# Convierto la tabla en una tabla espacial con retícula irregular en este caso.
coordinates(a.int) <- ~ x + y
gridded(a.int) <- FALSE

# Como los datos de Maggi son una retícula irregular hay que "rasterizarlos"
# e igualarlos con alguna retícula de referencia, en este caso uso la que
# tiene Luci en los datos climatológicos

# Asigna la resolución deseada para el mapa final
# El raster de referencia debe ser "blanco" si se quiere que sólo
# la ingformación proporcionada se refleje en el resultado. Eso lo hago
# produciendo una copia a la que le pongo valores iguales con la función "values"
# y usa un valor que no interfiera. En todo caso se puede usar la función de
# asignación "last", para llenar el raster con los valores de la capa de puntos.
# Por si quiero alterar la resolcuión del mapa puedo usar "res".
rr <- x
values(rr) <- 1

res(rr) <- 0.009
a.x <- rasterize(x=a.int, y=rr, field="IE", fun="last")
plot(a.x)
projection(x)

# Genera el mapa en geoTIFF
af <- writeRaster(a.x, filename="maggi.tif", format="GTiff", overwrite=TRUE)
head(a.x$layer)

# Genera el mapa con ggplot2
r.df <- data.frame(rasterToPoints(a.x))
a.q <- mapa.ggplot(a.x, etiqueta="Integridad")
plot(a.q)

# Guardarlo en cualquier formato como para texto o ppt. 
ggsave(paste(dir$GIS.out, "maggi.jpg", sep="/"), dpi=300, units="cm",  width=25, height=18)
