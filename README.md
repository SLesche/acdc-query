# acdc-query - Query the Attenional Control Data Collection
## Installation
You can install this package via `devtools::install_github("SLesche/acdc-query")`. You may need to update imported packages.

## Dependencies
This package is designed for use in R 4.2.2. Certain functions may break in different R versions. It heavily relies on the packages DBI, RSQLite, dplyr, stringr

## Use
In order to interact with the database, you must first [download](https://github.com/jstbcs/inhibitiontasks/raw/inhibitiontaks_db2023/inhibitiontasks.db) it from its [parent repo](https://github.com/jstbcs/inhibitiontasks/tree/inhibitiontaks_db2023).

To query the database, specify the connection to the database (obtained via `conn <- connect_to_db("path/to/db.db")`), a list of filter arguments (obtained by using `add_argument()`), and a vector containing the names of the variables you want returned.

## Working example
```
# devtools::install_github("SLesche/inhibitiondb")
library(inhibitiondb)
library(dplyr)
conn <- connect_to_db("inhibitiontasks.db")

arguments <- list() %>% 
  add_argument(
    conn = conn,
    variable = "n_participants",
    operator = "greater",
    values = 200
  ) %>% 
  add_argument(
    conn = conn,
    variable = "task_name",
    operator = "equal",
    values = c("stroop", "flanker")
  )

requested_vars <- c("rt", "accuracy", "n_participants")

df <- query_db(conn, arguments, requested_vars)
```

## Documentation
### General
Querying is accomplished by lower level functions using user input to construct an SQL-query which is then applied to the database. To query the full database and select a subset of variables to be returned, functions locate the tables in which the requested variables are present and construct an SQL query selecting those rows of the observation table that match the filter arguments in the respective tables. If multiple filter arguments are present, the variable `argument_relation` controls how these are combined. 

This database consists of multiple tables, each with variables potentially used when filtering. This presents an interesting challenge, as a user should be able to filter based on any argument in any table (and even multiple arguments each located in different tables) and return the requested variables. These returned variables may themselves need to be assembled from different tables.

We selected our _observation table_, consisting of trial-level data as a central point for data querying. This was done because it contains response-time and accuracy data, as well as information about the condition of the trial. All of which are variables highly likely to be requested by the user. Any given filter argument, independent of the table the filter-variable is located in, is ultimately returning entries from the observation table. Other tables are then joined onto these matches in order to return variables not present in the observation table to the user.

### Filter Arguments
The filter function requires 3 main inputs. The connection to the database `conn`, a vector fo the requested variables returned to the user `target_vars` and a list of the filter arguments `arguments`. The function `add_argument()` can be used for creating this list of filter arguments. Its objective is to provide a user-friendly way of specifying the variable and conditions used when filtering the database. Detailed information is provided in the function's source code. Users have to provide the connection to the database `conn`. This allows the function to validate that the variable is present in the database and locate the table in which it is present. Furthermore, users need to specify the variable `variable`, the operator for the condition `operator` and the value (or values) which make up the filter argument. Please find an example of filtering the database to only return entries where _the study contains more than 200 participants_ and _the study used either stroop or flanker tasks_ below.
```{r}
conn <- connect_to_db("inhibitiontasks.db")

arguments <- list() %>% 
  add_argument(
    conn = conn,
    variable = "n_participants",
    operator = "greater",
    values = 200
  ) %>% 
  add_argument(
    conn = conn,
    variable = "task_name",
    operator = "equal",
    values = c("stroop", "flanker")
  )

```

The function uses this input to construct an SQL query that corresponds to the filter condition and selects the primary key of the table the filter variable is located in. In the above example, `arguments` is a list of 2 elements. The first being the character string "SELECT dataset_id FROM dataset_table WHERE n_participants > 200" and the second the string "SELECT task_id FROM task_table WHERE task_name = 'stroop' OR task_name = 'flanker'".

### Argument Relations
When using multiple different arguments to filter, you may specify the operators used to combine these arguments. This can be done via the `argument_relation` argument in the `query_db()` function. This argument takes either the strings "and" or "or" or a numerical vector with length equal to the number of arguments specified. "and" or "or" result in all arguments being connected via this operator, with "and" being the default option. Passing a numerical vector allows more complicated logical combinations of filter arguments. Each entry of the vector should correspond to a filter argument. Arguments corresponding to the same number in the vector are combined via an "OR" operator. Arguments corresponding to different numbers are combined via an "AND" operator.

If you specify 4 arguments A, B, C, D and want to filter the database such that it meets the conditions A & B & (C | D), the corresponding argument_relation should be `argument_relation = c(1, 2, 3, 3)`.

### Forward and Backward Connections
This database contains multiple tables each connected via primary and foreign keys. A _forward connection_ in our terminology is any table whose primary key is listed as a foreign key in the current table. The observation table, for example, has forward connections to the dataset, between, within and condition tables. A _backward connection_ represents the opposite path. The dataset table has a backward connection to the observation table. These two means of connections between tables are relevant when filtering and joining tables.

### Filter Paths
Querying makes use of the function `compute_fastest_way_to_table()` which discovers the fastest way from a given input table to a specified target table, while avoiding connections through the observation table. If the user filters based on a variable in the _study table_, for example. The fastest way towards the observation table starting from the task-table, as in the second argument in the example above is through the dataset-table. The function `convert_query_path_to_sql()` takes the filter-argument and the list containing path info returned by `compute_fastest_way_to_table()` and extends the SQL query to now select from the observation table:
> "SELECT * FROM observation_table AS tab WHERE (tab.dataset_id IN (SELECT dataset_id FROM dataset_table WHERE task_id IN (SELECT task_id FROM task_table WHERE task_id IN (SELECT task_id FROM task_table WHERE task_name = 'stroop' OR task_name = 'flanker'))))"

The function `combine_sql_queries()` handles multiple arguments and combines them based on `argument_relation`, which indicated which arguments should be combined with an AND / OR operator. Applied to the argument list created in the example above, with only AND operators being used and the target variables being `c("rt", "accuracy")` the output looks as follows: 

```{r}
combine_sql_queries(
  arguments = arguments, 
  argument_sequence = get_argument_sequence(arguments, argument_relation), 
  path_list = compute_fastest_way_to_table(conn, target_table = "observation_table"),
  requested_vars = c("rt", "accuarcy")
)
```
> "SELECT rt, accuracy FROM observation_table AS tab WHERE (tab.dataset_id IN (SELECT dataset_id FROM dataset_table WHERE dataset_id IN (SELECT dataset_id FROM dataset_table WHERE n_participants > 200))) AND (tab.dataset_id IN (SELECT dataset_id FROM dataset_table WHERE task_id IN (SELECT task_id FROM task_table WHERE task_id IN (SELECT task_id FROM task_table WHERE task_name = 'stroop' OR task_name = 'flanker'))))"

### Join Paths
In order for the user to be able to select variables not present in the observation table, information from other tables must be added to the rows retained in the observation table after applying the filtering statements above. The function `add_join_paths_to_query()` handles this issue. The combined arguments returned by `combine_sql_queries()`, the connection to the database, the requested variables and a list of optimal join paths, similar to the list of optimal filter paths is required as inputs to the function. 

The list for optimal join paths is determined by the function `precompute_table_join_paths()` which discovers an optimal path from the table listed first in the SQL-argument (in our case, this is always the observation table) to all other tables that contain at least one of the requested variables in the database. The function prefers paths which contain the larger number of forward joins (implemented via LEFT JOIN), as these are easier to  implement.  

The function `add_join_paths_to_query()` thus joins the relevant tables present in the database to the requested target table. Because some variables (id-variables only) are present in multiple tables, each joined table is renamed based on its location in the join path list. The table joined first to the observation table is named "dtjoin1", the second "dtjoin2" and so on. The variables on which the tables are joined also receive the names of the tables they originate from as a prefix. The function `discover_id_introduction_steps()` returns a dataframe with information on which table and which position in the join path list an id-variable is introduced. This is then used to append the id-variable with the proper table name. Additionally, only variables that are not yet present in the joined data up to this point will be selected from the table to be joined.

See an example of join paths added to the combined SQL query generated above, with n_participants additionally being requested:
```
add_join_paths(
  conn = conn,
  argument = combine_sql_queries(
    arguments = arguments, 
    argument_sequence = get_argument_sequence(arguments, argument_relation), 
    path_list = compute_fastest_way_to_table(conn, target_table = "observation_table"),
    requested_vars = c("rt", "accuarcy")
    ),
  join_path_list = precompute_table_join_paths(conn),
  requested_vars = c("rt", "accuracy", "n_participants")
)
```
> "SELECT rt, accuracy, n_participants FROM observation_table AS tab LEFT JOIN (SELECT study_id, task_id, data_excl, n_participants, n_blocks, n_trials, neutral_trials, fixation_cross, time_limit, github, comment, dataset_id FROM dataset_table) AS dtjoin1 ON tab.dataset_id = dtjoin1.dataset_id LEFT JOIN (SELECT mean_age, percentage_female, n_members, group_description, between_id FROM between_table) AS dtjoin2 ON tab.between_id = dtjoin2.between_id LEFT JOIN (SELECT within_description, within_id FROM within_table) AS dtjoin3 ON tab.within_id = dtjoin3.within_id LEFT JOIN (SELECT percentage_congruent, percentage_neutral, n_obs, mean_obs_per_participant, condition_id FROM condition_table) AS dtjoin4 ON tab.condition_id = dtjoin4.condition_id LEFT JOIN (SELECT publication_id, n_groups, n_tasks, comment, study_id FROM study_table) AS dtjoin5 ON dtjoin1.study_id = dtjoin5.study_id LEFT JOIN (SELECT task_name, task_description, task_id FROM task_table) AS dtjoin6 ON dtjoin1.task_id = dtjoin6.task_id LEFT JOIN (SELECT authors, conducted, added, country, contact, apa_reference, keywords, publication_code, publication_id FROM publication_table) AS dtjoin7 ON dtjoin5.publication_id = dtjoin7.publication_id WHERE (tab.dataset_id IN (SELECT dataset_id FROM dataset_table WHERE dataset_id IN (SELECT dataset_id FROM dataset_table WHERE n_participants > 200))) AND (tab.dataset_id IN (SELECT dataset_id FROM dataset_table WHERE task_id IN (SELECT task_id FROM task_table WHERE task_id IN (SELECT task_id FROM task_table WHERE task_name = 'stroop' OR task_name = 'flanker'))))"

In the above output, you can see that all queries begin with a selection of variables from the observation table. Relevant other tables from the database are joined onto the observation table. This is then filtered by the combined statements and finally, only the requested variables are returned to the user.




