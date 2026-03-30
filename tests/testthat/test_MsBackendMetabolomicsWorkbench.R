
test_that("MsBackendMetabolomicsWorkbench works", {
    res <- MsBackendMetabolomicsWorkbench()
    expect_s4_class(res, "MsBackendMetabolomicsWorkbench")
    expect_true(inherits(res, "MsBackendMzR"))
})

test_that("backendInitialize,MsBackendMetabolomicsWorkbench works", {
    ## Test errors
    expect_error(backendInitialize(MsBackendMetabolomicsWorkbench(),
                                   data = data.frame(a = 3)),
                 "Parameter 'data' is not supported")
    expect_error(backendInitialize(MsBackendMetabolomicsWorkbench(),
                                   mwbId = c("a", "b")),
                 "Parameter 'mwbId' is required and can")
    expect_error(backendInitialize(MsBackendMetabolomicsWorkbench(),
                                   mwbId = "a"),
                 "Failed to retrieve")

    ## Test NMR data set
    expect_error(backendInitialize(MsBackendMetabolomicsWorkbench(),
                                   mwbId = "AAAA"),
                 "Failed to retrieve")
    ## Test failing POST request
    query_args <- NULL
    mock_POST <- function(url, query) {
        query_args <<- list(url = url, query = query)
        stop("simulated POST failure")
    }

    with_mocked_bindings("POST" = mock_POST, {
        expect_error(backendInitialize(MsBackendMetabolomicsWorkbench(),
                                       mwbId = "ST002115",
                                       filePattern = "DMSO_01_RP.mzXML$"),
                     "Failed to connect")
    })

    ## Test real data set.
    res <- backendInitialize(MsBackendMetabolomicsWorkbench(),
                             mwbId = "ST002115",
                             filePattern = "DMSO_01_RP.mzXML$")
    expect_s4_class(res, "MsBackendMetabolomicsWorkbench")
    expect_true(all(c("mwb_id", "zip_file", "file_name") %in%
                        Spectra::spectraVariables(res)))
    expect_true(all(res$mwb_id == "ST002115"))

    ## Test real data set via FTP server.
    res <- backendInitialize(MsBackendMetabolomicsWorkbench(),
                             mwbId = "ST002115",
                             filePattern = "DMSO_02_RP.mzXML$", ftp_zip = TRUE)
    expect_s4_class(res, "MsBackendMetabolomicsWorkbench")
    expect_true(all(c("mwb_id", "zip_file", "file_name") %in%
                        Spectra::spectraVariables(res)))
    expect_true(all(res$mwb_id == "ST002115"))

    ## Offline
    res_o <- backendInitialize(MsBackendMetabolomicsWorkbench(),
                               mwbId = "ST002115",
                               filePattern = "DMSO_02_RP.mzXML$",
                               offline = TRUE)
    expect_equal(Spectra::rtime(res), Spectra::rtime(res_o))
})

test_that("backendRequiredSpectraVariables,MsBackendMetabolomicsWorkbench
          works", {
              expect_equal(backendRequiredSpectraVariables(
                  MsBackendMetabolomicsWorkbench()),
                  c("dataStorage", "scanIndex", "mwb_id",
                    "zip_file", "file_name"))
          })

test_that("mwb_sync works", {
    expect_error(mwb_sync(3, offline = TRUE), "'x' is expected to be")

    x <- backendInitialize(MsBackendMetabolomicsWorkbench(), mwbId = "ST002115",
                           filePattern = "DMSO_02_RP.mzXML$", offline = TRUE)
    res <- mwb_sync(x, offline = TRUE)
    expect_equal(rtime(x), rtime(res))
    expect_equal(mz(x[1:50]), mz(res[1:50]))

    ## Remove local content.
    mwb_delete_cache("ST002115")
    expect_error(mwb_sync(x, offline = TRUE),
                 "No locally cached data files")

    Sys.sleep(4)

    ## Re-add content
    res <- mwb_sync(x, offline = FALSE)
    expect_equal(rtime(x), rtime(res))
    expect_equal(mz(x[1:50]), mz(res[1:50]))

    ## Error.
    with_mocked_bindings(
        "mwb_cached_data_files" = function(mwbId, ...) {
            data.frame(rid = c("1", "2"),
                       file_name = c("a", "b"),
                       rpath = "tmp")
        },
        code = expect_error(mwb_sync(x, offline = TRUE), "not available")
    )
})

test_that(".valid_mwb_required_columns works", {
    x <- MsBackendMetabolomicsWorkbench()
    expect_equal(.valid_mwb_required_columns(x), character())
    x@spectraData <- DataFrame(a = 1:4, b = "c")
    expect_match(.valid_mwb_required_columns(x), "One or more")
    x@spectraData$mwb_id <- 3
    x@spectraData$zip_file <- "z"
    x@spectraData$file_name <- "b"
    expect_equal(.valid_mwb_required_columns(x), character())
})

test_that(".valid_files_local works", {
    x <- MsBackendMetabolomicsWorkbench()
    expect_equal(.valid_files_local(x), character())
    x@spectraData <- DataFrame(a = 1:4, b = "c", dataStorage = "d")
    expect_match(.valid_files_local(x), "One or more of the data files")
})

test_that("backendMerge,MsBackendMetabolomicsWorkbench works", {
    ## Online mode
    be <- backendInitialize(MsBackendMetabolomicsWorkbench(),
                            mwbId = "ST002115",
                            filePattern = "DMSO_01_RP.mzXML$")
    l <- split(be, factor(be$dataOrigin, levels = unique(be$dataOrigin)))
    res <- backendMerge(l)

    expect_equal(rtime(be), rtime(res))
    expect_equal(dataOrigin(be), dataOrigin(res))
    expect_equal(mz(be), mz(res))

    ## Offline data
    a <- backendInitialize(MsBackendMetabolomicsWorkbench(), mwbId = "ST002115",
                           filePattern = "DMSO_01_RP.mzXML$", offline = TRUE)
    b <- backendInitialize(MsBackendMetabolomicsWorkbench(), mwbId = "ST000016",
                           filePattern = "D20101022-LC2-PP0000705-A1-I1-P.mzML")

    d <- backendMerge(a, b)
    expect_true(length(d) == (length(a) + length(b)))
    expect_equal(rtime(d), c(rtime(a), rtime(b)))
})
