#' @title Utility functions for the Metabolomics Workbench repository
#'
#' @name MetabolomicsWorkbench-utils
#'
#' @description
#'
#' Utility functions to interact with the Metabolomics Workbench (MWB)
#' repository, including listing, downloading, caching, and querying data
#' files and study metadata.
#'
#' - `mwb_cached_data_files()`: lists locally cached data files from
#'   Metabolomics Workbench. Since this function evaluates only local content
#'   it does not require an internet connection. With the default parameters all
#'   available data files are listed. The parameters can be used to restrict the
#'   lookup.
#'
#' - `mwb_list_files()`: returns the available files for the specified
#'   Metabolomics Workbench data set by submitting a POST request to the
#'   Metabolomics Workbench archive contents endpoint. The function returns a
#'   `data.frame` with columns `zip_file` and `sample_file` containing,
#'   respectively, the archive name and the relative file within that archive.
#'   Parameter `pattern` allows to filter the results by matching against the
#'   `sample_file` column.
#'
#' - `mwb_rest_request()`: queries the Metabolomics Workbench REST API for
#'   a given study ID and output item (e.g. `summary`, `factors`).
#'   Returns the raw response as a `character` string in the format specified
#'   by `outputFormat` (`json` or `txt`). This function requires an
#'   active internet connection.
#'
#' - `mwb_ftp_list_files()`: queries the Metabolomics Workbench FTP server for a
#'   given experiment ID and returns the related files. Parameter `pattern`
#'   allows to filter the results.
#'
#' - `mwb_ftp_download()`: download from Metabolomics Workbench FTP server the
#'   files for a given experiment ID. Use `pattern` to filter files by name
#'   using a regular expression (downloads all files by default). Use `path` to
#'   set the destination directory for downloaded files.
#'
#' - `mwb_sync_data_files()`: synchronize data files of a specified
#'   MWB data set eventually downloading and locally caching them.
#'   Parameter `fileName` allows to specify names of selected data files to
#'   sync.
#'
#' - `mwb_delete_cache()`: removes all local content for the mwb
#'   data set with ID `mwbId`. This will delete eventually present
#'   locally cached data files for the specified data set. This does not
#'   change any other data eventually present in the local `BiocFileCache`.
#'
#' @details
#'
#' Metabolomics Workbench uses a
#' [REST API](https://metabolomicsworkbench.org/tools/mw_rest.php) to provide
#' metadata files. To retrieve the MS files, there are two approaches. The
#' first is to download the `zip` files available on the
#' [FTP server](ftp://www.metabolomicsworkbench.org/Studies/). The second
#' approach allows downloading individual files via two POST requests.
#' First, the
#' [MWB show archive page](https://metabolomicsworkbench.org/data/show_archive_contents_link.php)
#' is queried to obtain the correct file names. Then, the files are
#' downloaded and cached via a POST request to the
#' [MWB file extract page](https://metabolomicsworkbench.org/data/file_extract_7z.php).
#'
#'
#' @param x `character(1)` with the ID of the MBW data set (usually
#'     starting with a *ST* followed by a number).
#'
#' @param mwbId `character(1)` with the ID of a single Metabolomics
#'     Workbench data set/experiment.
#'
#' @param pattern for `mwb_list_files()`, `mwb_sync_data_files()`,
#'     `mwb_cached_data_files()`, `mwb_ftp_list_files` and `mwb_ftp_download`:
#'     `character(1)` defining a pattern to filter the file names, such as
#'     `pattern = "mzML$"` to retrieve the file names of all files of the data
#'     set (i.e., files with extension `"mzML"`). This parameter is passed to
#'     the [grepl()] function.
#'
#' @param fileName for `mwb_sync_data_files()` and `mwb_cached_data_files()`: #'     optional `character` defining the names of specific data files of a data
#'     set that should be downloaded and cached.
#'
#' @param ftp_zip for `mwb_sync_data_files()`: `logical(1)` download the
#'     complete zip of the experiment from the FTP server. Defaults to `FALSE`,
#'     in which case the files are downloaded singularly via POST request.
#'
#' @param outputItem for `mwb_rest_request`: `character(1)` defining the
#'     metadata to retrieve from Metabolomics Workbench. To get more information
#'     about the possible output visit the webpage
#'     [MBW REST API](https://metabolomicsworkbench.org/tools/mw_rest.php).
#'
#' @param outputFormat for `mwb_rest_request`: `character(1)` defining the
#'     output format of the metadata. The supported output are `json` and `txt`.
#'
#' @param path for `mwb_ftp_download()`: optional `character` defining the
#'     directory where download the files.
#'
#' @param overwrite for `mwb_ftp_download()`: `logical(1)` whether
#'     existing files should be overwritten. Defaults to `FALSE`, in which
#'     case files that already exist in `path` are skipped.
#'
#' @return
#'
#' - For `mwb_list_files()`: `data.frame` with columns `zip_file` and
#'   `sample_file` containing, respectively, the archive name and the relative
#'   file within that archive
#' - For `mwb_rest_request()`: `character(1)` with the raw REST API response
#'   body, formatted as JSON or plain text depending on `outputFormat`.
#' - For `mwb_sync_data_files()` and `mwb_cached_data_files()`: a
#'   `data.frame` with the MWB ID, the name(s) and remote and
#'   local file names of the synchronized data files.
#' - For `mwb_ftp_list_files`: `character` with the files in FTP server for a
#'   specific ID.
#'
#' @author Gabriele Tomè, Johannes Rainer, Philippine Louail
#'
#' @examples
#'
#' ## Retrieve available files for the data set ST002115
#' mwb_list_files("ST002115")
#'
#' ## Retrieve the available .mzML files.
#' A1_mzMLfiles <- mwb_list_files("ST000016", pattern = "A1")
#' A1_mzMLfiles
#'
#' ## Query the REST API for a study summary in JSON format
#' mwb_rest_request("ST002115", outputItem = "summary")
#'
#' ## List zip file of the data set ST002115
#' mwb_ftp_list_files("ST002115")
#'
NULL

#' @importFrom httr POST content
#'
#' @importFrom rvest html_nodes html_attr
#'
#' @rdname MetabolomicsWorkbench-utils
#'
#' @export
mwb_list_files <- function(x = character(), pattern = NULL) {
    if(length(x) > 1)
        stop("Provide a single Metabolomics Workbench ID.")

    # MWB lisf files function
    url <- paste0("https://metabolomicsworkbench.org/data/",
                  "show_archive_contents_link.php")
    params <- list(
        STUDY_ID = x
    )

    ## Submit the POST request and save the response to a file
    tryCatch({
        res <- retry(POST(
            url,
            body = params,
            encode = "form"
        ),
        sleep_mult = .sleep_mult())
    }, error = function(e) {
        stop("Failed to connect to Metabolomics Workbench. No internet
             connection? Does the data set \"", x, "\" exist?\n - ",
             e$message, call. = FALSE)
    })

    webpage <- content(res)
    zip_file <- webpage |>
        html_nodes("input[name='A']") |>
        html_attr("value")

    sample_file <- webpage |>
        html_nodes("input[name='F']") |>
        html_attr("value")

    anno_df <- unique(data.frame("zip_file" = zip_file,
                                 "sample_file" = sample_file))

    if(nrow(anno_df) == 0)
        stop("Failed to retrieve info from Metabolomics Workbench. Does the
             data set \"", x, "\" exist?")

    if (length(pattern))
        anno_df[grepl(pattern, anno_df$sample_file), ]
    else
        anno_df
}


#' @importFrom httr2 request req_perform resp_body_string
#'
#' @rdname MetabolomicsWorkbench-utils
#'
#' @export
mwb_rest_request <- function(mwbId = character(), outputItem = character(),
                             outputFormat = "json") {
    if (length(mwbId) != 1)
        stop("Provide a single Metabolomics Workbench ID.")

    if (length(outputItem) != 1)
        stop("Provide a single outputItem request.")

    if (!(outputFormat %in% c("txt", "json")))
        stop("Wrong output format. The accepted format are: 'txt', 'json'")

    url_base <- "https://www.metabolomicsworkbench.org/rest/study/study_id/"
    ## For json, MWB use empty outputFormat. For txt, add a final txt
    rest_url <- paste0(url_base, mwbId, "/", outputItem, "/")
    if (outputFormat == "txt")
        rest_url <- paste0(rest_url, outputFormat)

    tryCatch({
        response <- retry(request(rest_url) |>
                              req_perform() |>
                              resp_body_string(),
                          sleep_mult = .sleep_mult())
    }, error = function(e) {
        stop("Failed to connect to Metabolomics Workbench. No internet
             connection? Does the data set \"", mwbId, "\" exist?\n - ",
             e$message, call. = FALSE)
    })

    return(response)
}

#' @importFrom curl curl new_handle handle_setopt
#'
#' @rdname MetabolomicsWorkbench-utils
#'
#' @export
mwb_ftp_list_files <- function(mwbId = character(), pattern = "*") {
    if (length(mwbId) != 1)
        stop("Provide 1 Metabolomics Workbench ID.")

    ftp_url <- "ftp://www.metabolomicsworkbench.org/Studies/"
    cu <- new_handle()
    handle_setopt(cu, ftp_use_epsv = TRUE, dirlistonly = TRUE)

    tryCatch({
        res <- retry(
            curl(url = ftp_url, "r", handle = cu),
            sleep_mult = .sleep_mult())
    }, error = function(e) {
        stop("Failed to connect to Metabolomics Workbench FTP server. ",
             "No internet connection? - ", e$message, call. = FALSE)
    })
    list_ftp_files <- grep(mwbId, readLines(res), value = TRUE)
    close(res)

    if(!length(list_ftp_files))
        stop("No files detected. Does the data set ", mwbId, " exist?\n",
             call. = FALSE)

    list_ftp_files <- list_ftp_files[grep(pattern, list_ftp_files)]
    if (!length(list_ftp_files))
        stop("No files matching the provided file pattern found for ",
             "data set ", mwbId, ".", call. = FALSE)

    return(list_ftp_files)
}

#' @importFrom progress progress_bar
#'
#' @importFrom utils capture.output download.file
#'
#' @rdname MetabolomicsWorkbench-utils
#'
#' @export
mwb_ftp_download <- function(mwbId = character(), pattern = "*", path = "./",
                             overwrite = FALSE) {
    if (length(mwbId) != 1)
        stop("Provide 1 Metabolomics Workbench ID.")

    ftp_url <- "ftp://www.metabolomicsworkbench.org/Studies/"
    list_files <- mwb_ftp_list_files(mwbId, pattern)

    ## Create dir if not exist
    if (!dir.exists(path)) {
        dir.create(path, recursive = TRUE)
    }

    ## Save files in the folder
    pb <- progress_bar$new(format = paste0("[:bar] :current/:",
                                           "total (:percent) in ",
                                           ":elapsed"),
                           total = length(list_files), clear = FALSE)
    res <- lapply(list_files, function(x) {
        pb$tick()
        dest <- file.path(path, basename(x))
        if (file.exists(dest) && !overwrite) {
            message("File '", basename(x), "' already exists in '",
                    path, "'. Skipping. Use 'overwrite = TRUE' to replace.")
            return(invisible(NULL))
        }

        tryCatch({
            invisible(capture.output(suppressMessages(
                retry(
                    download.file(paste0(ftp_url, x),
                                  destfile = file.path(path, x), quiet = T),
                    sleep_mult = .sleep_mult()))))
        }, error = function(e) {
            stop("Failed to connect to Metabolomics Workbench FTP server.",
                 "No internet connection? - ", e$message, call. = FALSE)
        })
    })

}

################################################################################
##
## File caching utils
##
################################################################################

#' @rdname MetabolomicsWorkbench-utils
#'
#' @export
mwb_sync_data_files <- function(mwbId = character(),
                                pattern = "mzML$|mzml$|CDF$|cdf$|mzXML$",
                                fileName = character(), ftp_zip = FALSE) {
    if (!length(mwbId))
        stop("No Metabolomics Workbench data set ID provided with parameter",
             "'mwbId'")
    .mwb_data_files(mwbId, pattern, fileName, ftp_zip)
}

#' @rdname MetabolomicsWorkbench-utils
#'
#' @export
mwb_cached_data_files <- function(mwbId = character(),
                                  pattern = "*", fileName = character()) {
    res <- .mwb_data_files_offline(mwbId = mwbId,
                                   pattern = pattern)
    if (length(fileName))
        res <- res[basename(res$file_name) %in% fileName, ]
    else res
}

#' Get information on data files for a given ST (MWB) ID eventually
#' downloading and caching them. This function needs an active internet
#' connection as it queries the MWB server for available data files
#' that are then cached. The function returns the **local** file names
#' **from the cache**.
#'
#' The function:
#' - retrieves all files for one MetabolomicsWorkbench ID.
#' - uses BiocFileCache to cache these files, i.e. downloading them if they
#'   are not yet cached.
#' - returns a `data.frame` with all information.
#'
#' This `data.frame` has one row per data file with columns:
#' - `"rid"`: the BiocFileCache ID of each file.
#' - `"mwb_id"`: the MetabolomicsWorkbench ID
#' - `"zip_file"`: the name of the zip file containing the data file
#' - `"file_name"`: the name of the data file
#' - `"rpath"`: the name of the cached data file (full local path)
#'
#' @note
#'
#' Download from MsBackendMetabolomicsWorkbench is tried 3 times with an
#' increasing time delay between tries that can be configured using the
#' `"mwb.sleep_mult"` option.
#'
#' @importFrom BiocFileCache BiocFileCache
#'
#' @importFrom httr POST write_disk status_code
#'
#' @importMethodsFrom BiocFileCache bfcnew bfcmeta<- bfcremove bfcupdate
#'
#' @importMethodsFrom BiocFileCache bfcrpath bfccache bfcadd
#'
#' @noRd
.mwb_data_files <- function(mwbId = character(),
                            pattern = "mzML$|mzml$|CDF$|mzXML$",
                            fileName = character(), ftp_zip = FALSE) {
    dfiles <- mwb_list_files(mwbId, pattern = pattern)
    if(!nrow(dfiles)) {
        stop("No files matching the provided file pattern found for ",
                "Metabolomics Workbench data set ", mwbId, ".", call. = FALSE)
    }

    bfc <- BiocFileCache()

    if (ftp_zip) {
        res <- .mwb_data_files_ftp(mwbId, dfiles, fileName, bfc)
        lfiles <- unlist(lapply(res, `[[`, 1))
        dfiles <- Reduce(rbind, lapply(res, `[[`, 2))
    } else {
        res <- .mwb_data_files_post(mwbId, dfiles, fileName, bfc)
        lfiles <- res$lfiles
        dfiles <- res$dfiles
    }


    if (is.null(lfiles)) {
        stop("Failed to connect to Metabolomics Workbench. ",
                "No internet connection?")
    }

    ## Add and store metadata to the cached files
    mdata <- data.frame(
        rid = names(lfiles),
        mwb_id = mwbId,
        zip_file = dfiles$zip_file,
        file_name = dfiles$sample_file)
    bfcmeta(bfc, name = "MWB", overwrite = TRUE) <- mdata
    mdata$rpath <- lfiles
    mdata
}

#' Download and cache data files for a given MWB ID via POST request. This
#' function is used by `.mwb_data_files()` when `ftp_zip = FALSE`.
#'
#' @importFrom httr POST write_disk status_code
#'
#' @importMethodsFrom BiocFileCache bfcnew bfcremove bfcupdate
#'
#' @noRd
.mwb_data_files_post <- function(mwbId = character(), dfiles = NULL,
                                 fileName = character(), bfc = NULL) {
    if (length(fileName)) {
        keep <- basename(dfiles$sample_file) %in% fileName
        if (!any(keep))
            stop("None of the 'fileName' found in data set \"", mwbId, "\"")
        dfiles <- dfiles[keep, ]
    }

    ## Cache files
    pb <- progress_bar$new(format = paste0("[:bar] :current/:",
                                            "total (:percent) in ",
                                            ":elapsed"),
                            total = nrow(dfiles), clear = FALSE)

    url <- "https://metabolomicsworkbench.org/data/file_extract_7z.php"
    lfiles <- c()
    for (sample_file in dfiles$sample_file) {
        pb$tick()
        params <- list(
            A = paste0(dfiles[dfiles$sample_file == sample_file, "zip_file"]),
            F = paste0(sample_file)
        )

        ## Submit POST request and save directly to cache path
        cache_path <- bfcnew(bfc, sample_file, fname = "exact")

        invisible({
            response <- retry(POST(url, body = params, encode = "form",
                                    write_disk(cache_path,
                                                overwrite = TRUE)),
                            sleep_mult = .sleep_mult())

            ## Remove failed POST request
            if (status_code(response) != 200) {
                bfcremove(bfc, names(cache_path))
                dfiles <- dfiles[dfiles$sample_file != sample_file, ]
            } else {
                rpath_update <- file.path(dirname(cache_path), sample_file)
                file.rename(cache_path, rpath_update)
                suppressWarnings(bfcupdate(bfc, names(cache_path),
                                            rpath = rpath_update))
                names(rpath_update) <- names(cache_path)

                lfiles <- c(lfiles, rpath_update)
            }
        })
    }

    res <- list("lfiles" = lfiles, "dfiles" = dfiles)
    res
}

#' Download and cache data files for a given MWB ID via FTP server. This
#' function is used by `.mwb_data_files()` when `ftp_zip = TRUE`.
#'
#' @importFrom progress progress_bar
#'
#' @importFrom stringr str_replace_all
#'
#' @importFrom archive archive_extract
#'
#' @importMethodsFrom BiocFileCache bfcrpath bfccache bfcadd bfcremove
#'
#' @noRd
.mwb_data_files_ftp <- function(mwbId = character(), dfiles = NULL,
                                fileName = character(), bfc = NULL) {
    ## Substitute the "+" with the real value " "
    if(any(grepl("+", dfiles$sample_file)))
        dfiles$sample_file <- str_replace_all(dfiles$sample_file,
                                                "\\+", " ")
    ## Substitute the "%2F" with the real value "/"
    if(any(grepl("%2F", dfiles$sample_file)))
        dfiles$sample_file <- str_replace_all(dfiles$sample_file,
                                                "%2F", "/")

    if (length(fileName)) {
        keep <- basename(dfiles$sample_file) %in% fileName
        if (!any(keep))
            stop("None of the 'fileName' found in data set \"", mwbId, "\"")
        dfiles <- dfiles[keep, ]
    }
    ## Cache files
    zip_files <- unique(dfiles$zip_file)
    ftp_url <- "ftp://www.metabolomicsworkbench.org/Studies/"
    pb <- progress_bar$new(format = paste0("[:bar] :current/:",
                                            "total (:percent) in ",
                                            ":elapsed"),
                            total = length(zip_files), clear = FALSE)
    res <- lapply(zip_files, function(z) {
        pb$tick()
        invisible(capture.output(suppressMessages(
            f <- retry(bfcrpath(bfc, paste0(ftp_url, z), fname = "exact"),
                        sleep_mult = .sleep_mult()))))
        res <- archive_extract(f, dir = bfccache(bfc),
                                files = dfiles[dfiles$zip_file == z,
                                                "sample_file"])
        res_f <- bfcadd(bfc, paste0(bfccache(bfc), "/", res),
                        fname = "exact")
        bfcremove(bfc, rids = names(f))

        dfiles <- data.frame("zip_file" = z,
                            "sample_file" = basename(res_f))
        list("lfiles" = res_f, "dfiles" = dfiles)
    })

    res
}


#' Check for a given MWB ID if we have cached data files. This function is
#' supposed to work also offline using only previously cached content.
#' In contrast to `.mwb_data_files()`, this function just
#' queries the BiocFileCache for content and returns a `data.frame` with
#' all cached data files for a given MWB ID, assay name and pattern. The
#' returned `data.frame` has the same format as the one returned by
#' `.mwb_data_files()`.
#'
#' @importMethodsFrom BiocFileCache bfcquery
#'
#' @noRd
.mwb_data_files_offline <- function(mwbId = character(),
                                    pattern = "mzML$|CDF$|mzXML$") {
    bfc <- BiocFileCache()
    if (!.mwb_has_mwb_table())
        stop("No local Metabolomics Workbench cache available. Please re-run ",
             "with 'offline = FALSE' first.", call. = FALSE)
    res <- as.data.frame(bfcquery(bfc, mwbId, field = "mwb_id"))
    res <- res[grepl(pattern, res$file_name), ]
    if (!nrow(res))
        stop("No locally cached data files found for the specified ",
             "parameters.", call. = FALSE)
    res[, c("rid", "mwb_id", "zip_file", "file_name", "rpath")]
}

#' @importMethodsFrom BiocFileCache bfcmetalist
#'
#' @noRd
.mwb_has_mwb_table <- function() {
    bfc <- BiocFileCache()
    any(bfcmetalist(bfc) == "MWB")
}

#' @rdname MetabolomicsWorkbench-utils
#'
#' @importFrom BiocFileCache bfcremove bfcinfo
#'
#' @export
mwb_delete_cache <- function(mwbId = character()) {
    bfc <- BiocFileCache()
    b <- as.data.frame(bfcinfo(bfc))
    if (nrow(b) && any(colnames(b) == "mwb_id")) {
        if (length(mwbId)) {
            rem <- b[b$mwb_id %in% mwbId, ]
            bfcremove(bfc, rids = rem$rid)
        }
    }
}

