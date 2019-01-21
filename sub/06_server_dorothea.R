selected_disease_dorothea = eventReactive(input$select_disease_dorothea, {
  input$select_disease_dorothea
}) 

selected_tf = eventReactive(input$select_tf, {
  input$select_tf
}) 


output$dorothea_heatmap = renderPlot({
  sig_matrix = dorothea_result %>%
    select(disease, tf, adj.p.val) %>%
    mutate(adj.p.val = stars.pval(adj.p.val)) %>%
    spread(disease, adj.p.val) %>%
    data.frame(row.names=1)
  
  dorothea_result %>%
    select(disease, tf, activity) %>%
    spread(disease, activity) %>%
    data.frame(row.names=1, check.names = F) %>%
    pheatmap(scale = "row", display_numbers = sig_matrix)
})

output$dorothea_volcano = renderPlotly({
  if (!is.null(selected_disease_dorothea()) & !is.null(selected_tf())) {
    dorothea_volcano = processed_limma_result() %>%
      filter(disease == selected_disease_dorothea()) %>%
      inner_join(rename(dorothea_regulon, gene=target), by="gene") %>%
      filter(tf == selected_tf()) %>%
      ggplot(aes(x=logFC, y=-log10(adj.p.val), color=effect, label=gene)) +
      geom_point() +
      #theme(aspect.ratio = c(1)) +
      labs(x="logFC", y="-log10(FDR)") +
      scale_color_manual(values = rwth_color(c("bordeaux", "black50","green")),
                         drop=F)
    ggplotly(dorothea_volcano, tooltip = c("label")) %>% 
      config(displayModeBar = F) %>%
      layout(xaxis=list(fixedrange=T)) %>% 
      layout(yaxis=list(fixedrange=T))
  }
})

output$download_dorothea = downloadHandler(
  filename = function() {
    "dorothea_scores.csv"
  },
  content = function(file) {
    dorothea_result %>%
      write_delim(., file)
  })