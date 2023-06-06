#' Return entries from IDs
#'
#' This function retrieves entries from the database based on the provided matches.
#' It queries each table with the corresponding IDs and returns the retrieved data.
#'
#' @param conn A database connection object.
#' @param matches A list of matches containing connected IDs for each table.
#'
#' @return A list of data frames containing the retrieved entries for each table.
#' @examples
#' # Return entries from IDs
#' conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#' matches <- list(
#'   publication_table = c(1, 2, 3),
#'   study_table = c(4, 5, 6),
#'   task_table = c(7, 8, 9)
#' )
#' return_entries_from_id(conn, matches)
return_entries_from_id <- function(conn, matches){
  tables = names(matches)

  data = list(
    publication_table = data.frame(),
    study_table = data.frame(),
    task_table = data.frame(),
    between_table = data.frame(),
    within_table = data.frame(),
    condition_table = data.frame(),
    dataset_table = data.frame(),
    observation_table = data.frame()
  )

  for (table in tables){
    id_name = return_id_name_from_table(table)

    query = write_id_query(table, id_name, matches[[table]])

    data[[table]] = DBI::dbGetQuery(conn, query)
  }

  return(data)
}
