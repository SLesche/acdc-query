#' Return only matching rows between two data frames
#'
#' This function returns the rows that have matching values in specified columns
#' between two data frames. It performs an inner join by default and returns the
#' matching rows based on the common columns between the data frames.
#'
#' @param data1 The first data frame.
#' @param data2 The second data frame.
#' @param id The column(s) to select from the joined data frames. By default,
#'   it selects all common columns.
#' @param full Logical indicating whether to return the full joined data frames.
#'   If TRUE, it returns all columns from both data frames.
#'
#' @return A data frame containing the matching rows based on the specified columns.
#'   If id is specified, it returns a data frame with only the selected column(s).
#'   If full is TRUE, it returns the full joined data frames.
#'
#' @examples
#' # Return matching rows based on common columns
#' return_only_matches(data1, data2)
#'
#' # Return matching rows and select specific column(s)
#' return_only_matches(data1, data2, id = "column_name")
#'
#' # Return the full joined data frames
#' return_only_matches(data1, data2, full = TRUE)
return_only_matches <- function(data1, data2, id = NULL, full = FALSE){
  if (!is.null(id)){
    matches = dplyr::inner_join(data1, data2) %>%
      dplyr::select({{id}})

    return(matches)
  }

  common_cols = intersect(
    colnames(data1),
    colnames(data2)
  )

  if (full == FALSE){
    matches = dplyr::inner_join(data1, data2) %>%
      dplyr::select({{common_cols}})
  } else {
    matches = dplyr::inner_join(data1, data2)
  }


  return(matches)
}
