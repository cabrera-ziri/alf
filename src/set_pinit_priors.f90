SUBROUTINE SET_PINIT_PRIORS(pos,prlo,prhi,velz)

  !define the first position (pos), and the lower and upper bounds 
  !on the priors (prlo, prhi).  The priors are defined in such a way
  !that if the user defines a prior limit that is **different from
  !the default parameter set**, then that value overrides the defaults below

  USE alf_vars; USE alf_utils, ONLY : myran
  IMPLICIT NONE

  TYPE(PARAMS), INTENT(inout) :: pos,prlo,prhi
  TYPE(PARAMS) :: test
  REAL(DP), OPTIONAL :: velz
  INTEGER :: i
  
  !---------------------------------------------------------------!
  !---------------------------------------------------------------!

  !setup the first position
  pos%logage    = myran()*0.5+0.5
  pos%feh       = myran()*1.0-0.5
  pos%ah        = myran()*1.0-0.5
  pos%nhe       = myran()*1.0-0.5
  pos%ch        = myran()*1.0-0.5
  pos%nh        = myran()*1.0-0.5
  pos%nah       = myran()*1.0-0.5
  pos%mgh       = myran()*1.0-0.5
  pos%sih       = myran()*1.0-0.5
  pos%kh        = myran()*1.0-0.5
  pos%cah       = myran()*1.0-0.5
  pos%tih       = myran()*1.0-0.5
  pos%vh        = myran()*1.0-0.5
  pos%crh       = myran()*1.0-0.5
  pos%mnh       = myran()*1.0-0.5
  pos%coh       = myran()*1.0-0.5
  pos%nih       = myran()*1.0-0.5
  pos%cuh       = myran()*1.0-0.5
  pos%rbh       = myran()*1.0-0.5
  pos%srh       = myran()*1.0-0.5
  pos%yh        = myran()*1.0-0.5
  pos%zrh       = myran()*1.0-0.5
  pos%bah       = myran()*1.0-0.5
  pos%euh       = myran()*1.0-0.5
  pos%teff      = myran()*80-40
  pos%imf1      = myran()*0.6-0.3 + 1.3
  pos%imf2      = myran()*0.6-0.3 + 2.3
  pos%logfy     = myran()*1-4
  pos%fy_logage = myran()*0.5
  pos%logm7g    = myran()*1-4
  pos%hotteff   = myran()*5+15
  pos%loghot    = myran()*1-4
  pos%chi2      = huge_number
  pos%sigma     = myran()*100+100
  pos%sigma2    = myran()*100+100
  pos%velz2     = myran()*10-5
  pos%logtrans  = myran()*3-4.
  pos%logemline_h    = myran()*1-4
  pos%logemline_oiii = myran()*1-4
  pos%logemline_ni   = myran()*1-4
  pos%logemline_nii  = myran()*1-4
  pos%logemline_sii  = myran()*1-4

  IF (PRESENT(velz)) THEN
     pos%velz  = velz + (myran()*10-5)
  ELSE
     pos%velz  = myran()*10-5
  ENDIF

  !these pr=test statements allow the user to pre-set
  !specific priors at the beginning of alf.f90; those
  !choices are then not overwritten below

  !priors (low)
  IF (fit_type.EQ.0) THEN
     !in this case we're fitting a two component model
     !so dont allow them to overlap in age
     IF (prlo%logage.EQ.test%logage) prlo%logage = LOG10(3.0)
  ELSE
     !in this case we have a single age model, so it needs to
     !cover the full range
     IF (prlo%logage.EQ.test%logage) prlo%logage = LOG10(0.5)
  ENDIF
  IF (prlo%feh.EQ.test%feh) prlo%feh          = -1.0
  IF (prlo%ah.EQ.test%ah) prlo%ah             = -0.3
  IF (prlo%nhe.EQ.test%nhe) prlo%nhe          = -0.3
  IF (prlo%ch.EQ.test%ch) prlo%ch             = -0.3
  IF (prlo%nh.EQ.test%nh) prlo%nh             = -0.3
  IF (prlo%nah.EQ.test%nah) prlo%nah          = -0.3
  IF (prlo%mgh.EQ.test%mgh) prlo%mgh          = -0.3
  IF (prlo%sih.EQ.test%sih) prlo%sih          = -0.3
  IF (prlo%kh.EQ.test%kh) prlo%kh             = -0.3
  IF (prlo%cah.EQ.test%cah) prlo%cah          = -0.3
  IF (prlo%tih.EQ.test%tih) prlo%tih          = -0.3
  IF (prlo%vh.EQ.test%vh) prlo%vh             = -0.3
  IF (prlo%crh.EQ.test%crh) prlo%crh          = -0.3
  IF (prlo%mnh.EQ.test%mnh) prlo%mnh          = -0.3
  IF (prlo%coh.EQ.test%coh) prlo%coh          = -0.3
  IF (prlo%nih.EQ.test%nih) prlo%nih          = -0.3
  IF (prlo%cuh.EQ.test%cuh) prlo%cuh          = -0.3
  IF (prlo%rbh.EQ.test%rbh) prlo%rbh          = -0.3
  IF (prlo%srh.EQ.test%srh) prlo%srh          = -0.3
  IF (prlo%yh.EQ.test%yh) prlo%yh             = -0.3
  IF (prlo%zrh.EQ.test%zrh) prlo%zrh          = -0.6
  IF (prlo%bah.EQ.test%bah) prlo%bah          = -0.6
  IF (prlo%euh.EQ.test%euh) prlo%euh          = -0.6
  IF (prlo%teff.EQ.test%teff) prlo%teff       = -75.0
  IF (prlo%imf1.EQ.test%imf1) prlo%imf1       = 0.5
  IF (prlo%imf2.EQ.test%imf2) prlo%imf2       = 0.5
  IF (prlo%logfy.EQ.test%logfy) prlo%logfy    = -5.0
  IF (prlo%fy_logage.EQ.test%fy_logage) prlo%fy_logage = LOG10(0.5)
  IF (prlo%logm7g.EQ.test%logm7g) prlo%logm7g   = -5.0
  IF (prlo%hotteff.EQ.test%hotteff) prlo%hotteff= 8.0
  IF (prlo%loghot.EQ.test%loghot) prlo%loghot   = -5.0
  IF (prlo%sigma.EQ.test%sigma) prlo%sigma      = 10.0
  IF (prlo%sigma2.EQ.test%sigma2) prlo%sigma2   = 10.0
  IF (prlo%velz.EQ.test%velz) prlo%velz         = -1E3
  IF (prlo%velz2.EQ.test%velz2) prlo%velz2      = -1E3
  IF (prlo%logtrans.EQ.test%logtrans) prlo%logtrans = -6.0
  IF (prlo%logemline_h.EQ.test%logemline_h) prlo%logemline_h          = -6.0
  IF (prlo%logemline_oiii.EQ.test%logemline_oiii) prlo%logemline_oiii = -6.0
  IF (prlo%logemline_sii.EQ.test%logemline_sii) prlo%logemline_sii    = -6.0
  IF (prlo%logemline_ni.EQ.test%logemline_ni) prlo%logemline_ni       = -6.0
  IF (prlo%logemline_nii.EQ.test%logemline_nii) prlo%logemline_nii    = -6.0

 
  !priors (high)
  !if you change the prior on the age, also change the max 
  !age allowed in getmodel
  IF (prhi%logage.EQ.test%logage) prhi%logage = LOG10(15.0)
  IF (prhi%feh.EQ.test%feh) prhi%feh          = 0.5
  IF (prhi%ah.EQ.test%ah) prhi%ah             = 0.5
  IF (prhi%nhe.EQ.test%nhe) prhi%nhe          = 0.5
  IF (prhi%ch.EQ.test%ch) prhi%ch             = 0.5
  IF (prhi%nh.EQ.test%nh) prhi%nh             = 1.0
  IF (prhi%nah.EQ.test%nah) prhi%nah          = 1.0
  IF (prhi%mgh.EQ.test%mgh) prhi%mgh          = 0.5
  IF (prhi%sih.EQ.test%sih) prhi%sih          = 0.5
  IF (prhi%kh.EQ.test%kh) prhi%kh             = 0.5
  IF (prhi%cah.EQ.test%cah) prhi%cah          = 0.5
  IF (prhi%tih.EQ.test%tih) prhi%tih          = 0.5
  IF (prhi%vh.EQ.test%vh) prhi%vh             = 0.5
  IF (prhi%crh.EQ.test%crh) prhi%crh          = 0.5
  IF (prhi%mnh.EQ.test%mnh) prhi%mnh          = 0.5
  IF (prhi%coh.EQ.test%coh) prhi%coh          = 0.5
  IF (prhi%nih.EQ.test%nih) prhi%nih          = 0.5
  IF (prhi%cuh.EQ.test%cuh) prhi%cuh          = 0.5
  IF (prhi%rbh.EQ.test%rbh) prhi%rbh          = 0.5
  IF (prhi%srh.EQ.test%srh) prhi%srh          = 0.5
  IF (prhi%yh.EQ.test%yh) prhi%yh             = 0.5
  IF (prhi%zrh.EQ.test%zrh) prhi%zrh          = 0.5
  IF (prhi%bah.EQ.test%bah) prhi%bah          = 0.5
  IF (prhi%euh.EQ.test%euh) prhi%euh          = 0.5
  IF (prhi%teff.EQ.test%teff) prhi%teff       = 75.0
  IF (prhi%imf1.EQ.test%imf1) prhi%imf1       = 3.5
  IF (prhi%imf2.EQ.test%imf2) prhi%imf2       = 3.5
  IF (prhi%logfy.EQ.test%logfy) prhi%logfy    = -0.7
  IF (prhi%fy_logage.EQ.test%fy_logage) prhi%fy_logage = LOG10(3.0)
  IF (prhi%logm7g.EQ.test%logm7g) prhi%logm7g   = -1.0
  IF (prhi%hotteff.EQ.test%hotteff) prhi%hotteff= 30.0
  IF (prhi%loghot.EQ.test%loghot) prhi%loghot   = -1.0
  IF (prhi%sigma.EQ.test%sigma) prhi%sigma      = 1E3
  IF (prhi%sigma2.EQ.test%sigma2) prhi%sigma2   = 1E3
  IF (prhi%velz.EQ.test%velz) prhi%velz         = 1E4
  IF (prhi%velz2.EQ.test%velz2) prhi%velz2      = 1E3
  IF (prhi%logtrans.EQ.test%logtrans) prhi%logtrans = 1.0
  IF (prhi%logemline_h.EQ.test%logemline_h) prhi%logemline_h          = 1.0
  IF (prhi%logemline_oiii.EQ.test%logemline_oiii) prhi%logemline_oiii = 1.0
  IF (prhi%logemline_sii.EQ.test%logemline_sii) prhi%logemline_sii    = 1.0
  IF (prhi%logemline_ni.EQ.test%logemline_ni) prhi%logemline_ni       = 1.0
  IF (prhi%logemline_nii.EQ.test%logemline_nii) prhi%logemline_nii    = 1.0

END SUBROUTINE SET_PINIT_PRIORS
