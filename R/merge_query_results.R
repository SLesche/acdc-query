#' Merge query results from multiple tables
#'
#' This function merges the query results from multiple tables into a single data frame.
#' It performs left joins on the tables based on specified join keys.
#'
#' @param query_results A list of tables containing the query results.
#'   The list should include the following tables: observation_table, between_table, within_table,
#'   condition_table, dataset_table, study_table, publication_table, task_table.
#'
#' @return A merged data frame with the query results from all the tables.
#' @examples
#' # Merge query results
#' query_results <- list(
#'   observation_table = data.frame(observation_id = 1:3, value = c(10, 20, 30)),
#'   between_table = data.frame(observation_id = 1:3, between_var = c("A", "B", "C")),
#'   within_table = data.frame(observation_id = 1:3, within_var = c("X", "Y", "Z"))
#' )
#' merged_data <- merge_query_results(query_results)
#' merged_data
merge_query_results <- function(query_results) {
  # Join the proper tables, return data frame
  data_raw = query_results$observation_table

  data_joined = data_raw %>%
    dplyr::left_join(., query_results$between_table) %>%
    dplyr::left_join(., query_results$within_table) %>%
    dplyr::left_join(., query_results$condition_table) %>%
    dplyr::left_join(., query_results$dataset_table) %>%
    dplyr::rename(comment_dataset = comment) %>%
    dplyr::left_join(., query_results$study_table, by = "study_id") %>%
    dplyr::rename(comment_study = comment) %>%
    dplyr::left_join(., query_results$publication_table, by = "publication_id") %>%
    dplyr::left_join(., query_results$task_table, by = "task_id") %>%
    dplyr::select(dplyr::ends_with("id"), dplyr::everything())

  return(data_joined)
  # Maybe add functionality to compress this here
}
