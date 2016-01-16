library(shiny)
source('helper.R')

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Hello Shiny!"),
  
  
  # Sidebar with a slider input for the number of bins
  fluidRow(
    column(3,
      selectInput('Wrestler','Name',
                  c(wrestler.names), selected = 'Randy Savage')
    )),
    
    # Show a plot of the generated distribution
    mainPanel(
      fluidRow(column(7, plotOutput("distPlot")),column(5,plotOutput('graphPlot'))
      ),
      textOutput("Record"),
      br(),
      fluidRow(
      column(5,
      h5("Most Wins Against:"),
      tableOutput("Wins")),
      column(5,
      h5("Most Losses Against:"),
      tableOutput("Losses"))),
      br(),
      textOutput("Accuracy"),
      br(),
      tableOutput("Xtable"),
      br(),
      plotOutput("perf"),
      br(),
      textOutput('area.under.curve'),
      br(),
      tableOutput('strong.moves'),
      br(),
      tableOutput('danger.moves')
      
    )
  )
)