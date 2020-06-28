#!/bin/bash
#title           :repeatmask.sh
#description     :This script will run RepeatMasker.
#author		 :Shelvasha Burkes-Patton
#date            :07/01/2020
#version         :1.0
#notes           :Run install.sh prior to using this script.
###### Questions and Issues Please See: https://github.com/shelvasha/repbox ######
#==============================================================================

echo "Running RepeatMasker..."

### Computing resource setup
if [[ "$OSTYPE" == "darwin"* ]]; then
THREAD=$(expr $(sysctl -a | grep machdep.cpu | grep 'thread_count\|core_count'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        THREAD=$(expr $(lscpu | grep 'Thread(s)\|Core(s)\|Socket(s)'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)
fi

if [[ $THREAD -lt 8 ]]; then
    THREAD=4
fi

### Directory creation and assignment of variables
cd $REPBOX_PREFIX
LIBRARY=$(ls $DIRECTORY/*.classified)
GENOME=$(ls $HOME/Repbox/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
DIRECTORY=$REPBOX_PREFIX/repeatmodeler_out/RM*

rm -rf repeatmasker_out
mkdir repeatmasker_out
cd repeatmasker_out
OUTPUT=$(pwd)

## Runs RepeatMasker
RepeatMasker -pa $THREAD -e ncbi -lib $LIBRARY -gff -dir $OUTPUT -u $GENOME
