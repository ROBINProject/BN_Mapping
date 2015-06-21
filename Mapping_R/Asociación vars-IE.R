# @author Miguel Equihua 
# contact: equihuam@gmail.com
# Institution: Inecol


# preparación de ubicación de archivos y funciones de apoyo
source("ROBIN - código reutilizable.R")
dir <- ubica.trabajo(equipo="miguel_tab")

# Lectura de datos 2004 & 2007 --------------------------------------------
# 2004
arch <- dir(dir$base_2004, "csv$")
arch <- file.path(dir$base_2004, arch[1])
data_set_all_2004 <- read.table(arch, header = T, sep=",")
nombres <- names(data_set_all_2004)
nombres[8] <- "delta_vp" 
names(data_set_all_2004) <- nombres
data_set_all_2004$IE <- data_set_all_2004$delta_vp/18 * 100
nombres <- names(data_set_all_2004)
rangos_2004 <- apply(data_set_all_2004, 2, function(x) range(x, na.rm = T))
rangos_2004

# 2007
arch <- dir(dir$base_2007, "csv$")
arch <- file.path(dir$base_2007, arch[1])
data_set_all_2007 <- read.table(arch, header = T, sep=",")
data_set_all_2007$IE <- data_set_all_2007$delta_vp/18 * 100
names(data_set_all_2007) <- nombres # Vars 2004 y 2007 mismo orden. Iguala nombre
rangos_2007 <- apply(data_set_all_2007, 2, function(x) range(x, na.rm = T))
rangos_2007

# Hay diferencias entre los datasets?
identical(x = data_set_all_2004,y = data_set_all_2007)


# Crea archivos de "casos" para NETICA ------------------------------------
# Escribe archivo de casos en formato apropiado para NETICA 
#----- desactivados 22-oct-2014 y resultado almacenado en GD como "vigente"
# write.table(data_set_all_2004, paste(dir$base_2004, "all_vars_table_2004.cas", sep="/"), 
#             sep=",", col.names=T, row.names=F, na="*")
# 
# write.table(data_set_all_2007, paste(dir$base_2007,"all_vars_table_2007.cas", sep="/"), 
#             sep=",", col.names=T, row.names=F, na="*")


# Lectura de integridades 2004 y 2007 -------------------------------------

# Lee las integridades. Usa el "\\" para incluir el paréntesis en la búsqueda.
ie.2004.pj  <- lee.integridades(dir$base_2004, "\\(porcentaje")
ie.2004.dvp <- lee.integridades(dir$base_2004, "\\(supervisado")
ie.2007.pj  <- lee.integridades(dir$base_2007, "\\(porcentaje")
ie.2007.dvp <- lee.integridades(dir$base_2007, "\\(supervisado\\).csv")
ie.2004.infys <- lee.integridades(dir$base_2004, "INFyS")
ie.2007.infys <- lee.integridades(dir$base_2007, "INFyS.csv")

ie <- data.frame(dvp_2004=ie.2004.dvp[,3], pj_2004=ie.2004.pj[,3], 
                 dvp_2007=ie.2007.dvp[,3], pj_2007=ie.2007.pj[,3],
                 ie.infys.2004 = ie.2004.infys[,3],
                 ie.infys.2007 = ie.2007.infys[,3])
cor(ie)

# Elimina variables intermedias que ya no se utilizarán
elimina <- ls(pattern = "ie\\.")
rm(list = elimina[grep("[r]", elimina)])

#agregar el valor de integridad inferido a las bases de datos asociadas 
data_set_all_2004$ie.dvp <- ie$dvp_2004
data_set_all_2004$ie.pj <- ie$pj_2004
data_set_all_2007$ie.dvp <- ie$dvp_2007
data_set_all_2007$ie.pj <- ie$pj_2007
data_set_all_2004$ie.dvp.infys <- ie$ie.infys.2004
data_set_all_2007$ie.dvp.infys <- ie$ie.infys.2007

# agrego una columna de zvh como factor con etiquetas, zvh.char contiene
# las etiquetas y la definí en "ROBIN - código reutilizable"
zvh.fact <- factor(x = data_set_all_2004$zvh, labels = zvh.char)
data_set_all_2004$zvh.fact <- zvh.fact
zvh.fact <- factor(x = data_set_all_2007$zvh, labels = zvh.char)
data_set_all_2007$zvh.fact <- zvh.fact
nombres <- names(data_set_all_2004)


# Graficación de variables vs. IE por ZVH ---------------------------------
library(ggplot2)


# graficación a destajo
gr <- ggplot(data = data_set_all_2004[complete.cases(data_set_all_2004),])
var.ie <- nombres[31] # Integridad Ecosistémica expresada en porcentaje (100 = deteriorado)
for (i in 4:24)
{
  var.y <- nombres[i]
  gr.vars <- gr + aes_string(x=var.ie, y=var.y) + 
                  geom_point(alpha=1/60, col="blue") + 
                  stat_smooth(col="red", method = lm) + 
                  facet_grid(facets = . ~ zvh.fact)
  
  nombre.archivo <- file.path(dir$figs,paste("ie_lm_var",i,".png", sep=""))
  ggsave(nombre.archivo, gr.vars, width = 11, height = 8)
}

gr_ie_mexb <- ggplot(data = data_set_all_2004[,c(12,28,29)], aes(x=mexbio, y=ie.pj)) +
  geom_point(alpha=1/50, col="blue") + stat_smooth(col="red") + facet_grid(facets = . ~ zvh.fact) 

gr_alt <- ggplot(data = data_set_all_2004[,c(3,30,29)], aes(x=ie.dvp.infys, y=rf_altprom_2)) +
  geom_point(alpha=1/50, col="blue")+ stat_smooth(col="red") + facet_grid(facets = . ~ zvh.fact) 

gr_biomasa <- ggplot(data = data_set_all_2004[,c(6,30,29)], aes(x=ie.dvp.infys, y=biomasa_media)) +
  geom_point(alpha=1/50, col="blue") + facet_grid(facets = . ~ zvh.fact) 

ggsave(file.path(dir$figs,"ie_mexbio.png"), gr_ie_mexb)
ggsave(file.path(dir$figs,"ie_alt.png"), gr_alt)
ggsave(file.path(dir$figs,"ie_biomasa.png"), gr_biomasa)

# ggpairs(data=subset(data_set_all_2004[, 3:25], subset = (zvh == 1)))
