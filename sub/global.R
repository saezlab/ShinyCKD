library(shiny)
library(shinyWidgets)
library(tidyverse)
library(cowplot)
library(plotly)
library(gtools)
library(pheatmap)
library(DT)

# load data
limma_result = readRDS("data/limma_result.rds")
progeny_result = readRDS("data/progeny_result.rds")
dorothea_result = readRDS("data/dorothea_result.rds")
drug_result = readRDS("data/drug_result.rds")
piano_result = readRDS("data/piano_result.rds")

progeny_matrix = get(load("data/models/progeny_matrix_human_v1.rda")) %>%
  filter(!(pathway %in% c("Androgen", "Estrogen", "WNT")))

dorothea_regulon = readRDS("data/models/dorothea_regulon_df_old_version.rds")

meta_df = read_csv("data/misc/exp_meta.csv")

# load color palette
rwth_colors_df = get(load("data/misc/rwth_colors.rda"))

# functions
rwth_color = function(colors) {
  if (!all(colors %in% rwth_colors_df$query)) {
    wrong_queries = tibble(query = colors) %>%
      anti_join(rwth_colors_df, by="query") %>%
      pull(query)
    warning(paste("The following queries are not available:",
                  paste(wrong_queries, collapse = ", ")))
  }
  tibble(query = colors) %>%
    inner_join(rwth_colors_df, by="query") %>%
    pull(hex)
}

