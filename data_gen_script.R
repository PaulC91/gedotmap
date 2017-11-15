library(rgdal)
library(maptools)
library(rgeos)
library(tidyverse)
library(broom)
library(sp)

regions <- c("East", "East Midlands", "London", "North East", "North West",
             "Scotland", "South East", "South West", "Wales", "West Midlands",
             "Yorkshire and The Humber")

ge2017 <- read.csv("ge2017.csv", stringsAsFactors = F)

uk <- readOGR(dsn = "uk_650_wpc_2017_low_res_v1.9/uk_650_wpc_2017_low_res_v1.9.shp") %>%
  spTransform(CRS("+proj=longlat +datum=WGS84"))
uk <- uk[uk$REGN != "Northern Ireland",]
uk@data <- merge(uk@data, ge2017, by = "PCONCODE")

# data gen for each region ------------------------

selected.regions <- lapply(regions, function(x) {
  region <- uk[uk$REGN == x,]
  #region.df <- tidy(region)
  #region@data$id <- row.names(region@data)
  #region.points <- fortify(region, region = "id")
  #region.df <- merge(region.points, region@data, by = "id")
})
names(selected.regions) <- regions

centroids <- lapply(1:length(selected.regions), function(i) {
  data.frame(gCentroid(selected.regions[[i]]))
})
names(centroids) <- regions

# ge2015 data gen ------------------------------------------------------- 

ge.dots.2015 <- lapply(1:length(selected.regions), function(i) {
  
  if (sum(selected.regions[[i]]@data$SNP > 0)) {
    num.dots <- select(selected.regions[[i]]@data, CON:SNP) / 250
  } else {
    num.dots <- select(selected.regions[[i]]@data, CON:GREEN) / 250
  }
  
  sp.dfs <- lapply(names(num.dots), function(x) {
    dotsInPolys(selected.regions[[i]], as.integer(num.dots[, x]), f="random")
  })
  
  dfs <- lapply(sp.dfs, function(x) {
    data.frame(coordinates(x)[,1:2])
  })
  
  parties <- names(num.dots)
  for (i in 1:length(parties)) {
    dfs[[i]]$Party <- parties[i]
  }
  
  dots.final <- bind_rows(dfs)
  levels <- c("SNP", "CON", "LAB", "LD", "UKIP", "GREEN")
  dots.final$Party <- factor(dots.final$Party, levels = levels)
  
  return(dots.final)
})
names(ge.dots.2015) <- regions

# ge2017 data gen ------------------------------------------------------- 

ge.dots.2017 <- lapply(1:length(selected.regions), function(i) {
  
  if (sum(selected.regions[[i]]@data$SNP_2017 > 0)) {
    num.dots <- select(selected.regions[[i]]@data, CON_2017:SNP_2017) / 250 #%>%
      #rename(CON_2017 = CON, LAB_2017 = LAB, LD_2017 = LD, UKIP_2017 = UKIP, 
       #      GREEN_2017 = GREEN, SNP_2017 = SNP)
  } else {
    num.dots <- select(selected.regions[[i]]@data, CON_2017:GREEN_2017) / 250 #%>%
      #rename(CON_2017 = CON, LAB_2017 = LAB, LD_2017 = LD, UKIP_2017 = UKIP, 
       #      GREEN_2017 = GREEN, SNP_2017 = SNP)
  }
  
  sp.dfs <- lapply(names(num.dots), function(x) {
    dotsInPolys(selected.regions[[i]], as.integer(num.dots[, x]), f="random")
  })
  
  dfs <- lapply(sp.dfs, function(x) {
    data.frame(coordinates(x)[,1:2])
  })
  
  parties <- names(num.dots)
  for (i in 1:length(parties)) {
    dfs[[i]]$Party <- parties[i]
  }
  
  dots.final <- bind_rows(dfs) %>% 
    mutate(Party = factor(Party, levels = parties))
  
  party_labels <- c("CON_2017" = "CON", "LAB_2017" = "LAB", "LD_2017" = "LD", "UKIP_2017" = "UKIP", 
                    "GREEN_2017" = "GREEN", "SNP_2017" = "SNP")
  levels <- c("SNP", "CON", "LAB", "LD", "UKIP", "GREEN")
  dots.final$Party <- factor(party_labels[dots.final$Party], levels = levels)
  
  return(dots.final)
})
names(ge.dots.2017) <- regions

# EU ref data gen ----------------------------------------------------------------

brexit.dots <- lapply(1:length(selected.regions), function(i) {
  
  num.dots <- select(selected.regions[[i]]@data, POP18PLU15, EUHANLEAVE, EUHANREM) %>%
    mutate(POP18PLU15 = as.numeric(levels(POP18PLU15))[POP18PLU15]) %>%
    mutate(Leave = as.integer(((POP18PLU15 * 0.722) * EUHANLEAVE) / 250),
           Remain = as.integer(((POP18PLU15 * 0.722) * EUHANREM) / 250)) %>%
    select(Leave, Remain)
  
  sp.dfs <- lapply(names(num.dots), function(x) {
    dotsInPolys(selected.regions[[i]], as.integer(num.dots[, x]), f="random")
  })
  
  dfs <- lapply(sp.dfs, function(x) {
    data.frame(coordinates(x)[,1:2])
  })
  
  parties <- names(num.dots)
  for (i in 1:length(parties)) {
    dfs[[i]]$Party <- parties[i]
  }
  
  dots.final <- bind_rows(dfs) %>% 
    mutate(Party = factor(Party, levels = parties))
  
  return(dots.final)
})
names(brexit.dots) <- regions
