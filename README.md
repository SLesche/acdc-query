# inhibitiondb - Interaction with the Amsterdam Inhibitiontasks Database
## Installation
You can install this package via `devtools::install_github("SLesche/inhibitiondb")`. You may need to update imported packages.

## Dependencies
This package is designed for use in R 4.2.2. Certain functions may break in different R versions. It heavily relies on the packages DBI, RSQLite, dplyr, stringr

## Use
In order to interact with the database, you must first [download](https://github.com/jstbcs/inhibitiontasks/raw/inhibitiontaks_db2023/inhibitiontasks.db) it from its [parent repo](https://github.com/jstbcs/inhibitiontasks/tree/inhibitiontaks_db2023).

The you can connect to the database via `connect_to_db("path/to/db.db")`. Store this connection in an object (called conn, for example). Then add arguments based on which to filter data from the database to a list as in the following example:

```
arguments <- list() %>% 
  add_argument(
    conn = conn,
    variable = "n_tasks",
    operator = "greater",
    values = 15
  ) %>% 
  add_argument(
    conn = conn,
    variable = "task_name",
    operator = "equal",
    values = c("stroop", "simon")
  ) %>% 
  add_argument(
    conn = conn,
    variable = "percentage_female",
    operator = "between",
    values = c(0.25, 0.75)
  ) %>% 
  add_argument(
    conn = conn,
    variable = "percentage_congruent",
    operator = "greater",
    values = 0.2
  )
```

This argument list can then be used to filter proper entries from the database via `query_db(conn, arguments)`. This will return a list containing proper matched in the respective tables. It can be merged to an R-dataframe via `merge_query_results()`.

## Working example
```
# devtools::install_github("SLesche/inhibitiondb")
library(inhibitiondb)
library(dplyr)
conn <- connect_to_db("inhibitiontasks.db")

arguments <- list() %>% 
  add_argument(
    conn = conn,
    variable = "n_tasks",
    operator = "greater",
    values = 15
  ) %>% 
  add_argument(
    conn = conn,
    variable = "task_name",
    operator = "equal",
    values = c("stroop", "simon")
  ) %>% 
  add_argument(
    conn = conn,
    variable = "percentage_female",
    operator = "between",
    values = c(0.25, 0.75)
  ) %>% 
  add_argument(
    conn = conn,
    variable = "percentage_congruent",
    operator = "greater",
    values = 0.2
  )

df <- query_db(conn, arguments) %>% 
  merge_query_results()
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

### Filter Paths
Querying makes use of the function `compute_fastest_way_to_table()` which discovers the fastest way from a given input table to a specified target table, while avoiding connections through the observation table. If the user filters based on a variable in the _study table_, for example. The fastest way towards the observation table starting from the task-table, as in the second argument in the example above is through the dataset-table. The function `convert_query_path_to_sql()` takes the filter-argument and the list containing path info returned by `compute_fastest_way_to_table()` and extends the SQL query to now select from the observation table:
> "SELECT * FROM observation_table AS tab WHERE (tab.dataset_id IN (SELECT dataset_id FROM dataset_table WHERE task_id IN (SELECT task_id FROM task_table WHERE task_id IN (SELECT task_id FROM task_table WHERE task_name = 'stroop' OR task_name = 'flanker'))))"

The function `combine_sql_queries()` handles multiple arguments and combines them based on `argument_relation`, which indicated which arguments should be combined with an AND / OR operator. Applied to the argument list created in the example above, with only AND operators being used and the target variables being `c("rt", "accuracy")` the output looks as follows: 

´´´{R}
combine_sql_queries(
  arugments = arguments, 
  argument_sequence = get_argument_sequence(arguments, argument_relation), 
  path_list = compute_fastest_way_to_table(conn, target_table = "observation_table"),
  requested_vars = c("rt", "accuarcy")
)

# "SELECT rt, accuracy FROM observation_table AS tab WHERE (tab.dataset_id IN (SELECT dataset_id FROM dataset_table WHERE dataset_id IN (SELECT dataset_id FROM dataset_table WHERE n_participants > 200))) AND (tab.dataset_id IN (SELECT dataset_id FROM dataset_table WHERE task_id IN (SELECT task_id FROM task_table WHERE task_id IN (SELECT task_id FROM task_table WHERE task_name = 'stroop' OR task_name = 'flanker'))))"
```

### Join Paths



