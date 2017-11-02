# farsfunctions

### *Functions for processing US traffic accident data*
The `farsfunctions` package assists in reading and summarizing of US Department of Transportation data compiled by the National
Highway Traffic Safety Administration (NHTSA) provided in the Fatality Analysis Reporting System (FARS).

## Installation
You can install farsfunctions from github with:

``` r
# install.packages("devtools")
devtools::install_github("jrwalker-projects/farsfunctions")
```

## Example

The `fars_map_state` function plots a US state map showing the locations of accidents in a given year from available FARS
accident files:

``` r
fars_map_state(1, 2016)
```
Use of these functions is described in the package vignette. 
For more information on FARS data see [the FARS website:](https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars)

[![Travis build status](https://travis-ci.org/jrwalker-projects/farsfunctions.svg?branch=master)](https://travis-ci.org/jrwalker-projects/farsfunctions)
