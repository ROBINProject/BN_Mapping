# Mapeo de raster sobrepuesto a googlemap
# idea tomada de: http://rpubs.com/alobo/rasterOnGM
# Hay información sobre proyecciones en: 
#       http://www.spatialreference.org/
#       http://www.epsg.org/
# Datos de parámetros de las funciones en:
#       http://www.remotesensing.org/geotiff/proj_list/
#
# Curiosidades:
#   ¿de dónde vienen los códigos EPSG?.- The OGP Geomatics Committee, 
#       previously known as the Surveying & Positioning Committee, was
#       formed in 2005 by the absorption into OGP of the now-defunct 
#       European Petroleum Survey Group (EPSG) which itself had been
#       formed in 1986. The Surveying & Positioning Committee comprises
#       specialists from OGP member companies working in the areas of 
#       surveying, geodesy, cartography and geo-spatial 
#       information/coordinate data management. An agreement with the 
#       Society of Exploration Geophysicists (SEG) is permitting 
#       deprecation of SEG’s positioning formats and recognition of the
#       revised OGP positioning formats as their replacement. 
#

require(utils)
require(colorRamps)
require(rgdal)
require(raster)
require(dismo)
require(rasterVis)

# Esta es la imagen que se sobrepondrá.
download.file(url="https://dl.dropboxusercontent.com/u/3180464/rprob520.tif",
              destfile="rprob520.tif", mode="wb")
rprob <- raster("rprob520.tif")
extent(rprob)
projection(rprob)
plot(rprob)

# Esta es la imagen de google maps que corresponde a la zona
# gmap() requires the extent to be in either longitude/latitude (epsg:4326)
# or Google PseudoMercator (epsg:3857), but can also accept an spatial 
# object in any CRS provided it is correctely defined.
migmap <- gmap(x = rprob, type = "hybrid", zoom = 5)
plot(migmap)

# gmap() will perform the reprojection if needed. As extent objects are not
# geospatial objects (they lack the CRS information), in case you provide
# the extent then you must take care of the eventual reprojection on your
# own first. The simplest way is to ask gmap() to download the GM layer 
# centered on our raster object at a given zoom level
# In case we provide the extent and not the spatial object we must deal
# with the reprojection on our own.
delme <- gmap(x = projectExtent(rprob, crs = CRS("+init=epsg:3857")), 
              type = "hybrid", zoom = 5)
plot(delme)
rm(delme)

# In order to overlay rprob on top of migmap, we must make both layers
# have the same CRS. As this is a large area, we select Google 
# PseudoMercator (epsg:3857) and reproject rprob.
rprobGM <- projectRaster(from = rprob, crs = CRS("+init=epsg:3857"))

# The reprojection involves some interpolation, thus we make sure the [0,1]
# interval is fulfilled.
rprobGM[rprobGM < 0] <- 0
rprobGM[rprobGM > 1] <- 1

# Despliega el mapa de google y luego sobrepone mi capa con cierta 
# transparencia definida por el parámetro "alpha".
plot(migmap)
plot(rprobGM, add = T, legend = F, col = rev(rainbow(10, alpha = 0.35)))

# Para "enchular" la paleta se puede usar la función respectiva:
#   pal(rev(rainbow(10, alpha=1)))
micolor <- rev(rainbow(12, alpha = 0.35))
transp <- rainbow(12, alpha = 0)
micolor[1:3] <- transp[1]
plot(migmap)
plot(rprobGM, add = T, legend = F, col = micolor)

# Mapa de México.  Utilizo proyección lat/lon epsg:4326
delme <- gmap(x = projectExtent(rf, crs = CRS("+init=epsg:4326")), 
              type = "satellite", zoom = 4)
rf.gm <- projectRaster(from = rf, crs = CRS("+init=epsg:4326"))
rf.gm[rf.gm < 0] <- 0
rf.gm[rf.gm > 1] <- 1

plot(delme)
plot(rf.gm, add = T, legend = F, col = rev(rainbow(10, alpha = 0.5)))
