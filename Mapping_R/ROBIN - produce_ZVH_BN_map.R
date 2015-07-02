# @author Miguel Equihua 
# contact: equihuam@gmail.com
# Institution: Inecol
#
#  Read output from NETICA to prudce maps of ZVH_NB
#
source("ROBIN - código reutilizable.R")
dir <- ubica.trabajo(equipo="miguel_tab")

# Reference map: Bovine numbers from CONABIO in GD
dir.ref <- dir$GIS.in
mapas.base <- dir(dir.ref, pattern = "tif$")
arch.ref <- paste(dir.ref, mapas.base[grepl("bov", mapas.base)], sep="/")
mapa.ref <- raster(arch.ref)
gama.valores <- range(values(mapa.ref),na.rm = T)
plot(mapa.ref)

# read data table with NETICA data
dir.ref <- paste(dir.ref,"/2004", sep = "")
arch.netica  <- dir(dir.ref, pattern = "out.+\\.csv$")
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
datos.netica.c1$ZVH_BN <- apply(datos.netica.c1[,3:13], 1, 
                                 function(x) which.max(x))
datos.netica.map$ZVH_BN <- apply(datos.netica.map[,3:13], 1, 
                                 function(x) which.max(x))

# preparare map data for mapping
# Read coordinates from the map file used to produced the NETICA results
datos.netica.map[,1:2] <- climat.2.df@coords
head(datos.netica.map)
coordinates(datos.netica.map) <- ~ x + y
gridded(datos.netica.map) <- T
head(datos.netica.map)

# Put all variables and estimates of ZVH together and write the table
datos.zvh.clima <- cbind(climat.2.df@data, datos.netica.map@data)
coordinates(datos.zvh.clima) <- coordinates(climat.2.df)
opt.scipen <- getOption("scipen")
options(scipen=999) # Avoid printing in scientific notation
write.table(cbind(coordinates(datos.zvh.clima), datos.zvh.clima@data), sep=",",  
            file = paste(dir.ref, "/ZVH-clima-mx.csv", sep=""), row.names = FALSE)
options(scipen=opt.scipen)



# Generate the ZHV_BN map
rast_netica.map <- raster(datos.netica.map[,"ZVH_BN"])
projection(rast_netica.map) <- projection(mapa.ref)
plot(rast_netica.map)

# Load de "observed" ZVH
# Reference map: DEM from CONABIO in GD
dir.ref <- paste(dir$GIS.in, "/2004/clima", sep="")
mapas.base <- dir(dir.ref, pattern = "tif$")
arch.ref <- paste(dir.ref, mapas.base[grepl("Zvh", mapas.base)], sep="/")
mapa.ref <- raster(arch.ref)
mapa.ref[mapa.ref==-999] <- NA
mapa.ref <-extend(crop(mapa.ref, climat.2.df), climat.2.df)
zvh.observ <- rasterToPoints(mapa.ref)


# Igualo los mapas

# Create the Geo-tiff for GIS use
map.arch <-paste(dir.ref, "ZVH_RB_Mex.tif", sep="/")
rf <- writeRaster(rast_netica.map, filename=map.arch, 
                  format="GTiff", overwrite=TRUE)

datos.zvh.clima <- cbind(climat.2.df@coords, climat.2.df@data, zvh.observ, datos.netica.map@data)
