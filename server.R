library(leaflet)
library(leaflet.extras)
library(leaflet.mapbox)
library(ggplot2)
library(dplyr)
library(scales)
library(hrbrthemes)

# load data previously generated with data_gen_script.R to the environment
load("Data/250data_2017.RData")

function(input, output) {
  
  dots.final <-reactive(
    if (input$vote == "General Election 2017") {
      ge.dots.2017
    } else if (input$vote == "General Election 2015") {
      ge.dots.2015
    } else {
      brexit.dots
    }
  )
  
  dotsInBounds <-reactive({
    if (is.null(input$map_bounds))
      return(NULL)
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(dots.final()[[input$region]],
           y >= latRng[1] & y <= latRng[2] &
             x >= lngRng[1] & x <= lngRng[2])
  })
  
  votes <- reactive(
    count(dotsInBounds(), Party) %>%
      mutate(Votes = (n * 250)) %>%
      select(Party, Votes)
  )
  
  pal <-reactive(
    if (input$vote == "EU Referendum 2016") {
      c("Leave" = "RoyalBlue", "Remain" = "Yellow")
    } else if (input$region == "Scotland") {
      c("SNP" = "#FFFF00", "CON" = "#0087DC", "LAB" = "#DC241F", "LD" = "#FCBB30", "UKIP" = "#70147A", "GREEN" = "#78B943")
    } else {
      c("CON" = "#0087DC", "LAB" = "#DC241F", "LD" = "#FCBB30", "UKIP" = "#70147A", "GREEN" = "#78B943")
    }
  )
  
  cols <-reactive(
    if (input$vote == "EU Referendum 2016") {
      colorFactor(pal(), domain = brexit.dots[[1]]$Party)
    } else if (input$region == "Scotland") {
      colorFactor(pal(), domain = ge.dots.2015[[6]]$Party)
    } else {
      colorFactor(pal(), levels = c("CON", "LAB", "LD", "UKIP", "GREEN"))
    }
  )
  
  zoom <- reactive(
    if (input$region == "London") {
      11
    } else if (input$region == "West Midlands" | input$region == "Yorkshire and The Humber" | 
               input$region == "South East" | input$region == "North East") {
      9
    } else if (input$region == "Scotland") {
      7
    } else {
      8
    }
  )
  
  radiuses <- reactive(
    if (zoom() %in% 7:9) {
      80
    } else if (zoom() %in% 10:11){
      40
    } else {
      10
    }
  )
  
  popup <- reactive(
    if (input$vote == "General Election 2017") {
      paste0(selected.regions[[input$region]]$PCONNAME,
             "<br>Winner: ",             
             selected.regions[[input$region]]$WINNER_2017,
             "<br>Second: ", 
             selected.regions[[input$region]]$SECOND_2017
             ,"<br>Majority: ", 
             selected.regions[[input$region]]$MAJ_2017
      ) %>% lapply(htmltools::HTML)
    } else if (input$vote == "General Election 2015") {
      paste0(selected.regions[[input$region]]$PCONNAME,
             "<br>Winner: ",             
             selected.regions[[input$region]]$WINNER,
             "<br>Second: ", 
             selected.regions[[input$region]]$SECOND
             ,"<br>Majority: ", 
             selected.regions[[input$region]]$MAJ
      ) %>% lapply(htmltools::HTML)
    } else {
      paste0(selected.regions[[input$region]]$PCONNAME,
             "<br>Estimated Constituency Vote",
             "<br>Leave: ", 
             percent(selected.regions[[input$region]]$EUHANLEAVE)
             ,"<br>Remain: ", 
             percent(selected.regions[[input$region]]$EUHANREM)
      ) %>% lapply(htmltools::HTML)
    }
    
  )
  
  output$map <- renderLeaflet({
    
    #token <- "pk.eyJ1IjoiY3VsdHVyZW9maW5zaWdodCIsImEiOiJjajV4cnJ6NzMwNHI5MnFwZ3E4cDFsMTBuIn0.I2QzkctPro7acqZBVaJ7Nw"
    maptile <- "https://api.mapbox.com/styles/v1/cultureofinsight/cj5xt18s90hzq2rpcfk612vkq/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiY3VsdHVyZW9maW5zaWdodCIsImEiOiJjajV4cnJ6NzMwNHI5MnFwZ3E4cDFsMTBuIn0.I2QzkctPro7acqZBVaJ7Nw"
    #map <- paste0(maptile, token)
    mapattr <- '© <a href="https://www.mapbox.com/map-feedback/">Mapbox</a> © <a href="http://www.openstreetmap.org/copyright" target="_blank">OpenStreetMap</a>'
    
    leaflet(data = selected.regions[[input$region]]) %>%
      #addProviderTiles("CartoDB.DarkMatter", options = tileOptions(minZoom = 7, maxZoom = 13)) %>%
      addTiles(urlTemplate = maptile, attribution = mapattr, options = tileOptions(minZoom = 7, maxZoom = 13)) %>% 
      setView(centroids[[input$region]]$x + 0.05, centroids[[input$region]]$y, zoom = zoom()) %>%
      addFullscreenControl
  })
  
  observe({
      withProgress(message = 'Plotting dots',
                   detail = 'This may take a while...',
                   value = 0, {
                     for (i in 1:15) {
                       incProgress(1/15)
                     }
                     leafletProxy("map", data = dots.final()[[input$region]]) %>%
                       clearShapes() %>%
                       addPolygons(data = selected.regions[[input$region]], 
                                   stroke = T, color = "grey", weight = 1, opacity = .1, fillOpacity = 0,
                                   highlightOptions = highlightOptions(
                                     color = "white", weight = 2, opacity = 1, bringToFront = T),
                                   label = popup(),
                                   labelOptions = labelOptions(textsize = "14px"), #~PCONNAME, 
                                   popup = popup()) %>%
                       addCircles(lng = ~x, lat = ~y, weight = 1, radius = radiuses(), 
                                  fillColor = ~cols()(Party), stroke = FALSE, fillOpacity = 1) %>%
                       addLegend("bottomleft", pal = cols(), values = ~Party,
                                 title = "1 Dot = 250 Votes", opacity = 1, layerId = "legend")
                   })
  })
  
  output$bar <- renderPlot({
    if (is.null(input$map_bounds))
      return(NULL)
    ggplot(votes(), aes(x=Party, y = Votes, fill = Party)) +
      geom_bar(stat = "identity") +
      scale_fill_manual(values = pal()) +
      theme_ipsum_rc() +
      labs(subtitle = "Votes within map bounds (c.)") +
      theme(plot.background = element_rect(fill = '#272b30'), legend.position = "none",
            text = element_text(colour = "white"), axis.text = element_text(colour = "white"),
            axis.title = element_blank(), panel.border = element_blank(),
            plot.margin = unit(c(.5,.5,.5,.2), "cm")) + 
      scale_y_comma()
  })
  
}