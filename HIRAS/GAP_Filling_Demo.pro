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

;$$ Main code for HIRAS gap filling (Run):
; Hui Xu  (huixu@umd.edu)
; 02/28/2018
pro GAP_Filling_Demo
; 2. HIRAS 
do_gap_filling = 1
if do_gap_filling then begin 
; 2a.
  ; HIRAS gap prediction COEFFICIENT DATASET NAME
  coef_file = 'C:\Users\Administrator\Desktop\hiras.GapCoeff.h5'
  gap_coef_name = ['P0','C0', 'GAP_NUM']
  ; read gap prediction coefficients
  extract_h5_ds_by_name, coef_file, gap_coef_name[0], P
  extract_h5_ds_by_name, coef_file, gap_coef_name[1], C
  extract_h5_ds_by_name, coef_file, gap_coef_name[2], CH_N
; 2b. 
  ; HIRAS DATASET NAME
  hiras_sdr_file = 'D:\20180305\FY3D_HIRAS_GBAL_L1_20180305_1035_016KM_MS.HDF'
  sdr_ds_name = ['Data/ES_RealLW', $
    'Data/ES_RealMW1', $
    'Data/ES_RealMW2']
  ; read hiras radiance data
  extract_h5_ds_by_name, hiras_sdr_file, sdr_ds_name[0], hiras_lw
  extract_h5_ds_by_name, hiras_sdr_file, sdr_ds_name[1], hiras_mw
  extract_h5_ds_by_name, hiras_sdr_file, sdr_ds_name[2], hiras_sw
  ; add hamming apodization
  ; and reform the dataset from [nDIM, nFOV, nFOR, nScan] to [nDIM, nFOV*nFOR*nScan] 
  hiras_lw = spec_hamming_apod(hiras_lw, 0.54)
  hiras_mw = spec_hamming_apod(hiras_mw, 0.54)
  hiras_sw = spec_hamming_apod(hiras_sw, 0.54)
  ; merge the three measured bands together
  hiras_rad = [hiras_lw, hiras_mw, hiras_sw]
; 2c.
  ; calculate the gap channel radiances
  sif = size(hiras_rad, /dimension)
  ndata = sif[1]
  C = rebin(C, n_elements(C), ndata)
  hiras_gap_rad = hiras_rad ## P
  hiras_gap_rad += C
; 2d. 
  ; combine to the full HIRAS (3369 channels from 650 to 2755)
  hiras_full_rad = [hiras_lw, $ 
                      hiras_gap_rad[0:CH_N[0]-1, *], $   ; gap in lw
                   hiras_mw, $
                      hiras_gap_rad[CH_N[0]:(CH_N[0]+CH_N[1]-1), *], $   ; gap in mw
                   hiras_sw, $
                      hiras_gap_rad[(CH_N[0]+CH_N[1]):(CH_N[0]+CH_N[1]+CH_N[2]-1), *]]  ; gap in sw
; 2e. Plot
  sif = size(hiras_full_rad, /dimensions) & ndim = sif[0]
  wn = 650.0 + findgen(ndim) * 0.625
  plot, wn, hiras_full_rad[*, 1]
  
  ; release unused variables
  hiras_lw = size(temporary(hiras_lw),/n_elements)
  hiras_mw = size(temporary(hiras_mw),/n_elements)
  hiras_sw = size(temporary(hiras_sw),/n_elements)
  hiras_rad = size(temporary(hiras_rad),/n_elements)
  hiras_gap_rad = size(temporary(hiras_gap_rad),/n_elements)
  P = size(temporary(P),/n_elements)
  C = size(temporary(C),/n_elements)
  CH= size(temporary(CH),/n_elements)
endif


end