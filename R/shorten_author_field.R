shorten_author_field <- function(authors){
  # assumes all authors are separated by commas and the letters
  # following the last space is the last name of the author

  n_commas = stringr::str_count(authors, ",")

  if (n_commas < 2){
    return(authors)
  } else {
    first_author = strsplit(authors, ",")[[1]][1]
    last_name = strsplit(first_author, " ")[[1]][length(strsplit(first_author, " ")[[1]])]

    authors = paste(last_name, "et al.")
    return(authors)
  }
}
