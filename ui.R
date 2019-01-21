# UI
source("sub/global.R")
ui = function(request) {
  fluidPage(
    #useShinyjs(),
    #tags$head(includeScript("google-analytics.js")),
    # theme = shinythemes::shinytheme("spacelab"),
    navbarPage(
      id = "menu", 
      title = div(img(src="logo_saezlab.png", width="25", height="25"), "CKD-App"),
      collapsible=T,
      footer = column(12, align="center", "CKD-App 2019"),
      source("sub/01_ui_welcome.R")$value,
      source("sub/02_ui_experiments.R")$value,
      source("sub/03_ui_deg.R")$value,
      source("sub/04_ui_progeny.R")$value,
      #source("sub/05_ui_piano.R")$value,
      source("sub/06_ui_dorothea.R")$value,
      source("sub/07_ui_dvd.R")$value,
      hr()
      ) # close navbarPage
    ) # close fluidPage
}