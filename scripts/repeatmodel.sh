#!/bin/bash
#title           :repeatmodel.sh
#description     :This script will run build a custom repeat library using and RepeatModeler.
#author		 :Shelvasha Burkes-Patton
#date            :07/01/2020
#version         :1.0
#notes           :Run install.sh prior to using this script.
###### Questions and Issues Please See: https://github.com/shelvasha/repbox ######
#==============================================================================

echo "Running RepeatModeler..."

### Computing resource setup
if [[ "$OSTYPE" == "darwin"* ]]; then
THREAD=$(expr $(sysctl -a | grep machdep.cpu | grep 'thread_count\|core_count'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        THREAD=$(expr $(lscpu | grep 'Thread(s)\|Core(s)\|Socket(s)'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)
fi

if [[ $THREAD -lt 8 ]]; then
    THREAD=4
fi

### Directory creation and assignment of variables.
cd $REPBOX_PREFIX
GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
DBNAME=$(basename $GENOME | cut -f 1 -d '.')

rm -rf repeatmodeler_out
mkdir repeatmodeler_out
cd repeatmodeler_out

## Building repeat database
BuildDatabase -name $DBNAME -engine ncbi $GENOME #>/dev/null

## Compare Fasta squences in Databases to those in ncbi database
## This is a slow step due to the multiple tools that used to form a consensus of repeats
## identified (RECON, RepeatScout, TRF & RMBlast)
RepeatModeler -database $DBNAME -engine ncbi -pa $THREAD -LTRStruct
