# Acceso y manejo de datos de archivos tipo "nc"
# fuente: https://www.image.ucar.edu/GSP/Software/Netcdf/
library(ncdf4)

ejemplo.nc <- nc_open("example.nc")
print(ejemplo.nc)
summary(ejemplo.nc)

# Obtención de los datos deseados
y <- ncvar_get(ejemplo.nc, "SN")          # coordinate variable
x <- ncvar_get(ejemplo.nc, "EW")          # coordinate variable
z <- ncvar_get(ejemplo.nc, "Elevation")   # variable

# Ahora grafico los datos que son del ejemplo topográfico de un volcán
filled.contour(x,y,z, color = terrain.colors, asp = 1)

# Se puede sacar sólo un poco de los datos a placer!!!
# The hottest topic in the netCDF user community right now is "large file" 
# support. In the GCM community, a "large file" is over 2GB, anything less 
# that that is "just a file" ...
z1 = ncvar_get(ejemplo.nc, "Elevation", start=c(11,26), count=c( 5,5))
head(z1)

# como comparan z y z1??
sapply(list(z,z1), length)
data.frame(z[11:15, 26:30],sep=rep("|", times=5), z1)

# ahora los datos de JULES
# Ubicación de datos ------------------------------------------------------
# Preparación de donde leer los archivos de datos, estoy suponiendo que estÃ¡n accesibles 
# en el equipo local mediante la aplicación GoogleDrive respectiva.

source("ROBIN - código reutilizable.R")
dir <- ubica.trabajo(equipo="miguel_tab")


# combina la información de ubicación que me convenga
# "r1_LC.an.ann.nc" contains annual output
# The run was done for: dates: 1952-2002, spatial extent: 120W to 30W 
# and 25S to 33N (Meso America and a part of South America). This first 
# model run used the observed land cover mode (the model uses a vegetation
# map which is based on observations).
dir.jules <- paste(dir$datos, "/JULES/", sep="")
archivo.jules <- paste(dir.jules, "r1_LC.an.ann.nc", sep="")

# Leo el archivo de datos
datos.jules <- nc_open(archivo.jules) 

# veo que trae!!!!!
print(datos.jules)
summary(datos.jules)


# Tomo nota de los nombres de las variables en el archivo.
variables.jules <- sapply(1:datos.jules$nvars, function (i) 
  definicion.vars.JULES(datos.jules, i))
write.table(data.frame(variables.jules), "variables_JULES.csv", sep=",")



# recupero lo que me interesa
lat <- ncvar_get(datos.jules,"lat")
lon <- -ncvar_get(datos.jules, "lon")

# Tres dimensiones: [x,y,tstep] 
cs <- arregla.datos.JULES(datos.jules, "cs", 30)
cv <- arregla.datos.JULES(datos.jules, "cv", 30)
fwetl <- arregla.datos.JULES(datos.jules, "fwetl", 30)
litCMn <- arregla.datos.JULES(datos.jules, "litCMn", 30)
runoff <- arregla.datos.JULES(datos.jules, "runoff", 30)

for (i in 1:50)
{
  if (i==1)
    cs.df <- arregla.datos.JULES(datos.jules, "cs", i)
  else
    cs.df <- cbind(arregla.datos.JULES(datos.jules, "cs", i))
}

# ¿Cómo andan los datos?
data.frame(range(cs, na.rm=T), range(cv, na.rm=T), range(fwetl, na.rm=T),
           range(litCMn, na.rm=T))

# Cuatro dimensiones: [x,y,pft,tstep] 
cVegP <- arregla.datos.JULES(datos.jules, "cVegP", 1, 1)
canhtP <- arregla.datos.JULES(datos.jules, "canhtP", 1, 1)
gLeafP <- arregla.datos.JULES(datos.jules, "gLeafP", 1, 1)
laiP <- arregla.datos.JULES(datos.jules, "laiP", 1, 1)
laiPhenP <- arregla.datos.JULES(datos.jules, "laiPhenP", 1, 1)
litCP <- arregla.datos.JULES(datos.jules, "litCP", 1, 1)
nppDrOutP <- arregla.datos.JULES(datos.jules, "nppDrOutP", 1, 1)
nppP <- arregla.datos.JULES(datos.jules, "nppP", 1, 1)
respWDrOutP <- arregla.datos.JULES(datos.jules, "respWDrOutP", 1, 1)
frac <- arregla.datos.JULES(datos.jules, "frac", 1, 3)

# ¿Cómo andan los datos?
data.frame(cVegP = range(cVegP, na.rm=T),
           canhtP = range(canhtP, na.rm=T),
           gLeafP = range(gLeafP, na.rm=T),
           laiP = range(laiP, na.rm=T),
           laiPhenP = range(laiPhenP, na.rm=T),
           litCP = range(litCP, na.rm=T),
           nppDrOutP = range(nppDrOutP, na.rm=T),
           nppP = range(nppP, na.rm=T),
           respWDrOutP = range(respWDrOutP, na.rm=T),
           frac = range(frac, na.rm=T))


# Prepara el mapa
r <-raster(runoff,
           xmn=range(-lon)[1], xmx=range(-lon)[2],
           ymn=range(lat)[1], ymx=range(lat)[2], 
           crs=mex.proj)
plot(r, main="runoff")

frac.r <-raster(frac,
           xmn=range(-lon)[1], xmx=range(-lon)[2],
           ymn=range(lat)[1], ymx=range(lat)[2], 
           crs=CRS("+proj=longlat +datum=WGS84"))

frac.r.ie <- projectRaster(to=frac.r, from=raster_base, method="ngb")

# projection (frac.r) <- projection(raster_base)
# plot(frac.r, main="frac.r")
frac.r.ie <- projectRaster(from=frac.r, to=raster_base, method="ngb")
# extent(frac.r.ie) <- extent(raster_base)
# plot(frac.r.ie, main="frac.r.ie")
# plot(raster_base)

writeRaster(raster_base, filename="base.tif", format="GTiff")
writeRaster(frac.r.ie, filename="JULES_3.tif", format="GTiff")

tabla_datos <- rasterToPoints(frac.r.ie)
head(tabla_datos)
length(tabla_datos)

library(plotKML)
names(frac.r.ie) <- "JULES_frac_1"

plotKML(frac.r.ie, colour="JULES_frac_1", filename="JULES-r.kml", colour_scale=rev(terrain.colors(255)))

projection(r) <- projection(raster_base)
extent(r) <- extent(imagen)

rlatlong <- projectRaster(r, crs=CRS("+proj=longlat +datum=WGS84"))
plotKML(rlatlong, colour="layer", filename='JULES-r.kml', 
        colour_scale=rev(terrain.colors(255)))
names(rlatlong)
