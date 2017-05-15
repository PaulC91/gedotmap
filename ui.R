library(shiny)
library(shinythemes)
library(leaflet)

navbarPage("The Colours of The Electorate",
           theme = "bootstrap.css",
           #theme = shinytheme('cosmo'),
           
           tabPanel("Map",
                    leafletOutput("map", width = "auto", height = "650px"), #height = "700px"),
                    absolutePanel(id = "controls", class = "panel panel-default", 
                                  fixed = TRUE,
                                  draggable = TRUE, top = "20%", left = 20, right = "auto", bottom = "auto",
                                  width = 300, height = "auto",
                      br(),
                      p("Please allow a few moments for the dots to appear."),
                      p("Hover mouse on the map to highlight constituencies."),
                      p("Click on constituencies for more information"),
                      br(),
                      selectInput("vote", "What Results?", c("General Election 2015", "EU Referendum 2016"),
                                   selected = "General Election 2015"),
                      selectInput("region", "What Region?",
                                   c("London", "East", "East Midlands", "North East", "North West",
                                     "Scotland", "South East", "South West", "Wales", "West Midlands",
                                     "Yorkshire and The Humber"), selected = "London"),
                      br(),
                      p("Map by", a("Culture of Insight", href = "http://cultureofinsight.com", target = "_blank"), 
                        a("@datasetfree", href = "https://twitter.com/datasetfree", target = "_blank")),
                      p("Data sources:", a("Alasdair Rae, ", 
                        href = "http://www.statsmapsnpix.com/2017/04/getting-ready-for-ge2017-big-shapefile.html", 
                        target = "_blank"),
                        a("Chris Hanretty", 
                          href = "https://medium.com/@chrishanretty/final-estimates-of-the-leave-vote-or-areal-interpolation-and-the-uks-referendum-on-eu-membership-5490b6cab878", 
                          target = "_blank"))
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