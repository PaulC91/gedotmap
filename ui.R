library(shiny)
library(leaflet)

tags$head(tags$link(rel="shortcut icon", href="/www/favicon.png"))

navbarPage("The Colours of The Electorate",
           theme = "bootstrap.css",
           
           tabPanel("Map",
                    div(class="outer",
                        leafletOutput("map", width = "100%", height = "100%"), #
                        absolutePanel(id = "controls", class = "panel panel-default", 
                                      fixed = TRUE,
                                      draggable = TRUE, top = "10%", left = "auto", right = 20, bottom = "auto",
                                      width = 330, height = "auto", cursor = "move",
                                      br(),
                                      p("Please allow a few moments for the dots to appear."),
                                      p("Hover mouse on the map to highlight constituencies."),
                                      p("Click on constituencies for more information"),
                                      selectInput("region", "What Region?",
                                                  c("London", "East", "East Midlands", "North East", "North West",
                                                    "Scotland", "South East", "South West", "Wales", "West Midlands",
                                                    "Yorkshire and The Humber"), selected = "London"),
                                      selectInput("vote", "What Results?", c("General Election 2017", "General Election 2015", "EU Referendum 2016"),
                                                  selected = "General Election 2017"),
                                      plotOutput("bar", height = "250px"),
                                      br(),
                                      p("Map by", a("Culture of Insight", href = "http://cultureofinsight.com", target = "_blank"), 
                                        a("@datasetfree", href = "https://twitter.com/datasetfree", target = "_blank")),
                                      p("Data sources:", a("Alasdair Rae, ", 
                                                           href = "http://www.statsmapsnpix.com/2017/04/getting-ready-for-ge2017-big-shapefile.html", 
                                                           target = "_blank"),
                                        a("Chris Hanretty,", 
                                          href = "https://medium.com/@chrishanretty/final-estimates-of-the-leave-vote-or-areal-interpolation-and-the-uks-referendum-on-eu-membership-5490b6cab878", 
                                          target = "_blank"),
                                        a("Commons Library", 
                                          href = "http://researchbriefings.parliament.uk/ResearchBriefing/Summary/CBP-7979", 
                                          target = "_blank"))
                            )
                          )
                        ),
                    
           tabPanel("About",
                    fluidRow(
                      column(12,
                             wellPanel(
                               includeMarkdown("about.md"))
                            )
                            )
                    )
           
)