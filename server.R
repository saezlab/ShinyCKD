# SERVER
server = function(input, output, session) {
  source("sub/server_experiments.R", local=T)
  source("sub/02_server_deg.R", local=T)
  source("sub/03_server_progeny.R", local=T)
  source("sub/04_server_dorothea.R", local=T)
  source("sub/06_server_dvd.R", local=T)
}
