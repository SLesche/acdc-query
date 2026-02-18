#' Create SHA256 hash file for a SQLite database
#'
#' Computes a SHA256 hash for a SQLite database file and writes it to
#' a `.sha256` file. The hash file can be uploaded alongside the database
#' in a GitHub release to allow version comparison without downloading
#' the full database.
#'
#' @param sqlite_path Path to the SQLite file.
#' @param output_file Optional output path for the hash file.
#'   Defaults to `<sqlite_path>.sha256`.
#' @param algo Hash algorithm (default: `"sha256"`).
#'
#' @return Invisibly returns the path to the hash file.
#' @import httr
#' @examples
#' \dontrun{
#' create_sqlite_hash_file("database.sqlite")
#' }
create_sqlite_hash_file <- function(sqlite_path,
                                    output_file = NULL,
                                    algo = "sha256") {

  if (!file.exists(sqlite_path)) {
    stop("SQLite file does not exist.", call. = FALSE)
  }

  hash_value <- digest::digest(file = sqlite_path, algo = algo)

  if (is.null(output_file)) {
    output_file <- paste0(sqlite_path, ".", algo)
  }

  writeLines(hash_value, output_file)

  invisible(output_file)
}


#' Download SQLite file from GitHub release
#'
#' Downloads a SQLite database file from the latest or a specific
#' GitHub release.
#'
#' @param owner Repository owner.
#' @param repo Repository name.
#' @param asset_name Name of the SQLite asset in the release.
#' @param dest_dir Local directory where the file should be saved.
#' @param tag Optional release tag (e.g., `"v1.2.0"`).
#'   If NULL, the latest release is used.
#' @param algo Hash algorithm (default: `"sha256"`).
#' @param token Optional GitHub token. Defaults to `Sys.getenv("GITHUB_PAT")`.
#' @param overwrite Whether to overwrite existing file (default: TRUE).
#'
#' @return Invisibly returns the full path to the downloaded file.
#'
#' @examples
#' \dontrun{
#' download_sqlite_release(
#'   owner = "myuser",
#'   repo = "myrepo",
#'   asset_name = "database.sqlite",
#'   dest_dir = tempdir()
#' )
#' }
download_sqlite_release <- function(owner,
                                    repo,
                                    asset_name,
                                    dest_dir,
                                    tag = NULL,
                                    algo = "sha256",
                                    token = Sys.getenv("GITHUB_PAT"),
                                    overwrite = TRUE) {

  release <- get_github_release(owner, repo, tag, token)

  hash_asset_name <- paste0(asset_name, ".", algo)

  if (length(release$assets) == 0){
    stop("No assests found in release")
  }

  asset <- release$assets[release$assets$name == hash_asset_name, ]

  if (nrow(asset) == 0) {
    stop(
      paste(
        "Hash asset", asset_name, "not found in release.",
        "\nAvailable assets:", paste(release$assets$name, collapse = "; ")
        ),
      call. = FALSE
    )
  }

  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE)
  }

  dest_file <- file.path(dest_dir, asset_name)

  resp <- httr::GET(
    asset$browser_download_url,
    httr::write_disk(dest_file, overwrite = overwrite)
  )

  if (httr::status_code(resp) != 200) {
    stop("Download failed.", call. = FALSE)
  }

  invisible(dest_file)
}


#' Compare local SQLite database to GitHub release hash
#'
#' Compares the SHA256 hash of a local SQLite database file
#' with the hash file stored in a GitHub release.
#'
#' This avoids downloading the full database when checking
#' for updates.
#'
#' @param owner Repository owner.
#' @param repo Repository name.
#' @param asset_name Name of the SQLite asset (used to derive hash filename).
#' @param local_sqlite_path Path to local SQLite database.
#' @param tag Optional release tag. If NULL, uses latest release.
#' @param token Optional GitHub token. Defaults to `Sys.getenv("GITHUB_PAT")`.
#' @param algo Hash algorithm (default: `"sha256"`).
#'
#' @return TRUE if hashes match, FALSE otherwise.
#' @import digest
#' @import httr
#'
#' @examples
#' \dontrun{
#' compare_sqlite_to_release(
#'   owner = "myuser",
#'   repo = "myrepo",
#'   asset_name = "database.sqlite",
#'   local_sqlite_path = "database.sqlite"
#' )
#' }
compare_sqlite_to_release <- function(owner,
                                      repo,
                                      asset_name,
                                      local_sqlite_path,
                                      tag = NULL,
                                      token = Sys.getenv("GITHUB_PAT"),
                                      algo = "sha256") {

  if (!file.exists(local_sqlite_path)) {
    stop("Local SQLite file does not exist.", call. = FALSE)
  }

  release <- get_github_release(owner, repo, tag, token)

  hash_asset_name <- paste0(asset_name, ".", algo)

  if (length(release$assets) == 0){
    stop("No assests found in release")
  }

  asset <- release$assets[release$assets$name == hash_asset_name, ]

  if (nrow(asset) == 0) {
    stop(
      paste(
        "Hash asset", asset_name, "not found in release.",
        "\nAvailable assets:", paste(release$assets$name, collapse = "; ")
        ),
      call. = FALSE
    )
  }

  tmp <- tempfile()

  resp <- httr::GET(
    asset$browser_download_url,
    httr::write_disk(tmp, overwrite = TRUE)
  )

  if (httr::status_code(resp) != 200) {
    stop("Failed to download hash file.", call. = FALSE)
  }

  remote_hash <- trimws(readLines(tmp, warn = FALSE))
  unlink(tmp)

  local_hash <- digest::digest(file = local_sqlite_path, algo = algo)

  identical(local_hash, remote_hash)
}


# Internal helper (not exported)
get_github_release <- function(owner, repo, tag = NULL, token = NULL) {

  base_url <- sprintf("https://api.github.com/repos/%s/%s/releases", owner, repo)

  final_url <- if (is.null(tag)) {
    paste0(base_url, "/latest")
  } else {
    paste0(base_url, "/tags/", tag)
  }

  req <- if (!is.null(token) && nzchar(token)) {
    httr::GET(
      final_url,
      httr::add_headers(Authorization = paste("token", token))
    )
  } else {
    httr::GET(final_url)
  }

  if (httr::status_code(req) != 200) {
    stop(
      sprintf("GitHub API request failed [%s].", httr::status_code(req)),
      call. = FALSE
    )
  }

  jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))
}

