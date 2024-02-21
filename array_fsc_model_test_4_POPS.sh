#!/bin/bash -l
#$ -l h_rt=48:0:0
#$ -l mem=64G
#$ -pe smp 1
#$ -t 25
#$ -l tmpfs=15G
#$ -N ARRAY_FSC
#$ -cwd

MODELNAME="FMS_MIG_N_ANC_032"
BASEDIR="home/username/Scratch/fsc_directory/4_POPS_FSC/$MODELNAME"
INPUTSUFFIX="MSFS"
FASTSIMCOAL="fsc28"
NSIMS=100000
NLOOPS=40
NBATCHES=1
NTHREADS=1

#You will need to change BASEDIR to the the directory for your fastsimcoal2 project. The MODELNAME is the prefix for your .tpl, .est and .obs file. The '-t' refer

cd /$BASEDIR/$MODELNAME"_"$SGE_TASK_ID/ 
./$FASTSIMCOAL -n $NSIMS -m -u -t $MODELNAME.tpl -e $MODELNAME.est -M  -L $NLOOPS -B $NBATCHES -c $NTHREADS -q  --multiSFS
