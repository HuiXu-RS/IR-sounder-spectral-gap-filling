# Satellite-Infrared-Sounder-Spectral-Gap-Filling
The principle component regression based IR sounder spectral gap filling method:

Spectral gaps within the IR sounder measurements impact the accuracy of inter-comparison between IR sounders and other instruments. To fill up the spectral gaps, this project develops a PCR based method to fill up the gap channels.
Currently, the NOAA SNPP/J1 Cross-track Infrared Sounder (CrIS) spectral gaps are filled with principle component regression (PCR) methods. Fundamentally, the atmospheric spectrum is determined by the atmospheric temperature and humidity conditions, trace gas concentration, and land and cloud conditions. The basic assumption of the proposed gap filling method is that the CrIS gap channel information contents have already existed in current measured channels. Using the spectral gap 1095.625 to 1209.375 cm-1 at atmospheric window region as an example, their spectral information is strongly correlated to the CrIS measured spectra from 800 to 1000 cm-1. The same correlation also applies to water vapor regions from 1750.625 to 2154.375 cm-1, which could possibly be predicated by the channels from 1250 to 1750 cm-1. The spectral absorption of some trace gases, such as N2O, CH4, also happens at both the CrIS measured and gap channels. Therefore, the CrIS gap channel’s prediction can be simplified to establish an accurate and reliable relationship between the CrIS measured and gap channels. To fill up the spectral gaps, a training dataset was first built based on the Infrared Atmospheric Sounding Interferometer (IASI) spectra selected from different seasons to represent different atmospheric and surface conditions. The PCR method is then developed to derive the prediction coefficients between the CrlS measured and the gap channel spectra. The derived prediction coefficients are used to fill up the CrIS gap channels from the measured channels. A Full-CrIS spectrum (after the gap was filled) has 3369 channels from 650 to 2755 cm-1 with a interval of 0.625 cm-1, including a total of 1158 gap channels, i.e. 183 channels between the LW and MW bands, 647 channels between the MW and SW bands, and 328 channels extending the SW band to 2755 cm-1. The detailed descriptions are summarized in the attached paper and presentation:

Xu et al. - 2019 - IEEE-TGRS, Cross-Track Infrared Sounder Spectral Gap Filling Toward Improving Intercalibration Uncertainties.pdf 
Xu et al. - 2018 - GSICS, CrIS spectral gap filling - Part I  Methodology.pdf

Particularly, it is now also successfully applied to the FY3D HIRAS instrument which has similar spectral gaps as the CrIS by Na Xu & Hanlie Xu from CMA.

We are now trying to fill up the IASI short wave channels beyond 2760 cm-1, which allows IASI to fully cover some broadband short wave channels when it was used as a standard reference (such as, the SEVIRI channel 3B, ...). Preliminary results can be found in 
 'Xu et al. - 2019 - GSICS, CrIS spectral gap filling - Part II Sensitive test and validation.pdf'. The IASI SW channel gap filling coefficients will be uploaded ASAP. 

The CrIS spectral gap filling coefficients as well as readme and testing code (in IDL) is in CrIS directory.

Update will be made in the future if it is necessary. 
