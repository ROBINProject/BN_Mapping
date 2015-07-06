# @author Miguel Equihua 
# contact: equihuam@gmail.com
# Institution: Inecol
#
#  Lee archivo de datos de NETICA para contruir curvas de calibración
#

# File locations to get and store data Tablet: miguel_tab, Excritorio: miguel_esc
dir <- ubica.trabajo(equipo="miguel_tab")

# Location of climate maps in ROBIN-GISdata in "GD/2004"
dir.ref <- dir$GIS.in
mapas.base <- dir(dir.ref, pattern = "txt$")
arch.ref <- paste(dir.ref, mapas.base[grepl("cal_EM", mapas.base)], sep="/")

# Read calibration curve data prepared by python program from Netica output
dat <- scan(arch.ref, what = "character", sep = "\n")

dato <- list()
i <- 0
for (d in dat)
{
  if (grepl("[a-zA-Z]+", d))
  {
      i <- i + 1
      xx <- T
      dato[[i]] <- list(tipo=d)
  } else {
      if (xx)  
        {
            dato[[i]][[2]] <- list(x=unlist(lapply(strsplit(d, ","), as.numeric)))
            xx <- F
      } else {
        dato[[i]][[2]] <- data.frame(x=dato[[i]][[2]], y=unlist(lapply(strsplit(d, ","), as.numeric)))
      }
  }
}

library(ggplot2)
qplot(dato[[2]][[2]]$x, dato[[2]][[2]]$y, data = dato[[2]][[2]]) + 
       geom_smooth(method = "loess", size = 2)

