# Retrieve Mass Spectrometry Data from Metabolomics Workbench

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![license](https://img.shields.io/badge/license-Artistic--2.0-brightgreen.svg)](https://opensource.org/licenses/Artistic-2.0)
[![R-CMD-check-bioc](https://github.com/RforMassSpectrometry/MsBackendMetabolomicsWorkbench/workflows/R-CMD-check-bioc/badge.svg)](https://github.com/RforMassSpectrometry/MsBackendMetabolomicsWorkbench/actions?query=workflow%3AR-CMD-check-bioc)
[![:name status
badge](https://rformassspectrometry.r-universe.dev/badges/:name)](https://rformassspectrometry.r-universe.dev/)
[![license](https://img.shields.io/badge/license-Artistic--2.0-brightgreen.svg)](https://opensource.org/licenses/Artistic-2.0)

This repository provides a *backend* for
[Spectra](https://github.com/RforMassSpectrometry/Spectra) objects that
represents and retrieves mass spectrometry (MS) data directly from data
sets deposited at the public [Metabolomics
Workbench](https://www.metabolomicsworkbench.org/) repository. Mass
spectrometry data files of a data set are downloaded and cached locally
using the
[BiocFileCache](https://bioconductor.org/packages/BiocFileCache) package
to avoid repeated download.

# Installation

The package can be installed with

``` r

install.packages("BiocManager")
BiocManager::install("RforMassSpectrometry/MsBackendMetabolomicsWorkbench")
```

# Contributions

Contributions are highly welcome and should follow the [contribution
guidelines](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html#contributions).
Also, please check the coding style guidelines in the
[RforMassSpectrometry
vignette](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html).

# Funding information

This work was co-funded by *MetaRbolomics4Galaxy* project (CUP:
D53C25001030003) financed by Autonomous Province of Bolzano under the
framework of the *Joint Projects South Tyrol–Germany 2025* funding
program.

![funding](https://github.com/rformassspectrometry/MsBackendMetabolomicsWorkbench/raw/main/man/figures/SuedDFG-60.png)

funding
