tabPanel(
  title = "Pathway enrichment",
  icon = icon("chart-area"),
  sidebarPanel(
    h4("Pathway enrichment with Piano"),
    p(a("Piano", href = "https://bioconductor.org/packages/release/bioc/html/piano.html", targer="_blank"), "performs gene set analysis using various statistical methods, from different gene level statistics and combines the results of multiple runs."),
    sliderInput(inputId = "adjust_fdr_piano", label = "Adjust FDR cutoff",
                min=0.001, max=1, value = 0.05),
    sliderInput(inputId = "select_common_diseases", label = "Pathways enriched in min 'n' diseases.",
                min=1, max=9, value = 3, step = 1),
    downloadButton("download_piano", "Download enrichment scores")
  ),
  mainPanel(
    plotOutput("piano_tile"),
    DT::dataTableOutput("piano_df")
  )
)