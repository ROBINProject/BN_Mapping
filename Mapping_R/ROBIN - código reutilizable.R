# @author Miguel Equihua 
# contact: equihuam@gmail.com
# Institution: Inecol

# installing/loading the package:
if(!require(installr)) { 
  install.packages("installr"); require(installr)} #load / install+load installr

# this will start the updating process of your R installation.  
updateR() 

if (!require(ggplot2)) {install.packages("ggplot2"); require(ggplot2)}
if (!require(installr)) {install.packages("installr"); require(installr)}
if (!require(raster)) {install.packages("raster"); require(raster)}
if (!require(ggplot2)) {install.packages("ggplot2"); require(ggplot2)}
if (!require(plotKML)) {install.packages("plotKML"); require(plotKML)}
if (!require("ncdf4")) {install.packages("ncdf4", pkgs = "http://cirrus.ucsd.edu/~pierce/ncdf/win64/ncdf4_1.12.zip");library("ncdf4")}

suppressPackageStartupMessages(library(installr))
if(!require(installr)) { 
  install.packages("installr"); require(installr)} #load / install+load installr

# Directorios de trabajo -------------------------------------------------
ubica.trabajo <- function(equipo="default", gd=T)
  # Selecciona directorios
  # Preparación de donde leer los archivos de datos, considera la posibilidad
  # de que estón accesibles en el equipo local mediante la aplicación 
  # GoogleDrive respectiva. Incluye la ubicación GIS propuesta por Octavio
  #
  # Args:
  #   equipo : directorio de trabajo en el equipo indicado:
  #              miguel_tab
  #              miguel_esc
  #              octavio_tab
  #              octavio_conabio
  #              julian
  #   gd     : GoogleDrive instalado en el equipo.
  #
  # Returns:
  #   Resultados: devuelve las rutas que ubican los directorios de interés
  #               en una lista con tres ubicaciones base que tenemos en
  #               la estructura vigente de google drive: datos base, datos de 
  #               salida y mapas de entrada y salida (GIS in y out).
  #  
  # @author Miguel Equihua 
  # contact: equihuam@gmail.com
  # Institution: Inecol
  
{
  # localización de google drive o de la copia local de los directorios
  if (gd)
  {
    gd.robin <- switch (equipo, 
        default = choose.dir(caption="Ubicación de tu copia de ROBIN del Google Drive?"),
        # Tablet Miguel
        miguel_tab = "C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/",
        #Escritorio Miguel
        miguel_esc = "C:/Users/miguel.equihua/Documents/1 Nube/Google Drive/2 Proyectos/RoBiN/",
        # Tablet Octavio
        octavio_tab = "D:/Drive/RoBiN",
        #Conabio Octavio
        octavio_conabio = "C:/Users/operez/Google Drive/RoBiN/",
    )
  }
  else
    gd.robin <- choose.dir(caption="Dónde están tus datos de ROBIN?")
  
  # sub-directorios de interés
  dir.base_2004 <- "Datos RoBiN/México/0_Vigente/Datos Base/all_vars_table_2004"
  dir.base_2007 <- "Datos RoBiN/México/0_Vigente/Datos Base/all_vars_table_2007"
  dir.output    <- "Datos RoBiN/México/0_Vigente/Resultados"
  dir.GIS.in    <- "Datos RoBiN/México/0_Vigente/GIS/Mapas_base"
  dir.GIS.out   <- "Datos RoBiN/México/0_Vigente/GIS/Mapas_integridad"
  
  # combina la información de ubicación que me convenga
  dir.base_2004 <- paste(gd.robin, dir.base_2004, sep="")
  dir.base_2007 <- paste(gd.robin, dir.base_2007, sep="")
  dir.output <- paste(gd.robin, dir.output, sep="")
  dir.GIS.in   <- paste(gd.robin, dir.GIS.in, sep="")
  dir.GIS.out   <- paste(gd.robin, dir.GIS.out, sep="")
  directorios <- list(base_2004=dir.base_2004, base_2007=dir.base_2007, 
                      output=dir.output, GIS.in=dir.GIS.in, GIS.out=dir.GIS.out)
  return(directorios)
}


# Lee Integrides -----------------------------------------------------------

lee.integridades <- function(dir.datos=getwd(), patron="")
  # Lee los datos de integridad. Asumo tienen datos "x=lon", "y=lat" e "int" 
  # o algo parecido que se quiera graficar y en ese orden. Crea una tabla de datos
  # con todos los archivos seleccionados seg?n el "patron" proporcionado.
  #
  # Args:
  #   dir.datos : directorio de trabajo en el equipo.
  #   patron : especifica un patrón de selección de archivos según la sintaxis de
  #            "regular expressions", n?tense "^" y "$" en estos ejemplos: 
  #               ^inicia
  #               termina$
  #
  # Returns:
  #   Resultados: 
  #   
  # @author Miguel Equihua 
  # contact: equihuam@gmail.com
  # Institution: Inecol

{
  # identifica todos los archivos que cumplen con el "patron"
  archs <- dir(dir.datos, pattern=patron)

  # Lee los datos de integridad.
  for (i in 1:length(archs))
  {
    archivo <- paste(dir.datos, archs[i], sep="/")
    datos <- read.table(archivo, header=TRUE, sep="\t", colClasses="numeric")
    if (i==1) 
      d.int <- data.frame(datos)
    else
      d.int <- cbind(d.int, datos[, 3])
  }
  names(d.int) <- c("x", "y", archs)
  return(d.int)
}



# Genera mapas con ggplo --------------------------------------------------

mapa.ggplot <- function(datos.geo, etiqueta, pos.leyenda=c(0.90, 0.70))
  # Mapea estéticamente y con buen control del tipo y calidad de la salida
  # utilizando la biblioteca "ggplot2". Asumo que la variable "z" es siempre
  # una proporción y eso se refleja en que la leyenda siempre usa mínimos 
  # y máximos [0,1]
  #
  # Args:
  #   datos.geo : datos georeferidos en formato raster.
  #   etiqueta : Rótulo que se desplegará en la leyenda.
  #
  # Returns:
  #   Resultados: Gráfica con las características de la biblioteca ggplot. 
  #
  #   
  # @author Miguel Equihua 
  # contact: equihuam@gmail.com
  # Institution: Inecol
{
  # Convertir rasters a dataframes para usar ggplot
  r.df <- data.frame(rasterToPoints(datos.geo))
  var.z <- names(datos.geo)
  names(r.df) <- c("x", "y", var.z)
  
  #  Crea vectores para diferenciar el color de las clases
  c.1 <- seq(from=0, to=1, length.out=5)
  
  #  Grafica la capa de delta_vp con ggplot()
  mapa <- ggplot(data = r.df, aes_string(x = "x", y = "y", fill = var.z)) + 
            geom_raster() + 
            scale_fill_gradientn(name = etiqueta,
              colours = rev(terrain.colors(100)), breaks = c.1) +
            scale_x_continuous(name = "Longitud") +
            scale_y_continuous(name = "Latitud") +
            theme(axis.text.y = element_text(angle = 90, hjust = 0.5), 
              legend.position = pos.leyenda) +
            coord_equal()
  return(mapa)
}

# Herramientas Excel ------------------------------------------------------
#
# Rutinitas para jalar cositas de Excel ida y vuelta mediante
# el tablero de recortes o "clip" estrategia *** "copy & paste" ***
#

excel.copia.clip_a_R <- function(header=TRUE,...) 
  # copia datos de Excel para pegar en un data frame de R. Basicamente configura read.table
  # para procesar lo que se encuentre en el clip de windows
  #
  # Args:
  #   header : datos georeferidos en formato raster.
  #
  # Returns:
  #   Resultados: data.frame con los datos copiados
  #   
  # @author Miguel Equihua 
  # Contact: equihuam@gmail.com
  # Institution: Inecol
{
  read.table("clipboard",sep="\t",header=header,...)
}

# copia datos de R apara pegar en Excel
excel.copia.clip_desde_R <- function(x,row.names=FALSE,col.names=TRUE,...) 
  # copia datos de R a Excel mediante el clipboard. Basicamente configura write.table
  # para dar formato a lo que se copia al clip de windows
  #
  # Args:
  #   header : datos georeferidos en formato raster.
  #
  # Returns:
  #   Resultados: columnas de datos apropiadas para pegar en Excel
  #   
  # @author Miguel Equihua 
  # Contact: equihuam@gmail.com
  # Institution: Inecol  
{
  write.table(x,"clipboard", sep="\t", row.names=row.names, col.names=col.names,...)
}


# Uso de datos en formato NCBF --------------------------------------------

arregla.datos.NC <- function (datos, var, tstep=50, tipo=NA)
  # Lee el archivo  de datos en formato NCBF. Cambia el orden de acceso
  # a los datos de "columna primero" que usa C a "renglón primero" que usa
  # R. Extrae bloques indexados por año (tstep) y tipo=[pft o type]
  # Args:
  #   datos : referencia a archivo NCBF ya abierto.
  #   var : variable cuya matriz geográfica se extraerá
  #   tstep: Tiempo seleccionado para la matriz de datos que se extraerá.
  #   tipo : En su caso, tipo de vegetación o suelos de referencia.
  #
  # Returns:
  #   Resultados: devuelve la matriz de datos correspondiente a la 
  #               variablelos, tiempo y tipo que se haya especificado.
  # @author Miguel Equihua 
  # contact: equihuam@gmail.com
  # Institution: Inecol
{
  # Parámetros de la estructura de la variable en el archivo nc
  varsize <- datos$var[[var]]$varsize
  ndims <- datos$ndims
  start <- rep(1, ndims) # genera vector apropiado (lat, lon,..., t)
  
  # Si hay el dato de tipo de vege, apunta al indicado al llamar la función
  if (ndims==4) start[ndims-1] <- tipo
  start[ndims] <- tstep  # apunta a la capa de tiempo solicitada
  count <- varsize # Longitud de cada columna en la matriz de datos espacial
  count[ndims] <- 1 # Hace que sólo se lea un corte de tiempo a la vez
  matriz <- ncvar_get(datos, var, start, count)

  # Gira la matriz de datos para hacerla apropiada para "raster"
  resultado <- sapply(1:length(matriz[,1]), function (i) rev(matriz[i,]))
  return(resultado)
}


# Variables modelo JULES y LPJ-------------------------------------------

definicion.vars.NC <- function (nc, i, sep="\t")
  # Despliega la estructura de una variable o atributo del archivo NCDF.
  # Basado en el código de la biblioteca "ncdf4" en la función print.
  # Args:
  #   nc : referencia a archivo NCBF ya abierto.
  #   i : índice que apunta a las variable o atributo de interés.
  #   sep : separador para el nombre de la variable y sus parámetros.
  #
  # Returns:
  #   Resultados: devuelve el nombre de la matriz de datos seleccionada
  #               y los parámetros de su extensión (tiempo, tipo, etc), 
  #               separados por el separador deseado.
  # @author Miguel Equihua 
  # contact: equihuam@gmail.com
  # Institution: Inecol
{
  nd <- nc$var[[i]]$ndims
  dimstring <- paste(sep, "[", sep="")
  if (nd > 0) 
  {
    for (j in 1:nd) 
    {
      dimstring <- paste(dimstring, nc$var[[i]]$dim[[j]]$name, sep = "")
      if (j < nd) 
        dimstring <- paste(dimstring, ",", sep = "")
    }
  }
  dimstring <- paste(dimstring, "] ", sep = "")
  dimstring <- paste(nc$var[[i]]$name, dimstring, sep = "")
} 


# Zonas de vida Holdridge (provincias de humendad) ------------------------

# Desierto (1)
# Tundra (2)
# Estepa espinosa  (3)
# Estepa  (4)
# Matorral desértico  (5)
# Bosque espinoso  (6)
# Bosque muy seco  (7)
# Bosque seco  (8)
# Bosque subhúmedo  (9)
# Bosque húmedo (10)
# Bosque lluvioso (11)
zvh.char <- c("Desierto","Tundra","Estepa espinosa","Estepa","Matorral desértico",
              "Bosque espinoso","Bosque muy seco","Bosque seco","Bosque subhúmedo",
              "Bosque húmedo","Bosque lluvioso")


# Barra de progreso -------------------------------------------------------

#pb <- winProgressBar(title="Example progress bar", 
#                     label="0% done", min=0, max=100, initial=0)
#
#for(i in 1:100) {
#  Sys.sleep(0.1) # slow down the code for illustration purposes
#  info <- sprintf("%d%% done", round((i/100)*100))
#  setWinProgressBar(pb, i/(100)*100, label=info, )
#}
#
#close(pb)
