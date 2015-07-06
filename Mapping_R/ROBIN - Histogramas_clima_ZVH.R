# @author Miguel Equihua 
# contact: equihuam@gmail.com
# Institution: Inecol
#
#  Genera histogramas de todas las variables que participan en el cálculos de ZVH
#

library (ggplot2)
library(reshape2)

# Función definida para generar histogramas de una variable en el ciclo anual y guardarlos
histogramas.clima <- function (vars, intervalo, archivo, ubicación, zvh)
{
  # Genera una tabla de datos con dos columnas que etiquetan 
  # los datos según el nombre de la columna de orígen
  mdat <- melt(subset(datos.zvh.clima, Zvh_observed==zvh)@data[, vars]) 
  
  graf <- ggplot(mdat, aes(value)) + geom_histogram(aes(y=..count..), 
          binwidth=intervalo, colour='black', fill='skyblue') + 
          geom_density() + facet_wrap(~variable, scales="free")
  graf <- graf + labs(title=paste("ZVH observed (zvh", zvh, ")", sep=""))        
  
  # Save the plot in GD sync structure
  ggsave(archivo, path = dir.ref, graf, width = 22, height = 17, units = "in")
  
  return (graf)
}

# Base directories for storage
dir <- ubica.trabajo(equipo="miguel_tab")
dir.ref <- paste(dir$GIS.in, "/2004/clima", sep="")

# Variables to display
pp.vars <- c(1:12)
tmax.vars <- c(13:24)
tmin.vars <- c(25:36)

# Files to store
prec_arch <- "ZVH_pp_hist.pdf"
tmax_arch <- "ZVH_tmax_hist.pdf"
tmin_arch <- "ZVH_tmin_hist.pdf"

for (i in 11:11)
{
  # Precipitación
  pp_a <- gsub("ZVH", paste("ZVH", i, sep=""), prec_arch)
  tx_a <- gsub("ZVH", paste("ZVH", i, sep=""), tmax_arch)
  tm_a <- gsub("ZVH", paste("ZVH", i, sep=""), tmin_arch)
  
  graf <- histogramas.clima (pp.vars, 2, pp_a, dir.ref, zvh = i)
  
  # Temperatura máxima
  graf <- histogramas.clima (tmax.vars, 0.5, tx_a, dir.ref, zvh = i)

    # Temperatura mínima
  graf <- histogramas.clima (tmin.vars, 0.5, tm_a, dir.ref, zvh = i)
  gc()
}

for (i in 13:36)
{
  mdat <- melt(datos.zvh.clima@data[, c(i, 37)], "Zvh_observed") 
  intervalo  <- ifelse (i <=12, 2, 0.5) 
  graf <- ggplot(mdat, aes(value)) + geom_histogram(aes(y=..count..), 
                    binwidth=intervalo, colour='black', fill='skyblue') + 
                    geom_density() + facet_wrap(~Zvh_observed, scales="free")
  graf <- graf + labs(title=paste(mdat$variable[1], "  by ZVH", sep = ""))    
  
  # Save the plot in GD sync structure
  archivo <- paste("ZVH_all_", mdat$variable[1], "_hist.pdf", sep="")
  ggsave(archivo, path = dir.ref, graf, width = 22, height = 17, units = "in")
  gc()
}

