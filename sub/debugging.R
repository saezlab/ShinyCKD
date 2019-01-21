adjusted_ez = 1
adjusted_fdr = 0.05
selected_disease = "DN"
selected_disease_progeny = "DN"
selected_disease_dorothea = "DN"
selected_pathway = "NFkB"
selected_tf = "FOXM1"
selected_gene = "FOXM1"
##### processing of limma results #####
processed_limma_result = limma_result %>%
  mutate(effect = case_when(logFC >= adjusted_ez & adj.p.val <= adjusted_fdr ~ "upregulated",
                            logFC <= -adjusted_ez & adj.p.val <= adjusted_fdr ~ "downregulated",
                            TRUE ~ "not regulated")) %>%
  mutate(effect = factor(effect, c("downregulated", "not regulated", "upregulated")))

deg_volcano = processed_limma_result %>%
  filter(disease %in% c("DN")) %>%
  ggplot(aes(x=logFC, y=-log10(adj.p.val), color=effect, label=gene)) +
  geom_point() +
  facet_wrap(~disease, scales = "free")
ggplotly(deg_volcano)


##### deg barplot #####
deg_barplot = processed_limma_result %>%
  filter(gene %in% selected_gene) %>%
  ggplot(aes(x=disease, y=logFC, fill=effect, label=gene)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~gene) +
  scale_fill_manual(values = rwth_color(c("bordeaux", "black50","green")),
                    drop=F) +
  labs(x = "", y="logFC")
##### progeny scatter #####
limma_result %>%
  filter(disease == selected_disease_progeny) %>%
  inner_join(progeny_matrix, by="gene") %>%
  filter(pathway == selected_pathway) %>%
  mutate(contribution = case_when(sign(logFC) * sign(weight) == 1 ~ "positive",
                                  TRUE ~ "negative")) %>%
  ggplot(aes(x=logFC, y=weight, color=contribution)) +
  geom_point() +
  geom_hline(yintercept = c(0), linetype=c(1) ,color=c("black")) +
  geom_vline(xintercept = c(0), linetype=c(1) , color=c("black")) +
  theme_minimal() +
  theme(aspect.ratio = c(1)) +
  scale_color_manual(values = rwth_color(c("magenta", "green")),
                     drop=F) +
  labs(x="Effect size", y="PROGENy weight")

##### dorothea volcano plot #####
dorothea_volcano = processed_limma_result %>%
  filter(disease == selected_disease_dorothea) %>%
  inner_join(rename(dorothea_regulon, gene=target), by="gene") %>%
  filter(tf == selected_tf) %>%
  ggplot(aes(x=logFC, y=-log10(adj.p.val), color=effect, label=gene)) +
  geom_point() +
  #theme(aspect.ratio = c(1)) +
  labs(x="logFC", y="-log10(FDR)") +
  scale_color_manual(values = rwth_color(c("bordeaux", "black50","green")),
                     drop=F)
ggplotly(dorothea_volcano, tooltip = c("label"))
