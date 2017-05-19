library(leaflet)
library(ggplot2)
library(dplyr)
library(scales)
library(hrbrthemes)

# load data previously generated with data_gen_script.R to the environment
load("Data/250data.RData")

function(input, output) {
  
  dots.final <-reactive(
    if (input$vote == "General Election 2015") {
      ge.dots
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
    if (input$vote == "General Election 2015") {
      c("#0087DC", "#DC241F", "#FCBB30", "#70147A", "#78B943", "#FFFF00")
    } else {
      c("RoyalBlue", "Yellow")
    }
  )
  
  cols <-reactive(
    if (input$vote == "General Election 2015") {
      colorFactor(pal(), domain = ge.dots[[6]]$Party)
    } else {
      colorFactor(pal(), domain = brexit.dots[[1]]$Party)
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
      addProviderTiles("CartoDB.DarkMatter", 
                       options = tileOptions(minZoom = 7, maxZoom = 13)) %>% 
      setView(centroids[[input$region]]$x + 0.05, centroids[[input$region]]$y, zoom = zoom())
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
                                   label = ~PCONNAME, 
                                   popup = popup()) %>%
                       addCircles(lng = ~x, lat = ~y, weight = 1, radius = 80, 
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