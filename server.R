library(leaflet)
library(scales)

# load data previously generated with data_gen_script.R to the environment
load("Data/newdata.RData")

function(input, output) {
  
  # get different zoom levels for different regions
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
  
  popup <- reactive(
    if (input$vote == "General Election 2015") {
      paste0("Winner: ",             
             selected.regions[[input$region]]$WINNER,
             "<br>Second: ", 
             selected.regions[[input$region]]$SECOND
             ,"<br>Majority: ", 
             selected.regions[[input$region]]$MAJ
      )
    } else {
      paste0("Probable Constituency Vote",
             "<br>Leave: ", 
             percent(selected.regions[[input$region]]$EUHANLEAVE)
             ,"<br>Remain: ", 
             percent(selected.regions[[input$region]]$EUHANREM)
      )
    }
    
  )
  
  output$map <- renderLeaflet({
    leaflet(selected.regions[[input$region]]) %>%
      addProviderTiles("CartoDB.DarkMatter", options = tileOptions(minZoom = 7)) %>% 
      setView(centroids[[input$region]]$x, centroids[[input$region]]$y, zoom = zoom())
  })
  
  observe({
    if (input$vote == "General Election 2015") {
      pal <- c("#0087DC", "#DC241F", "#FCBB30", "#70147A", "#78B943", "#FFFF00")
      cols <- colorFactor(pal, domain = ge.dots[[6]]$Party)
      withProgress(message = 'Plotting dots',
                   detail = 'This may take a while...',
                   value = 0, {
                     for (i in 1:15) {
                       incProgress(1/15)
                     }
                     leafletProxy("map", data = ge.dots[[input$region]]) %>%
                       clearShapes() %>%
                       addPolygons(data = selected.regions[[input$region]], 
                                   stroke = T, color = "grey", weight = 1, opacity = .1, fillOpacity = 0,
                                   highlightOptions = highlightOptions(
                                     color = "white", weight = 3, opacity = 1, bringToFront = T),
                                   label = ~PCONNAME, 
                                   popup = popup()) %>%
                       addCircles(lng = ~x, lat = ~y, weight = 1, radius = 50, 
                                  fillColor = ~cols(Party), stroke = FALSE, fillOpacity = 0.8) %>%
                       addLegend("topright", pal = cols, values = ~Party,
                                 title = "1 Dot = 100 Votes", opacity = 1, layerId = "legend")
                   })
    } else {
      pal <- c("RoyalBlue", "Yellow")
      cols <- colorFactor(pal, domain = brexit.dots[[1]]$Party)
      withProgress(message = 'Plotting dots',
                   detail = 'This may take a while...',
                   value = 0, {
                     for (i in 1:15) {
                       incProgress(1/15)
                     }
                     leafletProxy("map", data = brexit.dots[[input$region]]) %>%
                       clearShapes() %>%
                       addPolygons(data = selected.regions[[input$region]], 
                                   stroke = T, color = "grey", weight = 1, opacity = .1, fillOpacity = 0,
                                   highlightOptions = highlightOptions(
                                     color = "white", weight = 3, opacity = 1, bringToFront = T),
                                   label = ~PCONNAME, 
                                   popup = popup()) %>%
                       addCircles(lng = ~x, lat = ~y, weight = 1, radius = 50, 
                                  fillColor = ~cols(Party), stroke = FALSE, fillOpacity = 0.8) %>%
                       addLegend("topright", pal = cols, values = ~Party,
                                 title = "1 Dot = 100 Votes", opacity = 1, layerId = "legend")
                   })
    }
  })
  
}