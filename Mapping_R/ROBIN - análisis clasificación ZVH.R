# @author Miguel Equihua 
# contact: equihuam@gmail.com
# Institution: Inecol
#
#  Lee archivo de datos de NETICA para contruir curvas de calibración
#

# File locations to get and store data Tablet: miguel_tab, Excritorio: miguel_esc
dir <- ubica.trabajo(equipo="miguel_esc")

# Location of climate maps in ROBIN-GISdata in "GD/2004"
dir.ref <- paste(dir$GIS.in, "/2004/clima", sep="")
mapas.base <- dir(dir.ref, pattern = "txt$")
arch.ref <- paste(dir.ref, mapas.base[grepl("curva", mapas.base)], sep="/")

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


dato[[2]][2]

