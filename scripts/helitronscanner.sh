#!/bin/bash
echo "Running HelitronScanner..."

cd $REPBOX_PREFIX
rm -rf helitronscanner_out
mkdir helitronscanner_out
cd helitronscanner_out

if [[ "$OSTYPE" == "darwin"* ]]; then
THREAD=$(expr $(sysctl -a | grep machdep.cpu | grep 'thread_count\|core_count'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        THREAD=$(expr $(lscpu | grep 'Thread(s)\|Core(s)\|Socket(s)'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)
fi

if [[ $THREAD -lt 8 ]]; then
    THREAD=4
fi

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')

HelitronScanner="java -jar $REPBOX_PREFIX/bin/HelitronScanner/HelitronScanner.jar"

# Identify 5’ and 3’ heltron sequences based on homology to known.
$HelitronScanner scanHead -lf $REPBOX_PREFIX/bin/HelitronScanner/TrainingSet/head.lcvs -g $GENOME -bs 0 -o $INDEXNAME.head -tl $THREAD
$HelitronScanner scanTail -lf $REPBOX_PREFIX/bin/HelitronScanner/TrainingSet/tail.lcvs -g $GENOME -bs 0 -o $INDEXNAME.tail -tl $THREAD

# Pair the helitron ends
$HelitronScanner pairends -hs $INDEXNAME.head -ts $INDEXNAME.tail -hlr 200:20000 -o $INDEXNAME.paired -lcv_filepath paired.log

# Create the fasta sequences for each helitrons
$HelitronScanner draw -p $INDEXNAME.paired -g $GENOME -o helitronscanner_out.$INDEXNAME -pure_helitron
