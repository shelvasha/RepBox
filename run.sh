#!/bin/bash

cd $REPBOX_PREFIX

PATH=$PATH$(find $REPBOX_PREFIX/bin -type d -exec echo ":{}" \; | tr -d '\n')

$REPBOX_PREFIX/scripts/repeatmodel.sh

pid1=$(pgrep repeatmodel.sh)
while [ -d /proc/$pid1 ] ; do
    sleep 2
done

$REPBOX_PREFIX/scripts/repeatmask.sh

pid2=$(pgrep repeatmask.sh)
while [ -d /proc/$pid2 ] ; do
    sleep 2
done

$REPBOX_PREFIX/scripts/eahelitron.sh &&
$REPBOX_PREFIX/scripts/mitetracker.sh &&
$REPBOX_PREFIX/scripts/sinescan.sh &&
$REPBOX_PREFIX/scripts/mitefinder.sh &&

###$REPBOX_PREFIX/scripts/genericrepeatfinder.sh &&
###$REPBOX_PREFIX/scripts/helitronscanner.sh &&

echo "Consensus now running..."
$REPBOX_PREFIX/scripts/consensus.sh
pid3=$(pgrep consensus.sh)
while [ -d /proc/$pid3 ] ; do
    sleep 2
done

$REPBOX_PREFIX/scripts/classify.sh

## Directory rearrangement
pid3=$(pgrep classify.sh)
while [ -d /proc/$pid3 ] ; do
    sleep 2
done

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')
mkdir results_$INDEXNAME
sleep 2

mv $REPBOX_PREFIX/consensus_out/Summary*.txt results_$INDEXNAME
sleep 2

for folder in $(ls -d *_out)
do
    mv $folder $REPBOX_PREFIX/results_$INDEXNAME;
done;

sleep 2

echo "Repbox Complete."
