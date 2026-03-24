
test_that(".mwb_data_files and .mwb_data_files_offline works", {
    ## error
    expect_error(.mwb_data_files(mwbId = "ST000000000"),
                 "Failed to retrieve")

    mwb_delete_cache("ST002115")

    expect_error(.mwb_data_files(mwbId = "ST002115",
                                 pattern = "nonexistentpattern"),
                 "No files matching")

    ## Error if no cache available
    with_mocked_bindings(
        ".mwb_has_mwb_table" = function() FALSE,
        code = expect_error(.mwb_data_files_offline("ST002115"),
                            "No local Metabolomics Workbench cache")
    )

    ## Cache the data: Will use a specfic pattern to just load 2 files.
    a <- .mwb_data_files("ST002115", pattern = "01_RP.mzXML$")
    expect_true(is.data.frame(a))
    expect_true(nrow(a) == 4)
    expect_true(all(a$mwb_id == "ST002115"))
    ## Re-call function the data.
    Sys.sleep(1)
    b <- .mwb_data_files("ST002115", pattern = "01_RP.mzXML$")
    expect_true(is.data.frame(b))
    expect_true(nrow(b) == 4)
    expect_true(all(b$mwb_id == "ST002115"))
    expect_equal(a$rpath, b$rpath)

    ## with fileNames
    expect_error(.mwb_data_files("ST002115", pattern = "01_RP.mzXML$",
                                 fileName = c("a", "b")), "None of the ")


    expect_true(.mwb_has_mwb_table())

    ## Use offline
    expect_error(.mwb_data_files_offline("ST002115", pattern = ".raw$"),
                 "No locally cached data files")

    d <- .mwb_data_files_offline("ST002115", pattern = "01_RP.mzXML$")
    expect_true(is.data.frame(a))
    expect_true(nrow(a) == 4)
    expect_true(all(a$mwb_id == "ST002115"))
    expect_equal(a$rpath, d$rpath)
})

test_that("mwb_sync_data_files works", {
    expect_error(mwb_sync_data_files(), "No Metabolomics Workbench data")
    res <- mwb_sync_data_files("ST002115", pattern = "*",
                               fileName = c("HT1080_DMSO_01_RP.mzXML"))
    expect_true(is.data.frame(res))
    expect_equal(nrow(res), 1L)
    expect_equal(res$mwb_id, "ST002115")
})

test_that("mwb_cached_data_files works", {
    res <- mwb_cached_data_files()
    expect_true(is.data.frame(res))
    expect_true(nrow(res) > 0)

    res <- mwb_cached_data_files(fileName = "other")
    expect_true(is.data.frame(res))
    expect_true(nrow(res) == 0)
})

test_that("mwb_list_files works", {
    expect_error(mwb_list_files(c("ST000016", "ST002115")),
                 "Provide a single Metabolomics Workbench ID")
})

test_that("mwb_delete_cache works", {
    bfc <- BiocFileCache()
    l <- length(bfc)
    mwb_delete_cache()
    expect_equal(length(bfc), l)

    mwb_delete_cache("ST002115")
    i <- bfcinfo(bfc)
    expect_true(!any(i$mwb_id %in% "ST002115"))
})

test_that("mwb_rest_request works", {
    expect_error(mwb_rest_request(c("ST000016", "ST002115")),
                 "Provide a single Metabolomics Workbench ID")

    expect_error(mwb_rest_request("ST002115",
                                  outputItem = c("summary","factors")),
                 "Provide a single outputItem request")

    expect_error(mwb_rest_request("ST002115", outputItem = "summary",
                                  outputFormat = "wrongFormat"),
                 "Wrong output format")

    ## simulate connection error and assert custom message
    with_mocked_bindings(
      "request" = function(...) stop("request failed"),
      expect_error(
        mwb_rest_request("ST002115", outputItem = "summary"),
        "Failed to connect to Metabolomics Workbench"
      )
    )

    res <- mwb_rest_request("ST002115", outputItem = "summary")
    expect_true(jsonlite::validate(res))

})

test_that("mwb_ftp_list_files works", {
    expect_error(mwb_ftp_list_files(), "Provide 1 Metabolomics Workbench ID")
    expect_error(mwb_ftp_list_files(c("ST002115","ST000016")),
                 "Provide 1 Metabolomics Workbench ID")

    expect_error(mwb_ftp_list_files("AAA"), "No files detected")

    expect_error(mwb_ftp_list_files("ST002115", pattern = "nonexistentpattern"),
                 "No files matching")

    ## simulate connection error and assert custom message
    with_mocked_bindings(
        "curl" = function(...) stop("request failed"),
        expect_error(
            mwb_ftp_list_files("ST002115"),
            "Failed to connect to Metabolomics Workbench"
        )
    )

    res <- mwb_ftp_list_files("ST002115")
    expect_true(length(res) == 1)
    expect_true(grepl(".zip", res))

    res <- mwb_ftp_list_files("ST000909", pattern = ".txt")
    expect_true(length(res) == 2)
    expect_true(all(grepl(".txt", res)))
})

test_that("mwb_ftp_download works", {
    expect_error(mwb_ftp_download(), "Provide 1 Metabolomics Workbench ID")
    expect_error(mwb_ftp_download(c("ST002115","ST000016")),
                 "Provide 1 Metabolomics Workbench ID")

    ## simulate connection error and assert custom message
    with_mocked_bindings(
        "download.file" = function(...) stop("request failed"),
        expect_error(
            mwb_ftp_download("ST000909", pattern = ".txt", path = tempdir()),
            "Failed to connect to Metabolomics Workbench"
        )
    )

    ## Test creation directory
    tmp <- file.path(tempdir(), paste0("test_", sample(1e6, 1)))
    on.exit(unlink(tmp, recursive = TRUE))
    suppressWarnings(mwb_ftp_download("ST000909", pattern = ".txt", path = tmp))
    expect_true(dir.exists(tmp))
    expect_true(file.exists(paste0(tmp, "/ST000909_AN001476_Results.txt")))

    ## Test overwrite = FALSE (default): file should be skipped
    mtime_before <- file.info(file.path(tmp,
                                        "ST000909_AN001476_Results.txt"))$mtime
    Sys.sleep(1)
    expect_message(
        suppressWarnings(
            mwb_ftp_download("ST000909", pattern = ".txt", path = tmp)
        ),
        "already exists"
    )
    mtime_after <- file.info(file.path(tmp,
                                       "ST000909_AN001476_Results.txt"))$mtime
    expect_equal(mtime_before, mtime_after)

    ## Test overwrite = TRUE: file should be re-downloaded
    Sys.sleep(1)
    suppressWarnings(
        mwb_ftp_download("ST000909", pattern = ".txt", path = tmp,
                         overwrite = TRUE)
    )
    mtime_overwritten <- file.info(
        file.path(tmp, "ST000909_AN001476_Results.txt"))$mtime
    expect_true(mtime_overwritten > mtime_before)
})
