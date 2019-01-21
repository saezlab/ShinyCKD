selected_disease_progeny = eventReactive(input$select_disease_progeny, {
  input$select_disease_progeny
}) 

selected_pathway = eventReactive(input$select_pathway, {
  input$select_pathway
}) 


output$progeny_heatmap = renderPlot({
  sig_matrix = progeny_result %>%
    select(disease, pathway, adj.p.val) %>%
    mutate(adj.p.val = stars.pval(adj.p.val)) %>%
    spread(disease, adj.p.val) %>%
    data.frame(row.names=1)
  
  progeny_result %>%
    select(disease, pathway, activity) %>%
    spread(disease, activity) %>%
    data.frame(row.names=1, check.names = F) %>%
    pheatmap(scale = "row", display_numbers = sig_matrix)
})

output$progeny_scatter = renderPlotly({
  if (!is.null(selected_disease_progeny()) & !is.null(selected_pathway())) {
    progeny_scatter = limma_result %>%
      filter(disease == selected_disease_progeny()) %>%
      inner_join(progeny_matrix, by="gene") %>%
      filter(pathway == selected_pathway()) %>%
      mutate(contribution = case_when(sign(logFC) * sign(weight) == 1 ~ "positive",
                                      TRUE ~ "negative")) %>%
      ggplot(aes(x=logFC, y=weight, color=contribution, label=gene)) +
      geom_point() +
      geom_hline(yintercept = c(0), linetype=c(1) ,color=c("black")) +
      geom_vline(xintercept = c(0), linetype=c(1) , color=c("black")) +
      theme_minimal() +
      #theme(aspect.ratio = c(1)) +
      scale_color_manual(values = rwth_color(c("magenta", "green")),
                         drop=F) +
      labs(x="Effect size", y="PROGENy weight")
    ggplotly(progeny_scatter, tooltip = c("label")) %>% 
      config(displayModeBar = F) %>%
      layout(xaxis=list(fixedrange=T)) %>% layout(yaxis=list(fixedrange=T))
  }
})