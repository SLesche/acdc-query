% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_filter_statement.R
\name{get_filter_statement}
\alias{get_filter_statement}
\title{Get Filter Statement}
\usage{
get_filter_statement(filter_statements, argument_sequence, introduction_table)
}
\arguments{
\item{filter_statements}{A character vector of SQL filter statements, one for each argument in the argument sequence.}

\item{argument_sequence}{A numeric vector representing the argument sequence for constructing the filter statement.}

\item{introduction_table}{A data frame containing information about table prefixes for ID variables.}
}
\value{
A character string representing the constructed SQL filter statement.
}
\description{
This function constructs a SQL filter statement based on the provided filter statements and argument sequence.
}
