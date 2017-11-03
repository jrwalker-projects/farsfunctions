
context("file access")

af2016 <- make_filename(2016)
#test make_filename
test_that("building accident file names", {
    expect_is(af2016, "character") #type character
    expect_equal(af2016, "accident_2016.csv.bz2")
    expect_warning(make_filename("XyZ"), "NAs introduced by coercion") #warning expected for non-numeric param
})

#set wd to access test accident files in the package
setwd(system.file("extdata",package="farsfunctions"))

ac2016 <- fars_read(make_filename(2016))
#test fars_read
test_that("direct file read using fars_read", {
    expect_is(ac2016, "tbl_df") #type tibble
    expect_gt(ncol(ac2016), 0) #at least 1 col
    expect_gt(nrow(ac2016), 0) #at least 1 row
    expect_equal(names(ac2016[1]), "STATE") #check a col name
})

ac_list2015_16 <- fars_read_years(2015:2016)
ac_l1 <- data.frame(ac_list2015_16[1])
#test fars_read_years
test_that("read_years", {
    expect_is(ac_list2015_16, "list") #type list
    expect_equal(length(ac_list2015_16), 2) #list of length 2
    expect_warning(fars_read_years(1017)) #warning expected for a year with no file to read
    expect_equal(names(ac_l1), c("MONTH", "year")) #expecting specific column names
    expect_gt(nrow(ac_l1), 0) #at least 1 row
})
