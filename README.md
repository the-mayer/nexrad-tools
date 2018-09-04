# nexrad-tools
A compilation of scripts used to download NEXRAD data from AWS, unpack, read, and generate simple plots. 

#aws_download_NEXRAD.R & aws_download_NEXRAD.R
Grab nexrad binary files from AWS by supplying a station and date range OR by supplying a list of specific filenames. 

#unpack_NEXRAD_binary.R
utilizing system commands, decompress nexrad data (if compressed) and export to netCDF file format utilizing java blob from UCAR. 

#merge_NEXRAD_moments_v2.0.R
extract data from netCDF arrays, melt into data frames and merge nexrad resolution cells by azimuth, range, elevation, and time. Additionally, calculate Z from dBZ for use in calculating biological reflectivity, per Chilson. 
