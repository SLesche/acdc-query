get_detailed_information <- function(conn, arguments, argument_relation){
  # This function should get the data displayed when inspecting single dataset-ids.
  query_results_dataset = query_db(
    conn = conn,
    arguments = arguments,
    argument_relation = argument_relation,
    target_table = "dataset_table",
    target_vars = c(
      "dataset_id",
      "within_description",
      "group_description",
      "task_name",
      "n_participants",
      "n_trials",
      "mean_obs_per_participant",
      "percentage_congruent",
      "percentage_neutral",
      "time_limit",
      "mean_dataset_rt",
      "mean_dataset_acc",
      "mean_condition_rt",
      "mean_condition_acc",
      "within_id",
      "between_id",
      "condition_id"
    ),
    full_db = TRUE
  )

  query_results_trial = query_db(
    conn = conn,
    arguments = arguments,
    argument_relation = argument_relation,
    target_table = "observation_table",
    target_vars = c(
      "rt",
      "accuracy",
      "dataset_id",
      "condition_id"
    )
  )

  condition_ids = unique(query_results_dataset$condition_id)

  n_conditions = length(condition_ids)
  plots = vector(mode = "list", length = n_conditions)
  for (i in 1:n_conditions){
    plots[[i]] = hist(query_results_trial$rt[query_results_trial$rt < 2 & query_results_trial$condition_id == condition_ids[i]],
                      breaks = 40,
                      plot = FALSE)
  }

  query_results = list()
  query_results$data = query_results_dataset
  query_results$plots = plots
  query_results$trial_data = query_results_trial

  return(query_results)
}
