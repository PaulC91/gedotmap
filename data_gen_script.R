library(rgdal)
library(maptools)
library(rgeos)
library(tidyverse)
library(broom)

regions <- c("East", "East Midlands", "London", "North East", "North West",
             "Scotland", "South East", "South West", "Wales", "West Midlands",
             "Yorkshire and The Humber")

uk <- readOGR(dsn = "UK_constituencies/uk_650_wpc_2017_full_res_v1.8.shp") %>%
  spTransform(CRS("+proj=longlat +datum=WGS84"))

# data gen for each region ------------------------

selected.regions <- lapply(regions, function(x) {
  uk[uk$REGN == x,]
})

centroids <- lapply(1:length(selected.regions), function(i) {
  data.frame(gCentroid(selected.regions[[i]]))
})

dots.final <- lapply(1:length(selected.regions), function(i) {
  
  if (sum(selected.regions[[i]]@data$SNP > 0)) {
    num.dots <- select(selected.regions[[i]]@data, CON:SNP) / 100
  } else {
    num.dots <- select(selected.regions[[i]]@data, CON:GREEN) / 100
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