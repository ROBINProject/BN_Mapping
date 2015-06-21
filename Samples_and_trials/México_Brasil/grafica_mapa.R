# Despliegue del mapa usando la librería ggplot2

# Si se usa "scale_fill_gradientn" los colores se pueden generar con:
#    rainbow(), topo.colors(), terrain.colors() entre otras
grafica.mapa <- function(dato.integ, datos.coord, nombre.datos, nlevels=20)
{
  # Preparé la función para hacer un mapa por vez y asumo que los datos están listos.
  datos <- cbind(integrity=dato.integ, datos.coord)
  
  #Escoges DOS colores para interpolar
  levels <- seq(min(dato.integ),max(dato.integ),length.out = nlevels)
  col <- colorRampPalette(c("red","yellow","dark green"))(nlevels)  
  #col <- colorRampPalette(c("dark green","yellow","red"))(nlevels)
  colz <- col[cut(dato.integ,nlevels)]  
  
  # Se preparan la graficación con los datos dados en la estructura "i.map" 
  i.map <- ggplot(data = datos, aes(x = XCOORD, y = YCOORD, fill=integrity))
  #rainbow(start=0.08, end=0.57, n=15)
  # Se arma el mapa y sus detalles de despliegue.  
  mapa <- i.map + geom_raster(interpolate=FALSE) + 
    ggtitle (nombre.datos) +
    labs (fill="Integrity") + coord_fixed() +
    scale_fill_gradientn (guide="colourbar", colours=col) +
    scale_x_continuous (labels = comma, name = "") +
    scale_y_continuous (labels = comma, name = "") +
    theme(axis.text.y = element_text(angle = 90, hjust=0.5, size=7),
          axis.text.x = element_text(size=7), 
          legend.title = element_text(size=9), legend.text = element_text(size=7),
          legend.position = c(0.90,0.70), plot.title=element_text(size=12))
  
  return(mapa)
}
