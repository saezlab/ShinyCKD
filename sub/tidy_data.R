library(tidyverse)
library(piano)

##### load limma result #####
limma_result = list.files("data/limma", full.names = T) %>%
  map_df(function(file_name) {
    disease = basename(file_name) %>%
      str_split("_") %>% 
      pluck(1, 2) %>%
      str_to_upper()
    
    top_table = readRDS(file_name) %>%
      rownames_to_column("gene") %>%
      as_tibble() %>%
      select(gene, logFC, adj.p.val = adj.P.Val) %>%
      mutate(disease = disease)
  }) %>%
  mutate(disease = case_when(disease == "IGAN" ~ "IgAN",
                             disease == "HT" ~ "HN",
                             TRUE ~ disease))

saveRDS(limma_result, "data/limma_result.rds")

##### load piano results #####
piano_result = list.files("data/piano", full.names = T) %>%
  map_df(function(path) {
    disease = basename(path) %>%
      str_split("_") %>% 
      pluck(1, 3) %>%
      str_to_upper()
    y = readRDS(path) %>% map(function(method) {
      GSAsummaryTable(method) %>%
        as_tibble()
    }) %>% enframe(name = "method") %>%
      mutate(disease = disease)
  })

tidy_piano_result = piano_result %>%
  #filter(disease == "DN") %>%
  unnest() %>%
  select(method, disease, geneset = Name, 
         nes_non_dir = `Stat (non-dir.)`,
         padj_non_dir = `p adj (non-dir.)`,
         nes_mix_up = `Stat (mix.dir.up)`,
         padj_mix_up = `p adj (mix.dir.up)`,
         nes_mix_dn = `Stat (mix.dir.dn)`,
         padj_mix_dn = `p adj (mix.dir.dn)`,
         nes_dist_up = `Stat (dist.dir.up)`,
         padj_dist_up = `p adj (dist.dir.up)`,
         nes_dist_dn = `Stat (dist.dir.dn)`,
         padj_dist_dn = `p adj (dist.dir.dn)`) %>%
  gather(key, value, -c(method, disease, geneset)) %>%
  mutate(type = case_when(str_detect(key, "nes") ~ "nes",
                         str_detect(key, "padj") ~ "adj.p.val")) %>%
  mutate(key = str_remove(key, "nes_"),
         key = str_remove(key, "padj_")) %>%
  spread(type, value) %>%
  drop_na() %>%
  select(-nes) %>%
  group_by(disease, geneset, key) %>%
  summarise(geom_mean_padj = exp(mean(log(adj.p.val)))) %>%
  ungroup()

saveRDS(tidy_piano_result, file="data/piano_result.rds")    

##### load progeny results #####
load("data/progeny/GlomFDR.RData")
progeny_scores = glom_prog11 %>%
  as.data.frame() %>%
  rownames_to_column("disease") %>%
  gather(pathway, activity, -disease) %>%
  as_tibble()

progeny_sig = GlomFDR %>%
  as.data.frame() %>%
  rownames_to_column("disease") %>%
  gather(pathway, adj.p.val, -disease) %>%
  as_tibble()

progeny_result = inner_join(progeny_scores, progeny_sig, 
                            by = c("disease", "pathway")) %>%
  mutate(pathway = case_when(pathway == "NFKb" ~ "NFkB",
                             TRUE ~ pathway),
         disease = case_when(disease == "HT" ~ "HN",
                             TRUE ~ disease))
saveRDS(progeny_result, "data/progeny_result.rds")

##### load dorothea results #####
load("data/dorothea/tfscores_fdr.RData")

dorothea_scores = tf_activity %>%
  as.data.frame() %>%
  rownames_to_column("tf") %>%
  gather(disease, activity, -tf) %>%
  as_tibble()

dorothea_sig = fdr %>%
  as.data.frame() %>%
  rownames_to_column("tf") %>%
  gather(disease, adj.p.val, -tf) %>%
  as_tibble()

dorothea_result = inner_join(dorothea_scores, dorothea_sig,
                             by = c("disease", "tf")) %>%
  mutate(disease = case_when(disease == "HT" ~ "HN",
                             TRUE ~ disease))
saveRDS(dorothea_result, "data/dorothea_result.rds")

##### dorothea regulon #####
dorothea_regulons = get(load("data/models/dorothea_regulon_old_version.rdata"))
regulon_df = map2_df(dorothea_regulons$GENES, dorothea_regulons$NAME, 
                     function(targets,tf) {
                       targets %>% enframe("target", "mor") %>%
                         mutate(tf = tf) %>%
                         select(tf, target, mor)
                       }
                     )

saveRDS(regulon_df, "data/models/dorothea_regulon_df_old_version.rds")

##### drug repositioning #####
drug_repo_result = list.files("data/dvd", full.names = T) %>%
  map_df(function(path) {
    disease = basename(path) %>%
      str_split("[.]") %>%
      pluck(1,2) %>%
      str_split("_") %>%
      pluck(1,1) %>%
      str_to_upper()
    read_delim(path, delim = "\t") %>%
      mutate(disease = disease) %>%
      separate(Perturbation.LIFE.URL, into=c("tmp", "drug_id"), sep="&input=") %>%
      select(drug = Perturbation, drug_id, cos_dist = X1.cos.α., pvalue, adj.p.val = BH, disease)
  }) %>%
  mutate(disease = case_when(disease == "IGAN" ~ "IgAN",
                             TRUE ~ disease),
         disease = factor(disease)) #%>%
  
drug_id_anno = drug_repo_result %>%
  distinct(drug, drug_id) %>%
  #filter(drug_id %in% c("BRD-K04853698", "BRD-K80786583")) %>%
  group_by(drug_id) %>%
  add_count() %>%
  ungroup() %>%
  filter(!(drug == drug_id & n==2)) %>%
  mutate(label = case_when(drug == drug_id ~ drug,
                           drug != drug_id ~ paste0(drug, "(", drug_id, ")"))) %>%
  distinct(drug_id, label)

drug_result = drug_repo_result %>%
  distinct(disease, drug_id) %>%
  group_by(drug_id) %>%
  add_count() %>%
  arrange(-n, drug_id) %>%
  ungroup() %>%
  nest(-drug_id) %>%
  mutate(rank = row_number()) %>%
  unnest() %>%
  inner_join(drug_id_anno)

saveRDS(drug_result, "data/drug_result.rds")


##### meta data #####
meta_df = get(load("data/misc/exp_meta.RData")) %>% 
  as_tibble() %>%
  select(Sample = Accession, Series = Study, Platform, Entity = Group, Sex, Age) %>%
  separate(Sample, sep="_", into = c("Sample", "tmp")) %>%
  separate(Sample, sep="[.]", into=c("Sample", "tmp2")) %>%
  select(-tmp2, -tmp) %>%
  mutate_all(funs(na_if(.,""))) %>%
  mutate(Series_link = paste0("<a href='https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=", Series, "' target='_blank'", ">", Series, "</a>")) %>%
  mutate(Sample_link = paste0("<a href='https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=", Sample, "' target='_blank'", ">", Sample, "</a>"))

write_csv(meta_df, "data/misc/exp_meta.csv")




  

