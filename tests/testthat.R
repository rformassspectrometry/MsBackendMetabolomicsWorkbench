library(testthat)
library(MsBackendMetabolomicsWorkbench)

test_check("MsBackendMetabolomicsWorkbench")

## Run tests with the unit test suite defined in the Spectra package to ensure
## compliance with the definitions of the MsBackend interface/class.
be <- backendInitialize(MsBackendMetabolomicsWorkbench(), "ST002115",
                        filePattern = "HT1080_DMSO_01_RP.mzXML$")

library(Spectra)
test_suite <- system.file("test_backends", "test_MsBackend",
                          package = "Spectra")
res <- test_dir(test_suite, stop_on_failure = TRUE)
