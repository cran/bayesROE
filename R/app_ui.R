#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny 
#' @importFrom colourpicker colourInput
#' @importFrom golem get_golem_options
#' @noRd
app_ui <- function(request) {
  # set default options
  inits <- get_golem_options("inits")
  ref_cols <- get_golem_options("ref_cols")
  
  # fundamental sidebar elements
  sidebar_args <- list(
    fluidRow(
      column(radioButtons(inputId = "type", label = "Plot Type", 
                          choices = list("Threshold"="thres","Probability"="prob")),
             width = 6),
      column(sliderInput(inputId = "nregion", label = "Regions", 
                         min = 1, max = 5, value = length(inits$delta), step = 1, ticks = FALSE),
             width = 6)
    ),
    numericInput(inputId = "ee", label = "Effect Estimate", value = inits$ee,
                 min = -10, max = 10, step = 0.01),
    numericInput(inputId = "se", label = "Standard Error", value = inits$se,
                 min = 0.1, max = 10, step = 0.01),
    br()
  )
  
  # additional sidebar elements | Plot Type
  sidebar_args[[length(sidebar_args)+1]] <- uiOutput("add_sidebar")
  sidebar_args[["width"]] <- 3
  
  tagList(
    # adding external resources
    golem_add_external_resources(),
    # application UI logic
    fluidPage(
      titlePanel("Bayesian Regions of Evidence"),
      
      sidebarLayout(
        do.call(sidebarPanel, args = sidebar_args),
        mainPanel(width = 9,
                  plotOutput(outputId = "ROEplot"),
                  fluidRow(
                    column(
                      wellPanel(
                        fluidRow(
                          column(
                            uiOutput("plot_limits"),
                            checkboxInput(inputId = "addRef", label = "Show Sceptical Prior", value = FALSE),
                            
                            checkboxInput(inputId = "addEst", label = "Show Effect Estimate", value = FALSE),
                            checkboxInput(inputId = "addConfl", label = "Conflict Region", value = FALSE),
                            width = 6),
                          column(
                            sliderInput(inputId = "col_alpha", label = "Colour Opacity", min = 0, max = 1, value = 1, step = 0.1, ticks = FALSE),
                            colourInput(inputId = "col_lower", label = "Lower Colour Key", value = ref_cols$col_lower),
                            colourInput(inputId = "col_upper", label = "Upper Colour Key", value = ref_cols$col_upper),
                            checkboxInput(inputId = "flip", label = "Flip Axes", value = FALSE),
                            width = 6)
                        ),
                      ), width = 6),
                    column(
                      wellPanel(
                        fluidRow(
                          column(downloadButton(outputId = "fig_download",
                                                label = "Download Figure"),
                                 br(),br(),
                                 selectInput(inputId = "fig_format", label = "Data Format", 
                                             choices = list("pdf", "eps", "svg", "tex", "png", "tiff"), 
                                             selected = "pdf"),
                                 numericInput(inputId = "fig_width", label = "Figure Width (mm)", 
                                              min = 150, max = 400, step = 10, value = 200),
                                 width=6),
                          
                          column(radioButtons(inputId = "fig_aspect", label = "Aspect Ratio", 
                                              choices = list("4:3", "16:9", "16:10"), selected = "4:3"),
                                 width=6)
                        )
                      ), width = 6)
                  )
        )
      )
    )
  )
  
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "bayesROE"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
