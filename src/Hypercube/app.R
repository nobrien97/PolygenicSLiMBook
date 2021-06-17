# Shiny app to generate hypercubes, display their information, and save them to file

library(shiny)

# Define UI

ui <- fluidPage(
  titlePanel("Latin hypercube generator and visualiser"),
  
  sidebarLayout(
    sidebarPanel("Options",
      numericInput("nfactors",
                   h3("Number of hypercube parameters"),
                   value = 3),
      uiOutput("factors")),
    mainPanel()
  )
  
)

# Define server

server <- function(input, output, session) {
  output$factors <- renderUI({
    numFactors <- as.integer(input$nfactors)
    lapply(1:numFactors, function(i) {
      fluidRow(
        column(width = 3,
               numericInput(inputID = paste0("fac_min", i), label = h3(paste("Minimum for factor", i)),
                  value = 0)),
        column(width = 3,
               numericInput(inputID = paste0("fac_max", i), label = h3(paste("Maximum for factor", i)),
                            value = 1)),
      )
      selectInput(inputID = paste0("fac_type", i), label = h3(paste("Data type for factor", i)),
                  choices = list("Integer" = 1,
                                 "Float" = 2))
    })
  })
}

# Run the app

shinyApp(ui = ui, server = server)