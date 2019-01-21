tabPanel(
  title = "Pathway enrichment",
  icon = icon("chart-area"),
  sidebarPanel(
    h4("Pathway enrichment with Piano"),
    p(a("Piano", href = "https://bioconductor.org/packages/release/bioc/html/piano.html", targer="_blank"), "performs gene set analysis using various statistical methods, from different gene level statistics and combines the results of multiple runs."),
    pickerInput(inputId = "select_disease_piano", label = "Select disease entity",
                choices = sort(unique(limma_result$disease)), 
                options = list(`actions-box` = TRUE)), 
    pickerInput(inputId = "select_pathway_piano", label = "Select pathway",
                choices = sort(unique(progeny_result$pathway))),
    downloadButton("download_piano", "Download enrichment scores")
  ),
  mainPanel(
  )
)