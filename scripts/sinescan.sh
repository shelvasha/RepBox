#!/bin/bash
#title           :sinescan.sh
#description     :This script will run Sine_scan.
#author		 :Shelvasha Burkes-Patton
#date            :07/01/2020
#version         :1.0
#notes           :Run install.sh prior to using this script.
###### Questions and Issues Please See: https://github.com/shelvasha/repbox ######
#==============================================================================

echo "Running Sine_Scan..."

### Computing resource setup
if [[ "$OSTYPE" == "darwin"* ]]; then
THREAD=$(expr $(sysctl -a | grep machdep.cpu | grep 'thread_count\|core_count'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        THREAD=$(expr $(lscpu | grep 'Thread(s)\|Core(s)\|Socket(s)'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)
fi

if [[ $THREAD -le 8 ]]; then
    THREAD=4
fi

### Directory creation and assignment of variables.
cd $REPBOX_PREFIX/
GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')
FASTA=$(basename $GENOME)

rm -rf sinescan_out
mkdir sinescan_out
cd sinescan_out
DIRECTORY=$(pwd)
cd $REPBOX_PREFIX/bin/SINE_Scan-v1*/

## An example : perl SINE_Scan_process.pl -g genome_file(fasta) -d workdir -s 123 -o species_name;
perl SINE_Scan_process.pl -g $GENOME -d $DIRECTORY -o $INDEXNAME -s 123 -k $THREAD
cd $REPBOX_PREFIX/sinescan_out

### Fasta output cleanup and classification
python3 $REPBOX_PREFIX/util/Sheader.py $REPBOX_PREFIX/sinescan_out/*.sine.fa

#FASTA=$REPBOX_PREFIX/sinescan_out/*.sine.fa.clean
#perl $HOMEBREW_PREFIX/opt/repeatmodeler/RepeatClassifier -consensi $FASTA -engine ncbi -pa $THREAD
