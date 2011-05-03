This project uses modis band7,band2,and band1 to produce the rgb image.

A. scripts are stored in

dir_prog=svadmin@dvimapp:/home/svadmin/dbvm/scripts/nps_721bands.

dir_script=svadmin@dvimapp:/home/svadmin/dbvm/scripts

B. script files:

hdf_to_tif_to_721_main.bash
hdf_to_721tif.bash
hdf_to_tif_by_mrtswath.bash
alaska_albers_nps_250m.prm
alaska_albers_nps_500m.prm 
rtstps_main.bash
rtstps_zero_pds.bash

C. complete process from modis zero file to 721 band tif file

0. identify the interested file by using swathviwer
   produces a favorite file list


1. downlaod zero data from http://web7.arsc.edu:8080/UAFGINA/t1/2010/

   modis_zero_data_download.bash 

2. convert zero files into PDS files

   rtstps_zero_pds.bash

3. convert PDS files to modis level1 data files

svadmin@/svimapp:/home/dbvm/scripts/modis_pds_to_level1/moddis_pds_to_level1_main.bash

4. level1 data to 721 tif file
 
 Core process in this step:


1.modis level1 250m.hdf,500m.hdf and geo.hdf are converted to uint16 tif files

250m.hdf -> mrtswath, 16uint, EV_250_RefSB, 1, 1-> tif files
500m.hdf -> mrtswath, 16uint, EV_500_RefSB, 0, 0, 0, 0, 1 -> tif file

2.single band uint16 tif files stacks together

gdalbuildvrt -separate tmp.vrt $TIF_DIR/${fn500m}_EV_500_RefSB_b4.tif
$TIF_DIR/${fn250m}_EV_250_RefSB_b1.tif $TIF_DIR/${fn250m}_EV_250_RefSB_b0.tif

tmp.vrt

note: r-first file,g-second file, b-third file

gdal_translate -of GTiff tmp.vrt  $TIF_DIR/${fn}_721.tif

one three-bands uint16 tif file

3. stretch the three-band uint16 tif file to uint8 tif file

gdal_contrast_stretch $TIF_DIR/${fn}_721.tif
$TIF_DIR/band721/${fn}_721_stretch.tif -percentile-range 0.02 0.98 -ndv 65535
-outndv 0

one uint8 tif file, r,g,b bands correspond to first,second,and third input files

