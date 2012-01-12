Calculation processes for ndvi metrics

A. Directories

The programs are resided in jzhu.gina.alaska.edu. 

The description of directories:

1. nps-cesu home directory: CESU_NDVI=~/nps/cesu/modis_ndvi_250m

2. directory for scripts: $CESU_NDVI/script
    
     unzip_ndvi.bash, rename_ndvi.bash

3. work directory: $CESU_NDVI/wrkdir 

   store unziped data files, immediate data files, result data files

4. idl programs directory: $CENSU_NDVI/wrkdir/ndvi_nps
   
   
5. raw zip ndvi data directory: ~/nps/cesu/modis_ndvi_250m/TERRA


B. The procedure of the data process: 


1. unzip the ndvi files (~nps/cesu/script)
 
  ndvi files comes from EMODIS website. download them and store 
  them in ~/nps/cesu/modis_ndvi_250m/TERRA. They are zip files.

  The scripts to unzip them and rename them are: 

  unzip_ndvi.bash

  rename_ndvi.bash



2. stack and subset weekly data files of one year, and keep only good data into one-year data
     
 inputs: file list of monthly ndvi file of one year,
         file list of monthly ndvi_bq files of the same year
 
 program:  oneyear_data_layer_subset_good.pro
   
 subroutines: start_batch.pro,read_ndvi.pro,subset.pro

 outputs: one-year stacked, subseted, and good data file       
 
3. stack three years of one-year data into a multiple-year(three years) data
  
   inputs: file list of one-year good data files, normally three sequency years  
   
   program: layer_stack.pro
     
   subroutines: start_batch.pro
  
   outputs: a multiple year (normally 3 years) stacked data file named: multiyear_layer_stack

4. calculate one-year metrics
  
   inputs: a multiple-year data file
  
   program: smooth_calculate_metrics_tile.pro
          
   subroutines: start_batch.pro, user_smooth.pro, interpol_vector.pro, 
   oneyear_extension.pro,cutoff_interp.pro,filter_odd.pro,user_metrics.pro 

   outputs: a metrics data file and smoothed data file




C. list of the program files 

calculate_ndvi_metrics.pro
interpol_vector.pro
layer_stack.pro
oneyear_data_layer_subset_good.pro
oneyear_extension.pro
oneyear_main_yyyy.pro
read_ndvi.pro
smooth_calculate_metrics_tile.pro
start_batch.pro
subset.pro
user_metrics.pro
user_smooth.pro
;--------------------------------------------------------------



D. data format description

1. The raw data comes from EMODIS. I use two kinds of files to produce ndvi metrics. One is 250m_compisit_ndvi.tif and other is 250m_composit_ndvi_bq.tif. The data range in ndvi.tif is -1999 to 10,000, -2000 is fill value, and the scale factor is 0.0001. Data in ndvi_bq.tif includes flag information. It indicates the type of the pixels. Types of the pixels are cloud, snow, fog, etc.



2. First, we process one pair of ndvi and ndvi_bq files by getting rid of those cloud, snow, fog, bad quality, negative reflectance pixels by filling these pixels with another fill value of -4000. Then we convert the data into 0 to 200 byte data by using the formula y=byte(x/100.0+100).In the new data, valid ndvi values are in the range of 100 to 200. The fill values (-2000) are converted into 80, and cloud, snow, fog pixels in raw data are converted into 60.

3. Stack one weekly data into a one year data file. The result file is named as yyyy_one_year_subset_good.tif (data range is 0 to 200, and data include 42 bands).


4. Combine the year before, the year, and the year after data files into a multiple-year data file. The program layer_stack.pro finishes this process and produced a 3-year stacked data file named yyyy_multiyear_stack_stack_0_200_set_snow_cloud_n4000.hdr (data range is 0 to 200, and data include 42 bands).

5. Smooth the multiple year stacked data and calculate the metrics of the year. The result data file is named as yyyy_multiyear_layer_stack_0_200_set_snow_cloud_n4000_smooth.hdr (data range is 0 to 200), and the metrics data is named as yyyy_multiyear_layer_stack_metrics_not_0_200_set_snow_cloud_n2000.hdr (data include 12 bands).

      
E. detailed description of the algorithms

In the whole process of NDVI metrics calculation, three core algorithms
are used. They are bad pixel elimination,time-series smooth, and time-series NDVI metric calculation algorithm.

1. Bad pixel elimination

"read_ndvi.bash" does bad pixel elimination. 

a. It reads one pair of file (a ndvi file and its related ndvi quality file).
b. stack the two data(ns,nl,1) together to get a two bands data array(ns,nl,2).Band1 are pixel ndvi values, and band2 are quality flags of the pixels. 

c. goes through every pixel. for a pixel where the flag of the pixel(band2) is cloud,snow,bad quality,or negative reflectance, set the pixel value (band 1) to -4000. convert the ndvi values of the pixel from range -4000 to 10,000(integer) 
into range 0 to 200 byte by out=byte(in/100 +100).

d. output only the band1 of the data.

2. time-series smooth algorithm 

"interpol_nonextension_vector.pro" and "wls_smooth.pro" do smooth for
time-series vector.

 
a.suppose we have already got the three year data in chronological sequence. The data is a
array(ns,nl,126),which include 126 bands( 42 bands per year). Each pixel
corresponds to a 126 points time-series vector.

b.goes through each pixel to smooth the pixel time-series vector.      

  for each 126 points time-series, count the number of valid points. if the number/number of points is equal or greater than
a ratio (for example,0.6), we conitue to do smooth, otherwise, we mark the
pixel with not good pixel.   
 
         


  
 
