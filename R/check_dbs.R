#' Check local TED database against GitHub release
#'
#' Compares the SHA256 hash of a local TED SQLite database (`ted.db`)
#' with the hash stored in the latest (or specified) release on
#' `SLesche/truth-effect-database`.
#'
#' @param local_sqlite_path Path to the local `ted.db` file.
#' @param tag Optional release tag. If NULL, uses latest release.
#' @param token Optional GitHub token. Defaults to `Sys.getenv("GITHUB_PAT")`.
#' @param algo Hash algorithm used for comparison (default: `"sha256"`).
#'
#' @return Returns TRUE if the local database is up to date,
#'   FALSE if it is outdated.
#' @export
#'
#' @examples
#' \dontrun{
#' check_ted("ted.db")
#' }
check_ted <- function(
    local_sqlite_path,
    tag = NULL,
    token = Sys.getenv("GITHUB_PAT"),
    algo = "sha256"
) {
  
  is_current <- compare_sqlite_to_release(
    owner = "SLesche",
    repo = "truth-effect-database",
    asset_name = "ted.db",
    local_sqlite_path = local_sqlite_path,
    tag = tag,
    token = token,
    algo = algo
  )

  if (is_current) {
    message("Local TED database is up to date.")
  } else {
    message("Local TED database is outdated. Consider running update_ted() to download the latest version.")
  }
  
  return(is_current)
}

#' Check local ACDC database against GitHub release
#'
#' Compares the SHA256 hash of a local ACDC SQLite database (`acdc.db`)
#' with the hash stored in the latest (or specified) release on
#' `jstbcs/acdc-database`.
#'
#' @param local_sqlite_path Path to the local `acdc.db` file.
#' @param tag Optional release tag. If NULL, uses latest release.
#' @param token Optional GitHub token. Defaults to `Sys.getenv("GITHUB_PAT")`.
#' @param algo Hash algorithm used for comparison (default: `"sha256"`).
#'
#' @return Returns TRUE if the local database is up to date,
#'   FALSE if it is outdated.
#' @export
#'
#' @examples
#' \dontrun{
#' check_acdc("acdc.db")
#' }
check_acdc <- function(
    local_sqlite_path,
    tag = NULL,
    token = Sys.getenv("GITHUB_PAT"),
    algo = "sha256"
) {
  
  is_current <- compare_sqlite_to_release(
    owner = "jstbcs",
    repo = "acdc-database",
    asset_name = "acdc.db",
    local_sqlite_path = local_sqlite_path,
    tag = tag,
    token = token,
    algo = algo
  )

  if (is_current) {
    message("Local ACDC database is up to date.")
  } else {
    message("Local ACDC database is outdated. Consider running update_acdc() to download the latest version.")
  }
  
  return(is_current)
}
