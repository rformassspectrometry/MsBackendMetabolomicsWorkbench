# Changelog

## MsBackendMetabolomicsWorkbench 0.1

### Changes in 0.1.5

- Fix bug caching files with same filename. Add zip filename to sample
  filename.

### Changes in 0.1.4

- Handle encoded sample filenames.
- Improve the managing of POST failures.
- Improve the handling of cached files.
- Add the POST request for .tar.gz archive.
- Change from copy to move when adding files to cache after zip
  download.
- Centralize retry pattern.
- Expand tests.
- Add GHA.

### Changes in 0.1.3

- Add vignette.

### Changes in 0.1.2

- Update documentation.

### Changes in 0.1.1

- Possibility to download the zip file of the experiment from the FTP
  server.
- Update documentation.
- Update unit tests.

### Changes in 0.1.0

- Initial version, add the basic Metabolomics Workbench functions.
- Add functionality to download and cache MS data files from
  Metabolomics Workbench.
- Add unit tests.
