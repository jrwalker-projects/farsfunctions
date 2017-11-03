
context("plot map")

#set wd to access test accident files in the package
setwd(system.file("extdata",package="farsfunctions"))

#test fars_map_state - unless there's an error map function only has side effects
test_that("state map using fars_map_state", {
    expect_null(fars_map_state(1, 2016)) #expect to run without error returning NULL
    expect_error(fars_map_state(100, 2016)) #expect error for invalid state (where file is found)
    expect_error(fars_map_state(1, 2000)) #expect error for file not found
})

