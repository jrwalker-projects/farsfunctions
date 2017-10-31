## quiets concerns of R CMD check re : the .'s that appear in pipelines
if(getRversion() >= "2.15.1") utils::globalVariables(c("STATE", "MONTH", "year", "n"))
#' Reads the named csv file into a data table
#'
#' \code{fars_read} is a simple function that reads a csv file and returns
#' a data table. If a file for a given year is not found a warning is issued
#' showing the year that is not valid.
#'
#' @param filename character name of the csv file to be read - must be a vector of length 1 or an error
#' message is returned.
#'
#' @return data frame coerced from the csv file input
#'
#' @examples
#' \dontrun{
#' df <- fars_read("data/fars_data.csv")
#' my.data.frame <- fars_read("data/accident_2002.csv.bz2")
#'}
#'
#' @details This routine calls read_csv and returns a 'tbl_df' table data frame. The routine has
#' no expectations for (nor awareness of) the FARS data structures.
#'
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#'
#' @export
fars_read <- function(filename) {
    if(!file.exists(filename))
        stop("file '", filename, "' does not exist")
    data <- suppressMessages({
        readr::read_csv(filename, progress = FALSE)
    })
    dplyr::tbl_df(data)
}
#' Creates a name for the accident csv file using a year value
#'
#' \code{make filename} uses the input year to create a file name for the accident csv file. For example
#' if the year parameter has a value of 2012 the file name constructed will be "accident_2002.csv.bz2".
#' If the year parameter value cannot be coerced into a numeric integer value the file name will be
#' ""accident_NA.csv.bz2"
#'
#' @param year one or more year values to be included in the file name string
#'
#' @return character vector of file names constructed from the years provided
#'
#' @examples
#' make_filename(2015)
#'
#' @export
make_filename <- function(year) {
    year <- as.integer(year)
    sprintf("accident_%d.csv.bz2", year)
}
#' Get year and month columns from one or more FARS accident data files
#'
#' \code{fars_read_years} reads one or more years of FARS accident data to provide
#' the year and MONTH columns. If a file is not found a warning is returned that the
#' year is not valid (if the file does not contain a column named MONTH and a column named
#' year the same warning is issued).
#'
#' @param years vector of one or more years of files to read
#'
#' @return a list of one or more data frames (one for each year). Each data frame has two columns from each row of the files found:
#' \itemize{\item MONTH is the numeric month (1 through 12)
#' \item year is the numeric year}
#'
#' @examples
#' \dontrun{
#' my_df <- fars_read_years(2014:2016)
#'}
#'
#' @seealso \code{\link{make_filename}} for the file nameing convention used
#'
#' @references for more information on FARS data see https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars
#'
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom magrittr %>%
#'
#' @export
fars_read_years <- function(years) {
    lapply(years, function(year) {
        file <- make_filename(year)
        tryCatch({
            dat <- fars_read(file)
            dplyr::mutate(dat, year = year) %>%
                dplyr::select(MONTH, year)
        }, error = function(e) {
            warning("invalid year: ", year)
            return(NULL)
        })
    })
}
#' Count the number of accidents in FARS data over the years requested
#'
#' \code{fars_summarize_years} reads one or more years of FARS accident data then summarizes a count
#' by month of the number of accidents. If a file is not found a warning is returned that the
#' year is not valid (if the file does not contain a column named MONTH and a column named
#' year the same warning is issued).
#'
#' @param years vector of one or more years of files to read
#'
#' @return a data frame with a column for the 12 months followed by a column for each year returned. The rows
#' are the numeric month followed by a count of the accidents for that year and month so the table has at most 12 rows.
#' For example, if years 2015 #' and 2016 are requested and there are 2371 accidents in 2015 and 2344 accidents in 2016,
#' the data frame would have column names of 'MONTH', '2015' and '2016' and start something like this:
#' \tabular{lllll}{
#' MONTH \tab 2015 \tab 2016\cr
#' 1 \tab 2371 \tab 2344\cr
#' 2 \tab 1983 \tab 2421\cr
#' }
#' with additional rows for the remaining months
#'
#' @examples
#' \dontrun{
#' my_df <- fars_summarize_years(2015:2016)
#'}
#'
#' @seealso \code{\link{make_filename}} for the file nameing convention used\cr
#' \code{\link{fars_read_years}} for the file input
#'
#' @references for more information on FARS data see https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars
#'
#' @importFrom dplyr bind_rows
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize
#' @importFrom tidyr spread
#' @importFrom magrittr %>%
#'
#' @export
fars_summarize_years <- function(years) {
    dat_list <- fars_read_years(years)
    dplyr::bind_rows(dat_list) %>%
        dplyr::group_by(year, MONTH) %>%
        dplyr::summarize(n = n()) %>%
        tidyr::spread(year, n)
}
#' Display a map of accidents in a US state for a given year from FARS data
#'
#' \code{fars_map_state} reads FARS accident data for the year requested. If the file for that year is found,
#' the function plots a map of the state then plots the location of accidents in that year using the latitude and
#' longitude provided in the data file. If the accident file is not found an error message is returned.
#'
#' @param state.num numeric value for the US state to be mapped - must be of length 1 or an error message is returned. If
#' the state value is not found in the accident file an error message is returned. For a list of numbers assigned
#' to the states see the FARS Analytical Users Manual.
#'
#' @param year numeric value for the year to be mapped - must be of length 1 or an error message is returned
#'
#' @return NULL
#'
#' @examples
#' \dontrun{
#' fars_map_state(17, 2016) #map accidents in Illinois for the year 2016
#'}
#'
#' @seealso \code{\link{make_filename}} for the file nameing convention used\cr
#' \code{\link{fars_read}} for the data file input
#'
#' @references for more information on FARS data see https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars
#'
#' @importFrom dplyr filter
#' @importFrom maps map
#' @importFrom graphics points
#'
#' @export
fars_map_state <- function(state.num, year) {
    filename <- make_filename(year)
    data <- fars_read(filename)
    state.num <- as.integer(state.num)

    if(!(state.num %in% unique(data$STATE)))
        stop("invalid STATE number: ", state.num)
    data.sub <- dplyr::filter(data, STATE == state.num)
    if(nrow(data.sub) == 0L) {
        message("no accidents to plot")
        return(invisible(NULL))
    }
    is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
    is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
    with(data.sub, {
        maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                  xlim = range(LONGITUD, na.rm = TRUE))
        graphics::points(LONGITUD, LATITUDE, pch = 46)
    })
}
