
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
devtools::install_github("skydavis435/nexrad-tools")
```

# nexrad-tools

A compilation of scripts used to download NEXRAD data from AWS, unpack,
read, and generate simple plots.

## download\_nexrad.R

Grab nexrad binary files from AWS by supplying a station and date range
OR by supplying a list of specific filenames.

## unpack\_NEXRAD\_binary.R

utilizing system commands, decompress nexrad data (if compressed) and
export to netCDF file format utilizing java blob from UCAR.

## merge\_NEXRAD\_moments\_v2.0.R

extract data from netCDF arrays, melt into data frames and merge nexrad
resolution cells by azimuth, range, elevation, and time. Additionally,
calculate Z from dBZ for use in calculating biological reflectivity, per
Chilson.
