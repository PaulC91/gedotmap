library(leaflet)

# load data previously generated with data_gen_script.R to the environment
load("Data/shinydata.RData")

function(input, output) {
  
  pal <- c("#0087DC", "#DC241F", "#FCBB30", "#70147A", "#78B943", "#FFFF00")
  cols <- colorFactor(pal, domain = dots.final[[6]]$Party)
  
  # get different zoom levels for different regions
  zoom <- reactive(
    if (input$region == "London") {
      10
    } else if (input$region == "Scotland") {
      7
    } else {
      8
    }
  )
  
  popup <- reactive(
    paste0("Winner: ",             
           selected.regions[[input$region]]$WINNER,
           "<br>Second: ", 
           selected.regions[[input$region]]$SECOND
           ,"<br>Majority: ", 
           selected.regions[[input$region]]$MAJ
    )
  )
  
  output$map <- renderLeaflet({
    leaflet(selected.regions[[input$region]]) %>%
      addProviderTiles("CartoDB.DarkMatter", options = tileOptions(minZoom = 7)) %>% 
      setView(centroids[[input$region]]$x, centroids[[input$region]]$y, zoom = zoom()) %>%
      addPolygons(stroke = T, color = "white", weight = 1, opacity = .1, fillOpacity = 0,
                  highlightOptions = highlightOptions(
                    color = "white", weight = 3, opacity = 1, bringToFront = T),
                  label = ~PCONNAME, 
                  popup = popup()) #popup text is grey, any way to make it black?
  })
  
  observe({
    withProgress(message = 'Plotting dots',
                 detail = 'This may take a while...',
                 value = 0, {
                   for (i in 1:15) {
                     incProgress(1/15)
                   }
                   leafletProxy("map", data = dots.final[[input$region]]) %>%
                     addCircles(lng = ~x, lat = ~y, weight = 1, radius = 50, 
                                fillColor = ~cols(Party), stroke = FALSE, fillOpacity = 0.8) %>%
                     addLegend("topright", pal = cols, values = ~Party,
                               title = "1 Dot = 100 Votes", opacity = 1)
                 })
  })
  
}