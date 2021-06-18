# Shiny app to generate hypercubes, display their information, and save them to file

library(shiny)
library(DoE.wrapper)

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
  titlePanel(h1("Latin hypercube generator and visualiser")),
  
  sidebarLayout(
    sidebarPanel(
      h2("Options"),
      # Generate hypercube button
      fluidRow(
        column(width = 6, style = "margin-top: 25px;",
               actionButton(inputId = "genButton",
                            label = "Generate hypercube!",
                            icon = icon("play")))
      ),
      br(),
      # Save button and filepath entry
      fluidRow(style = "display:inline-block;",
               column(width = 10,
                      textInput(inputId = "saveText",
                                label = "Filepath",
                                placeholder = "~/hypercube.csv")
               ),
               column(width = 2, style = "margin-top: 25px;",
                      actionButton(inputId = "saveButton",
                                   label = "Save file!",
                                   icon = icon("save")))
      ),
      sliderInput("nfactors",
                   h3("Number of hypercube parameters"),
                   min = 1, max = 20, step = 1, value = 1),
      
      # Number of runs and LHC type
      fluidRow(
        column(width = 6, inline = T,
        numericInput("nruns",
                    "Number of samples",
                    value = 512, step = 1)),
        column(width = 6, inline = T,
        selectInput("lhctype", 
                    "Sampling method",
                    choices = list(
                                "genetic",
                                "improved",
                                "maximin",
                                "optimum",
                                "random"
                    ), selected = "maximin")
      )),
    
      uiOutput("factors"),
      

    ),
    mainPanel()
  )
  
)

# Define server

server <- function(input, output, session) {
  
  # Generate factors
  output$factors <- renderUI({
    numFactors <- as.integer(input$nfactors)
    lapply(1:numFactors, function(i) {

      # Inputs and factor name
      fluidRow(
        column(width = 3, h3(paste("Factor", i), align = "left")),
        column(width = 4,
        selectInput(inputId = paste0("fac_type", i), label = h4("Data type"),
                    list("Integer" = 1,
                         "Float" = 2))),
        column(width = 4,
        numericInput(inputId = paste0("fac_min", i), label = h4("Minimum"),
                  value = 0)),
        column(width = 4,
        numericInput(inputId = paste0("fac_max", i), label = h4("Maximum"),
                  value = 1)),
        align = "center"
)
    })
  })
  
  # Generate hypercube
  
  eventReactive(input$genButton, {
    # Sample a random 32 bit int as a seed for the LHC generation
    lhc_seed <- sample(0:.Machine$integer.max, 1)
    
    lhc <- lhs.design(
      nruns = as.integer(trunc(input$nruns)),
      nfactors = as.integer(input$nfactors),
      type = input$lhctype,
      factor.names = list(
        param1 = c(0.0, 1.0),
        param2 = c(100, 20000)),
      seed = lhc_seed
    )
    
  })
  
  # Save output
  
  eventReactive(input$saveButton, {
    print("saved")
    write.csv(input$lhc, input$Filepath)
  })
  
}


# Run the app

shinyApp(ui = ui, server = server)