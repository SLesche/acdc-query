#' Return ID column name from table name
#'
#' This function generates the ID column name based on the provided table name.
#' It replaces the "table" suffix with "id" to obtain the ID column name.
#'
#' @param table_name The name of the table.
#'
#' @return The generated ID column name.
#' @examples
#' # Return ID column name from table name
#' return_id_name_from_table("publication_table")
return_id_name_from_table <- function(table_name){
  name = c()
  for (i in seq_along(table_name)){
    name[i] = base::sub("table$", "id", table_name[i])
  }

  return(name)
}
