download_db <- function(local_path){
  # TODO: Have this updated
  # TODO: Return a "last updated" file somewhere.
  db_url = "https://github.com/jstbcs/inhibitiontasks/raw/inhibitiontaks_db2023/initial_db.db"
  download.file(
    url = db_url,
    destfile = local_path,
    quiet = TRUE
  )
}
