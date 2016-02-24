FUNCTION FUNC(nposarr,spec,funit)

  !routine to get a new model and compute chi^2.  Optionally,
  !the model spectrum is returned (spec).  The model priors
  !are computed in this routine.

  USE alf_vars; USE nr, ONLY : locate
  USE alf_utils, ONLY : linterp3,contnormspec,getmass,&
       str2arr,getmodel,linterp
  IMPLICIT NONE

  REAL(DP), DIMENSION(:), INTENT(inout) :: nposarr
  REAL(DP), DIMENSION(nl), OPTIONAL :: spec
  INTEGER, INTENT(in), OPTIONAL :: funit
  REAL(DP) :: func,pr,tchi2,ml,tl1,tl2,oneplusz
  REAL(DP), DIMENSION(nl)   :: mspec
  REAL(DP), DIMENSION(ndat) :: mflx,dflx,poly,zmspec
  REAL(DP), DIMENSION(npar) :: tposarr=0.0
  REAL(DP), DIMENSION(ncoeff) :: tcoeff
  INTEGER  :: i,i1,i2,j,npow,tpow
  TYPE(PARAMS)   :: npos

  !------------------------------------------------------!

  func = 0.0
  tpow = 0

  IF (SIZE(nposarr).NE.npar.AND.SIZE(nposarr).NE.npowell) THEN
     WRITE(*,*) 'FUNC ERROR: size(nposarr) NE npar or npowell'
     STOP
  ENDIF

  !this is for Powell minimization
  IF (SIZE(nposarr).LT.npar) THEN
     !coppy over the default parameters first
     CALL STR2ARR(1,npos,tposarr) !str->arr
     !only copy the first four params (velz,sigma,age,[Fe/H])
     tposarr(1:npowell) = nposarr(1:npowell)
  ELSE
     tposarr = nposarr
  ENDIF

  CALL STR2ARR(2,npos,tposarr) !arr->str

  !compute priors (don't count all the priors if fitting
  !in (super) simple mode or in powell fitting mode)
  pr = 1.0
  DO i=1,npar
     IF (i.GT.npowell.AND.(powell_fitting.EQ.1.OR.fit_type.EQ.2)) CYCLE
     IF (fit_type.EQ.1.AND.i.GT.nparsimp) CYCLE
     IF (nposarr(i).GT.prhiarr(i)) &
          pr = pr*EXP(-(nposarr(i)-prhiarr(i))**2/2/0.001)
     IF (nposarr(i).LT.prloarr(i)) &
          pr = pr*EXP(-(nposarr(i)-prloarr(i))**2/2/0.001)
  ENDDO

  !only compute the model and chi2 if the priors are >0.0
  IF (pr.GT.tiny_number) THEN

     !get a new model spectrum
     CALL GETMODEL(npos,mspec)
     
     IF (PRESENT(spec)) THEN
        spec = mspec
     ENDIF

     !de-redshift the data and interpolate to model wavelength array
   !  data%lam0 = data%lam / (1+npos%velz/clight*1E5)
   !  CALL LINTERP3(data(1:datmax)%lam0,data(1:datmax)%flx,&
   !       data(1:datmax)%err,data(1:datmax)%wgt,&
   !       sspgrid%lam(1:nl_fit),idata(1:nl_fit)%flx,&
   !       idata(1:nl_fit)%err,idata(1:nl_fit)%wgt)

     oneplusz = (1+npos%velz/clight*1E5)
     zmspec = 0.0
     zmspec(1:datmax) = LINTERP(sspgrid%lam(1:nl_fit)*oneplusz,&
          mspec(1:nl_fit),data(1:datmax)%lam)

     !compute chi2, looping over wavelength intervals
     DO i=1,nlint
        
        tl1 = MAX(l1(i)*oneplusz,data(1)%lam)
        tl2 = MIN(l2(i)*oneplusz,data(datmax)%lam)
        !if wavelength interval falls completely outside 
        !of the range of the data, then skip
        IF (tl1.GE.tl2) CYCLE
        
        i1 = MIN(MAX(locate(data(1:datmax)%lam,tl1),1),datmax-1)
        i2 = MIN(MAX(locate(data(1:datmax)%lam,tl2),2),datmax)
        ml = (tl1+tl2)/2.0
        
        !fit a polynomial to the ratio of model and data
        IF (fit_poly.EQ.1) THEN
           !CALL CONTNORMSPEC(sspgrid%lam,idata%flx/mspec,&
           !     idata%err/mspec,tl1,tl2,mflx,coeff=tcoeff)
           CALL CONTNORMSPEC(data(1:datmax)%lam,&
                data(1:datmax)%flx/zmspec(1:datmax),&
                data(1:datmax)%err/zmspec(1:datmax),tl1,tl2,mflx(1:datmax),&
                coeff=tcoeff)
           poly = 0.0
           npow = MIN(NINT((tl2-tl1)/poly_dlam),npolymax)
           DO j=1,npow+1 
              !poly = poly + tcoeff(j)*(sspgrid%lam-ml)**(j-1)
              poly = poly + tcoeff(j)*(data%lam-ml)**(j-1)
           ENDDO
           mflx  = zmspec * poly
           !dflx  = idata%flx
           dflx  = data%flx
           !tchi2 = SUM((dflx(i1:i2)-mflx(i1:i2))**2/idata(i1:i2)%err**2)
           tchi2 = SUM((dflx(i1:i2)-mflx(i1:i2))**2/data(i1:i2)%err**2)
        ELSE
       !    CALL CONTNORMSPEC(sspgrid%lam,idata%flx,idata%err,tl1,tl2,dflx)
       !    CALL CONTNORMSPEC(sspgrid%lam,mspec,idata%wgt*SQRT(mspec),&
       !         tl1,tl2,mflx)
       !    tchi2 = SUM(idata(i1:i2)%flx**2/idata(i1:i2)%err**2*&
       !         (dflx(i1:i2)-mflx(i1:i2))**2)
           WRITE(*,*) 'oops, this part of the code is not maintained!'
           STOP
        ENDIF
        
        !error checking
        IF (isnan(tchi2)) THEN
           WRITE(*,'(" FUNC ERROR: chi2 returned a NaN")') 
           WRITE(*,'(" error occured at wavelength interval: ",I1)') i
           WRITE(*,'("data:",2000F14.2)') dflx(i1:i2)
           WRITE(*,*)
           WRITE(*,'("model:",2000F14.2)') mspec(i1:i2)*1E3
           WRITE(*,*)
           WRITE(*,'("errors:",2000F14.2)') idata(i1:i2)%err
           WRITE(*,*)
           WRITE(*,'("params:",100F14.2)') tposarr
           STOP
        ENDIF
        
        func  = func + tchi2
        
        IF (PRESENT(funit)) THEN
           !write final results to screen and file
           WRITE(*,'(2x,F5.2,"um-",F5.2,"um:"," rms:",F5.1,"%, ","Chi2/dof:",F5.1)') &
                tl1/1E4,tl2/1E4,SQRT( SUM( (dflx(i1:i2)/mflx(i1:i2)-1)**2 )/&
                (i2-i1+1) )*100,tchi2/(i2-i1)
           DO j=i1,i2
            !  WRITE(funit,'(F9.2,4ES12.4)') sspgrid%lam(j),mflx(j),&
            !       dflx(j),idata(j)%flx/idata(j)%err,poly(j)
              WRITE(funit,'(F9.2,4ES12.4)') data(j)%lam,mflx(j),&
                   dflx(j),data(j)%flx/data(j)%err,poly(j)
           ENDDO
        ENDIF

     ENDDO
  
  ENDIF

  !include priors
  IF (pr.LE.tiny_number) THEN 
     func = huge_number 
  ELSE 
     func = func - 2*LOG(pr)
  ENDIF

  !for testing purposes
  IF (1.EQ.0) THEN
     IF (powell_fitting.EQ.1) THEN
        WRITE(*,'(2ES10.3,2F12.2,99F7.3)') &
             func,pr,npos%velz,npos%sigma,10**npos%logage,npos%feh
     ELSE
        WRITE(*,'(2ES10.3,2F12.2,99F7.3)') &
             func,pr,npos%velz,npos%sigma,10**npos%logage,npos%feh,npos%ah,&
             npos%nhe,npos%ch,npos%nh,npos%nah,npos%mgh,npos%sih,npos%kh,&
             npos%cah,npos%tih!,npos%vh,npos%crh,npos%mnh,npos%coh,npos%nih !,&
        !     npos%rbh,npos%srh,npos%yh,npos%zrh,npos%bah,npos%euh,npos%teff,&
        !     npos%imf1,npos%imf2,npos%logfy,npos%velz,npos%logm7g,npos%hotteff,&
        !     npos%loghot
     ENDIF
  ENDIF

END FUNCTION FUNC
