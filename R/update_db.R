#' Update the database file
#'
#' This function updates the existing database file by downloading the latest version from a specified URL and saving it to the local path. It uses the \code{\link{download_db}} function internally.
#'
#' @param local_path The local path where the downloaded file will be saved.
#'
#' @return NULL (no explicit return value).
#' @export
#'
#' @examples
#' # Update the database file in the current working directory
#' update_db("initial_db.db")
#' @seealso \code{\link{download_db}}
update_db <- function(local_path){
  download_db(local_path)
}
