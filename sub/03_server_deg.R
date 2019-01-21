processed_limma_result = reactive({
  limma_result %>%
    mutate(effect = case_when(logFC >= adjusted_ez() & adj.p.val <= adjusted_fdr() ~ "upregulated",
                              logFC <= -adjusted_ez() & adj.p.val <= adjusted_fdr() ~ "downregulated",
                              TRUE ~ "not regulated")) %>%
    mutate(effect = factor(effect, c("downregulated", "not regulated", "upregulated")))
    
})


selected_disease = eventReactive(input$select_disease, {
  input$select_disease
}) 

selected_gene = eventReactive(input$select_gene, {
  input$select_gene
}) 

adjusted_fdr = eventReactive(input$adjust_fdr, {
  input$adjust_fdr
}) 

adjusted_ez = eventReactive(input$adjust_effectsize, {
  input$adjust_effectsize
}) 


output$deg_volcano = renderPlotly({
  if (!is.null(selected_disease())) {
    deg_volcano = processed_limma_result() %>%
      filter(disease %in% selected_disease()) %>%
      ggplot(aes(x=logFC, y=-log10(adj.p.val), color=effect, label=gene)) +
      geom_point() +
      facet_wrap(~disease, scales = "free") +
      scale_color_manual(values = rwth_color(c("bordeaux", "black50","green")),
                         drop=F)
    
    ggplotly(deg_volcano, tooltip = c("label")) %>%
      config(displayModeBar = F) %>%
      layout(xaxis=list(fixedrange=TRUE)) %>% layout(yaxis=list(fixedrange=TRUE))
  }
})

output$deg_barplot = renderPlot({
  if (!is.null(selected_gene())) {
    processed_limma_result() %>%
      filter(gene %in% selected_gene()) %>%
      ggplot(aes(x=disease, y=logFC, fill=effect)) +
      geom_col() +
      coord_flip() +
      facet_wrap(~gene) +
      scale_fill_manual(values = rwth_color(c("bordeaux", "black50","green")),
                        drop=F) +
      labs(x = "", y="logFC")
    #ggplotly(deg_barplot)
  }
})

output$download_deg = downloadHandler(
  filename = function() {
    "differential_expressed_genes.csv"
  },
  content = function(file) {
      limma_result %>%
        write_delim(., file)
  })