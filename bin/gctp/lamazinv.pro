;/*******************************************************************************
;NAME                  LAMBERT AZIMUTHAL EQUAL-AREA
;
;PURPOSE:	Transforms input Easting and Northing to longitude and
;		latitude for the Lambert Azimuthal Equal Area projection.  The
;		Easting and Northing must be in meters.  The longitude
;		and latitude values will be returned in radians.
;
;PROGRAMMER              DATE            
;----------              ----           
;D. Steinwand, EROS      March, 1991   
;S. Nelson,EROS		Dec, 1993	changed asin() to asinz() because
;					NaN resulted expecting poles.
;
;This function was adapted from the Lambert Azimuthal Equal Area projection
;code (FORTRAN) in the General Cartographic Transformation Package software
;which is available from the U.S. Geological Survey National Mapping Division.
; 
;ALGORITHM REFERENCES
;
;1.  "New Equal-Area Map Projections for Noncircular Regions", John P. Snyder,
;    The American Cartographer, Vol 15, No. 4, October 1988, pp. 341-355.

;2.  Snyder, John P., "Map Projections--A Working Manual", U.S. Geological
;    Survey Professional Paper 1395 (Supersedes USGS Bulletin 1532), United
;    State Government Printing Office, Washington D.C., 1987.
;
;3.  "Software Documentation for GCTP General Cartographic Transformation
;    Package", U.S. Geological Survey National Mapping Division, May 1982.
;*******************************************************************************/
;#include "cproj.h"

;/* Variables common to all subroutines in this code file
;  -----------------------------------------------------*/
;static double Lon0;	/* Center longitude (projection center) */
;static double lat_center;	/* Center latitude (projection center) 	*/
;static double R;		/* Radius of the earth (sphere) 	*/
;static double sin_lat_o;	/* Sine of the center latitude 		*/
;static double cos_lat_o;	/* Cosine of the center latitude 	*/
;static double FE;	/* x offset in meters			*/
;static double FN;	/* y offset in meters			*/
;
;/* Initialize the Lambert Azimuthal Equal Area projection
;  ------------------------------------------------------*/
;long lamazinvint(r, Lon0, Lat0,false_east,false_north) 
;double r; 			/* (I) Radius of the earth (sphere) 	*/
;double Lon0;		/* (I) Center longitude 		*/
;double Lat0;		/* (I) Center latitude 			*/
;double false_east;		/* x offset in meters			*/
;double false_north;		/* y offset in meters			*/
;{
;/* Place parameters in static storage for common use
;  -------------------------------------------------*/
;R = r;
;lon_center = Lon0;
;lat_center = Lat0;
;FE = false_east;
;FN = false_north;
;sincos(Lat0, &sin_lat_o, &cos_lat_o);

;/* Report parameters to the user
;  -----------------------------*/
;ptitle("LAMBERT AZIMUTHAL EQUAL-AREA"); 
;radius(r);
;cenlon(Lon0);
;cenlat(Lat0);
;offsetp(FE,FN);
;return(OK);
;}
;
;/* Lambert Azimuthal Equal Area inverse equations--mapping x,y to lat,long 
;  -----------------------------------------------------------------------*/
FUNCTION lamazinv, x, y, Lon0=Lon0, Lat0=Lat0, R=R, FE=FE, FN=FN
;double x;		/* (I) X projection coordinate */
;double y;		/* (I) Y projection coordinate */
;double lon;		/* (O) Longitude */
;double lat;		/* (O) Latitude */
;{
;double Rh;
;double z;		/* Great circle dist from proj center to given point */
;double sin_z;		/* Sine of z */
;double cos_z;		/* Cosine of z */
;double temp;		/* Re-used temporary variable */

EPSLN=1.0e-10
HALF_PI=!PI/2

;/* Inverse equations
;  -----------------*/
xn = double(x)-FE;
yn = double(y)-FN;
Rh = sqrt(xn^2 + yn^2);
temp = Rh / (2.0 * R);

if (temp GT 1) THEN BEGIN
   MESSAGE, "Input data error in lamaz-inverse";
   return, 115
END
z = 2.0d * asinz(temp);
sincos, z, sin_z, cos_z;
sincos, Lat0, sin_lat_o, cos_lat_o;
lon = lon0;
if (abs(Rh) GT EPSLN) THEN BEGIN
   
   lat = asinz(sin_lat_o * cos_z + cos_lat_o * sin_z * y / Rh);
   temp = abs(lat0) - HALF_PI
   if (abs(temp) GT EPSLN) THEN BEGIN
      
      temp = cos_z - sin_lat_o * sin(lat);
      if(temp NE 0.0) THEN $
         lon=adjust_lon(Lon0+atan(x*sin_z*cos_lat_o,temp*Rh));
   END else if (lat0 LT 0.0) then $
      lon = adjust_lon(Lon0 - atan(-x, y)) $
   else lon = adjust_lon(Lon0 + atan(x, -y));
END else lat = lat0;

return, {lat:lat, lon:lon};
END
