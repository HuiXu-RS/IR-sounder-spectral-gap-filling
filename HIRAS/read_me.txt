03/05/2019:
  There are three datasets inside the 'hiras.GapCoeff.h5' file, which are P, C and CH.
     P: is the HIRAS gap channel prediction coefficients (1094 in col * 2275 in row) 
     C: is the constant of the HIRAS gap channels (1094)
     CH: has 3 values which are 119, 647 and 328 representing the number of gap channels in LW[1135.625~1209.375], MW [1750.625~2154.375] and SW [2550.625~2755] spectral regions respectively. 
  The attached IDL code will help you easily (I hope) get the HIRAS gap channel radiance by using above P and C datasets.