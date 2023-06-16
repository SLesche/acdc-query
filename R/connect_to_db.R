connect_to_db <- function(path_to_db){
  conn = DBI::dbConnect(RSQLite::SQLite(), path_to_db)
  return(conn)
}
