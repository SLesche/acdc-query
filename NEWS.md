# acdcquery 1.2.2

* Fixed issues with directory paths

# acdcquery 1.2.1

* Provided new functions to download recent versions of the supported databases and check whether a file is up-to-date. 
* Improved error handling when specifying wrong file names or non-existent table names

# acdcquery 1.1.1

* Fixed issues with variables present in filter but not requested

# acdcquery 1.1.0

* Results from `query_db()` now only return distinct entries for all tables except the observation table
* Improved matching speed by only selecting variables from tables required by filter arguments and return arguments
* Made the package compatible to work with the Truth Effect Database (TED)

# acdcquery 1.0.1

* Removed acdc.db. Changed examples

# acdcquery 1.0.0

* Initial release version
