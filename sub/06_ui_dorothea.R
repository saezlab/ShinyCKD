tabPanel(
  title = "TF-activity",
  icon = icon("bar-chart-o"),
  sidebarPanel(
    h4("Transcription factor activity inference using DoRothEA"),
    p(a("DoRothEA", href = "https://saezlab.github.io/DoRothEA/", targer="_blank"), "is a gene regulatory network allowing the estimation of TF activies from gene expression data."),
    pickerInput(inputId = "select_disease_dorothea", 
                label = "Select disease entity",
                choices = sort(unique(limma_result$disease)), 
                options = list(`actions-box` = TRUE), selected = NULL), 
    pickerInput(inputId = "select_tf", label = "Select TF",
                choices = sort(unique(dorothea_result$tf))),
    downloadButton("download_dorothea", "Download DoRothEA scores")
  ),
  mainPanel(
    plotOutput("dorothea_heatmap"),
    plotlyOutput("dorothea_volcano")
  )
)