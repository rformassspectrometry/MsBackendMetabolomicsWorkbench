# Retrieve and Use Mass Spectrometry Data from Metabolomics Workbench

**Package**:
*[MsBackendMetabolomicsWorkbench](https://bioconductor.org/packages/3.24/MsBackendMetabolomicsWorkbench)*\
**Authors**: Gabriele Tomè \[aut, cre\] (ORCID:
<https://orcid.org/0000-0002-3976-6068>, fnd: MetaRbolomics4Galaxy
project (CUP: D53C25001030003) co-funded by the Autonomous Province of
Bolzano under the Joint Projects South Tyrol–Germany 2025 program.),
Philippine Louail \[aut\] (ORCID:
<https://orcid.org/0009-0007-5429-6846>), Johannes Rainer \[aut\]
(ORCID: <https://orcid.org/0000-0002-6977-7147>)\
**Last modified:** 2026-06-11 14:19:20.077704\
**Compiled**: Thu Jun 11 14:19:34 2026

## Introduction

Metabolomics experiments and results including mass spectrometry (MS)
data can be deposited in several public repositories, such as
[Metabolomics Workbench](https://metabolomicsworkbench.org/) repository,
a data resource developed by the NIH Common Fund’s Data Repository and
Coordinating Center (DRCC) at the San Diego Supercomputer Center,
University of California San Diego. While data is available, manual
lookup and download is cumbersome hampering the re-analysis of public
data and replication of results. The *MsBackendMetabolomicsWorkbench*
package closes this gap by providing functionality to query, retrieve
and cache MS data from Metabolomics Workbench directly from R hence
enabling a direct and seamless integration of MS data from Metabolomics
Workbench into R-based analysis workflows.
*MsBackendMetabolomicsWorkbench* leverages on Bioconductor’s
*[BiocFileCache](https://bioconductor.org/packages/3.24/BiocFileCache)*
for caching remote data locally and provides a *MS data backend* for the
*[Spectra](https://bioconductor.org/packages/3.24/Spectra)* package to
enable loading and integrating cached MS data directly into R.

## Installation

The package can be installed from within R with the commands below:

``` r

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("RforMassSpectrometry/MsBackendMetabolomicsWorkbench")
```

## Importing MS Data from Metabolomics Workbench

Each experiment in Metabolomics Workbench is identified by a unique
accession starting with *ST* followed by a number. The repository
provides programmatic access via the Metabolomics Workbench REST API and
POST requests, so users can query experiments and associated data files
directly. With `MsBackendMetabolomicsWorkbench`, you can resolve these
accessions and download supported MS files (mzML/CDF/mzXML) into a local
cache, then load them into a `Spectra` object for downstream processing.

Below we list all files from Metabolomics Workbench experiment
*ST002115*.

``` r

library(MsBackendMetabolomicsWorkbench)

#' List files of a Metabolomics Workbench data set
all_files <- mwb_list_files("ST002115")
head(all_files)
```

    ##             zip_file              sample_file
    ## 1  ST002115_Data.zip  HT1080_DMSO_01_RP.mzXML
    ## 3  ST002115_Data.zip  HT1080_DMSO_02_RP.mzXML
    ## 5  ST002115_Data.zip  HT1080_DMSO_03_RP.mzXML
    ## 7  ST002115_Data.zip HT1080_ML162_01_RP.mzXML
    ## 9  ST002115_Data.zip HT1080_ML162_02_RP.mzXML
    ## 11 ST002115_Data.zip HT1080_ML162_03_RP.mzXML

MS data files in supported formats (mzML, CDF, mzXML) can be directly
loaded using the `MsBackendMetabolomicsWorkbench` backend into R as a
`Spectra` object (`MsBackendMetabolomicsWorkbench` directly extends
*Spectra*’s `MsBackendMzR` backend and therefore supports import of MS
data files in these formats). There are two supported download modes:

1.  POST request to fetch individual data files. (*default*)
2.  FTP request to download the zip containing all files of the
    experiment.

Below we list zip file of Metabolomics Workbench experiment *ST002115*.

``` r

#' List zipped FTP files for a Metabolomics Workbench data set
mwb_ftp_list_files("ST002115")
```

    ## [1] "ST002115_Data.zip"

The FTP archive contains all files for the experiment, which may include
unneeded files. If only a subset of files is needed, the default POST
option (with `ftp_zip = FALSE`) is more efficient. By default, all MS
data files of the data set would be retrieved, but in our example below
we restrict to a few data files to reduce the amount of data that needs
to be downloaded. To this end we define a pattern matching the file name
of only some data files using the `filePattern` parameter.

``` r

library(Spectra)

#' Load MS data files of one data set
s <- Spectra("ST002115", filePattern = "01_RP.mzXML$", ftp_zip = FALSE,
             source = MsBackendMetabolomicsWorkbench())
s
```

    ## MSn data (Spectra) with 5751 spectra in a MsBackendMetabolomicsWorkbench backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            0  0.569753         1
    ## 2            0  1.627010         2
    ## 3            0  2.684380         3
    ## 4            0  3.739880         4
    ## 5            0  4.795500         5
    ## ...        ...       ...       ...
    ## 5747         0   1498.87      1435
    ## 5748         0   1499.93      1436
    ## 5749         0   1500.98      1437
    ## 5750         0   1502.04      1438
    ## 5751         0   1503.10      1439
    ##  ... 37 more variables/columns.
    ## 
    ## file(s):
    ## ST002115_Data_HT1080_DMSO_01_RP.mzXML
    ## ST002115_Data_HT1080_ML162_01_RP.mzXML
    ## ST002115_Data_HT1080_ML210_01_RP.mzXML
    ##  ... 1 more files

This call downloaded 4 files from the experiment into the local cache
and loaded them as a `Spectra` object. The downloading and caching of
the data is handled by Bioconductor’s
*[BiocFileCache](https://bioconductor.org/packages/3.24/BiocFileCache)*.
The local cache can thus also be managed directly using functionality
from that package. Any subsequent loading of the same data files will
load the locally cached versions avoiding thus repetitive download of
the same data.

The `Spectra` object with the MS data files of the Metabolomics
Workbench data set enables now any subsequent analysis of the data in R.
On top of the spectra variables and mass peak data values that are
provided by the MS data files also additional information related to the
Metabolomics Workbench data set are available as specific *spectra
variables*. We list all available spectra variables of the data set
below.

``` r

spectraVariables(s)
```

    ##  [1] "msLevel"                  "rtime"                   
    ##  [3] "acquisitionNum"           "scanIndex"               
    ##  [5] "dataStorage"              "dataOrigin"              
    ##  [7] "centroided"               "smoothed"                
    ##  [9] "polarity"                 "precScanNum"             
    ## [11] "precursorMz"              "precursorIntensity"      
    ## [13] "precursorCharge"          "collisionEnergy"         
    ## [15] "isolationWindowLowerMz"   "isolationWindowTargetMz" 
    ## [17] "isolationWindowUpperMz"   "peaksCount"              
    ## [19] "totIonCurrent"            "basePeakMZ"              
    ## [21] "basePeakIntensity"        "electronBeamEnergy"      
    ## [23] "ionisationEnergy"         "lowMZ"                   
    ## [25] "highMZ"                   "mergedScan"              
    ## [27] "mergedResultScanNum"      "mergedResultStartScanNum"
    ## [29] "mergedResultEndScanNum"   "injectionTime"           
    ## [31] "filterString"             "spectrumId"              
    ## [33] "ionMobilityDriftTime"     "scanWindowLowerLimit"    
    ## [35] "scanWindowUpperLimit"     "mwb_id"                  
    ## [37] "zip_file"                 "file_name"

The Metabolomics Workbench-specific variables are `"mwb_id"`,
`"zip_file"` and `"file_name"` providing the Metabolomics Workbench ID
of the data set, the zip file name in the FTP server and the original
data file name in the Metabolomics Workbench for each individual
spectrum.

``` r

spectraData(s, c("mwb_id", "zip_file", "file_name"))
```

    ## DataFrame with 5751 rows and 3 columns
    ##           mwb_id          zip_file              file_name
    ##      <character>       <character>            <character>
    ## 1       ST002115 ST002115_Data.zip ST002115_Data_HT1080..
    ## 2       ST002115 ST002115_Data.zip ST002115_Data_HT1080..
    ## 3       ST002115 ST002115_Data.zip ST002115_Data_HT1080..
    ## 4       ST002115 ST002115_Data.zip ST002115_Data_HT1080..
    ## 5       ST002115 ST002115_Data.zip ST002115_Data_HT1080..
    ## ...          ...               ...                    ...
    ## 5747    ST002115 ST002115_Data.zip ST002115_Data_HT1080..
    ## 5748    ST002115 ST002115_Data.zip ST002115_Data_HT1080..
    ## 5749    ST002115 ST002115_Data.zip ST002115_Data_HT1080..
    ## 5750    ST002115 ST002115_Data.zip ST002115_Data_HT1080..
    ## 5751    ST002115 ST002115_Data.zip ST002115_Data_HT1080..

``` r

basename(s$file_name) |> head()
```

    ## [1] "ST002115_Data_HT1080_DMSO_01_RP.mzXML"
    ## [2] "ST002115_Data_HT1080_DMSO_01_RP.mzXML"
    ## [3] "ST002115_Data_HT1080_DMSO_01_RP.mzXML"
    ## [4] "ST002115_Data_HT1080_DMSO_01_RP.mzXML"
    ## [5] "ST002115_Data_HT1080_DMSO_01_RP.mzXML"
    ## [6] "ST002115_Data_HT1080_DMSO_01_RP.mzXML"

The
[`mwb_sync()`](https://rformassspectrometry.github.io/MsBackendMetabolomicsWorkbench/reference/MsBackendMetabolomicsWorkbench.md)
function can be used to *synchronize* the local content of a
`MsBackendMetabolomicsWorkbench` and is useful if, for example, locally
cached files were deleted. The function checks if all data files of the
backend are available locally and eventually downloads and caches
missing files.

``` r

mwb_sync(s@backend)
```

    ## MsBackendMetabolomicsWorkbench with 5751 spectra
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            0  0.569753         1
    ## 2            0  1.627010         2
    ## 3            0  2.684380         3
    ## 4            0  3.739880         4
    ## 5            0  4.795500         5
    ## ...        ...       ...       ...
    ## 5747         0   1498.87      1435
    ## 5748         0   1499.93      1436
    ## 5749         0   1500.98      1437
    ## 5750         0   1502.04      1438
    ## 5751         0   1503.10      1439
    ##  ... 37 more variables/columns.
    ## 
    ## file(s):
    ## ST002115_Data_HT1080_DMSO_01_RP.mzXML
    ## ST002115_Data_HT1080_ML162_01_RP.mzXML
    ## ST002115_Data_HT1080_ML210_01_RP.mzXML
    ##  ... 1 more files

In addition, it is also possible to *manually* cache and download
selected files from Metabolomics Workbench using the
[`mwb_sync_data_files()`](https://rformassspectrometry.github.io/MsBackendMetabolomicsWorkbench/reference/MetabolomicsWorkbench-utils.md)
function. Before downloading, this function first evaluates if the
respective data files are already cached and only downloads them if
needed. As a result, the function returns a `data.frame` with the
storage location and other information of the cached file(s). Below we
use this function to retrieve the local storage information on one of
the data files of the Metabolomics Workbench data set *ST002115*:

``` r

res <- mwb_sync_data_files("ST002115",
                            fileName = "HT1080_DMSO_01_RP.mzXML")
res
```

    ##     rid   mwb_id          zip_file                             file_name
    ## 2 BFC35 ST002115 ST002115_Data.zip ST002115_Data_HT1080_DMSO_01_RP.mzXML
    ##                                                                       rpath
    ## 2 /github/home/.cache/R/BiocFileCache/ST002115_Data_HT1080_DMSO_01_RP.mzXML

The
[`mwb_cached_data_files()`](https://rformassspectrometry.github.io/MsBackendMetabolomicsWorkbench/reference/MetabolomicsWorkbench-utils.md)
function can be used to inspect and list all locally cached Metabolomics
Workbench data files. This function does not require an active internet
connection since only local content is queried. With the default
settings, a `data.frame` with all available data files is returned.

``` r

mwb_cached_data_files()
```

    ##      rid   mwb_id          zip_file
    ## 11 BFC34 ST002115 ST002115_Data.zip
    ## 12 BFC35 ST002115 ST002115_Data.zip
    ## 13 BFC36 ST000016 ST000016_mzML.zip
    ## 14 BFC37 ST002115 ST002115_Data.zip
    ## 15 BFC38 ST002115 ST002115_Data.zip
    ## 16 BFC39 ST002115 ST002115_Data.zip
    ##                                             file_name
    ## 11              ST002115_Data_HT1080_DMSO_02_RP.mzXML
    ## 12              ST002115_Data_HT1080_DMSO_01_RP.mzXML
    ## 13 ST000016_mzML_D20101022-LC2-PP0000705-A1-I1-P.mzML
    ## 14             ST002115_Data_HT1080_ML162_01_RP.mzXML
    ## 15             ST002115_Data_HT1080_ML210_01_RP.mzXML
    ## 16              ST002115_Data_HT1080_RSL3_01_RP.mzXML
    ##                                                                                     rpath
    ## 11              /github/home/.cache/R/BiocFileCache/ST002115_Data_HT1080_DMSO_02_RP.mzXML
    ## 12              /github/home/.cache/R/BiocFileCache/ST002115_Data_HT1080_DMSO_01_RP.mzXML
    ## 13 /github/home/.cache/R/BiocFileCache/ST000016_mzML_D20101022-LC2-PP0000705-A1-I1-P.mzML
    ## 14             /github/home/.cache/R/BiocFileCache/ST002115_Data_HT1080_ML162_01_RP.mzXML
    ## 15             /github/home/.cache/R/BiocFileCache/ST002115_Data_HT1080_ML210_01_RP.mzXML
    ## 16              /github/home/.cache/R/BiocFileCache/ST002115_Data_HT1080_RSL3_01_RP.mzXML

Locally cached files for a Metabolomics Workbench data set can be
removed using the
[`mwb_delete_cache()`](https://rformassspectrometry.github.io/MsBackendMetabolomicsWorkbench/reference/MetabolomicsWorkbench-utils.md)
function providing the ID of the Metabolomics Workbench data set for
which local data files should be removed.

## General use and information retrieval from Metabolomics Workbench

Next to the `MsBackendMetabolomicsWorkbench` backend for `Spectra`
objects, the *MsBackendMetabolomicsWorkbench* package provides also
various utility functions to query and retrieve information from
Metabolomics Workbench.

The
[`mwb_rest_request()`](https://rformassspectrometry.github.io/MsBackendMetabolomicsWorkbench/reference/MetabolomicsWorkbench-utils.md)
queries the Metabolomics Workbench REST API for a given study/analysis
ID and output item (e.g. `summary`, `factors`). Returns the raw response
as a `character` string in the format specified by `outputFormat`
(`json` or `txt`).

Below we query the REST API for the summary of the Metabolomics
Workbench data set *ST002115*:

``` r

summary <- mwb_rest_request("ST002115", outputItem = "summary",
                            outputFormat = "json")
fromJSON(summary)
```

    ## $study_id
    ## [1] "ST002115"
    ## 
    ## $study_title
    ## [1] "LC-MS analysis of metabolic changes induced by GPX4 inhibitor treatment in cultured HT1080 cells"
    ## 
    ## $species
    ## [1] "Homo sapiens"
    ## 
    ## $institute
    ## [1] "University of Texas MD Anderson Cancer Center"
    ## 
    ## $analysis_type
    ## [1] "LC-MS"
    ## 
    ## $number_of_samples
    ## [1] "12"
    ## 
    ## $submission_date
    ## [1] "2022-04-20"
    ## 
    ## $release_date
    ## [1] "2022-04-14"
    ## 
    ## $version
    ## [1] "1"
    ## 
    ## $revision_no
    ## [1] "1"
    ## 
    ## $revision_datetime
    ## [1] "-"
    ## 
    ## $revision_comment
    ## [1] "-"
    ## 
    ## $license
    ## [1] "CC BY 4.0"
    ## 
    ## $license_url
    ## [1] "https://creativecommons.org/licenses/by/4.0/"
    ## 
    ## $study_url
    ## [1] "https://www.metabolomicsworkbench.org/data/DRCCMetadata.php?StudyID=ST002115"

The
[`mwb_ftp_download()`](https://rformassspectrometry.github.io/MsBackendMetabolomicsWorkbench/reference/MetabolomicsWorkbench-utils.md)
function allows to download the zip archive of the experiment (directly,
i.e., without caching). As an example we download below the zip archive
to a temporary folder. In our example below we do not run it to reduce
the amount of data that needs to be downloaded.

``` r

mwb_ftp_download("ST002115", path = tempdir())
```

The
[`mwb_metadata()`](https://rformassspectrometry.github.io/MsBackendMetabolomicsWorkbench/reference/MetabolomicsWorkbench-utils.md)
function retrieves the metadata of a given Metabolomics Workbench data
set as a `list` of 2 `data.frame`: - `MS_run`: contains the metadata of
the MS runs of the data set, identified by the analysis ID(s), -
`sample_annotation`: contains the metadata of the samples of the data
set. Not all the experiments have a column with the associated sample
file name, the association cab be retrieved by the
[`mwb_list_files()`](https://rformassspectrometry.github.io/MsBackendMetabolomicsWorkbench/reference/MetabolomicsWorkbench-utils.md)
function.

The function handles the case of multiple analysis IDs by combining the
metadata of all analysis IDs into a single `data.frame` for the
experiment and a single `data.frame` for the sample annotation.

Below we retrieve the metadata of the data set *ST002115*:

``` r

meta <- mwb_metadata("ST002115")
meta$MS_run
```

    ##   STUDY_ID ANALYSIS_ID VERSION CREATED_ON
    ## 1 ST002115    AN003513       1 02-08-2024
    ## 2 ST002115    AN003514       1 02-08-2024
    ##                                                                                      PROJECT_TITLE
    ## 1 A ferroptosis defense mechanism mediated by glycerol 3-phosphate dehydrogenase 2 in mitochondria
    ## 2 A ferroptosis defense mechanism mediated by glycerol 3-phosphate dehydrogenase 2 in mitochondria
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    PROJECT_SUMMARY
    ## 1 Mechanisms of defense against ferroptosis (an iron-dependent form of cell death induced by lipid peroxidation) in cellular organelles remain poorly understood, hindering our ability to target ferroptosis in disease treatment. In this study, metabolomic analyses revealed that treatment of cancer cells with glutathione peroxidase 4 (GPX4) inhibitors results in intracellular glycerol 3-phosphate (G3P) depletion. We further showed that supplementation of cancer cells with G3P attenuates ferroptosis induced by GPX4 inhibitors in a G3P dehydrogenase 2 (GPD2)-dependent manner; GPD2 deletion sensitizes cancer cells to GPX4 inhibition-induced mitochondrial lipid peroxidation and ferroptosis, and combined deletion of GPX4 and GPD2 synergistically suppresses tumor growth by inducing ferroptosis in vivo. Mechanistically, inner mitochondrial membrane-localized GPD2 couples G3P oxidation with ubiquinone reduction to ubiquinol, which acts as a radical-trapping antioxidant to suppress ferroptosis in mitochondria. Taken together, these results reveal that GPD2 participates in ferroptosis defense in mitochondria by generating ubiquinol.
    ## 2 Mechanisms of defense against ferroptosis (an iron-dependent form of cell death induced by lipid peroxidation) in cellular organelles remain poorly understood, hindering our ability to target ferroptosis in disease treatment. In this study, metabolomic analyses revealed that treatment of cancer cells with glutathione peroxidase 4 (GPX4) inhibitors results in intracellular glycerol 3-phosphate (G3P) depletion. We further showed that supplementation of cancer cells with G3P attenuates ferroptosis induced by GPX4 inhibitors in a G3P dehydrogenase 2 (GPD2)-dependent manner; GPD2 deletion sensitizes cancer cells to GPX4 inhibition-induced mitochondrial lipid peroxidation and ferroptosis, and combined deletion of GPX4 and GPD2 synergistically suppresses tumor growth by inducing ferroptosis in vivo. Mechanistically, inner mitochondrial membrane-localized GPD2 couples G3P oxidation with ubiquinone reduction to ubiquinol, which acts as a radical-trapping antioxidant to suppress ferroptosis in mitochondria. Taken together, these results reveal that GPD2 participates in ferroptosis defense in mitochondria by generating ubiquinol.
    ##                                       INSTITUTE LAST_NAME FIRST_NAME
    ## 1 University of Texas MD Anderson Cancer Center       Gan       Boyi
    ## 2 University of Texas MD Anderson Cancer Center       Gan       Boyi
    ##                                    ADDRESS               EMAIL        PHONE
    ## 1 6565 MD Anderson Blvd, Houston, TX 77030 bgan@mdanderson.org 713-792-8653
    ## 2 6565 MD Anderson Blvd, Houston, TX 77030 bgan@mdanderson.org 713-792-8653
    ##                                 DOI
    ## 1 http://dx.doi.org/10.21228/M8HD8Q
    ## 2 http://dx.doi.org/10.21228/M8HD8Q
    ##                                                                                        STUDY_TITLE
    ## 1 LC-MS analysis of metabolic changes induced by GPX4 inhibitor treatment in cultured HT1080 cells
    ## 2 LC-MS analysis of metabolic changes induced by GPX4 inhibitor treatment in cultured HT1080 cells
    ##                                                                                                                                                                                       STUDY_SUMMARY
    ## 1 HT1080 cells were treated with vehicle (DMSO), RSL3 (10 micromolar), ML210 (10 micromolar), or ML162 (10 micromolar) for 2 hours. Cellular metabolites were then extracted and analyzed by LC-MS.
    ## 2 HT1080 cells were treated with vehicle (DMSO), RSL3 (10 micromolar), ML210 (10 micromolar), or ML162 (10 micromolar) for 2 hours. Cellular metabolites were then extracted and analyzed by LC-MS.
    ##   SUBMIT_DATE   SUBJECT_TYPE SUBJECT_SPECIES TAXONOMY_ID CELL_STRAIN_DETAILS
    ## 1  2022-03-02 Cultured cells    Homo sapiens        9606              HT1080
    ## 2  2022-03-02 Cultured cells    Homo sapiens        9606              HT1080
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                   COLLECTION_SUMMARY
    ## 1 Metabolites were extracted from cells in 35 mm culture plates by rapidly aspirating the culture medium and incubating the plates with 0.6 ml of an 80% methanol: 20% water mixture on a cold block on dry ice for 15 min. Next, the cell material was scraped into Eppendorf tubes pre-chilled on ice. After centrifugation at 13,000 RCF for 5 min at 4 °C, the supernatant was collected into a fresh tube and stored on dry ice until analysis.
    ## 2 Metabolites were extracted from cells in 35 mm culture plates by rapidly aspirating the culture medium and incubating the plates with 0.6 ml of an 80% methanol: 20% water mixture on a cold block on dry ice for 15 min. Next, the cell material was scraped into Eppendorf tubes pre-chilled on ice. After centrifugation at 13,000 RCF for 5 min at 4 °C, the supernatant was collected into a fresh tube and stored on dry ice until analysis.
    ##      SAMPLE_TYPE STORAGE_CONDITIONS
    ## 1 Cultured cells               -80?
    ## 2 Cultured cells               -80?
    ##                                                                                                                                TREATMENT_SUMMARY
    ## 1 Cells were seeded in 35-mm culture plates. When the cell confluence reached 70-80%, cells were treated with RSL3, ML210, or ML162 for 2 hours.
    ## 2 Cells were seeded in 35-mm culture plates. When the cell confluence reached 70-80%, cells were treated with RSL3, ML210, or ML162 for 2 hours.
    ##                                                                                                                                                                                                                              SAMPLEPREP_SUMMARY
    ## 1 For analysis by reverse phase chromatography, just before analysis, 500 µL of extract was dried under a nitrogen gas flow and then resuspended in 100 µL of water. For analysis by HILIC chromatography, the extracts were analyzed directly.
    ## 2 For analysis by reverse phase chromatography, just before analysis, 500 µL of extract was dried under a nitrogen gas flow and then resuspended in 100 µL of water. For analysis by HILIC chromatography, the extracts were analyzed directly.
    ##   PROCESSING_STORAGE_CONDITIONS EXTRACT_STORAGE
    ## 1                            4?              4?
    ## 2                            4?              4?
    ##                                                                                                                                                                                                                                                                  CHROMATOGRAPHY_SUMMARY
    ## 1 The gradient was 0 min, 0% B; 2.5 min, 0% B; 5 min, 20% B; 7.5 min, 20% B; 13 min, 55% B; 15.5 min, 95% B; 18.5 min, 95% B; 19 min, 0% B; and 25 min, 0% B. Solvent A was 10 mM tributylamine and 15 mm acetic acid in water; Solvent B was methanol. The injection volume was 10 µL.
    ## 2 The gradient was 0 min, 85% B; 2 min, 85% B; 3 min, 80% B; 5 min, 80% B; 6 min, 75% B; 7 min, 75% B; 8 min, 70% B; 9 min, 70% B; 10 min, 50% B; 12 min, 50% B; 13 min, 25% B; 16 min, 25% B; 18 min, 0% B; 23 min, 0% B; 24 min, 85% B; 30 min, 85% B. The injection volume was 5 µL.
    ##      INSTRUMENT_NAME                                         COLUMN_NAME
    ## 1 Thermo Accela 1250 Phenomenex Synergi Hydro RP 100 A (100 x 2mm,2.5um)
    ## 2 Thermo Accela 1250   Waters XBridge BEH Amide (150 x 2.1mm,2.5um,100A)
    ##   COLUMN_TEMPERATURE FLOW_RATE
    ## 1                 40       200
    ## 2                 40       150
    ##                                                   SOLVENT_A         SOLVENT_B
    ## 1        100% water; 15 mM acetic acid; 10 mM tributylamine     100% methanol
    ## 2 95% water/5% acetonitrile; 20 mM ammonium acetate, pH 9.4 100% acetonitrile
    ##   CHROMATOGRAPHY_TYPE ANALYSIS_TYPE INSTRUMENT_TYPE MS_TYPE
    ## 1      Reversed phase            MS        Orbitrap     ESI
    ## 2               HILIC            MS        Orbitrap     ESI
    ##                                                                                                                                                                                                                                                                                   MS_COMMENTS
    ## 1 The scan range was 80-1000 m/z. Raw data files were converted to mzXML format using msconvert (ProteoWizard). Data was analyzed in the MAVEN software suite and metabolite assignments were made using a previously generated list of retention times derived from pure standard solutions.
    ## 2 The scan range was 80-1000 m/z. Raw data files were converted to mzXML format using msconvert (ProteoWizard). Data was analyzed in the MAVEN software suite and metabolite assignments were made using a previously generated list of retention times derived from pure standard solutions.
    ##   ION_MODE
    ## 1 NEGATIVE
    ## 2 NEGATIVE

``` r

meta$sample_annotation
```

    ##    Subject ID       Sample ID Factors: Treatment
    ## 1           -  HT1080_DMSO_01               DMSO
    ## 2           -  HT1080_DMSO_02               DMSO
    ## 3           -  HT1080_DMSO_03               DMSO
    ## 4           - HT1080_ML162_01              ML162
    ## 5           - HT1080_ML162_02              ML162
    ## 6           - HT1080_ML162_03              ML162
    ## 7           - HT1080_ML210_01              ML210
    ## 8           - HT1080_ML210_02              ML210
    ## 9           - HT1080_ML210_03              ML210
    ## 10          -  HT1080_RSL3_01               RSL3
    ## 11          -  HT1080_RSL3_02               RSL3
    ## 12          -  HT1080_RSL3_03               RSL3
    ##    Additional sample data: RAW_FILE_NAME
    ## 1                   HT1080_DMSO_01.mzXML
    ## 2                   HT1080_DMSO_02.mzXML
    ## 3                   HT1080_DMSO_03.mzXML
    ## 4                  HT1080_ML162_01.mzXML
    ## 5                  HT1080_ML162_02.mzXML
    ## 6                  HT1080_ML162_03.mzXML
    ## 7                  HT1080_ML210_01.mzXML
    ## 8                  HT1080_ML210_02.mzXML
    ## 9                  HT1080_ML210_03.mzXML
    ## 10                  HT1080_RSL3_01.mzXML
    ## 11                  HT1080_RSL3_02.mzXML
    ## 12                  HT1080_RSL3_03.mzXML
    ##    Additional sample data: RAW_FILE_NAME_2
    ## 1               HT1080_DMSO_01_HILIC.mzXML
    ## 2               HT1080_DMSO_02_HILIC.mzXML
    ## 3               HT1080_DMSO_03_HILIC.mzXML
    ## 4              HT1080_ML162_01_HILIC.mzXML
    ## 5              HT1080_ML162_02_HILIC.mzXML
    ## 6              HT1080_ML162_03_HILIC.mzXML
    ## 7              HT1080_ML210_01_HILIC.mzXML
    ## 8              HT1080_ML210_02_HILIC.mzXML
    ## 9              HT1080_ML210_03_HILIC.mzXML
    ## 10              HT1080_RSL3_01_HILIC.mzXML
    ## 11              HT1080_RSL3_02_HILIC.mzXML
    ## 12              HT1080_RSL3_03_HILIC.mzXML

## Session information

``` r

sessionInfo()
```

    ## R version 4.6.0 (2026-04-24)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.4 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ## [1] MsBackendMetabolomicsWorkbench_0.1.5 jsonlite_2.0.0                      
    ## [3] Spectra_1.23.3                       BiocParallel_1.47.0                 
    ## [5] S4Vectors_0.51.3                     BiocGenerics_0.59.7                 
    ## [7] generics_0.1.4                       BiocStyle_2.41.0                    
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] xfun_0.58              bslib_0.11.0           httr2_1.2.2           
    ##  [4] htmlwidgets_1.6.4      Biobase_2.73.1         vctrs_0.7.3           
    ##  [7] tools_4.6.0            curl_7.1.0             parallel_4.6.0        
    ## [10] tibble_3.3.1           RSQLite_3.53.1         cluster_2.1.8.2       
    ## [13] blob_1.3.0             pkgconfig_2.0.3        data.table_1.18.4     
    ## [16] dbplyr_2.5.2           desc_1.4.3             lifecycle_1.0.5       
    ## [19] stringr_1.6.0          compiler_4.6.0         textshaping_1.0.5     
    ## [22] progress_1.2.3         codetools_0.2-20       ncdf4_1.24            
    ## [25] clue_0.3-68            htmltools_0.5.9        sass_0.4.10           
    ## [28] yaml_2.3.12            tidyr_1.3.2            pkgdown_2.2.0.9000    
    ## [31] pillar_1.11.1          crayon_1.5.3           jquerylib_0.1.4       
    ## [34] MASS_7.3-65            cachem_1.1.0           MetaboCoreUtils_1.21.1
    ## [37] rvest_1.0.5            tidyselect_1.2.1       digest_0.6.39         
    ## [40] stringi_1.8.7          purrr_1.2.2            dplyr_1.2.1           
    ## [43] bookdown_0.46          fastmap_1.2.0          archive_1.1.13        
    ## [46] cli_3.6.6              magrittr_2.0.5         withr_3.0.2           
    ## [49] prettyunits_1.2.0      filelock_1.0.3         rappdirs_0.3.4        
    ## [52] bit64_4.8.2            httr_1.4.8             rmarkdown_2.31        
    ## [55] bit_4.6.0              otel_0.2.0             hms_1.1.4             
    ## [58] ragg_1.5.2             memoise_2.0.1          evaluate_1.0.5        
    ## [61] knitr_1.51             IRanges_2.47.2         BiocFileCache_3.3.0   
    ## [64] rlang_1.2.0            Rcpp_1.1.1-1.1         glue_1.8.1            
    ## [67] DBI_1.3.0              mzR_2.47.0             selectr_0.5-1         
    ## [70] xml2_1.5.2             BiocManager_1.30.27    R6_2.6.1              
    ## [73] plyr_1.8.9             systemfonts_1.3.2      fs_2.1.0              
    ## [76] ProtGenerics_1.45.0    MsCoreUtils_1.25.4
