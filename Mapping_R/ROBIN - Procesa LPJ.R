# @author Miguel Equihua 
# contact: miguel.equihua@inecol.mx
# Institution: Inecol
# Reading and reprojection of output of LPJmL to make it compatible with EI
#
# Description provided by Alice Boit (alice.boit@pik-potsdam.de) 
#
# NetCDF is self documented, when loaded just type de object's name
# for a description of the contents
#
# Run received on 3rd June, 2015
#
# The output file contains the output for 4 variables: 
#      fracnatveg - Fraction of natural vegetation in the pixel
#      NPP        - Net primary production
#      runoff     - Total water runoff in the pixel
#      vegC       - Total carbon contents in the vegetation of the pixel
#
# Some files were obtained from PIK in NCDF4 format
#
# Preparation ------------------------------------------------------------
source("ROBIN - código reutilizable.R")
library(ncdf4)

# File locations to get and store data Tablet: miguel_tab, Excritorio: miguel_esc
dir <- ubica.trabajo(equipo="miguel_tab")

# Reference map in CONABIO/INFyS package
dir.ref <- paste(dir$GIS.in, "/2004", sep="")
mapas.base <- dir(dir.ref, pattern = "tif$")
arch.ref <- paste(dir.ref, mapas.base[10], sep="/")
mapa.ref <- raster(arch.ref)
mapa.ref[mapa.ref==-999] <- NA
gama.valores <- range(values(mapa.ref),na.rm = T)
plot(mapa.ref)

# Location of tif & nc files with LPJmL
dir.lpj <- sub("Mapas_base", "LPJ", dir$GIS.in)
nc.lpj <- dir(dir.lpj)[grepl("\\.nc$", dir(dir.lpj))]

# Open nc and read file descriptions which are store in a list: [var][details]
nc.all <- lapply(nc.lpj, function (x) c(var=x, 
                          data=list(nc_open(paste(dir.lpj, "/", x, sep="")))))

# Take note of the variables found in the nc files and lat, lon data
for (d in nc.all)
{
  nc.temp <- d$data
  vars <- sapply(1:nc.temp$nvars, function (x) 
                        definicion.vars.NC(nc.temp, x, sep=" "))
  latitude <- ncvar_get(nc.temp,"lat")
  longitude <- ncvar_get(nc.temp,"lon")

  # lat & lon are compile in a list of one component by file
  if (d$var == nc.all[[1]]$var)
  {
    nc.vars <- vars
    lat <- list(latitude)
    lon <- list(longitude)
  } else
  {
    nc.vars <- c(nc.vars, vars)
    lat <- c(lat, list(latitude))
    lon <- c(lon, list(longitude))
  }
}


# Verify that all (lat, lon) are the same throughout the files
if (all(all(sapply(lat, function(x) sapply(lat,function(y) identical(x,y)))),
   all(sapply(lon, function(x) sapply(lon,function(y) identical(x,y))))))
 {
   lat <- lat[[1]]
   lon <- lon[[1]]
 } else print ("ERROR: Inconsistent data")

# recover the variables time, and simulation output
# Time step in data file and time origin
nc.time <- sapply(nc.all, function (d) c(var=d$var, time.length=d$data$dim$time$len,
                              time.origin=d$data$dim$time$units))

# Store existing time patterns in data files
nc.time.types <- nc.time[1, nc.time[2,] == unique(nc.time[2,])] == nc.time[1,]
nc.time <- lapply(nc.all[nc.time.types], function(d) 
       c(type=d$data$dim$time$units, time=list(ncvar_get(d$data,"time"))))

# Reads yearly and monthly blocks, computes yearly totals where appropriate
# If any variable is less than zero it is trimmed to zero.
t0.robin <- (2004 - 1951) * 12 + 1 ; var.year.totals <- list()
for (d in nc.all)
{
  if (grepl("days", d$data$dim$time$units)) # Monthly type
  {
    variable <- d$data$var[[1]]$name 
    for (i in 0:11) # Monthly steps
    {
      if (i==0)
      {
        var.data <- arregla.datos.NC(d$data, variable, (t0.robin + i))
        var.data[(var.data < 0) & (!is.na(var.data))] <- 0
      } else 
      {
        v.temp <- arregla.datos.NC(d$data, variable, (t0.robin + i))        
        v.temp[(v.temp < 0) & (!is.na(v.temp))] <- 0
        var.data <- var.data + v.temp
      }
    }
  } else
  {
    if (d$data$nvars == 1)
    {
      variable <- d$data$var[[1]]$name 
      var.data <- arregla.datos.NC(d$data, variable, 54)
      var.data[(var.data < 0) & (!is.na(var.data))] <- 0
    } else
    { 
      # Label these layers with initials of the name string
      variable <- lapply(d$data$var, function(v) if (v$ndims > 3) v$name)
      variable <- unlist(variable, use.names = F)
      
      # Determines the number of variables in the file and gets the
      vege.types.num <- d$data$var[[2]]$size[3]  
      vege.types <- ncvar_get(d$data, d$data$var[[1]]$name)
      var.data <- lapply(1:vege.types.num, function (k) 
                      list(PFP=vege.types[k],
                      frec=arregla.datos.NC(d$data, variable, 54, k)))
    }
  }
  var.year.totals <- c(var.year.totals, 
                      list(list(name=variable, data=var.data)))
}

# close all nc files
lapply(nc.all, function (f) nc_close(f$data))


# Join all maps in a single brick
nc.mapas.brick <- brick()
for (d in var.year.totals)
{
  if (length(d$data) == 33432)   # The coverage has 33432 pixel per layer
  { mapa <- raster(d$data,
            xmn=range(lon)[1], xmx=range(lon)[2],
            ymn=range(lat)[1], ymx=range(lat)[2], 
            crs=CRS("+proj=longlat +datum=WGS84"))
    names(mapa) <- d$name
    nc.mapas.brick <- addLayer(nc.mapas.brick,mapa) 
  } else {
    for (x in d$data)
    {mapa <- raster(x$frec,
              xmn=range(lon)[1], xmx=range(lon)[2],
              ymn=range(lat)[1], ymx=range(lat)[2], 
              crs=CRS("+proj=longlat +datum=WGS84"))
    FPC.acronim <- paste(substr(strsplit(x$PFP, " ")[[1]],1,2), collapse = "")
    names(mapa) <- paste("fpc", toupper(FPC.acronim), collapse = "")
    nc.mapas.brick <- addLayer(nc.mapas.brick, mapa)
    }
  }
}

lapply(nc.mapas.brick, function (l) range(values(l), na.rm = T))
range(values(nc.mapas.brick[[13]]), na.rm = T)
names(nc.mapas.brick)

range# Save multilayer GeoTiff with all LPJmL data
for (i in 1:13)
  bf <- writeRaster(nc.mapas.brick[[i]], bylayer=T, overwrite=TRUE,
                    filename=paste(dir.lpj, "/LPJmL_2004_", 
                                   names(nc.mapas.brick[[i]]), ".tif", 
                                   sep=""))

# Reproject to Mexican ROBIN parameters 1km database
lpj_robin_mx.maps.brick <- brick()
for (i in 1:13)
{
  mapa.nuevo <- projectRaster(from=nc.mapas.brick[[i]], 
                              to=mapa.ref, method="bilinear")
  mapa.nuevo[is.na(mapa.ref)] <- NA
  lpj_robin_mx.maps.brick <- addLayer(lpj_robin_mx.maps.brick, mapa.nuevo)
}
names(lpj_robin_mx.maps.brick) <- names(nc.mapas.brick)

plot(lpj_robin_mx.maps.brick[[11]])
plot(mapa.ref)

# Red file with brick data in "raster" format
lpj_robin_mx.maps.brick <- raster(paste(dir.lpj, "/lpj_2004_mx.grd", sep=""),
                                  values=T, package="raster")
names(lpj_robin_mx.maps.brick)
plot(lpj_robin_mx.maps.brick[[11]])

#writeRaster(lpj_robin_mx.maps.brick, paste(dir.lpj, "/lpj_2004_mx", Sep="/"))

# Save multilayer GeoTiff with all LPJmL data
for (i in 1:13)
  bf <- writeRaster(lpj_robin_mx.maps.brick[[i]], bylayer=T, overwrite=TRUE,
                    filename=paste(dir.lpj, "/LPJmL_2004_mx_",
                                   names(lpj_robin_mx.maps.brick[[i]]), ".tif", 
                                   sep=""))

# LPJmL data into data.frame
lpj.mx.df <- rasterToPoints(lpj_robin_mx.maps.brick, spatial = T)
head(lpj.mx.df)
class(lpj.mx.df)

# Write point data to file
opt.scipen <- getOption("scipen")
options(scipen=999) # Avoid printing in scientific notation
write.table(cbind(coordinates(lpj.mx.df), lpj.mx.df@data), sep=",",  
          file = paste(dir.lpj, "/lpj-mx_df.csv", sep=""), row.names = FALSE)
options(scipen=opt.scipen)



# Tipos de cobertura vegetal
#
# natural fraction                      tropical broadleaved evergreen tree   
# tropical broadleaved raingreen tree   temperate needleleaved evergreen tree 
# temperate broadleaved evergreen tree  temperate broadleaved summergreen tree
# boreal needleleaved evergreen tree    boreal broadleaved summergreen tree   
# C3 perennial grass                    C4 perennial grass 
#

mapa.lpj.plt <- mapa.ggplot(Vege.lpj.nat.frac, 
                            "Natural vegetation", pos.leyenda = c(0.25,0.25))
mapa.vg <- projectRaster(from=Vege.lpj.nat.frac, to=mapa.ref, method="bilinear")
mapa.vg.mx <- mapa.ggplot(mapa.vg, 
                            "Natural vegetation", pos.leyenda = c(0.25,0.25))

lpj.mx.df <- read.table(paste(dir.lpj, "lpj-mx_df.csv", sep="/"), 
                        sep=",", header = T)


# Carbon store in vegetation should be about 2.8 km/cm2 on average in ROBIN
# region
vege.C.lpj <- ncvar_get(nc.all[[4]]$data, "VegC")

# Attributes of the variable
range(nc.all[[4]]$data$dim$lat$vals, na.rm = T)
nc.all[[4]]$data$dim$time
nc.all[[4]]$data$var$VegC$units


# Average by latitude slices
apply(vege.C.lpj, 3, mean, na.rm=T)
plot(nc.all[[4]]$data$dim$time$vals, 
     apply(vege.C.lpj, 2:3, mean, na.rm=T)[70,], type="l")


# Lectura de  los mapas tif ---->> length(variables.lpj)
multicapa.lpj <- brick()
region <- data.frame(); k <- 0
for (i in 1:3)
{
  for (j in 1:length(archivos.lpj[[i]]))
  {
    k <- k + 1
    mapa <- raster(paste(variables.lpj[i], archivos.lpj[[i]][j], sep="/"))
    region <- rbind(region, extent(mapa)[1:4])
    region$mapa[k] <- names(mapa)
    mapa <- projectRaster(from=mapa, to=mapa.ref, method="bilinear")
    multicapa.lpj <- addLayer(multicapa.lpj, mapa)
  }
}
names(region) <- c("xmin", "xmax", "ymin", "ymax", "map")


multicapa.lpj[multicapa.lpj==255] <- NA
plot(multicapa.lpj$layer.1)

mapa.nuevo <- projectRaster(from=multicapa.lpj[[1]], 
                            to=mapa.ref, method="bilinear")
plot(mapa.nuevo)
