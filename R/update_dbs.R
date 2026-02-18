#' Update a local SQLite database from a GitHub release
#'
#' Internal helper function that compares a local SQLite database
#' with a GitHub release and optionally downloads the latest version.
#'
#' @param owner GitHub repository owner.
#' @param repo GitHub repository name.
#' @param asset_name Name of the SQLite file in the release.
#' @param local_sqlite_path Path to the local SQLite database.
#' @param tag Optional release tag. If NULL, uses latest release.
#' @param token Optional GitHub token. Defaults to `Sys.getenv("GITHUB_PAT")`.
#' @param algo Hash algorithm to use (default: `"sha256"`).
#' @param update Logical; if TRUE, will download the latest database
#'   when the local copy is outdated (default: FALSE).
#'
#' @return Invisibly returns TRUE if the local database is up to date,
#'   FALSE if it is outdated (and possibly updated if `update = TRUE`).
update_database <- function(
  owner,
  repo,
  asset_name,
  local_sqlite_path,
  tag = NULL,
  token = Sys.getenv("GITHUB_PAT"),
  algo = "sha256",
  update = FALSE
) {

  is_current <- compare_sqlite_to_release(
    owner = owner,
    repo = repo,
    asset_name = asset_name,
    local_sqlite_path = local_sqlite_path,
    tag = tag,
    token = token,
    algo = algo
  )

  if (is_current) {
    message("Local database is up to date with GitHub release.")
    return(invisible(TRUE))
  } else {
    message("Local database is NOT up to date with GitHub release.")
    if (update) {
      message("Downloading latest database...")
      download_sqlite_release(
        owner = owner,
        repo = repo,
        asset_name = asset_name,
        dest_dir = local_sqlite_path,
        tag = tag,
        token = token
      )
      message("Database updated successfully.")
    } else {
      message("Database update skipped. Set `update = TRUE` to download the latest version.")
    }
    return(invisible(FALSE))
  }
}

#' Update local TED database from GitHub release
#'
#' Checks whether the local TED SQLite database (`ted.db`) is up to date
#' with the release on `SLesche/truth-effect-database` and optionally downloads
#' the latest version.
#'
#' @param local_sqlite_path Path to the local `ted.db` file.
#' @param tag Optional release tag. If NULL, uses latest release.
#' @param update Logical; if TRUE, will download the latest database
#'   when the local copy is outdated (default: FALSE).
#' @param token Optional GitHub token. Defaults to `Sys.getenv("GITHUB_PAT")`.
#' @param algo Hash algorithm (default: `"sha256"`).
#'
#' @return Invisibly returns TRUE if up to date, FALSE if outdated.
#' @export
#'
#' @examples
#' \dontrun{
#' update_ted("ted.db")
#' update_ted("ted.db", update = TRUE)
#' }
update_ted <- function(
    local_sqlite_path,
    tag = NULL,
    update = FALSE,
    token = Sys.getenv("GITHUB_PAT"),
    algo = "sha256"
) {

  update_database(
    owner = "SLesche",
    repo = "truth-effect-database",
    asset_name = "ted.db",
    local_sqlite_path = local_sqlite_path,
    tag = tag,
    token = token,
    algo = algo,
    update = update
  )
}

#' Update local ACDC database from GitHub release
#'
#' Checks whether the local ACDC SQLite database (`acdc.db`) is up to date
#' with the release on `jstbcs/acdc-database` and optionally downloads
#' the latest version.
#'
#' @param local_sqlite_path Path to the local `acdc.db` file.
#' @param tag Optional release tag. If NULL, uses latest release.
#' @param update Logical; if TRUE, will download the latest database
#'   when the local copy is outdated (default: FALSE).
#' @param token Optional GitHub token. Defaults to `Sys.getenv("GITHUB_PAT")`.
#' @param algo Hash algorithm (default: `"sha256"`).
#'
#' @return Invisibly returns TRUE if up to date, FALSE if outdated.
#' @export
#'
#' @examples
#' \dontrun{
#' update_acdc("acdc.db")
#' update_acdc("acdc.db", update = TRUE)
#' }
update_acdc <- function(
    local_sqlite_path,
    tag = NULL,
    update = FALSE,
    token = Sys.getenv("GITHUB_PAT"),
    algo = "sha256"
) {

  update_database(
    owner = "jstbcs",
    repo = "acdc-database",
    asset_name = "acdc.db",
    local_sqlite_path = local_sqlite_path,
    tag = tag,
    token = token,
    algo = algo,
    update = update
  )
}
