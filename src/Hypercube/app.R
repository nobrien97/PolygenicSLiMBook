# Shiny app to generate hypercubes, display their information, and save them to file

library(shiny)

# Helper functions

numericInputInline <-function(inputId, label, value = "") 
{
  div(type = "text/css",
      style="display: inline-block;
             padding-right: 40px;",
      tags$label(label, `for` = inputId), 
      tags$input(id = inputId, type = "numeric", value = value, class = ))
}

selectInputInline <- function(inputId, label)
{
  div(style="label.control-label, .selectize-control.single{ display: table-cell; text-align: center; vertical-align: middle; } .form-group { display: table-row;}",
      tags$label(label, `for` = inputId),
      tags$input(id = inputId, choices = ))
}


# Define UI

ui <- fluidPage(
  titlePanel("Latin hypercube generator and visualiser"),
  
  sidebarLayout(
    sidebarPanel("Options",
      sliderInput("nfactors",
                   h3("Number of hypercube parameters"),
                   min = 1, max = 20, step = 1, value = 1),
      uiOutput("factors"), width = 12),
    mainPanel()
  )
  
)

# Define server

server <- function(input, output, session) {
  output$factors <- renderUI({
    numFactors <- as.integer(input$nfactors)
    lapply(1:numFactors, function(i) {
      fluidRow(style = "text-align: center;
                 vertical-align:top;",
        div(h3(paste("Factor", i))),
        div(selectInput(inputId = paste0("fac_type", i), label = h4(paste("Data type for factor", i)),
                    list("Integer" = 1,
                         "Float" = 2)), style = "display: inline-block; padding-right: 40px;"),
        div(numericInput(inputId = paste0("fac_min", i), label = h4("Minimum"),
                  value = 0), style = "display: inline-block; padding-right: 40px;"),
        div(numericInput(inputId = paste0("fac_max", i), label = h4("Maximum"),
                  value = 1), style = "display: inline-block; padding-right: 40px;"),
        br(),
        br()
)
    })
  })
}


# Run the app

shinyApp(ui = ui, server = server)