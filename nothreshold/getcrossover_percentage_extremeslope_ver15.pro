FUNCTION GetCrossOver_percentage_extremeslope_ver15, Xref, Yref, XData, YData, bq, bpy, UP=up, DOWN=down, ALL=ALL
   
;jzhu, modified from GetCrossOver2.pro, input ndvi pixel type bq, check the possible crossover points against bq, elimite the crossover
;which are not good type points
;jzhu, get 20% of maximun points and maximun or minimun slope points, 
;output points,xvalue,yvalue,slope,type(0-crossover,1-20%,2-extrmeslope)
    
   mxidx = where( Yref EQ max(Yref) ) 
   mxidxst=mxidx(0)
   mxidxed=mxidx(n_elements(mxidx)-1)
   
   v20=0.2*max(yref)
   
   slopemax=0.0
   xslopemax=0.0
   yslopemax=0.0
   
   slopemin=0.0
   xslopemin=0.0
   yslopemin=0.0
   
   nSize = Size(XRef)
   nDim=nSize[0]
   oSize=nSize
   oSize[nDim]=nSize[nDim]/2
   XPts=Make_Array(Size=oSize)
   YPts=Make_Array(Size=oSize)
   SPts=Make_Array(Size=oSize)
   TPts=Make_Array(Size=oSize)
   CPts=Make_Array(Size=oSize)

   if(not keyword_set(up)) then up=0
   if(not keyword_set(down)) then down=0
   if(not keyword_set(ALL)) then ALL=0

   IF (ALL EQ 1) THEN BEGIN
      UP=1 
      DOWN=1
   ENDif

   iCount=0
   
   CASE nDim OF

      1: BEGIN
         
    
         
         FOR i = 0L, nSize[nDim]-2 DO BEGIN


 
        
            RSlope = float(YRef[i+1]-YRef[i])/(XRef[i+1]-XRef[i])
            DSlope = float(YData[i+1]-YData[i])/(XData[i+1]-XData[i])
            
            SlopeDiff=DSlope-RSlope
            
            IF (SlopeDiff EQ 0) THEN SlopeDiff=1.e-6

            RInt = YRef[i]-RSlope*XRef[i]
            DInt = YData[i]-DSlope*XData[i]
            

            XStar = (RInt-DInt)/SlopeDiff
      
            BetweenD=Between(XStar, XData[i], XData[i+1])
            BetweenR=Between(XStar, XRef[i], XRef[i+1])
            
            
            ;----- looking for crossover with 20% of maximun ndvi line
            
            if (YRef[i] LE v20 and v20 LE Yref[i+1]) and Rslope GT 0 and Down then begin ; found xstar
              
               XStar1=Xref[i]+(v20-Yref[i])/RSlope 
               XPts[iCount]=XStar1
               YPts[iCount]=V20
               SPts[iCount]=RSlope
               tPts[icount]=1    ; type of the point, 0-crossover, 1-20%,2-extremeslope
               CPts[iCount]=1
               iCount = iCount+1
            endif
            
            
            if (YRef[i] GE v20 and v20 GE Yref[i+1]) and Rslope LT 0 and UP then begin ; found xstar
              
               XStar1=Xref[i]+(v20-Yref[i])/RSlope 
               XPts[iCount]=XStar1
               YPts[iCount]=V20
               SPts[iCount]=RSlope
               tPts[icount]=1    ; type of the point, 0-crossover, 1-20%,2-extremeslope
               CPts[iCount]=1
               iCount = iCount+1
            endif
 
 
 
 
 
 
 
 
            ;-----get maximun slope for down and minimun slope for up
            
            
            if RSlope GE 0 and Down and Rslope GT slopemax and xref[i] LT mxidxst then begin
            
              Slopemax=Rslope   
             xslopemax=Xref[i]
             yslopemax=yref[i]
             
            endif
            
            if RSlope LT 0 and UP and Rslope LT slopemin and xref[i] GT mxidxed then begin
            
              Slopemin=Rslope
             xslopemin=Xref[i]
             yslopemin=Yref[i]
             
            endif
            
             
      ;jzhu, 9/14/2011, modify the condition,
  
      
      ;      If(BetweenD AND BetweenR) Then PtSC=1 ELSE PtSC=0
      
      
            
            if ( (BetweenD AND BetweenR) and (Xstar LT min([mxidxst,0.5*bpy])) and DOWN ) or $
               ( (BetweenD AND BetweenR) and (Xstar GT max([mxidxed,0.5*bpy])) and UP ) then begin
                 
                 PtSC=1
            endif else begin
                 PtSC=0
            endelse     
                
            ;-----------for sos crossover----------------------
            
              IF PtSC gt 0 AND ((DSlope lt RSlope) and DOWN ) then begin  ; for sos crossover 
            
               
               XPts[iCount]=XStar
               YPts[iCount]=DSlope*XStar + DInt
               sPts[icount]=Rslope
               tPts[icount]=0
               CPts[iCount]=PtSC
               iCount = iCount+1
              
               
              endif
            
              
            
            
           ;----------for EOS crossover ----------------------------------
         
              if PtSC GT 0 AND ((DSlope gt RSlope) and UP ) THEN BEGIN
            
 
              
                XPts[iCount]=XStar
                YPts[iCount]=DSlope*XStar + DInt
                sPts[iCount]=Rslope
                tPts[icount]=0
                CPts[iCount]=PtSC
                iCount = iCount+1
              
              endif     
              
          
         END  ;for
         
         ;------ add maxslope point to down or minslope point to up
         
         if Down then begin
           
           if xslopemax EQ 0.0 then begin ; not find maximun slope point, use middle point
           Xpts[iCount]=bpy/2.0 -1 
           ypts[iCount]=yref(bpy/2.0-1) 
           endif else begin
           Xpts[iCount]=xslopemax
           ypts[iCount]=yslopemax
           endelse
           
           spts[icount]=Slopemax
           CPts[icount]=1
           tPts[icount]=2
         endif
         
         if UP then begin
           if xslopemin EQ 0.0 then begin ; not find the minimum slope point, use middle point
           Xpts[icount]=bpy/2.0
           ypts[iCount]=yref(bpy/2.0)
           endif else begin
           Xpts[icount]=xslopemin
           ypts[iCount]=yslopemin
           endelse
           
           sPts[icount]=slopemin
           CPts[icount]=1
           tPts[icount]=2
           
         endif
         
         
         
         NPts=0 ; initial value
         NPtsidx=where(xPts NE 0, NPtscnt)
         if NPtscnt GT 0 then begin
         NPts =Nptscnt
         endif


         ;----test
          if NPts EQ 0 then begin
          print,'check'
          endif
         ;----------- 
          
         CASE (NPts GT 0) OF
            0:Cross={X:0., Y:0., S:0, T:0, C:0., N:Npts}
            ;1:Cross={X:Xpts[0:NPts-1], Y:YPts[0:NPts-1], S:sPts[0:NPts-1],T:tPts[0:NPts-1],C:CPts[0:NPts-1], N:NPts}
            1:Cross={X:Xpts(NPtsidx),Y:YPts(NPtsidx),S:sPts(NPtsidx),T:tPts(NPtsidx),C:CPts(NPTsidx),N:NPTs}
            ELSE:
         ENDCASE

      END;1 case
      
      2: BEGIN
      END;2

      3: BEGIN
         ;Index = lindgen(nSize[1]*nSize[2])
         CurIdx= intarr(nSize[1], nSize[2])
         ;RealIdx = CurIdx*nSize[1]*nSize[2] + Index

         FOR i = 0L, nSize[3]-2 DO BEGIN
            RSlope = float(YRef[*,*,i+1]-YRef[*,*,i])/(XRef[*,*,i+1]-XRef[*,*,i])
            DSlope = float(YData[*,*,i+1]-YData[*,*,i])/(XData[*,*,i+1]-XData[*,*,i])
            SlopeDiff=DSlope-RSlope
            z=where(SlopeDiff EQ 0, nz)
            IF(nz gt 0) THEN SlopeDiff[z]=1.0e-6
            RInt = YRef[*,*,i]-RSlope*XRef[*,*,i]
            DInt = YData[*,*,i]-DSlope*XData[*,*,i]

            XStar = (RInt-DInt)/SlopeDiff

            BetweenD=Between(XStar, XData[*,*,i], XData[*,*,i+1])
            BetweenR=Between(XStar, XRef[*,*,i], XRef[*,*,i+1])
      
;            If(BetweenD AND BetweenR) Then PtSC=1 ELSE PtSC=0
      
            CIdx = where(BetweenD and BetweenR, nci) ; on [0:ns*nl]


CrossIdx=where(BetweenD and BetweenR  AND $
               ((DSlope lt RSlope and DOWN) OR $
                (DSlope gt RSlope and UP)), ncri) 

               
                              
if (ncri gt 0) then begin

            RealIdx=CurIdx[CrossIdx]*nSize[1]*nSize[2] + CrossIdx

               XPts[RealIdx]=XStar[CrossIdx]
               YPts[RealIdx]=DSlope[CrossIdx]*XStar[CrossIdx] + DInt[CrossIdx]
               CPts[RealIdx]=1
               
               CurIdx[CrossIdx]=CurIdx[CrossIdx]+1
 
            END
         END; FOR

MaxZ=Max(CurIdx)
Xpts=Temporary(Xpts[*,*,0:MaxZ-1])
Ypts=Temporary(Ypts[*,*,0:MaxZ-1])
Cpts=Temporary(Cpts[*,*,0:MaxZ-1])

Zero=where(Xpts[*,*,1:MaxZ-1] EQ 0)
Xpts[nSize[1]*nSize[2]+Zero] = -1
Ypts[nSize[1]*nSize[2]+Zero] = -1
Cpts[nSize[1]*nSize[2]+Zero] = -1

;print, MaxZ
;showimg, rebin(curidx, 256, 256), Down


            Cross={X:Xpts, Y:Ypts, C:Cpts, N:MaxZ}

      END;3

      ELSE:
   ENDCASE 



undefine, xpts
undefine, ypts

RETURN, Cross
END
