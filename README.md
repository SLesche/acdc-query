# inhibitiondb - Interaction with the Amsterdam Inhibitiontasks Database
## Installation
You can install this package via `devtools::install_github("SLesche/inhibitiondb"). You may need to update imported packages.

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

