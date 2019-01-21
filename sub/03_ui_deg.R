tabPanel(
  title = "Disease signature",
  icon = icon("search"),
  sidebarPanel(
    h4("Analysis of differentially expressed genes"),
    p("Select a kidyney disease entity and explore the correspondig gene signature or select a gene and observe its expression across disease entities."),
    pickerInput(inputId = "select_disease", label = "Select disease entitie(s)",
                choices = sort(unique(limma_result$disease)), multiple = T, 
                options = list(`actions-box` = TRUE)), 
    sliderInput(inputId = "adjust_fdr", label = "Adjust FDR cutoff",
                min=0.001, max=1, value = 0.05),
    sliderInput(inputId = "adjust_effectsize", label = "Adjust effect-size curoff",
                min = 0, max = 7, value = 1, step = 0.5),
    pickerInput(inputId = "select_gene", label = "Select gene(s)",
                choices = sort(unique(limma_result$gene)), multiple = T, 
                options = list(size=10, `live-search` = TRUE)),
    downloadButton("download_deg", "Download signatures")
  ),
  mainPanel(
    plotlyOutput("deg_volcano"),
    plotOutput("deg_barplot")
  )
)