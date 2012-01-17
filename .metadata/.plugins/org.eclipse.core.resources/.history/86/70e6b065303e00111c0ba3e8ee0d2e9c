FUNCTION ComputeMetrics_by1yr, NDVI, bq, bn, wl, bpy, CurrentBand, DaysPerBand;dt
;for modis ndvi 7-days data, DaysperBand=7
;jzhu, 9/21/2011, this program modified from computemetrics.pro,
;it inputs three-year ndvi time series abd rerlated band anme vectors,wl,bpy,currentband, and daysperband 

;-----

   nSize=Size(NDVI)
   Time=Make_Array(Size=nSize)
   Time1=findgen(nSize[nSize[0]])

   CASE(nSize[0]) OF
      1: Time=Time1
      2: FOR i=0, nSize[1]-1 DO Time[i]=Time1
      3: BEGIN
         FOR i=0, nSize[1]-1 DO BEGIN
            FOR j=0, nSize[2]-1 DO BEGIN
               Time[i,j,*]=Time1
            END
         END
      END;3
      ELSE:
   ENDCASE

;
; Calculate Forward/Backward moving average
;
   fma=GetForwardMA(ndvi, wl[0])
   bma=GetBackwardMA(ndvi, wl[1])

;
;
; Get crossover points (potential starts/ends)
;
   Starts=GetCrossOver_percentage_extremeslope_ver15(Time, NDVI, Time, FMA, bq, bpy, /Down)
   Ends=GetCrossOver_percentage_extremeslope_ver15(Time, NDVI, Time, BMA, bq, bpy, /Up)
;die
;
; Determine start/end of season
;
;SOS=GetSOS_ver15(Starts, NDVI,bq,Time, bpy, FMA) ;dayindex of start season and related ndvi valuei, quarentee possib sos > threshold,
                                                     ; possib eos  less than threshold  
                                                     
SOS=GetSOS_ver16(Starts, NDVI,bq,Time, bpy, FMA) ;  
                                                     ;                                                    
;SOS=GetSOS_between_threshold(Starts, NDVI,bq,Time, bpy, FMA) ;dayindex of start season and related ndvi value, find sos between possib and threshold

;SOS=GetSOS_nothreshold_ver15(Starts, NDVI,bq,Time,bpy,FMA); do not consider to compare with threshold

;EOS=GetEOS_ver15(Ends, NDVI, bq, Time,bpy,SOS,bma) ;

EOS=GetEOS_ver16(Ends, NDVI, bq, Time,bpy,SOS,bma) ;

;EOS=GetEOS_nothreshold_ver15(Ends, NDVI,bq,Time, bpy,SOS,bma); do not consider to compare with threshold 

;EOS=GetEOS_between_threshold(Ends, NDVI,bq,Time, bpy, SOS,bma); pick sos between possible sos and threshold
 

; Generate structures for Start/End of season
;
   Start_End = {SOST:SOS.SOST, $
                SOSN:SOS.SOSN, $
                EOST:EOS.EOST, $
                EOSN:EOS.EOSN, $
                FwdMA:FMA, $
                BkwdMA:BMA $
               }


;PRINT, 'COMPUTEMETRICS:NY:',ny
;   ny=n_elements(eos.eost)
   SOST = Start_End.SOST
   SOSN = Start_End.SOSN
   EOST = Start_End.EOST
   EOSN = Start_End.EOSN

   MaxND=GetMaxNDVI(NDVI, Time, Start_End,bpy) ;dayindex and related maximun ndvi value
   TotalNDVI=GetTotNDVI(NDVI, Time, Start_End,bpy,DaysperBand) ; ndvi*day (it is a ndvi curve minus baseline ), 
                                                               ; baseline( start to end) vector,
                                                               ; ndvi vector (start to end),
                                                               ; time vector (start to end).
                                                               ; GrowingSeasonT=GST, GrowingSeasonN=GSN, GrowingSeasonB=GSB)

;MJS 7/30/98 Need to write this
   NDVItoDate=GetNDVItoDate(NDVI, Time, Start_End, bpy, DaysPerBand, CurrentBand) ; ndvi*day, nowT (dayindex),nowN

   Slope=GetSlope(Start_End, MaxND, bpy, DaysPerBand) ;slope = ndvi/day   
   
   Range=GetRange(Start_End, MaxND, bpy, DaysPerBand) ;range.ranget = day, range.rangeN = ndvi


;IF(N_ELEMENTS(GST LE 0)) THEN GST=-1L
;IF(N_ELEMENTS(GSN LE 0)) THEN GSN=-1L
;IF(N_ELEMENTS(GSB LE 0)) THEN GSB=-1L

mMetrics = {SOST:SOST, $
            SOSN:SOSN, $
            EOST:EOST, $
            EOSN:EOSN, $
            FwdMA: Start_End.FwdMA, $
            BkwdMA: Start_End.BkwdMA, $
            SlopeUp: Slope.SlopeUp, $
            SlopeDown:  Slope.SlopeDown, $
            TotalNDVI: TotalNDVI.TotalNDVI, $
            GrowingN:TotalNDVI.GSN, $
            GrowingT:TotalNDVI.GST, $
            GrowingB:TotalNDVI.GSB, $
            MaxT: MaxND.MaxT, $
            MaxN: MaxND.MaxN, $
            RangeT: Range.RangeT, $
            RangeN: Range.RangeN, $
            NDVItoDate: NDVItoDate.NDVItoDate, $
            NowT: NDVItoDate.NowT, $
            NowN: NDVItoDate.NowN $
           }


;   mMetrics = getall(ndvi, Time, start_end, ny, bpy)
;die
return, mMetrics
END
