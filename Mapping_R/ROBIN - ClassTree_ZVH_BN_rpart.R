library(rpart.plot)

arbol2 <- rpart(Zvh_observed ~ 
                     ppt01 + ppt02 + ppt03 + ppt04 + ppt05 + ppt06 +
                     ppt07 + ppt08 + ppt09 + ppt10 + ppt11 + ppt12 +
                     tmax01 + tmax02 + tmax03 + tmax04 + tmax05 + tmax06 +
                     tmax07 + tmax08 + tmax09 + tmax10 + tmax11 + tmax12 +
                     tmin01 + tmin02 + tmin03 + tmin04 + tmin05 + tmin06 +
                     tmin07 + tmin08 + tmin09 + tmin10 + tmin11 + tmin12 +
                     pptmax01 + pptmax02 + pptmax03 + pptmax04 + pptmax05 + 
                     pptmax06 + pptmax07 + pptmax08 + pptmax09 + pptmax10 + 
                     pptmax11 + pptmax12 + tx_tm01 + tx_tm02 + tx_tm03 +  
                     tx_tm04 + tx_tm05 + tx_tm06 + tx_tm07 + tx_tm08 + 
                     tx_tm09 + tx_tm10 + tx_tm11 + tx_tm12 +            
                     dem30_mean1000 + dem30_sd1000 + x + y, 
                     data = d.c, method = "class")

rpart.plot(arbol)

library(rattle)
rattle()
rpart.plot(arbol)

pt <- datos.zvh.clima@data[,1:12]/datos.zvh.clima@data[,13:24]
tmx_tmn <- datos.zvh.clima@data[,13:24] - datos.zvh.clima@data[,25:36]


names(pt) <- unlist(lapply(1:12, function(i) sprintf(fmt = "pptmax%02d", i)))
names(tmx_tmn) <- unlist(lapply(1:12, function(i) sprintf(fmt = "tx_tm%02d", i)))

d.c <- datos.zvh.clima
d.c@data <- cbind(d.c@data, pt, tmx_tmn)

# Write point data to file
opt.scipen <- getOption("scipen")
options(scipen=999) # Avoid printing in scientific notation
write.table(cbind(coordinates(d.c), d.c@data), sep=",",  
            file = paste(dir.ref, "/climat-mx_2004.csv", sep=""), row.names = FALSE)
options(scipen=opt.scipen)

# Base directories for storage
dir <- ubica.trabajo(equipo="miguel_tab")
dir.ref <- paste(dir$GIS.in, "/2004", sep="")
boosted.arch <- dir(dir.ref, patt="NA") 
boosted.arch <- paste(dir.ref, boosted.arch, sep="/")
boosted1 <- read.table(boosted.arch, header = T, sep=",", stringsAsFactors = F)
pt <- boosted[,6:17]/boosted[,18:29]
tmx_tmn <- boosted[,18:29] - boosted[,30:41]
names(pt) <- unlist(lapply(1:12, function(i) sprintf(fmt = "pptmax%02d", i)))
names(tmx_tmn) <- unlist(lapply(1:12, function(i) sprintf(fmt = "tx_tm%02d", i)))

boosted <- cbind(boosted, pt, tmx_tmn)
# Write point data to file
opt.scipen <- getOption("scipen")
options(scipen=999) # Avoid printing in scientific notation
write.table(boosted, sep=",",  
            file = paste(dir.ref, "/1_train_miguelB_boosted_sin_NA_pt_tmx-tmn.csv",
                         sep=""), row.names = FALSE)
options(scipen=opt.scipen)
head(boosted)

# Correlations of Climat vars with zvh
boost.corr.1 <- as.numeric(cor(boosted$Zvh, boosted[,c(6:41, 43:66)]))
boost.corr.DEM.2 <- data.frame(rep(0, times=60)) ; k <- 0
for (j in c(6:41, 43:66))
{
  k <- k + 1
  boost.corr.DEM.2[k] <- unlist(lapply(c(6:41, 43:66), function (i) 
    sqrt(summary(lm(Zvh ~ boosted[,i] + boosted[,j] + 
                      dem30_mean1000 + dem30_sd1000 + x+ y, 
                    data=boosted))$r.squared)))
  gc()
}

row.names(boost.corr.DEM.2) <- names(boosted[,c(6:41, 43:66)])
qplot (boost.corr.1)
