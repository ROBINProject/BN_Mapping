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

Lee.zvh_rb.netica <- function (dir.base, nombre.salida, archivo.datos, 
                               archivo.ref.geografica, raster.ref)
{
  # read data table with NETICA data
  datos <- read.csv(paste(dir.base, archivo.datos, sep="/"), header = T, sep ="\t")
  
  # Clean the names of the variables
  names.variables <- names(datos) 
  names.variables <- unlist(lapply(names.variables, function (name) 
            {l = strsplit(name,"\\.");l = l[[1]][length(l[[1]])]; unlist(l)}))
  names(datos) <- names.variables
  
  # Identify ZVH_BN with maximum probability
  datos$ZVH_BN <- apply(datos[,3:13], 1, function(x) which.max(x))
  
  # preparare map data for mapping
  # Read coordinates from the map file used to produced the NETICA results
  datos[,1:2] <- archivo.ref.geografica@coords
  coordinates(datos) <- ~ x + y
  gridded(datos) <- T

  # Generate the ZHV_BN map
  netica.map <- raster(datos[,"ZVH_BN"])
  projection(netica.map) <- projection(raster.ref)
  
  # Create the Geo-tiff for GIS use
  map.arch <-paste(dir.base, nombre.salida, sep="/")
  rf <- writeRaster(netica.map, filename=map.arch, 
                    format="GTiff", overwrite=TRUE)
  return (datos)
}

# Location of NETICA files
dir.work.clima <- paste(dir.ref,"/2004", sep = "")
arch.netica  <- dir(dir.ref, pattern = ".+4_lon\\.csv$")

# With reference map "bov_cbz_km2" and dir base: "2004"
Lee.zvh_rb.netica(dir.work.clima, "ZVH.tif", arch.netica, climat.2.df, mapa.ref)

# Put all variables and estimates of ZVH together and write the table
#datos.zvh.clima <- cbind(climat.2.df@data, datos.netica.map@data)
#coordinates(datos.zvh.clima) <- coordinates(climat.2.df)
#opt.scipen <- getOption("scipen")
#options(scipen=999) # Avoid printing in scientific notation
#write.table(cbind(coordinates(datos.zvh.clima), datos.zvh.clima@data), sep=",",  
#            file = paste(dir.ref, "/ZVH-clima-mx.csv", sep=""), row.names = FALSE)
#options(scipen=opt.scipen)
