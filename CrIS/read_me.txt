03/04/2018:
  There are three datasets inside the 'cris_fs.GapCoeff.h5' file, which are P, C and CH.
     P: is the CrIS gap channel prediction coefficients (1158 in col * 2211 in row) 
     C: is the constant of the CrIS gap channels (1158)
     CH: has 3 values which are 183, 647 and 328 representing the number of gap channels in LW[1095.625~1209.375], MW [1750.625~2154.375] and SW [2550.625~2755] spectral regions respectively. 
  The attached IDL code will help you easily (I hope) get the CrIS gap channel radiance by using above P and C datasets.

  Usage:
directly use the CrIS measured channel radiances (2211, Ndata) multiple(matrix multiple) CrIS gap channel prediction coefficients P and plus the constant C in each gap channels
    CrIS_RAD(gap) = CrIS_RAD(measure) ## P + C
