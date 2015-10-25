#!/bin/csh

##########################################################################################################################
## SCRIPT TO CALCULATE SEED-BASED RESTING-STATE FUNCTIONAL CONNECTIVITY
##
## This script can be run on its own, by filling in the appropriate parameters
## Alternatively this script gets called from batch_process.sh, where you can use it to run N sites, one after the other.
##
## Written by Clare Kelly, Maarten Mennes & Michael Milham
## for more information see www.nitrc.org/projects/fcon_1000
##
##########################################################################################################################


set study = COC
set visit = visit1
## full/path/to/subject_list.txt containing subjects you want to run
#set subject_list = (003 005 006 008 009 010 011 013 014 015 016 017 018 019 020 022 023 024 025)
#set subject_list = ( 024 025)

set subject_list = (012)

# FALTOU O 015!!!!



## image to extract timeseries from. default = rest_res.nii.gz


#set postprocessing_image = RST2_res2standard


## file containing list with full/path/to/seed.nii.gz
set seed_list = ( dACC )


set seed_loc = `pwd`

## standard brain as reference for registration
#set standard_whole = /media/DATA/IDEAL_BRAINS/nihpd_asym_04.5-18.5_t1w.3x3x3.nii.gz

## directory setup
## see below

## analysisdirectory
cd ..
set ddir = `pwd`

##########################################################################################################################
##---START OF SCRIPT----------------------------------------------------------------------------------------------------##
##########################################################################################################################



## Get subjects to run
foreach subj ($subject_list)

  ## directory setup
  set func_dir = ${ddir}/${study}${subj}/${visit}/PROC.RST.NL
 # set reg_dir = ${ddir}/${study}${subj}/REG2
  ## seed_timeseries
  set seed_ts_dir = ${ddir}/${study}${subj}/${visit}/PROC.RST.NL/seed_ts
  ## RSFC maps
  set RSFC_dir = ${ddir}/${study}${subj}/${visit}/PROC.RST.NL/RSFC

#echo ${seed_ts_dir}

  echo --------------------------
  echo running subject ${subj}
  echo --------------------------

  mkdir -p ${seed_ts_dir}
  mkdir -p ${RSFC_dir}


  ## Get seeds to run
  foreach seed ( $seed_list )

    set seed_file = ${seed_loc}/ROI_${seed}.nii.gz
    echo -------------------------
    echo running seed ${seed}
    echo -------------------------

    ## 1. Extract Timeseries
    echo Extracting timeseries for seed ${seed}
    3dROIstats -quiet -mask_f2short -mask ${seed_file} ${func_dir}/errts.${study}${subj}.tproject+tlrc > ${seed_ts_dir}/${seed}.1D


    ## 2. Compute voxel-wise correlation with Seed Timeseries		
    echo Computing Correlation for seed ${seed}
    3dfim+ -input ${func_dir}/errts.${study}${subj}.tproject+tlrc -ideal_file ${seed_ts_dir}/${seed}.1D -out Correlation \
    -bucket ${RSFC_dir}/${seed}_corr

    ## 3. Z-transform correlations		
    echo Z-transforming correlations for seed ${seed}
    3dcalc -a ${RSFC_dir}/${seed}_corr+tlrc -expr 'log((a+1)/(a-1))/2' -prefix ${RSFC_dir}/${seed}_Z

#    cd ${RSFC_dir}
#    3dcopy ${seed}_Z.nii.gz ${seed}_Z_float


  ## END OF SEED LOOP
  end

## END OF SUBJECT LOOP
end



