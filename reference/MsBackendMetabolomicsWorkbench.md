# MsBackend representing MS data from Metabolomics Workbench

`MsBackendMetabolomicsWorkbench` retrieves and represents mass
spectrometry (MS) data from metabolomics studies stored in the
[Metabolomics Workbench](https://metabolomicsworkbench.org/) repository,
a data resource developed by the NIH Common Fund's Data Repository and
Coordinating Center (DRCC) at the San Diego Supercomputer Center,
University of California San Diego. The repository provides access to
study metadata, processed experimental results, metabolite structures,
and reference compound information through a RESTful HTTP API / FTP
server / POST request. The backend directly extends the
[Spectra::MsBackendMzR](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
backend from the *Spectra* package and hence supports MS data in mzML,
CDF, and mzXML format. Data in other formats cannot be loaded with
`MsBackendMetabolomicsWorkbench`. Upon initialization with the
`backendInitialize()` method, the `MsBackendMetabolomicsWorkbench`
backend fetches and caches study data files locally using Bioconductor's
*BiocFileCache* package, avoiding repeated queries to the remote
repository. See the help and vignettes of that package for details on
cached data resources. Additional utility functions for management of
cached files are also provided by *MsBackendMetabolomicsWorkbench*. See
help for
[`mwb_cached_data_files()`](https://rformassspectrometry.github.io/MsBackendMetabolomicsWorkbench/reference/MetabolomicsWorkbench-utils.md)
for more information.

## Usage

``` r
MsBackendMetabolomicsWorkbench()

# S4 method for class 'MsBackendMetabolomicsWorkbench'
backendInitialize(
  object,
  mwbId = character(),
  filePattern = "mzML$|CDF$|cdf$|mzXML$",
  ftp_zip = FALSE,
  offline = FALSE,
  ...
)

# S4 method for class 'MsBackendMetabolomicsWorkbench'
backendRequiredSpectraVariables(object, ...)

mwb_sync(x, offline = FALSE)
```

## Arguments

- object:

  an instance of `MsBackendMetabolomicsWorkbench`.

- mwbId:

  `character(1)` with the ID of a single MetabolomicsWorkbench data
  set/experiment.

- filePattern:

  `character` with the pattern defining the supported (or requested)
  file types. Defaults to `filePattern = "mzML$|CDF$|cdf$|mzXML$"` hence
  restricting to mzML, CDF and mzXML files which are supported by
  *Spectra*'s `MsBackendMzR` backend.

- ftp_zip:

  for
  [`mwb_sync_data_files()`](https://rformassspectrometry.github.io/MsBackendMetabolomicsWorkbench/reference/MetabolomicsWorkbench-utils.md):
  `logical(1)` download the complete zip of the experiment from the FTP
  server. Defaults to `FALSE`, in which case the files are downloaded
  singularly via POST request.

- offline:

  `logical(1)` whether only locally cached content should be
  evaluated/loaded.

- ...:

  additional parameters; currently ignored.

- x:

  an instance of `MsBackendMetabolomicsWorkbench`.

## Value

- For `MsBackendMetabolomicsWorkbench()`: an instance of
  `MsBackendMetabolomicsWorkbench`.

- For
  [`backendInitialize()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html):
  an instance of `MsBackendMetabolomicsWorkbench` with the MS data of
  the specified MetabolomicsWorkbench data set.

- For
  [`backendRequiredSpectraVariables()`](https://rdrr.io/pkg/Spectra/man/MsBackend.html):
  `character` with spectra variables that are needed for the backend to
  provide the MS data.

- For `mwb_sync()`: the input `MsBackendMetabolomicsWorkbench` with the
  paths to the locally cached data files being eventually updated.

## Details

The backend uses the
[BiocFileCache](https://bioconductor.org/packages/BiocFileCache) package
for caching of the data files. These are stored in the default local
*BiocFileCache* cache along with additional metadata that includes the
Metabolomics Workbench ID. Note that at present only MS data files in
*mzML*, *CDF* and *mzXML* format are supported.

The `MsBackendMetabolomicsWorkbench` backend defines and provides
additional spectra variables `"mwb_id"`, `"zip_file"` and `"file_name"`
that list the MetabolomicsWorkbench ID, the original zip file name and
the original data file name on the Metabolomics Workbench ftp server for
each individual spectrum. The `"file_name"` can be used for the mapping
between the experiment's samples and the individual data files,
respective their spectra.

The `MsBackendMetabolomicsWorkbench` backend is considered *read-only*
and does thus not support changing *m/z* and intensity values directly.

## Note

To account for transient network failures and high server load on the
Metabolomics Workbench endpoint, download functions automatically retry
failed requests. An error is raised after 5 consecutive failed attempts.
Between each attempt, the function waits for a progressively increasing
time period (5 seconds between the first and second attempt, 10 seconds
between the second and third, and so forth). The sleep time multiplier
can be configured via the `"mwb.sleep_mult"` option (defaults to `5`).
An active internet connection is required for all non-cached operations;
use `offline = TRUE` in
[`backendInitialize()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html)
to suppress remote requests and rely exclusively on the local
*BiocFileCache* cache.

## Initialization and loading of data

New instances of the class can be created with the
`MsBackendMetabolomicsWorkbench()` function. Data is loaded and
initialized using the
[`backendInitialize()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html)
function, which accepts parameters `mwbId`, `filePattern` and `ftp_zip`.
`mwbId` must be the accession of a **single** existing Metabolomics
Workbench study (e.g. `"ST000016"`). Optional parameter `filePattern`
defines the pattern used to filter the file names of the MS data files
and defaults to data files with file endings of supported MS data
formats. Optional parameter `ftp_zip = TRUE` will download the complete
zip file of the experiment from the FTP server and extract the data
files locally, which can be faster than downloading the files
individually via POST request. However if only a subset of the data
files is required, it is more efficient to download the files separately
*via* POST request with `ftp_zip = FALSE` and `filePattern` set to the
desired file name pattern.
[`backendInitialize()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html)
requires an active internet connection, as the function queries the
Metabolomics Workbench via POST request and compares remote file content
against locally cached files before synchronizing any changes or
updates. This behavior can be bypassed with `offline = TRUE`, in which
case only locally cached content is used.

The
[`backendRequiredSpectraVariables()`](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
function returns the names of the spectra variables required for the
backend to provide the MS data.

The `mwb_sync()` function can be used to *synchronize* the local data
cache and ensure that all study data files are locally available. The
function checks the local cache and downloads any missing data files
from the Metabolomics Workbench repository.

## Author

Gabriele Tomè, Philippine Louail, Johannes Rainer

## Examples

``` r

library(MsBackendMetabolomicsWorkbench)

## List files of a MetabolomicsWorkbench data set
mwb_list_files("ST002115")
#>             zip_file                 sample_file
#> 1  ST002115_Data.zip     HT1080_DMSO_01_RP.mzXML
#> 3  ST002115_Data.zip     HT1080_DMSO_02_RP.mzXML
#> 5  ST002115_Data.zip     HT1080_DMSO_03_RP.mzXML
#> 7  ST002115_Data.zip    HT1080_ML162_01_RP.mzXML
#> 9  ST002115_Data.zip    HT1080_ML162_02_RP.mzXML
#> 11 ST002115_Data.zip    HT1080_ML162_03_RP.mzXML
#> 13 ST002115_Data.zip    HT1080_ML210_01_RP.mzXML
#> 15 ST002115_Data.zip    HT1080_ML210_02_RP.mzXML
#> 17 ST002115_Data.zip    HT1080_ML210_03_RP.mzXML
#> 19 ST002115_Data.zip     HT1080_RSL3_01_RP.mzXML
#> 21 ST002115_Data.zip     HT1080_RSL3_02_RP.mzXML
#> 23 ST002115_Data.zip     HT1080_RSL3_03_RP.mzXML
#> 25 ST002115_Data.zip  HT1080_DMSO_01_HILIC.mzXML
#> 27 ST002115_Data.zip  HT1080_DMSO_02_HILIC.mzXML
#> 29 ST002115_Data.zip  HT1080_DMSO_03_HILIC.mzXML
#> 31 ST002115_Data.zip HT1080_ML162_01_HILIC.mzXML
#> 33 ST002115_Data.zip HT1080_ML162_02_HILIC.mzXML
#> 35 ST002115_Data.zip HT1080_ML162_03_HILIC.mzXML
#> 37 ST002115_Data.zip HT1080_ML210_01_HILIC.mzXML
#> 39 ST002115_Data.zip HT1080_ML210_02_HILIC.mzXML
#> 41 ST002115_Data.zip HT1080_ML210_03_HILIC.mzXML
#> 43 ST002115_Data.zip  HT1080_RSL3_01_HILIC.mzXML
#> 45 ST002115_Data.zip  HT1080_RSL3_02_HILIC.mzXML
#> 47 ST002115_Data.zip  HT1080_RSL3_03_HILIC.mzXML

## Initialize a MsBackendMetabolomicsWorkbench representing all MS
## data files of the data set with the ID "ST002115". This will
## download and cache all files and subsequently load and represent
## them in R.

be <- backendInitialize(MsBackendMetabolomicsWorkbench(),
                        "ST002115",
                        filePattern = "DMSO_01_RP.mzXML$")
be
#> MsBackendMetabolomicsWorkbench with 1437 spectra
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            0  0.569753         1
#> 2            0  1.627010         2
#> 3            0  2.684380         3
#> 4            0  3.739880         4
#> 5            0  4.795500         5
#> ...        ...       ...       ...
#> 1433         0   1499.05      1433
#> 1434         0   1500.11      1434
#> 1435         0   1501.16      1435
#> 1436         0   1502.22      1436
#> 1437         0   1503.28      1437
#>  ... 37 more variables/columns.
#> 
#> file(s):
#> ST002115_Data_HT1080_DMSO_01_RP.mzXML

## The `mwb_sync()` function can be used to ensure that all data
## files are available locally. This function will eventually download
## missing data files or update their paths.
be <- mwb_sync(be)
```
