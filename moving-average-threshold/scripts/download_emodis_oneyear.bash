#!/bin/bash
#downloads emodis data by wget

if [ $# != 2 ]; then

echo "Usage:download_emodis_oneyear.bash dir_data year"

exit 1

fi

url=http://dds.cr.usgs.gov/emodis/Alaska/historical/TERRA

dir_data=$1
year=$2


cd $dir_data

#wget -r -nH -o log --reject="index.html*" ftp://emodisftp.cr.usgs.gov/eMODIS/Alaska/historical/TERRA/2008/comp_42/eMTH_NDVI.*.QKM.*

wget -r -nH --reject="index.html*" -A "*NDVI*QKM*.zip"$url/$year

exit 0
