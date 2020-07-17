#!/bin/bash
#title           :helitronscanner.sh
#description     :This script will run HelitronScanner.
#author		 :Shelvasha Burkes-Patton
#date            :07/01/2020
#version         :1.0
#notes           :Run install.sh prior to using this script.
###### Questions and Issues Please See: https://github.com/shelvasha/repbox ######
#==============================================================================echo "Running HelitronScanner..."

echo "Running HelitronScanner..."

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
GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')

rm -rf helitronscanner_out
mkdir helitronscanner_out
cd helitronscanner_out

### Running HelitronScanner - (1)scanHead, (2)scanTail, (3) pairends, (4) draw Fasta output
HelitronScanner="java -jar $REPBOX_PREFIX/bin/HelitronScanner/HelitronScanner.jar"

## Identify upstream helitron sequences based on homology to trained helitron flanking regions.
$HelitronScanner scanHead -lf $REPBOX_PREFIX/bin/HelitronScanner/TrainingSet/head.lcvs -g $GENOME -bs 0 -o $INDEXNAME.head -tl $THREAD

## Identify downstream helitron sequences based on homology to trained helitron flanking regions.
$HelitronScanner scanTail -lf $REPBOX_PREFIX/bin/HelitronScanner/TrainingSet/tail.lcvs -g $GENOME -bs 0 -o $INDEXNAME.tail -tl $THREAD

## Pairs helitron ends
$HelitronScanner pairends -hs $INDEXNAME.head -ts $INDEXNAME.tail -hlr 200:20000 -o $INDEXNAME.paired -lcv_filepath paired.log

## Create the fasta sequences for each helitrons
$HelitronScanner draw -p $INDEXNAME.paired -g $GENOME -o helitronscanner_out.$INDEXNAME -pure_helitron

### Fasta output cleanup and classification
#python3 $REPBOX_PREFIX/util/HSheader.py $REPBOX_PREFIX/helitronscanner_out/helitronscanner_out.$INDEXNAME.hel.fa
#FASTA=$REPBOX_PREFIX/helitronscanner_out/*hel.fa.clean

python $REPBOX_PREFIX/util/helitron_scanner_out_to_tabout.py helitronscanner_out.$INDEXNAME.hel.fa helitronscanner_out.$INDEXNAME.hel.gff3 > helitronscanner_out.$INDEXNAME.hel.gff3
#perl $HOMEBREW_PREFIX/opt/repeatmodeler/RepeatClassifier -consensi $FASTA -engine ncbi -pa $THREAD
