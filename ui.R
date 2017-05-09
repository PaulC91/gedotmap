library(shiny)
library(leaflet)

navbarPage("The Colours of The 2015 Electorate",
           theme = "bootstrap.css",
           
           tabPanel("Map",
                    sidebarLayout(
                      sidebarPanel(
                        p("Please allow a few moments for the dots to appear."),
                        p("Hover mouse on the map to highlight constituencies."),
                        p("Click on constituencies for Winner, Second Place and Majority."),
                        br(),
                        radioButtons("region", "Select a Region:",
                                     c("London", "East", "East Midlands", "North East", "North West",
                                       "Scotland", "South East", "South West", "Wales", "West Midlands",
                                       "Yorkshire and The Humber"), selected = "London"),
                        br(),
                        p("Map by", a("Culture of Insight", href = "http://cultureofinsight.com", target = "_blank"), 
                          a("@datasetfree", href = "https://twitter.com/datasetfree", target = "_blank")),
                        p("Data source:", a("Alasdair Rae", 
                          href = "http://www.statsmapsnpix.com/2017/04/getting-ready-for-ge2017-big-shapefile.html", 
                          target = "_blank"))
                      ),
                      
                      mainPanel(
                        leafletOutput("map", height = "525px")
                      )
                    )
           ),
           
           tabPanel("About",
                    fluidRow(
                      column(12,
                             wellPanel(
                               includeMarkdown("README.md"))
                      
                      )
                    ))
  
)