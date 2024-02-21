#!/bin/bash -l
#$ -l h_rt=0:1:0
#$ -l mem=8G
#$ -pe smp 1
#$ -l tmpfs=15G
#$ -N ARRAY_OUTPUT_RANKED
#$ -wd /home/username/Scratch/fsc_directory/4_POPS_FSC

MODELNAME="MODELNAME"
BASEDIR="/home/usernane/Scratch/fsc_directory/4_POPS_FSC/$MODELNAME"
NRUNS="50"

# Here your BASEDIR is the directory of the model that you want to rank the results from each run for. 

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

awk 'NR == 1 {$14 ="Difference"} NR >= 2{$14 = $13-$12}1' /$BASEDIR/bestlhoods_titled.txt > /$BASEDIR/bestlhoods_diff_$MODELNAME.txt
rm -f /$BASEDIR/bestlhoods_titled.txt

# finds best model
echo "Finding best run"
sed 1d /$BASEDIR/bestlhoods_diff_$MODELNAME.txt > /$BASEDIR/bestlhoods_diff_no_header.txt
sort -nk14 /$BASEDIR/bestlhoods_diff_no_header.txt | head -1 > /$BASEDIR/bestrun_no_header.txt

# You will need to adjust this for the free parameters you have in your models. If not, the script should run fine but your headings will be incorrect.
echo "RUN	NPOP0     NPOP1   NPOP2  NPOP3  NANC    TDIV_POP02      TDIV_POP12   TDIV_POP23   MaxEstLhood     MaxObsLhood	DIFF"| cat - /$BASEDIR/bestrun_no_header.txt  > /$BASEDIR/bestrun_$MODELNAME.txt
rm -f /$BASEDIR/bestlhoods_diff_no_header.txt
rm -f /$BASEDIR/bestrun_no_header.txt
echo "done!"
