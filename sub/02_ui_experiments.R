tabPanel(
  title = "Experiments",
  icon = icon("database"),
  #titlePanel("Annotated Experiments"),
  sidebarPanel(
    h4("Metadata"),
    p("This is the metadata associated with the experimental samples of this study."),
    downloadButton("download_meta", "Download metadata")
  ),
  mainPanel(
    DT::dataTableOutput("meta_df")
  )
  
  
)
