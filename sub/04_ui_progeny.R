tabPanel(
  title = "Pathway activity",
  icon = icon("line-chart"),
  sidebarPanel(
    h4("Pathway activity inference with PROGENy"),
    p(a("PROGENy", href = "https://saezlab.github.io/progeny/", targer="_blank"), "infers pathway activity from gene expression exploting footprint signatures for 11 signaling pathways."),
    pickerInput(inputId = "select_disease_progeny", label = "Select disease entity",
                choices = sort(unique(limma_result$disease)), 
                options = list(`actions-box` = TRUE)), 
    pickerInput(inputId = "select_pathway", label = "Select pathway",
                choices = sort(unique(progeny_result$pathway))),
    downloadButton("download_progeny", "Download PROGENy scores")
  ),
  mainPanel(
    plotOutput("progeny_heatmap"),
    plotlyOutput("progeny_scatter")
  )
)