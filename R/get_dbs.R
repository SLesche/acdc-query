#' Download TED database from GitHub release
#'
#' Downloads the `ted.db` SQLite database from the latest (or specified)
#' release on `SLesche/truth-effect-database` to a given directory.
#'
#' @param dest_dir Directory where the database should be saved.
#' @param tag Optional release tag. If NULL, uses latest release.
#' @param token Optional GitHub token. Defaults to `Sys.getenv("GITHUB_PAT")`.
#'
#' @return Invisibly returns the full path to the downloaded file.
#' @export
#'
#' @examples
#' \dontrun{
#' download_ted(tempdir())
#' }
download_ted <- function(dest_dir,
                    tag = NULL,
                    token = Sys.getenv("GITHUB_PAT")) {

  download_sqlite_release(
    owner = "SLesche",
    repo = "truth-effect-database",
    asset_name = "ted.db",
    dest_dir = dest_dir,
    tag = tag,
    token = token,
    overwrite = TRUE
  )
}

#' Download ACDC database from GitHub release
#'
#' Downloads the `acdc.db` SQLite database from the latest (or specified)
#' release on `jstbcs/acdc-database` to a given directory.
#'
#' @param dest_dir Directory where the database should be saved.
#' @param tag Optional release tag. If NULL, uses latest release.
#' @param token Optional GitHub token. Defaults to `Sys.getenv("GITHUB_PAT")`.
#'
#' @return Invisibly returns the full path to the downloaded file.
#' @export
#'
#' @examples
#' \dontrun{
#' download_acdc(tempdir())
#' }
download_acdc <- function(dest_dir,
                     tag = NULL,
                     token = Sys.getenv("GITHUB_PAT")) {

  download_sqlite_release(
    owner = "jstbcs",
    repo = "acdc-database",
    asset_name = "acdc.db",
    dest_dir = dest_dir,
    tag = tag,
    token = token,
    overwrite = TRUE
  )
}
