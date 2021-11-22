# Shiny app to generate hypercubes, display their information, and save them to file

library(shiny)
library(shinyjs)
library(shinyalert)
library(htmltools)
library(DoE.wrapper)
library(ggplot2)
library(GGally)
library(DT)


# Initialise variables 

num_factors <- 2 # keep track of the number of factors being added/removed at a time
current_id <- 1 # current module ID for adding factors
facCount <- 2 # current total count of factors, for plot width/height in ui()

hasBeenPressed <- c(FALSE, FALSE) # Since dynamic elements aren't playing nicely with IgnoreInit and IgnoreNULL, we need
                                  # to manually check if our generation buttons have been pressed yet or not

# Helper function to prevent user idiocy (generating LHC before the factors are generated)
buttonLocker <- function(buttons) {
  for (button in buttons)
    toggleState(button)
} 
buttons <- c("saveButton", "genButton")

# Helper function to set an appropriate placeholder name so we don't 
# overwrite existing files
findPlaceholderName <- function() {
  placeholderName <- ""
  prevCubes <- list.files("~", pattern = "hypercube[0-9]*.csv")
  if (length(prevCubes) < 1)
    placeholderName <- "~/hypercube.csv"
  prevCubes <- regmatches(prevCubes, regexpr("[0-9]+", prevCubes))
  if (length(prevCubes) < 1 & nchar(placeholderName) < 1) {
    placeholderName <- "~/hypercube1.csv"
  } else if (nchar(placeholderName) < 1) {
    largestCube <- max(as.numeric(prevCubes))
    placeholderName <- paste0("~/hypercube", largestCube + 1, ".csv")
  }
  return(placeholderName)
}

defaultSaveName <- findPlaceholderName()


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
  useShinyalert(),
  titlePanel(h1("Latin hypercube generator and visualiser")),
  #  img(src = 'Hypercubebanner.png',
  #      height = 512, width = 512),
  br(),
  mainPanel(
    tabsetPanel(id = "uiTabset",
      tabPanel(title = "Options",
               value = "tabOptions",
                 # Generate hypercube button
               
               # h2("Debug"),
               # actionButton("debugTabSwitch", "switch"),
                br(),
                 # Number of runs and LHC type
                 fluidRow(
                   column(width = 7, inline = T,
                          sliderInput("nfactors",
                                      h3("Number of hypercube parameters"),
                                      min = 2, max = 12, step = 1, value = 2, width = '100%')),
                   column(width = 5, inline = F,
                          numericInput("nruns",
                                       "Number of samples",
                                       value = 64, step = 1)),
                   column(width = 5, inline = F,
                          selectInput("lhctype", 
                                      "Sampling method",
                                      choices = list(
                                        "Genetic Algorithm" = "genetic",
                                        "Euclidean Distance" = "improved",
                                        "Maximise Minimum Distance" = "maximin",
                                        "Columnwise Pairwise" = "optimum",
                                        "Random" = "random"
                                      ), selected = "maximin"),
                          helpText(tags$a(href="https://cran.r-project.org/web/packages/lhs/lhs.pdf", target="_blank", 
                                          "Information on each option can be found in the docs for LHS")),
                   ),
                   column(width = 12, inline = T,
                          h3("Maximum correlation between parameters"),
                          helpText("Set the maximum correlation between variables and the number
                   of times you would like to try to find a hypercube with a 
                   maximum correlation less than that value.")),
                   column(width = 6, inline = T,
                          numericInput("corr_thres",
                                       "Maximum correlation",
                                       value = 0.05)),
                   column(width = 6, inline = T,
                          numericInput("max_iter",
                                       "Maximum iterations",
                                       value = 10))
                   
                 ),
#               ),
      ),
      
      tabPanel(title = "Parameters",
               value = "tabParameters",
               fluidRow(
                 column(width = 12, inline = T,
                        br())
               ),
               fluidRow(
                 column(width = 4, style = "margin-top: 25px;",
                        actionButton(inputId = "genButton",
                                     label = "Generate hypercube!",
                                     icon = icon("play"))),
                 # Save button and filepath entry
                 style = "display:inline-block;",
                 column(width = 5,
                        textInput(inputId = "saveText",
                                  label = "Filepath",
                                  placeholder = defaultSaveName)
                 ),
                 column(width = 2, style = "margin-top: 25px;",
                        actionButton(inputId = "saveButton",
                                     label = "Save file!",
                                     icon = icon("save")))
                 
               ),
               tags$div(id = "facInsert"),
      ),
      
    
    tabPanel(title = "Diagnostics",
             value = "tabDiagnostics",
             fluidRow(
              # Fix the height and width of the image to the row dimensions
              tags$style(HTML("div#plotInsert img {width: 100%; height: 100%;}")),
                 column(12, tags$div(id = "plotInsert")
                                )))
      )
    )
  )




# Define server

server <- function(input, output, session) {
  # Cleanup global objects after we're done
  onStop(function() {
    if (exists("lhcFile"))
      lhcFile <<- NULL
  })
  
  # Debug button
  # observeEvent(input$debugTabSwitch, {
  #   updateTabsetPanel(inputId = "uiTabset", selected = "tabParameters")
  # })
  
  # Disable buttons while factors aren't generated: stops issues with trying to 
  # generate LHC while factors are still generating
  buttonLocker(buttons)
  defaultSaveName <- findPlaceholderName()
  
  # Every 10 seconds update the placeholder name
  # TODO: get this to work - update placeholder text
  observe({
    invalidateLater(10000, session)
    defaultSaveName <- findPlaceholderName()
    updateTextInput(session, "saveText",
                    placeholder = defaultSaveName)
  })
  
  # Generate factors: on initial load
  for (i in seq_len(num_factors)) {
    insertUI(selector = "#facInsert",
             ui = modFacDraw(paste0("module_", current_id)))
    callModule(modFacServ, paste0("module_", current_id))
    current_id <<- current_id + 1
  }
  
  buttonLocker(buttons)
  
  
  # When the user changes the number of factors, 
  # update the list, adding or removing UI elements row wise
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
    if (input$genButton == TRUE)
      hasBeenPressed[1] <<- TRUE
    
    if (!hasBeenPressed[1]) {
      shinyalert("Error", "Safeguard boolean genButton not checked. Tell a developer.")
      return()
    }
    


    buttonLocker(buttons)
    
    
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
    
    # Factor information in proper format
    facoutput <- as.list(facinput$name)
    for (i in seq_along(facoutput)) {
      if (facinput$type[i] == "integer")
        facoutput[[i]] = c(as.integer(round(facinput$min[i])), as.integer(round(facinput$max[i])))
      else
        facoutput[[i]] = c(facinput$min[i], facinput$max[i])
    }
    
    names(facoutput) <- facinput$name
    
    # Run the lhc until we get a good result with acceptable correlations
    iter <- 0
    repeat {
      iter <- iter + 1
      if (iter >= ceiling(input$max_iter)) {
        updateTabsetPanel(inputId = "uiTabset", selected = "tabOptions")
        shinyalert("Error",
          paste("Unable to find a hypercube with maximum correlation",
            input$corr_thres, "within", input$max_iter, "attempts."),
          type = "error")
        buttonLocker(buttons)
        return()
      }
      # Sample a random 32 bit seed for the LHC generation
      lhc_seed <- sample(0:.Machine$integer.max, 1)
      lhc <- lhs.design(
        nruns = as.integer(trunc(input$nruns)),
        nfactors = as.integer(input$nfactors),
        type = input$lhctype,
        factor.names = facoutput,
        seed = lhc_seed
      )
      maxCor <- max(abs(cor(lhc)[upper.tri(cor(lhc))]))
      if (maxCor < input$corr_thres)
        break
    }
    if (iter < ceiling(input$max_iter)) {
      # If we've run this before, we need to remove the existing plot for the cor table to draw properly
      removeUI(selector = "#hcPlotCor", immediate = T)
      insertUI(selector = "#plotInsert",
               ui = tags$div(id = "hcPlotCor",
                             fluidRow(
                               column(12,
                                      h3("Hypercube distribution and correlations"),
                                      br(),
                                      h4(paste0("Seed: ", as.character(lhc_seed))),
                                      plotOutput("hypercubeplot", width = '100%', height = '100%')
                                      #250*input$nfactors, height = 250*input$nfactors),
                               )),
                             br(),
                             h3("Correlation matrix"),
                             fixedRow(
                               column(width = 6, 
                                      DT::dataTableOutput("hcCorTable"), style = "width:100%; overflow-y: scroll;overflow-x: scroll;"
                               )
                             )
               ))
      
      
      # Render output figures
    
    output$hypercubeplot <- renderPlot(
      width = 250*input$nfactors,
      height = 250*input$nfactors,
      {
        ggpairs(lhc, progress = F,
          lower = list(continuous = wrap("points", size = 0.1)),
          upper = list(continuous = wrap("cor", size=10))) +
          theme_classic() +
          theme(text = element_text(size = 22, face = "bold"),
                panel.spacing = unit(1.5, "lines")
          )
      })
    
    output$hcCorTable <- renderDataTable({
      datatable(round(cor(lhc), digits = 3), options = list(paging = FALSE, searching = FALSE))
    })
    


    # return lhc for saving
    lhcFile <<- lhc
    
    }
    buttonLocker(buttons)
    updateTabsetPanel(inputId = "uiTabset", selected = "tabDiagnostics")
  })
  
  # Save output
  
  observeEvent(input$saveButton, {
    if (input$saveButton == TRUE)
      hasBeenPressed[2] <<- TRUE
    
    if (!hasBeenPressed[2]) {
      shinyalert("Error", "Safeguard boolean saveButton not checked. Tell a developer.")
      return()
    }
    
    buttonLocker(buttons)
    savePath <- input$saveText
    if (!exists("lhcFile")) {
      shinyalert("Error", "To save a hypercube, you must first generate a hypercube. Such is the way of our linear understanding of time.", type = "error")
      buttonLocker(buttons)
      return()
    } 
    
     if (nchar(savePath) == 0)
         savePath <- findPlaceholderName()
    
    tryCatch(
      expr = {
        write.csv(lhcFile, savePath)
        shinyalert("Success", paste("Hypercube .csv saved to", savePath), type = "success")
      },
      error=function(e) {
        savePath <- findPlaceholderName()
        shinyalert("Warning", paste("Improper save path - writing to default file",
                                    savePath), type = "warning")
        write.csv(lhcFile, savePath)
      },
      warning=function(w) {
        savePath <- findPlaceholderName()
        shinyalert("Warning", paste("Improper save path - writing to default file",
                                    savePath), type = "warning")
        write.csv(lhcFile, savePath)
      })
    # Update placeholder value
    updateTextInput(session, "saveText",
                    placeholder = findPlaceholderName())
  
    buttonLocker(buttons)
    
  })
  
}


# Run the app

shinyApp(ui = ui, server = server)
