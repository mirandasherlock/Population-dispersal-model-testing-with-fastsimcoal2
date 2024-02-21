#!/bin/bash -l
#$ -l h_rt=0:5:0
#$ -l mem=8G
#$ -pe smp 1
#$ -l tmpfs=10G
#$ -N I_N_ANC_032
#$ -wd /path/to/your/fastsimcoal2/project/4_POPS_FSC

MODELNAME="MNN_MIG_N_ANC_032"
NRUNS="50"
BASEDIR="/home/username/Scratch/fsc_directory/4_POPS_FSC/$MODELNAME"
INPUTSUFFIX="MSFS"
FASTSIMCOAL="fsc28"

# This script will make the directories required for running multiple fastsimcoal2 runs simultaneously using a job array. It will also move the input files and executables required.
# You should have a base directory (BASEDIR) per model. Each base directory must include your fastsimcoal executable and your .tpl, .est and .obs files. These must be named MODELNAME.tpl, MODELNAME.est and MODELNAME_SUFFIX.obs

# START
cd $BASEDIR

# Make output directories

echo "Making output directories"

for i in $(seq 1 $NRUNS); do mkdir -p ./$MODELNAME"_"$i; 
done
echo "done"

# cp input files and fsc executable to directories
 
echo "Moving input files"
for i in $(seq 1 $NRUNS); do cp /$BASEDIR/$FASTSIMCOAL /$BASEDIR/$MODELNAME.tpl /$BASEDIR/$MODELNAME.est /$BASEDIR/$MODELNAME"_"$INPUTSUFFIX.obs /$BASEDIR/$MODELNAME"_"$i/;
done
echo "done"

# check for fsc
if [ -x "$FASTSIMCOAL" ]; 
then
echo "fsc is present"
else
echo "fsc is not present"; exit 1
fi
