# Retrieve Mass Spectrometry Data from Metabolomics Workbench

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![license](https://img.shields.io/badge/license-Artistic--2.0-brightgreen.svg)](https://opensource.org/licenses/Artistic-2.0)

This repository provides a *backend* for
[Spectra](https://github.com/RforMassSpectrometry/Spectra) objects that
represents and retrieves mass spectrometry (MS) data directly from data sets
deposited at the public [Metabolomics
Workbench](https://www.metabolomicsworkbench.org/) repository. Mass spectrometry
data files of a data set are downloaded and cached locally using the
[BiocFileCache](https://bioconductor.org/packages/BiocFileCache) package to
avoid repeated download.


# Installation

The package can be installed with

```r
install.packages("BiocManager")
BiocManager::install("RforMassSpectrometry/MsBackendMetabolomicsWorkbench")
```


# Contributions

Contributions are highly welcome and should follow the [contribution
guidelines](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html#contributions).
Also, please check the coding style guidelines in the [RforMassSpectrometry
vignette](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html).
