library(shiny)
library(DT)
library(knitr)
library(shinydashboard)

ui <- dashboardPage(
  skin = "purple",
  dashboardHeader(title = "Clinical QC Report Generator"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      box(
        title = "Run Generator", width = 3, height = 450,solidHeader = TRUE, status = "primary",
        
        textInput("manifest_file", "Enter a file path for QC (Nexus)", ""),
        textInput("study_sponsor", "Enter Author Name", ""),
        textInput("study_data_name", "Enter Study Name", ""),
        selectInput("exp_type", "Select Report Type",
                    c("ADaM", "RNAseq", "DNAseq")),
        
        actionButton("report", "Render Report")
      ),
      box(
        title = "Rmarkdown Preview", width = 9, solidHeader = TRUE, status = "primary",
        downloadButton("download_rmarkdown", "Download Rmarkdown"),
        uiOutput('markdown')
      ),
  )
)
)

server <- function(input, output) {
  
  output$downloadMarkdown <- downloadHandler(
    
    )
  
    observeEvent(input$report, {
      
      # For PDF output, change this to "report.pdf"
      filename = "report.html"
      
      #content = function(file) {
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed).
        tempReport <- file.path(tempdir(), "rnaseq_template.Rmd")
        file.copy("rnaseq_template.Rmd", tempReport, overwrite = TRUE)
        
        # Set up parameters to pass to Rmd document
        params <- list(n = input$slider)
        
        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        template_name = ""
        
        if(input$exp_type == "ADaM"){
          template_name = "rnaseq_template.Rmd" 
        }
        if(input$exp_type == "scRNAseq"){
          template_name = "scrnaseq_template.Rmd" 
        }
        
        output$markdown <- renderUI({
          
          withMathJax(HTML(readLines(rmarkdown::render(input = template_name,
                                                       output_format = rmarkdown::html_fragment(),
                                                       quiet = TRUE,
                                                       params = list(
                                                         author = input$author_name,
                                                         study_name = "RNAseq QC",
                                                         study1 = "A1234",
                                                         study2 = "P12934"
                                                       )
          ))))  
      })
    })
}

shinyApp(ui = ui, server = server)
