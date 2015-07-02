# @author Miguel Equihua 
# contact: equihuam@gmail.com
# Institution: Inecol
#
#  Read tif files of mex-climat wall to wall to prepare data tables
#  for NETICA modeling.
#
# File locations to get and store data Tablet: miguel_tab, Excritorio: miguel_esc
dir <- ubica.trabajo(equipo="miguel_tab")

# Location of climate maps in ROBIN-GISdata in "GD/2004"
dir.ref <- paste(dir$GIS.in, "/2004/clima", sep="")
mapas.base <- dir(dir.ref, pattern = "tif$")
map.names <- unlist(lapply(mapas.base, function (s) strsplit(s, ".tif")[1]))

# Read  climat data files in the "mapas.base" list from the directory
maps.brik <- brick()
for (map.name in mapas.base)
{
  arch.ref <- paste(dir.ref, map.name, sep="/")
  mapa <- raster(arch.ref)
  if (!identical(extent(mapa), extent(maps.brik)) ^ (map.name!=mapas.base[1]))
      mapa <- extend(crop(mapa, maps.brik), maps.brik)
  maps.brik <- addLayer(maps.brik, mapa)
}
names(maps.brik) <- map.names

# Add the DEM data: dem30_mean1000,dem30_sd1000
dir.ref <- gsub("/clima", "", dir.ref)
mapas.base <- dir(dir.ref, pattern = "dem.+\\.tif$")
map.names <- unlist(lapply(mapas.base, function (s) strsplit(s, ".tif")[1]))
for (map in mapas.base)
{
  arch.ref <- paste(dir.ref, map, sep="/")
  mapa.ref <- raster(arch.ref)
  maps.brik <- addLayer(maps.brik, mapa.ref)
}
names(maps.brik)

# Eliminate NA or data labeled with very negative values like -9999

maps.brik.2 <- maps.brik[!is.na(maps.brik)]


# Generates de data.frame with all the variables
climat.df <- rasterToPoints(maps.brik, spatial = T)

# Eliminates recors without data "NA"
climat.2.df <- climat.df[complete.cases(climat.df@data),]
length(climat.df) - length(climat.2.df)

# Write point data to file
opt.scipen <- getOption("scipen")
options(scipen=999) # Avoid printing in scientific notation
write.table(cbind(coordinates(climat.2.df), climat.2.df@data), sep=",",  
            file = paste(dir.ref, "/climat-mx_2004.csv", sep=""), row.names = FALSE)
options(scipen=opt.scipen)


