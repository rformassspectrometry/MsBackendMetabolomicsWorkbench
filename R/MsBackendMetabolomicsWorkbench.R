#' @title MsBackend representing MS data from Metabolomics Workbench
#'
#' @name MsBackendMetabolomicsWorkbench
#'
#' @aliases MsBackendMetabolomicsWorkbench-class
#'
#' @description
#'
#' `MsBackendMetabolomicsWorkbench` retrieves and represents mass spectrometry
#' (MS) data from metabolomics studies stored in the
#' [Metabolomics Workbench](https://metabolomicsworkbench.org/) repository, a
#' data resource developed by the NIH Common Fund's Data Repository and
#' Coordinating Center (DRCC) at the San Diego Supercomputer Center, University
#' of California San Diego.
#' The repository provides access to study metadata, processed experimental
#' results, metabolite structures, and reference compound information through a
#' RESTful HTTP API / FTP server / POST request. The backend directly extends
#' the [Spectra::MsBackendMzR] backend from the *Spectra* package and hence
#' supports MS data in mzML, CDF, and mzXML format. Data in other formats cannot
#' be loaded with `MsBackendMetabolomicsWorkbench`. Upon initialization with the
#' `backendInitialize()` method, the `MsBackendMetabolomicsWorkbench` backend
#' fetches and caches study data files locally using Bioconductor's
#' *BiocFileCache* package, avoiding repeated queries to the remote repository.
#' See the help and vignettes of that package for details on cached data
#' resources. Additional utility functions for management of cached files are
#' also provided by *MsBackendMetabolomicsWorkbench*. See help for
#' [mwb_cached_data_files()] for more information.
#'
#' @section Initialization and loading of data:
#'
#' New instances of the class can be created with the
#' `MsBackendMetabolomicsWorkbench()` function. Data is loaded and initialized
#' using the `backendInitialize()` function, which accepts parameters `mwbId`,
#' `filePattern` and `ftp_zip`. `mwbId` must be the accession of a **single**
#' existing Metabolomics Workbench study (e.g. `"ST000016"`). Optional parameter
#' `filePattern` defines the pattern used to filter the file names of the MS
#' data files and defaults to data files with file endings of supported MS data
#' formats. Optional parameter `ftp_zip = TRUE` will download the complete zip
#' file of the experiment from the FTP server and extract the data files
#' locally, which can be faster than downloading the files singularly via POST
#' request. However if only a subset of the data files is required, it is more
#' efficient to download the files singularly via POST request with
#' `ftp_zip = FALSE` and `filePattern` set to the desired file name pattern.
#' `backendInitialize()` requires an active internet connection, as the function
#' queries the Metabolomics Workbench via POST request and compares remote file
#' content against locally cached files before synchronizing any changes or
#' updates. This behavior can be bypassed with `offline = TRUE`, in which case
#' only locally cached content is used.
#'
#' The `backendRequiredSpectraVariables()` function returns the names of the
#' spectra variables required for the backend to provide the MS data.
#'
#' The `mwb_sync()` function can be used to *synchronize* the local data cache
#' and ensure that all study data files are locally available. The function
#' checks the local cache and downloads any missing data files from the
#' Metabolomics Workbench repository.
#'
#' @note
#'
#' To account for transient network failures and high server load on the
#' Metabolomics Workbench endpoint, download functions automatically retry
#' failed requests. An error is raised after 5 consecutive failed attempts.
#' Between each attempt, the function waits for a progressively increasing time
#' period (5 seconds between the first and second attempt, 10 seconds between
#' the second and third, and so forth). The sleep time multiplier can be
#' configured via the `"mwb.sleep_mult"` option (defaults to `5`). An active
#' internet connection is required for all non-cached operations; use
#' `offline = TRUE` in `backendInitialize()` to suppress remote requests and
#' rely exclusively on the local *BiocFileCache* cache.
#'
#' @param object an instance of `MsBackendMetabolomicsWorkbench`.
#'
#' @param mwbId `character(1)` with the ID of a single
#'     MetabolomicsWorkbench data set/experiment.
#'
#' @param filePattern `character` with the pattern defining the
#'     supported (or requested) file types. Defaults to
#'     `filePattern = "mzML$|CDF$|cdf$|mzXML$"` hence restricting to
#'     mzML, CDF and mzXML files which are supported by *Spectra*'s
#'     `MsBackendMzR` backend.
#'
#' @param ftp_zip for `mwb_sync_data_files()`: `logical(1)` download the
#'     complete zip of the experiment from the FTP server. Defaults to `FALSE`,
#'     in which case the files are downloaded singularly via POST request.
#'
#' @param offline `logical(1)` whether only locally cached content
#'     should be evaluated/loaded.
#'
#' @param x an instance of `MsBackendMetabolomicsWorkbench`.
#'
#' @param ... additional parameters; currently ignored.
#'
#' @return
#'
#' - For `MsBackendMetabolomicsWorkbench()`: an instance of
#'   `MsBackendMetabolomicsWorkbench`.
#' - For `backendInitialize()`: an instance of
#'   `MsBackendMetabolomicsWorkbench` with the MS data of the specified
#'   MetabolomicsWorkbench data set.
#' - For `backendRequiredSpectraVariables()`: `character` with spectra
#'   variables that are needed for the backend to provide the MS data.
#' - For `mwb_sync()`: the input `MsBackendMetabolomicsWorkbench` with
#'   the paths to the locally cached data files being eventually
#'   updated.
#'
#' @details
#'
#' The backend uses the
#' [BiocFileCache](https://bioconductor.org/packages/BiocFileCache) package for
#' caching of the data files. These are stored in the default local
#' *BiocFileCache* cache along with additional metadata that includes the
#' Metabolomics Workbench ID. Note that at present only MS data files in *mzML*,
#' *CDF* and *mzXML* format are supported.
#'
#' The `MsBackendMetabolomicsWorkbench` backend defines and provides additional
#' spectra variables `"mwb_id"`, `"zip_file"` and `"file_name"` that list
#' the MetabolomicsWorkbench ID, the original zip file name and the original
#' data file name on the Metabolomics Workbench ftp server for each individual
#' spectrum. The `"file_name"` can be used for the mapping between the
#' experiment's samples and the individual data files, respective their spectra.
#'
#' The `MsBackendMetabolomicsWorkbench` backend is considered *read-only* and
#' does thus not support changing *m/z* and intensity values directly.
#'
#' @importClassesFrom Spectra MsBackendMzR
#'
#' @importClassesFrom Spectra MsBackendDataFrame
#'
#' @importFrom S4Vectors DataFrame
#'
#' @exportClass MsBackendMetabolomicsWorkbench
#'
#' @author Gabriele Tomè, Philippine Louail, Johannes Rainer
#'
#' @examples
#'
#' library(MsBackendMetabolomicsWorkbench)
#'
#' ## List files of a MetabolomicsWorkbench data set
#' mwb_list_files("ST002115")
#'
#' ## Initialize a MsBackendMetabolomicsWorkbench representing all MS
#' ## data files of the data set with the ID "ST002115". This will
#' ## download and cache all files and subsequently load and represent
#' ## them in R.
#'
#' be <- backendInitialize(MsBackendMetabolomicsWorkbench(),
#'                         "ST002115",
#'                         filePattern = "DMSO_01_RP.mzXML$")
#' be
#'
#' ## The `mwb_sync()` function can be used to ensure that all data
#' ## files are available locally. This function will eventually download
#' ## missing data files or update their paths.
#' be <- mwb_sync(be)
NULL


setClass("MsBackendMetabolomicsWorkbench",
         contains = "MsBackendMzR")

#' @rdname MsBackendMetabolomicsWorkbench
#'
#' @importFrom methods new
#'
#' @export
MsBackendMetabolomicsWorkbench <- function() {
    new("MsBackendMetabolomicsWorkbench")
}

#' @rdname MsBackendMetabolomicsWorkbench
#'
#' @importMethodsFrom ProtGenerics backendInitialize
#'
#' @importMethodsFrom Spectra backendInitialize
#'
#' @importMethodsFrom Spectra [
#'
#' @importMethodsFrom ProtGenerics dataOrigin
#'
#' @importFrom methods callNextMethod
#'
#' @importFrom methods as
#'
#' @importFrom Spectra MsBackendMzR
#'
#' @exportMethod backendInitialize
setMethod(
    "backendInitialize", "MsBackendMetabolomicsWorkbench",
    function(object, mwbId = character(),
             filePattern = "mzML$|CDF$|cdf$|mzXML$", ftp_zip = FALSE,
             offline = FALSE, ...) {
        dots <- list(...)
        if (any(names(dots) == "data"))
            stop("Parameter 'data' is not supported for ",
                 "'MsBackendMetabolomicsWorkbench'. A ",
                 "'MsBackendMetabolomicsWorkbench' object ",
                 "can only be instantiated using 'backendInitialize()'.")
        if (length(mwbId) != 1)
            stop("Parameter 'mwbId' is required and can only be a single ",
                 "ID of a Metabolomics Workbench data set.")
        if (offline)
            mdata <- .mwb_data_files_offline(mwbId, filePattern)
        else mdata <- .mwb_data_files(mwbId, filePattern, ftp_zip = ftp_zip)
        object <- backendInitialize(MsBackendMzR(), files = mdata$rpath)
        idx <- match(dataOrigin(object),
                     normalizePath(mdata$rpath, mustWork = FALSE))
        object@spectraData$mwb_id <- mdata$mwb_id[idx]
        object@spectraData$zip_file <- mdata$zip_file[idx]
        object@spectraData$file_name <- mdata$file_name[idx]
        object <- as(object, "MsBackendMetabolomicsWorkbench")
    })


#' @rdname MsBackendMetabolomicsWorkbench
#'
#' @importMethodsFrom Spectra backendRequiredSpectraVariables
#'
#' @exportMethod backendRequiredSpectraVariables
setMethod(
    "backendRequiredSpectraVariables", "MsBackendMetabolomicsWorkbench",
    function(object, ...) {
        c(callNextMethod(), "mwb_id", "zip_file", "file_name")
    })

.valid_mwb_required_columns <- function(object) {
    if (nrow(object@spectraData)) {
        if (!all(c("mwb_id", "zip_file", "file_name") %in%
                 colnames(object@spectraData)))
            return(paste0("One or more of required spectra variable(s) ",
                          "\"mwb_id\", \"zip_file\", \"file_name\" is (are) ",
                          "missing"))
    }
    character()
}

.valid_files_local <- function(object) {
    if (nrow(object@spectraData)) {
        if (!all(file.exists(object@spectraData$dataStorage)))
            return(paste0("One or more of the data files are not found in ",
                          "the local cache. Please run `mwb_sync()` on ",
                          "the data object."))
    }
    character()
}

setValidity("MsBackendMetabolomicsWorkbench", function(object) {
    msg <- .valid_mwb_required_columns(object)
    msg <- c(msg, .valid_files_local(object))
    if (length(msg)) return(msg)
    else TRUE
})

#' @importFrom methods validObject
#'
#' @rdname MsBackendMetabolomicsWorkbench
#'
#' @export
mwb_sync <- function(x, offline = FALSE) {
    if (!inherits(x, "MsBackendMetabolomicsWorkbench"))
        stop("'x' is expected to be an instance of ",
             "'MsBackendMetabolomicsWorkbench'")
    sdata <- unique(
        as.data.frame(x@spectraData[, c("mwb_id", "file_name")]))
    cn <- c("file_name", "rpath")
    res <- lapply(split(sdata, sdata$mwb_id), function(z, offline) {
        if (offline)
            mwb_cached_data_files(
                sdata$mwb_id[1L], pattern = "*",
                fileName = basename(sdata$file_name))[, cn]
        else
            mwb_sync_data_files(
                sdata$mwb_id[1L], pattern = "*",
                fileName = basename(sdata$file_name))[, cn]
    }, offline = offline)
    res <- do.call(rbind, res)
    if (!all(sdata$file_name %in% res$file_name))
        stop("Some of the data files are not available. Please run with ",
             "'offline = FALSE' to ensure data missing data files get ",
             "downloaded.")
    x@spectraData$dataStorage <- res[match(
        x@spectraData$file_name,
        res$file_name), "rpath"]
    validObject(x)
    x
}

