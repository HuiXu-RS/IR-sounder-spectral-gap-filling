;===============================================================
; CREATION HISTORY:
;       Written by:     huixu, Nov.16 2016
; Purpose: extracts dataset from HDF5
; input:
;       h5_file: path of the hdf5 file
;       ds_name: dataset name need to be read
; output:
;       ds: dataset retrieved from a hdf5 file
;===============================================================
pro extract_h5_ds_by_name, h5_file, ds_name, ds
  h5_id = h5f_open(h5_file)
  tokens = strsplit(ds_name,'/', /extract,/preserve_null, count=ntokens)
  loc = h5_id & groups = lonarr(ntokens)
  for i = 0L, ntokens-2 do begin
    loc = h5g_open(loc,tokens[i])
    groups[i] = loc
  endfor

  ds_id = h5d_open(loc,tokens[ntokens-1])
  ds = h5d_read(ds_id)
  h5d_close,ds_id

  for i = ntokens-2, 0, -1 do begin
    loc = groups[i]
    h5g_close,loc
  endfor

  h5f_close,h5_id
end
;===============================================================
; CREATION HISTORY:
;       Written by:     huixu, Nov.16 2016
; Purpose: add hamming apodization in spectrum domin
; input:
;       spectrum: spectrum
;       a: apodization value (a = 0.54 for cris)
; output:
;       spectrum with hamming apodization
;===============================================================
function spec_hamming_apod, spectrum, a, orginaldim=orginaldim
  ; apod
  w0=(1.0-a)*0.5 ; 0.23
  w1=a           ; 0.54
  w2=(1.0-a)*0.5 ; 0.23

  ; add apod - hamming
  diminfo = size(spectrum,/dimension)
  ndim = n_elements(diminfo)
  if ndim eq 1 then begin
    n = n_elements(spectrum)
    spec_apod = w0 * spectrum[1:n-4] + w1 * spectrum[2:n-3] + w2 * spectrum[3:n-2]
  endif else begin
    l= 1l
    for i = 1, ndim-1 do begin
      l*=diminfo[i]
    endfor
    n = diminfo[0]
    spectrum = reform(spectrum, n, l)
    spec_apod = w0 * spectrum[1:n-4,0:l-1] + w1 * spectrum[2:n-3,0:l-1] + w2 * spectrum[3:n-2,0:l-1]
    if keyword_set(orginaldim) then begin
      diminfo[0]-=4
      spec_apod = reform(spec_apod, diminfo)
    endif
  endelse

  ; return, apod
  return, spec_apod
end

;$$ Main code for CrIS gap filling (Run):
; Hui Xu  (huixu@umd.edu)
; 02/28/2018

; 1. CrIS 
do_gap_filling = 1
if do_gap_filling then begin 
; 1a.
  ; CrIS gap prediction COEFFICIENT DATASET NAME
  coef_file = './cris_fs.GapCoeff.h5'
  gap_coef_name = ['P0','C0', 'GAP_NUM']
  ; read gap prediction coefficients
  extract_h5_ds_by_name, coef_file, gap_coef_name[0], P
  extract_h5_ds_by_name, coef_file, gap_coef_name[1], C
  extract_h5_ds_by_name, coef_file, gap_coef_name[2], CH_N
; 1b. 
  ; CrIS FS DATASET NAME
  cris_sdr_file = './SCRIF_npp_d20170805_t0757519_e0758217_b29906_c20170805090427634658_nobc_ops.h5'
  sdr_ds_name = ['All_Data/CrIS-FS-SDR_All/ES_RealLW', $
    'All_Data/CrIS-FS-SDR_All/ES_RealMW', $
    'All_Data/CrIS-FS-SDR_All/ES_RealSW']
  ; read cris radiance data
  extract_h5_ds_by_name, cris_sdr_file, sdr_ds_name[0], cris_lw
  extract_h5_ds_by_name, cris_sdr_file, sdr_ds_name[1], cris_mw
  extract_h5_ds_by_name, cris_sdr_file, sdr_ds_name[2], cris_sw
  ; add hamming apodization
  ; and reform the dataset from [nDIM, nFOV, nFOR, nScan] to [nDIM, nFOV*nFOR*nScan] 
  cris_lw = spec_hamming_apod(cris_lw, 0.54)
  cris_mw = spec_hamming_apod(cris_mw, 0.54)
  cris_sw = spec_hamming_apod(cris_sw, 0.54)
  ; merge the three measured bands together
  cris_rad = [cris_lw, cris_mw, cris_sw]
; 1c.
  ; calculate the gap channel radiances
  sif = size(cris_rad, /dimension)
  ndata = sif[1]
  C = rebin(C, n_elements(C), ndata)
  cris_gap_rad = cris_rad ## P
  cris_gap_rad += C
; 1d. 
  ; combine to the full CrIS (3369 channels from 650 to 2755)
  cris_full_rad = [cris_lw, $ 
                      cris_gap_rad[0:CH_N[0]-1, *], $   ; gap in lw
                   cris_mw, $
                      cris_gap_rad[CH_N[0]:(CH_N[0]+CH_N[1]-1), *], $   ; gap in mw
                   cris_sw, $
                      cris_gap_rad[(CH_N[0]+CH_N[1]):(CH_N[0]+CH_N[1]+CH_N[2]-1), *]]  ; gap in sw
; 1e. Plot
  sif = size(cris_full_rad, /dimensions) & ndim = sif[0]
  ; calculate the wavenumber of the FULL-CrIS
  wn = 650.0 + findgen(ndim) * 0.625
  ; plot the first Full-CrIS spectrum of the granule
  plot, wn, cris_full_rad[*, 0], $
    xtitle='wave number', $
    ytitle='Radiance (mW/m2/sr/cm-1)'
  
  ; release unused variables
  cris_lw = size(temporary(cris_lw),/n_elements)
  cris_mw = size(temporary(cris_mw),/n_elements)
  cris_sw = size(temporary(cris_sw),/n_elements)
  cris_rad = size(temporary(cris_rad),/n_elements)
  cris_gap_rad = size(temporary(cris_gap_rad),/n_elements)
  P = size(temporary(P),/n_elements)
  C = size(temporary(C),/n_elements)
  CH= size(temporary(CH),/n_elements)
endif

end