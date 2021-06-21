# Shiny app to generate hypercubes, display their information, and save them to file

library(shiny)
library(shinyjs)
library(DoE.wrapper)
library(ggplot2)
library(GGally)


# Initialise variables for factor generation

num_factors <- 2 # keep track of the number of factors being added/removed at a time
current_id <- 1 # current module ID for adding factors
facCount <- 2 # current total count of factors, for plot width/height in ui()

# Helper function to prevent user idiocy (generating LHC before the factors are generated)
buttonLocker <- function(buttons) {
  for (button in buttons)
    toggleState(button)
} 
buttons <- c("saveButton", "genButton")


# Modules for factor generation: https://stackoverflow.com/questions/62811707/shiny-dynamic-ui-resetting-to-original-values

modFacDraw <- function(id) {
  ns <- NS(id)

  # Inputs and factor name
  fluidRow(
    id = id,
    column(width = 4, inline = T, id = "facNum",
           h3(paste("Factor", current_id), align = "left")), 
    column(width = 4, inline = T,
           uiOutput(ns("facName")), 
           uiOutput(ns("facType"))),
    column(width = 4, inline = T,
           uiOutput(ns("facMin")),
           uiOutput(ns("facMax"))),
                                      
    align = "center"
  )
}


modFacServ <- function(input, output, session, data) {
  ns <- session$ns
  
  output$facName <- renderUI({
              textInput(inputId = ns("fac_name"), label = "Name", 
                        placeholder = paste("Parameter", substr(ns(NULL), 8, nchar(ns(NULL))))) # forgive me
  })                                                    # id is module_x, we need x, so substring it
    
  output$facType <- renderUI({
              selectInput(inputId = ns("fac_type"), label = "Data type",
              list("Integer",
                   "Float"))
  })
              
  output$facMin <- renderUI({
              numericInput(inputId = ns("fac_min"), label = "Minimum",
                           value = 0)
  })
    
  output$facMax <- renderUI({
              numericInput(inputId = ns("fac_max"), label = "Maximum",
                           value = 1)
      })
}



# Define UI

ui <- fluidPage(
  useShinyjs(),
  titlePanel(h1("Latin hypercube generator and visualiser")),
  
  sidebarLayout(
    sidebarPanel(
#      h2("Debug"),
#      textOutput("debugtext"),
      
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
    
    tags$div(id = "facInsert")

    ),
    mainPanel(
      column(width = 12,
             tags$div(id = "plotInsert")),
      div(),
      
    )
  )
  
)



# Define server

server <- function(input, output, session) {
  # Disable buttons while factors aren't generated: stops issues with trying to 
  # generate LHC while factors are still generating
  
  buttonLocker(buttons)
  # Generate factors: on initial load
  
  for (i in seq_len(num_factors)) {
    insertUI(selector = "#facInsert",
             ui = modFacDraw(paste0("module_", current_id)))
    
    callModule(modFacServ, paste0("module_", current_id))
    
    current_id <<- current_id + 1
  }
  buttonLocker(buttons)
  
  
  # Update factors, adding or removing UI elements row wise
  observeEvent(input$nfactors, {
    buttonLocker(buttons)
    
    if (input$nfactors > num_factors) {
      for (i in seq_len(input$nfactors - num_factors)) {
    
        
        insertUI(selector = "#facInsert",
                 ui = modFacDraw(paste0("module_", current_id)))
        
        callModule(modFacServ, paste0("module_", current_id))
        
        current_id <<- current_id + 1
      }
    } else {
      for (i in seq_len(num_factors - input$nfactors)) {
        removeUI(selector = paste0("#module_", current_id - 1))
        current_id <<- current_id - 1
      }
    }
    num_factors <<- input$nfactors
    
    
    buttonLocker(buttons)
    
}, ignoreInit = T)
  
  
  
  # Generate hypercube
  
  observeEvent(input$genButton, {
    buttonLocker(buttons)
    
    
    # Sample a random 32 bit int as a seed for the LHC generation
    lhc_seed <- sample(0:.Machine$integer.max, 1)
    
    # Store factor information to copy into properly formatted list
    facinput <- list(
      name = 1:as.integer(input$nfactors),
      min = 1:as.integer(input$nfactors),
      max = 1:as.integer(input$nfactors),
      type = 1:as.integer(input$nfactors)
    )
    
    
    
    # Fill in min, max, type, and fix names so they are in the correct order
    for (i in seq_along(facinput$name)) {
      facinput$name[i] = eval(parse(text = paste0("input$", "`module_", i, "-fac_name`")))
      if (facinput$name[i] == "")
        facinput$name[i] = paste("Parameter", i)
      facinput$min[i] = eval(parse(text = paste0("input$", "`module_", i, "-fac_min`")))
      facinput$max[i] = eval(parse(text = paste0("input$", "`module_", i, "-fac_max`")))
      facinput$type[i] = eval(parse(text = paste0("input$", "`module_", i, "-fac_type`")))
    }
    

    
    # This puts min, max and type in the correct order
    
    # Factor information in proper format
    facoutput <- as.list(facinput$name)
    for (i in seq_along(facoutput)) {
      if (facinput$type[i] == "integer")
        facoutput[[i]] = c(as.integer(round(facinput$min[i])), as.integer(round(facinput$max[i])))
      else
        facoutput[[i]] = c(facinput$min[i], facinput$max[i])
    }
    
    
    names(facoutput) <- facinput$name
    
    
    # Run the lhs
    lhc <- lhs.design(
      nruns = as.integer(trunc(input$nruns)),
      nfactors = as.integer(input$nfactors),
      type = input$lhctype,
      factor.names = facoutput,
      seed = lhc_seed
    ) 
    
    # If we've run this before, we need to remove the existing plot for the cor table to draw properly
    removeUI(selector = "#hcPlotCor", immediate = T)
    

    insertUI(selector = "#plotInsert",
             ui = tags$div(id = "hcPlotCor",
                           plotOutput("hypercubeplot", width = 250*input$nfactors, height = 250*input$nfactors),
                           tableOutput("hcCorTable")
             )
    )
    
    output$hypercubeplot <- renderPlot(
      width = 250*input$nfactors,
      height = 250*input$nfactors,
      {
        ggpairs(lhc, progress = F,
          lower = list(continuous = wrap("points", size = 0.1))) +
          theme_classic() +
          theme(text = element_text(size = 22, face = "bold"),
                panel.spacing = unit(1, "lines")
          )
      })
    
    
    output$hcCorTable <- renderTable({
      cor(lhc)
    })
    
    

    buttonLocker(buttons)
    
  })
  
  # Save output
  
  eventReactive(input$saveButton, {
    disable("genButton")
    write.csv(input$lhc, input$Filepath)
    enable("genButton")
    
  })
  
}


# Run the app

shinyApp(ui = ui, server = server)