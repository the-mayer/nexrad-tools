
<!-- README.md is generated from README.Rmd. Please edit that file -->

# NEXRAD Tools

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of project is to …

## Installation

You can install the development version of this package from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("skydavis435/nexrad-tools", ref = 'pkg')
```

# nexrad-tools

An R Package used to download NEXRAD data from AWS, write it to netCDF,
and align NEXRAD moments.

## download\_nexrad.R

Grab nexrad binary files from AWS by supplying a station and date range.

## create\_netCDF.R

Utility, to read and decompress NEXRAD binary data and export to netCDF
file format utilizing java blob from UCAR.

## align\_moments.R

extract data from netCDF arrays, and align NEXRAD moments by azimuth,
range, and elevation.
