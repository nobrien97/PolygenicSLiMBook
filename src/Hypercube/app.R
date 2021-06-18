# Shiny app to generate hypercubes, display their information, and save them to file

library(shiny)
library(DoE.wrapper)
library(dplyr)


# Define UI

ui <- fluidPage(
  titlePanel(h1("Latin hypercube generator and visualiser")),
  
  sidebarLayout(
    sidebarPanel(
      h2("Debug"),
      textOutput("debugtext"),
      
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
                   min = 2, max = 20, step = 1, value = 2),
      
      # Number of runs and LHC type
      fluidRow(
        column(width = 6, inline = T,
        numericInput("nruns",
                    "Number of samples",
                    value = 64, step = 1)),
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
    mainPanel(
      plotOutput("hypercubeplot")
    )
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
        column(width = 4, h3(paste("Factor", i), align = "left")),
        column(width = 4,
          textInput(inputId = paste0("fac_name", i), label = "Name", 
                    value = paste("Parameter", i)),
          selectInput(inputId = paste0("fac_type", i), label = "Data type",
                    list("Integer",
                         "Float"))),
        column(width = 4,
          numericInput(inputId = paste0("fac_min", i), label = "Minimum",
                  value = 0),
          numericInput(inputId = paste0("fac_max", i), label = "Maximum",
                  value = 1)),
        align = "center"
)
    })
  })
  
  # Generate hypercube
  
  observeEvent(input$genButton, {
    # Sample a random 32 bit int as a seed for the LHC generation
    lhc_seed <- sample(0:.Machine$integer.max, 1)
    
    # Store factor information to copy into properly formatted list
    facinput <- list(
      name = paste0("input$", grep(pattern = "fac_name+[[:digit:]]", x = names(input), value = TRUE)),
      min = 1:as.integer(input$nfactors),
      max = 1:as.integer(input$nfactors),
      type = 1:as.integer(input$nfactors)
    )
    # Fill in min and max 
    for (i in seq_along(facinput$name)) {
      facinput$min[i] = eval(parse(text = paste0("input$", grep(pattern = paste0("fac_min", i), x = names(input), value = TRUE))))
      facinput$max[i] = eval(parse(text = paste0("input$", grep(pattern = paste0("fac_max", i), x = names(input), value = TRUE))))
      facinput$type[i] = eval(parse(text = paste0("input$", grep(pattern = paste0("fac_type", i), x = names(input), value = TRUE))))
    }

    # Factor information in proper format
    facoutput <- as.list(facinput$name)
    for (i in seq_along(facoutput)) {
      if (facinput$type[i] == "integer")
        facoutput[[i]] = c(as.integer(round(facinput$min[i])), as.integer(round(facinput$max[i])))
      else
        facoutput[[i]] = c(facinput$min[i], facinput$max[i])
    }
    
    parnames <- grep(pattern = "fac_name+[[:digit:]]", x = names(input), value = TRUE)
    parnames <- paste0("input$fac_name", 1:length(parnames))
    output$debugtext <- renderText({parnames})
    
    
  for (i in seq_along(parnames)) {
    parnames[i] <- eval(parse(text = parnames[i]))
  }
    names(facoutput) <- parnames
    

    # Run the lhs
    lhc <- lhs.design(
      nruns = as.integer(trunc(input$nruns)),
      nfactors = as.integer(input$nfactors),
      type = input$lhctype,
      factor.names = facoutput,
      seed = lhc_seed
    )
    
    output$hypercubeplot <- renderPlot({
      plot(lhc)
    })
    
  })
  
  # Save output
  
  eventReactive(input$saveButton, {
    write.csv(input$lhc, input$Filepath)
  })
  
}


# Run the app

shinyApp(ui = ui, server = server)