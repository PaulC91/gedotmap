library(rgdal)
library(maptools)
library(rgeos)
library(tidyverse)
library(broom)

regions <- c("East", "East Midlands", "London", "North East", "North West",
             "Scotland", "South East", "South West", "Wales", "West Midlands",
             "Yorkshire and The Humber")

uk <- readOGR(dsn = "uk_650_wpc_2017_low_res_v1.9/uk_650_wpc_2017_low_res_v1.9.shp") %>%
  spTransform(CRS("+proj=longlat +datum=WGS84"))

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

ge.dots <- lapply(1:length(selected.regions), function(i) {
  
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
  
  dots.final <- bind_rows(dfs) %>% 
    mutate(Party = factor(Party, levels = parties))
  
  return(dots.final)
})
names(ge.dots) <- regions

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
