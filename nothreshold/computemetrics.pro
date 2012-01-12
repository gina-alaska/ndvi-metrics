FUNCTION ComputeMetrics, NDVI,  wl, bpy, CurrentBand, DaysPerBand;dt
;for modis ndvi 7-days data, DaysperBand=7

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
; Get crossover points (potential starts/ends)
;
   Starts=GetCrossOver2(Time, NDVI, Time, FMA, bpy, /Down)
   Ends=GetCrossOver2(Time, NDVI, Time, BMA, bpy, /Up)
;die
;
; Determine start/end of season
;
   SOS=GetSOS3(Starts, NDVI, Time, bpy, FMA) ;dayindex of start season and related ndvi value
   EOS=GetEOS3(Ends, NDVI, Time, bpy, SOS,bma)   ;dayindex of end season and related ndvi value
   
;-----asume valid range of wl(2) is 5 to 30

;if ( wl(2)-sos.sost ) GT 5 and wl(2) GE 5 and wl(2) LE 30 then begin
;print,' check this vector'
;idx1= where( abs(starts.x-wl(2)) EQ min(abs(starts.x-wl(2)) )  )
;if abs( wl(2)-starts.x( idx1(0) ) ) GT 5 then begin 
;sos.sost=wl(2)
;sos.sosn=ndvi(wl(2))
;endif else begin
;sos.sost=starts.x( idx1(0) )
;sos.sosn=starts.y( idx1(0) )
;endelse
;endif


;---do not judge eos against eos got from slope method, because I found up slope is correct, down slope is not correct.

;if abs(eos.eost-wl(3) ) GT 5 and wl(3) GE 30 and wl(3) LE 50 then begin
;print,'check this vector'
;eos.eost=wl(3)
;eos.eosn=ndvi(wl(3))
;endif

;
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
