# Utility functions for the Metabolomics Workbench repository

Utility functions to interact with the Metabolomics Workbench (MWB)
repository, including listing, downloading, caching, and querying data
files and study metadata.

- `mwb_cached_data_files()`: lists locally cached data files from
  Metabolomics Workbench. Since this function evaluates only local
  content it does not require an internet connection. With the default
  parameters all available data files are listed. The parameters can be
  used to restrict the lookup.

- `mwb_list_files()`: returns the available files for the specified
  Metabolomics Workbench data set by submitting a POST request to the
  Metabolomics Workbench archive contents endpoint. The function returns
  a `data.frame` with columns `"zip_file"` and `"sample_file"`
  containing the archive name and the file name within that archive.
  Parameter `pattern` allows to filter the results by matching against
  the `"sample_file"` column. This function requires an active internet
  connection.

- `mwb_rest_request()`: queries the Metabolomics Workbench REST API for
  a given study/analysis ID and output item (e.g. `"summary"`,
  `"factors"`). Returns the raw response as a `character` string in the
  format specified by `outputFormat` (`"json"` or `"txt"`). This
  function requires an active internet connection.

- `mwb_ftp_list_files()`: queries the Metabolomics Workbench FTP server
  for a given experiment ID and returns the related files. Parameter
  `pattern` allows to filter the results. In contrast to
  `mwb_list_files()`, this function lists only the files on the FTP
  server (like the zip file of the experiment), while `mwb_list_files()`
  lists the files contained within the zip file. Other files may also be
  present on the FTP server. This function requires an active internet
  connection.

- `mwb_ftp_download()`: download files from Metabolomics Workbench FTP
  server for a given experiment ID. Use `pattern` to filter files by
  name using a regular expression (by default all files are downloaded).
  Use `path` to set the destination directory for downloaded files. Only
  files listed by `mwb_ftp_list_files()` can be downloaded.

- `mwb_metadata()`: retrieves the metadata of a given MWB data set as a
  `list` with two `data.frame`: one with the metadata of the experiment
  and one with the sample annotation. The function handles the case of
  multiple analysis IDs by combining the metadata of all analysis IDs
  into a single `data.frame` for the experiment and a single
  `data.frame` for the sample annotation. This function requires an
  active internet connection.

- `mwb_sync_data_files()`: synchronize data files of a specified MWB
  data set eventually downloading and locally caching them. Parameter
  `fileName` allows to specify names of selected data files to sync.

- `mwb_delete_cache()`: removes all local content for the mwb data set
  with ID `mwbId`. This will delete eventually present locally cached
  data files for the specified data set. This does not change any other
  data eventually present in the local `BiocFileCache`.

## Usage

``` r
mwb_list_files(x = character(), pattern = NULL)

mwb_rest_request(
  id = character(),
  idType = c("study_id", "analysis_id"),
  outputItem = character(),
  outputFormat = c("json", "txt")
)

mwb_ftp_list_files(mwbId = character(), pattern = "*")

mwb_ftp_download(
  mwbId = character(),
  pattern = "*",
  path = "./",
  overwrite = FALSE
)

mwb_metadata(mwbId = character())

mwb_sync_data_files(
  mwbId = character(),
  pattern = "mzML$|mzml$|CDF$|cdf$|mzXML$",
  fileName = character(),
  ftp_zip = FALSE
)

mwb_cached_data_files(
  mwbId = character(),
  pattern = "*",
  fileName = character()
)

mwb_delete_cache(mwbId = character())
```

## Arguments

- x:

  `character(1)` with the ID of the MBW data set (usually starting with
  a *ST* followed by a number).

- pattern:

  for `mwb_list_files()`, `mwb_sync_data_files()`,
  `mwb_cached_data_files()`, `mwb_ftp_list_files` and
  `mwb_ftp_download`: `character(1)` defining a pattern to filter the
  file names, such as `pattern = "mzML$"` to retrieve the file names of
  all files of the data set (i.e., files with extension `"mzML"`). This
  parameter is passed to the
  [`grepl()`](https://rdrr.io/r/base/grep.html) function.

- id:

  `character(1)` with the ID of a single Metabolomics Workbench data
  set/experiment.

- idType:

  for `mwb_rest_request()`: `character(1)` defining the type of the ID
  provided in `id`. The accepted ID types are `"study_id"` and
  `"analysis_id"`. The default is `"study_id"`.

- outputItem:

  for `mwb_rest_request()`: `character(1)` defining the metadata to
  retrieve from Metabolomics Workbench. To get more information about
  the possible output visit the webpage [MBW REST
  API](https://metabolomicsworkbench.org/tools/mw_rest.php).

- outputFormat:

  for `mwb_rest_request()`: `character(1)` defining the output format of
  the metadata. The supported output are `json` and `txt`.

- mwbId:

  `character(1)` with the ID of a single Metabolomics Workbench data
  set/experiment.

- path:

  for `mwb_ftp_download()`: optional `character` defining the directory
  where download the files.

- overwrite:

  for `mwb_ftp_download()`: `logical(1)` whether existing files should
  be overwritten. Defaults to `FALSE`, in which case files that already
  exist in `path` are skipped.

- fileName:

  for `mwb_sync_data_files()` and `mwb_cached_data_files()`: optional
  `character` defining the names of specific data files of a data set
  that should be downloaded and cached.

- ftp_zip:

  for `mwb_sync_data_files()`: `logical(1)` download the complete zip of
  the experiment from the FTP server. Defaults to `FALSE`, in which case
  the files are downloaded singularly via POST request.

## Value

- For `mwb_list_files()`: `data.frame` with columns `zip_file` and
  `sample_file` containing, respectively, the archive name and the
  relative file within that archive

- For `mwb_rest_request()`: `character(1)` with the raw REST API
  response body, formatted as JSON or plain text depending on
  `outputFormat`.

- For `mwb_sync_data_files()` and `mwb_cached_data_files()`: a
  `data.frame` with the MWB ID, the name(s) and remote and local file
  names of the synchronized data files.

- For `mwb_ftp_list_files`: `character` with the files in FTP server for
  a specific ID.

- For `mwb_metadata`: `list` with two `data.frame`: one with the
  metadata of the experiment and one with the sample annotation.

## Details

Metabolomics Workbench provides metadata through a [REST
API](https://metabolomicsworkbench.org/tools/mw_rest.php). MS data files
can be obtained in two ways:

1.  Downloading the full *zip* archive from the [FTP
    server](ftp://www.metabolomicsworkbench.org/Studies/). A POST
    request to the [MWB archive
    page](https://metabolomicsworkbench.org/data/show_archive_contents_link.php)
    gets the correct *zip* archive name for a MWB ID. The archive
    contains all files of the experiment, which may include also
    unneeded files. If only a subset of files is needed, the second
    option is more efficient.

2.  Download individual files using a two-step POST-based procedure:
    query the [MWB archive
    page](https://metabolomicsworkbench.org/data/show_archive_contents_link.php)
    to get exact file names. Then, download each file via [POST
    request](https://metabolomicsworkbench.org/data/file_extract_7z.php).

## Author

Gabriele Tomè, Johannes Rainer, Philippine Louail

## Examples

``` r

## Retrieve available files for the data set ST002115
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

## Retrieve the available .mzML files.
A1_mzMLfiles <- mwb_list_files("ST000016", pattern = "A1")
A1_mzMLfiles
#>              zip_file                          sample_file
#> 233 ST000016_mzML.zip D20101022-LC2-PP0000705-A1-I1-P.mzML
#> 235 ST000016_mzML.zip D20101022-LC2-PP0000705-A1-I1-N.mzML
#> 485 ST000016_mzML.zip D20101020-LC2-PP0000698-A1-I1-Z.mzML
#> 487 ST000016_mzML.zip D20101020-LC2-PP0000698-A1-I1-P.mzML
#> 489 ST000016_mzML.zip D20101020-LC2-PP0000698-A1-I1-N.mzML
#> 491 ST000016_mzML.zip D20101025-LC2-PP0000705-A1-I2-Z.mzML

## Query the REST API for a study summary in JSON format
mwb_rest_request("ST002115", outputItem = "summary")
#> [1] "{\"study_id\":\"ST002115\",\"study_title\":\"LC-MS analysis of metabolic changes induced by GPX4 inhibitor treatment in cultured HT1080 cells\",\"species\":\"Homo sapiens\",\"institute\":\"University of Texas MD Anderson Cancer Center\",\"analysis_type\":\"LC-MS\",\"number_of_samples\":\"12\",\"submission_date\":\"2022-04-20\",\"release_date\":\"2022-04-14\",\"version\":\"1\",\"revision_no\":\"1\",\"revision_datetime\":\"-\",\"revision_comment\":\"-\",\"license\":\"CC BY 4.0\",\"license_url\":\"https:\\/\\/creativecommons.org\\/licenses\\/by\\/4.0\\/\",\"study_url\":\"https:\\/\\/www.metabolomicsworkbench.org\\/data\\/DRCCMetadata.php?StudyID=ST002115\"}"

## List zip file of the data set ST002115
mwb_ftp_list_files("ST002115")
#> [1] "ST002115_Data.zip"

## Download the file with: `mwb_ftp_download("ST002115", path = tempdir())`
```
