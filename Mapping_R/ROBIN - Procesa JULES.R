# @author Miguel Equihua 
# contact: miguel.equihua@inecol.mx
# Institution: Inecol
#
# Description provided by Iwona Cisowska (iwncis@ceh.ac.uk) 
#
# Run received on 5th June, 2014
#
# The first output will be shown for the year 1953, so 2000 => tstep = 47.
# The output file contains the output for 22 variables: 
#    cs, cv, fwetl, litcmn, cvegp, canhtp, gleafp, laip, laiphenp, litcp, 
#    nppdroutp, respwdroutp, frac , smcl, nppp, resps, runoff, subsurfroff, 
#    surfroff,  canopy, precip , and ecan. 
# Bear in mind that this run used the observed land cover mode (the model
# uses a vegetation map which is based on observations) so vegetation types
# and soil carbon are imposed (i.e. DGVM (Dynamic Global Vegetation Model) is not
# used in this run). It basically means that vegetation types will not compete
# in this run and value of e.g. cs will be the same for the whole area (the 
# prescribed value assumed as the initial state of the run).

# Preparación ----------------------------------------------------------------
source("ROBIN - código reutilizable.R")
library(ncdf4)

# Ubicación del archivo de datos NCDF de JULES
dir <- ubica.trabajo(equipo="miguel_tab")
dir.jules <- paste(dir$datos, "/JULES/", sep="")
archivo.jules <- paste(dir.jules, "r1_LC.an.ann.nc", sep="")

# Lee el archivo de datos
datos.jules <- nc_open(archivo.jules) 

# ve que trae!!!!!
datos.jules
summary(datos.jules)

# Tomo nota de los nombres de las variables en el archivo.
variables.jules <- sapply(1:datos.jules$nvars, function (i) 
  definicion.vars.JULES(datos.jules, i, sep=" "))
variables.jules

# recupero lo que me interesa
lat <- ncvar_get(datos.jules,"lat")
lon <- -ncvar_get(datos.jules, "lon")

# Variables con Tres dimensiones: [x,y,tstep] 
cs <- arregla.datos.NC(datos.jules, "cs", 30)
cv <- arregla.datos.NC(datos.jules, "cv", 30)
fwetl <- arregla.datos.NC(datos.jules, "fwetl", 30)
litCMn <- arregla.datos.NC(datos.jules, "litCMn", 30)
runoff <- arregla.datos.NC(datos.jules, "runoff", 30)

# ¿Cómo andan los datos?
data.frame(cs = range(cs, na.rm=T), cv = range(cv, na.rm=T), 
           fwetl = range(fwetl, na.rm=T), litCMn = range(litCMn, na.rm=T))

# Cuatro dimensiones: [x,y,pft/type,tstep] 
cVegP <- arregla.datos.NC(datos.jules, "cVegP", 1, 1)
canhtP <- arregla.datos.NC(datos.jules, "canhtP", 1, 1)
gLeafP <- arregla.datos.NC(datos.jules, "gLeafP", 1, 1)
laiP <- arregla.datos.NC(datos.jules, "laiP", 1, 1)
laiPhenP <- arregla.datos.NC(datos.jules, "laiPhenP", 1, 1)
litCP <- arregla.datos.NC(datos.jules, "litCP", 1, 1)
nppDrOutP <- arregla.datos.NC(datos.jules, "nppDrOutP", 1, 1)
nppP <- arregla.datos.NC(datos.jules, "nppP", 1, 1)
respWDrOutP <- arregla.datos.NC(datos.jules, "respWDrOutP", 1, 1)

# ¿Cómo andan los datos?
data.frame(cVegP = range(cVegP, na.rm=T),
           canhtP = range(canhtP, na.rm=T),
           gLeafP = range(gLeafP, na.rm=T),
           laiP = range(laiP, na.rm=T),
           laiPhenP = range(laiPhenP, na.rm=T),
           litCP = range(litCP, na.rm=T),
           nppDrOutP = range(nppDrOutP, na.rm=T),
           nppP = range(nppP, na.rm=T),
           respWDrOutP = range(respWDrOutP, na.rm=T))


# Datos Vege y área foliar para NETICA ----------------------------

# Recupera los datos de tipos de vegetación "frac"
# 
# PFT  Standars JULES
#  1	  broadleaf trees
#  2	  needle-leaf trees
#  3	  C3 (temperate) grasses
#  4	  C4 (tropical) grasses
#  5	  shrubs
#  6    urban
#  7    open water
#  8    bare soil
#  9    permanent land ice

# Selección de año a recuperar en términos de tstep. Año 2000 => tstep 47:
year <- 47

# Lee raster de referencia para proyección y extensión
raster_base <- raster(paste(dir$mapas,"rf_afust.tif",sep="/"))

# There is no permanent ice in our region!!!!
vege.nomb <- c("broadleaf trees", "needle-leaf trees", 
              "C3 (temperate) grasses", "C4 (tropical) grasses", "shrubs",
              "urban", "open water", "bare soil")

frac <- lapply(1:8, function(i) arregla.datos.NC(datos.jules, "frac", year, i))

frac.r <- lapply(1:8, function(capa)
                       raster(frac[[capa]], 
                                xmn=range(-lon)[1], xmx=range(-lon)[2],
                                ymn=range(lat)[1], ymx=range(lat)[2], 
                                crs=CRS("+proj=longlat +datum=WGS84")))

# Re-proyecta y hace compatibles las retículas
frac.r.ie <- lapply(1:8, function (capa)
                         projectRaster(from=frac.r[[capa]], 
                                       to=raster_base, method="bilinear"))

# Datos de PFT leaf area index.  Sólo hay 5 tipos de vegetación.
# ‘PFT’ means plant functional type (describes the vegetation composition 
# in a gridbox).
# La lectura los deja en el mismo orden de entrada, así que laiP_1 es el área
# foliar promedio en "broadleaf trees" en este caso.
laiP <- lapply(1:5, function(i) arregla.datos.NC(datos.jules, "laiP", year, i))

laiP.r <- lapply(1:5, function(capa)
                      raster(laiP[[capa]], 
                             xmn=range(-lon)[1], xmx=range(-lon)[2],
                             ymn=range(lat)[1], ymx=range(lat)[2], 
                             crs=CRS("+proj=longlat +datum=WGS84")))

laiP.r.ie <- lapply(1:5, function (capa)
                          projectRaster(from=laiP.r[[capa]], 
                                        to=raster_base, method="bilinear"))

# Apila las capas
miguel.stack <- brick()
for (i in 1:8) miguel.stack <- addLayer(miguel.stack, frac.r.ie[[i]])
for (i in 1:5) miguel.stack <- addLayer(miguel.stack, laiP.r.ie[[i]])
names(miguel.stack) <- c(paste("veg", 1:8, sep="_"), paste("laiP", 1:5, sep="_"))


# Armado de la tabla de datos con todas las capas -------------------------
datos <- rasterToPoints(miguel.stack, progress="window")
datos <- datos[complete.cases(datos),]

# lee datos integridad para igualar la cobertura de las tablas
temp.ie <- lee.integridades(dir$datos, patron="^DVH_ZVS_IS_NAIVE_M_30")
length(datos)
length(temp.ie[,1])

# Combina los conjuntos para extraer los que empata entre los dos
dat <- merge(temp.ie, datos)
length(dat[,1])
names(dat)
dat <- dat[c(1,2,4:16)]
write.table(dat, paste(dir$datos, "JULES_vege_laiP.txt", sep="/"), sep="\t", row.names=FALSE)

# Completa las muestras
arch.data.set <- dir(dir$datos, pattern="^data")
data.set <- read.table(paste(dir$datos, arch.data.set[1], sep="/"), sep=",", header=T)
names(data.set)
length(data.set[,1])
temp.dat <- merge(data.set, dat)
length(temp.dat[,1])
