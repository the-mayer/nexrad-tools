
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

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(nexrad.tools)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub\!

# nexrad-tools

A compilation of scripts used to download NEXRAD data from AWS, unpack,
read, and generate simple plots.

# aws\_download\_NEXRAD.R & aws\_download\_NEXRAD.R

Grab nexrad binary files from AWS by supplying a station and date range
OR by supplying a list of specific filenames.

# unpack\_NEXRAD\_binary.R

utilizing system commands, decompress nexrad data (if compressed) and
export to netCDF file format utilizing java blob from UCAR.

# merge\_NEXRAD\_moments\_v2.0.R

extract data from netCDF arrays, melt into data frames and merge nexrad
resolution cells by azimuth, range, elevation, and time. Additionally,
calculate Z from dBZ for use in calculating biological reflectivity, per
Chilson.
