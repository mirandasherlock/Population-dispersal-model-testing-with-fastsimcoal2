#!/bin/bash

#SBATCH --job-name="FSC_RUN"
#SBATCH --export=ALL
#SBATCH --partition=short
#SBATCH --mem=8G
#SBATCH --cpus-per-task=64
#SBATCH --output=R-%x.%j.out

MODELNAME="MODELNAME"
NRUNS="10"
BASEDIR="/home/username/fsc_directory/FSC_4_POPS/$MODELNAME"
INPUTSUFFIX="MSFS"
FASTSIMCOAL="fsc28"
NSIMS=10
NLOOPS=2
NBATCHES=64
NTHREADS=64

# You should have a base directory (BASEDIR) per model. Each base directory must include your fastsimcoal executable and your .tpl, .est and .obs files. These must be named MODELNAME.tpl, MODELNAME.est and MODELNAME_SUFFIX.obs

# START

# Make output directories
cd $BASEDIR
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

# run fastsimcoal
echo "Running fastsimcoal"
for i in $(seq 1 $NRUNS); do 
cd /$BASEDIR/$MODELNAME"_"$i/ 
# Edit line below for additional options
./$FASTSIMCOAL -n $NSIMS -m -u -t $MODELNAME.tpl -e $MODELNAME.est -M  -L $NLOOPS -B $NBATCHES -c $NTHREADS -q  --multiSFS
echo "Run $i";
done

echo "done"
# print likelihoods 
echo "Printing likelihoods"
rm -f /$BASEDIR/bestlhoods.txt
for i in $(seq 1 $NRUNS); do 
sed -n 2p $BASEDIR/$MODELNAME"_"$i/$MODELNAME/$MODELNAME.bestlhoods >> /$BASEDIR/bestlhoods.txt; 
done
echo "done"
# add row numbers to best likelihoods file (YOU MUST CHANGE FOR YOUR NUMBER OF POPS)

cat -n /$BASEDIR/bestlhoods.txt > /$BASEDIR/bestlhoods_numbered.txt
echo "RUN	NPOP0	NPOP1	NPOP2	NANC	TDIV_POP02	TDIV_POP12	MaxEstLhood	MaxObsLhood"| cat - /$BASEDIR/bestlhoods_numbered.txt  > /$BASEDIR/bestlhoods_titled.txt
rm -f /$BASEDIR/bestlhoods.txt
rm -f /$BASEDIR/bestlhoods_numbered.txt

# calculate difference in likelihoods

awk 'NR == 1 {$12 ="Difference"} NR >= 2{$12 = $11-$10}1' /$BASEDIR/bestlhoods_titled.txt > /$BASEDIR/bestlhoods_diff_$MODELNAME.txt
rm -f /$BASEDIR/bestlhoods_titled.txt

# finds best model
echo "Finding best run"
sed 1d /$BASEDIR/bestlhoods_diff_$MODELNAME.txt > /$BASEDIR/bestlhoods_diff_no_header.txt
sort -nk12 /$BASEDIR/bestlhoods_diff_no_header.txt | head -1 > /$BASEDIR/bestrun_no_header.txt
echo "RUN	NPOP0     NPOP1   NPOP2  NPOP3  NANC    TDIV_POP02      TDIV_POP12   TDIV_POP23   MaxEstLhood     MaxObsLhood	DIFF"| cat - /$BASEDIR/bestrun_no_header.txt  > /$BASEDIR/bestrun_$MODELNAME.txt
rm -f /$BASEDIR/bestlhoods_diff_no_header.txt
rm -f /$BASEDIR/bestrun_no_header.txt
echo "done!"
