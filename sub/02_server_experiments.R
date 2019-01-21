output$meta_df = DT::renderDataTable({
  meta_df %>%
    select(-Sample, -Series) %>%
    select(Sample=Sample_link, Series=Series_link, Platform, Entity, Sex, Age) %>%
    DT::datatable(., escape = F, option = list(scrollX = TRUE, autoWidth=T), 
                  filter = "top", selection = list(target = "none"))
  
})

output$download_meta = downloadHandler(
  filename = function() {
    "experiment_annotations.csv"
  },
  content = function(file) {
    meta_df %>%
      select(-Sample_link, -Series_link) %>%
      write_delim(., file)
  })