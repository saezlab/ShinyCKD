# selected_disease_dvd = eventReactive(input$select_disease_dvd, {
#   input$select_disease_dvd
# }) 
# 
# selected_drug = eventReactive(input$select_drug, {
#   input$select_drug
# }) 

selected_top_n_drug = eventReactive(input$select_top_n_drugs, {
  input$select_top_n_drugs
}) 


output$dvd_heatmap = renderPlot({
  drug_result %>%
    filter(rank <= selected_top_n_drug()) %>%
    ggplot(aes(x=disease, y=fct_reorder(label, n), fill=disease)) +
    geom_tile() +
    scale_x_discrete(drop=FALSE) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),
          axis.title = element_blank()) +
    scale_fill_manual(values = c("#EC853F", "#589A45", "#CCF3FF", "#624592", "#000000", "#B2B6BA", "#4279AD", "#FFFCAD", "#A45d3A"), drop=F) +
    labs(fill = "CDK entity")
})

output$dvd_df = DT::renderDataTable({
  drug_result %>% 
    mutate(label = as_factor(label)) %>%
    select(Drug = label, DrugID = drug_id, Hits=n, Disease=disease, Rank=rank) %>%
    DT::datatable(escape = F, option = list(scrollX = TRUE, autoWidth=T), 
                  filter = "top", selection = list(target = "none"))
  
})


output$download_dvd = downloadHandler(
  filename = function() {
    "drug_repositioning_scores.csv"
  },
  content = function(file) {
    drug_result %>%
      select(drug_id, label, hits=n, disease, rank) %>%
      write_delim(., file)
  })