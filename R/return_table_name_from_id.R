#' Return table name from ID column name
#'
#' This function generates the table name based on the provided ID column name.
#' It replaces the "id" suffix with "table" to obtain the table name.
#'
#' @param id_name The name of the ID column.
#'
#' @return The generated table name.
#' @examples
#' # Return table name from ID column name
#' return_table_name_from_id("publication_id")
return_table_name_from_id <- function(id_name){
  name = c()
  for (i in seq_along(id_name)){
    name[i] = base::sub("id$", "table", id_name[i])
  }
  return(name)
}
