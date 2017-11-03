
context("summarizing accident data")

#set wd to access test accident files in the package
setwd(system.file("extdata",package="farsfunctions"))

ac_sum <- fars_summarize_years(2015:2016)
#test fars_summarize_years
test_that("summary using fars_summarize_years", {
    expect_is(ac_sum, "tbl_df")
    expect_equal(ncol(ac_sum), 3) #at least 1 col
    expect_gt(nrow(ac_sum), 0) #at least 1 row
    expect_equal(names(ac_sum[1]), "MONTH") #check 1st col name
    expect_is(ac_sum$MONTH, "integer") #check colum data type
    expect_warning(fars_summarize_years(2014:2016)) #expect warning 'invalid year' for a file not found
})

