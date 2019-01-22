selected_disease_progeny = eventReactive(input$select_disease_progeny, {
  input$select_disease_progeny
}) 

selected_pathway = eventReactive(input$select_pathway, {
  input$select_pathway
}) 

selected_common_diseases = eventReactive(input$select_common_diseases, {
  input$select_common_diseases
})

adjusted_fdr_piano = eventReactive(input$adjust_fdr_piano, {
  input$adjust_fdr_piano
})



output$piano_tile = renderPlot({
  piano_result %>%
    filter(pVal > -log10(adjusted_fdr_piano())) %>%
    group_by(Pathway) %>%
    add_count() %>%
    ungroup() %>%
    filter(n>selected_common_diseases()) %>%
    arrange(-n) %>%
    mutate(Pathway = str_trunc(Pathway, 25)) %>%
    ggplot(aes(x=Disease, y=Pathway, fill=Disease)) +
    geom_tile() +
    scale_fill_manual(values = c("#EC853F", "#589A45", "#CCF3FF", "#624592", "#000000", "#B2B6BA", "#4279AD", "#FFFCAD", "#A45d3A"), drop=F) +
    labs(fill = "CKD entity") +
    theme(axis.title = element_blank())
})

output$piano_df = DT::renderDataTable({
  piano_result %>% 
    filter(pVal > -log10(adjusted_fdr_piano())) %>%
    rename(FDR = pVal) %>%
    mutate(FDR = 10**-FDR) %>%
    mutate(Pathway = as_factor(Pathway)) %>%
    DT::datatable(escape = F, option = list(scrollX = TRUE, autoWidth=T), 
                  filter = "top", selection = list(target = "none"))
  
})

output$download_piano = downloadHandler(
  filename = function() {
    "piano_results.csv"
  },
  content = function(file) {
    piano_result %>%
      write_delim(., file)
  })