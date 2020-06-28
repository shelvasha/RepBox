#!/bin/bash

#title           :run.sh
#description     :This script will run RepeatModeler, RepeatMasker, Sine_scan, HelitronScanner and .
#author		 :Shelvasha Burkes-Patton
#date            :07/01/2020
#version         :1.0
#usage		 :bash run.sh
#notes           :Run install.sh prior to using this script.
###### Questions and Issues Please See: https://github.com/shelvasha/repbox ######
#==============================================================================

cd $REPBOX_PREFIX

PATH=$PATH$(find $REPBOX_PREFIX/bin -type d -exec echo ":{}" \; | tr -d '\n')

$REPBOX_PREFIX/scripts/repeatmodel.sh
pid1=$(pgrep repeatmodel.sh)
while [ -d /proc/$pid1 ] ; do
    sleep 2
done

### Benchmarking RepeatMasker.
## It is redundant to run here, but feel free to uncomment if you desire to run RepeatMasker
## following repeat indentification in RepeatModeler

#$REPBOX_PREFIX/scripts/repeatmask.sh
#pid2=$(pgrep repeatmask.sh)
#while [ -d /proc/$pid2 ] ; do
#    sleep 2
#done

### Run specialized de novo TE detection software
## SINEs - sinescan.sh
## MITEs - mitefinder.sh
## Helitrons - helitronscanner.sh

$REPBOX_PREFIX/scripts/sinescan.sh
$REPBOX_PREFIX/scripts/mitefinder.sh
$REPBOX_PREFIX/scripts/helitronscanner.sh

## Classification of repeat generated from specialized de novo software packages
echo "Classification now running..."
$REPBOX_PREFIX/scripts/classify.sh

### Classify.sh process check
## Loops checking the status of classify.sh bash script.
## Loop will stop when classification is complete and the process check returns FALSE.

pid3=$(pgrep classify.sh)
while [ -d /proc/$pid3 ] ; do
    sleep 2
done

### Directory rearrangement - Moves directories generated from pipeline to
## folder named after target organism.

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')
mkdir results_$INDEXNAME
sleep 2
mv $REPBOX_PREFIX/consensus_out/RMLAST/Summary*.txt results_$INDEXNAME
sleep 2
for folder in $(ls -d *_out)
do
    mv $folder $REPBOX_PREFIX/results_$INDEXNAME;
done

sleep 2
echo "Repbox Complete."
