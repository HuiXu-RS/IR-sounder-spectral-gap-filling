03/05/2019:
  There are three datasets inside the 'iasi_fs.GapexdCoeff.h5' file, which are P, C and CH.
     P: is the IASI gap channel prediction coefficients (2060 in col * 8461 in row) 
     C: is the constant of the IASI SW gap channels (2060)
     CH: has 1 values which is 2060 representing the number of gap channels in SW [2760.625~3275.0] spectral regions respectively. 
  It has to be noted that this is an preliminary coefficient file which are supposed only to be used under clearsky, ocean only and nighttime.
  To uncompress the IASI spectral gap filling coefficients, please make sure all the following files are in the same directory:
        iasi_fs.GapexdCoeff.zip (uncompress this file),
        iasi_fs.GapexdCoeff.z01
        iasi_fs.GapexdCoeff.z02
        iasi_fs.GapexdCoeff.z03
