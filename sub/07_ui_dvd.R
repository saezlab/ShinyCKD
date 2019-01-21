tabPanel(
  title = "Drug repositioning",
  icon = icon("capsules"),
  sidebarPanel(
    h4("Prediction of potential novel drugs"),
    p("Drugs are predicted to have a therapeutic effect on chronic kidney diseases when the drug gene
      signature matches the inverse disease gene signature. Drug signatures were
      taken from", 
      a("L1000CDS2", href="http://amp.pharm.mssm.edu/L1000CDS2/#/index", 
        target="_blank")),
    sliderInput(inputId = "select_top_n_drugs", label = "Show top n drugs",
                min=1, max=221, value = 20, step = 1),
    # pickerInput(inputId = "select_disease_dvd", label = "Select disease entity",
    #             choices = sort(unique(limma_result$disease)), 
    #             options = list(`actions-box` = TRUE), multiple = T), 
    # pickerInput(inputId = "select_drug", label = "Select drug",
    #             choices = sort(unique(drug_result$label)), multiple = T),
    downloadButton("download_dvd", "Download drug results")
  ),
  mainPanel(
    plotOutput("dvd_heatmap", width="100%"),
    DT::dataTableOutput("dvd_df")
  )
)