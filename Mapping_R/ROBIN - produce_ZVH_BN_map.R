# @author Miguel Equihua 
# contact: equihuam@gmail.com
# Institution: Inecol
#
#  Read output from NETICA to prudce maps of ZVH_NB
#
source("ROBIN - código reutilizable.R")
dir <- ubica.trabajo(equipo="miguel_tab")

# Reference map: DEM from CONABIO in GD
dir.ref <- paste(dir$GIS.in, "/2004", sep="")
mapas.base <- dir(dir.ref, pattern = "tif$")
arch.ref <- paste(dir.ref, mapas.base[grepl("mean", mapas.base)], sep="/")
mapa.ref <- raster(arch.ref)
mapa.ref[mapa.ref==-999] <- NA
gama.valores <- range(values(mapa.ref),na.rm = T)
plot(mapa.ref)

# read data table with NETICA data
arch.netica  <- dir(dir.ref, pattern = "ZVH.+\\.csv$")
datos.netica.c1 <- read.csv(header = T, sep ="\t", paste(dir.ref, 
                            arch.netica[grepl("c1", arch.netica)], sep="/"))
datos.netica.map <- read.csv(header = T, sep ="\t", paste(dir.ref, 
                            arch.netica[grepl("map", arch.netica)], sep="/"))

# Clean the names of the variables
names.variables <- names(datos.netica.c1) 
names.variables <- unlist(lapply(names.variables, function (name) 
          {l = strsplit(name,"\\.");l = l[[1]][length(l[[1]])]; unlist(l)}))
names(datos.netica.c1) <- names.variables
names(datos.netica.map) <- names.variables

# Identify ZVH_BN with maximum probability
zz.var <- integer()
zz.sum <- numeric()
for (i in (1:length(datos.netica.map$x)))
{
  zz.sum <- 1 - sum(datos.netica.map[i, 3:13])
  zz.var[i] <- which.max(datos.netica.map[i, 3:13])
}

datos.netica.c1$ZVH_BN <- apply(datos.netica.c1[,3:13], 1, 
                                 function(x) which.max(x))
datos.netica.map$ZVH_BN <- apply(datos.netica.map[,3:13], 1, 
                                 function(x) which.max(x))

identical(zz.var, datos.netica.map$ZVH_BN)

identical(zz.var, datos.netica.map$ZVH_BN)

# preparare map data for mapping
# Read coordinates from the map file used to produced the NETICA results
datos.netica.map[,1:2] <- climat.2.df@coords
head(datos.netica.map)
coordinates(datos.netica.map) <- ~ x + y
gridded(datos.netica.map) <- T
head(datos.netica.map)

# Generate the ZHV_BN map
rast_netica.map <- raster(datos.netica.map[,"ZVH_BN"])
projection(rast_netica.map) <- projection(mapa.ref)
plot(rast_netica.map)

# Create the Geo-tiff for GIS use
map.arch <-paste(dir.ref, "ZVH_RB_Mex.tif", sep="/")
rf <- writeRaster(rast_netica.map, filename=map.arch, 
                  format="GTiff", overwrite=TRUE)
