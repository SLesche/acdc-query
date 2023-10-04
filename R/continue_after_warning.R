#' Require user input after warning
#'
#' This function requires the user to input that they want to continue with the current process.
#'
#' @param message The message displayed to the user.
#' @return Nothing. Throws an error depending on user input
#' @export
continue_after_warning <- function(message){
  answer = utils::menu(
    choices = c("Yes, I want to continue anyways", "No. That is not what I want"),
    title = paste0(message)
  )
  if (answer == 2)
  {
    stop("Process cancelled")
  }
}
