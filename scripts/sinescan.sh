#!/bin/bash
echo "Running SineFinder..."

cd $REPBOX_PREFIX/

if [[ "$OSTYPE" == "darwin"* ]]; then
THREAD=$(expr $(sysctl -a | grep machdep.cpu | grep 'thread_count\|core_count'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        THREAD=$(expr $(lscpu | grep 'Thread(s)\|Core(s)\|Socket(s)'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)
fi

if [[ $THREAD -le 8 ]]; then
    THREAD=4
fi

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')
FASTA=$(basename $GENOME)

rm -rf sinescan_out
mkdir sinescan_out
cd sinescan_out

DIRECTORY=$(pwd)

# An example : perl SINE_Scan_process.pl -g genome_file(fasta) -d workdir -s 123 -o species_name;
cd $REPBOX_PREFIX/bin/SINE_Scan-v1*/
THREAD=8
perl SINE_Scan_process.pl -g $GENOME -d $DIRECTORY -o $INDEXNAME -s 123 -k $THREAD

cd $REPBOX_PREFIX/sinescan_out

python3 $REPBOX_PREFIX/util/Sheader.py $REPBOX_PREFIX/sinescan_out/*.sine.fa
FASTA=$REPBOX_PREFIX/sinescan_out/*.sine.fa.clean
perl $HOMEBREW_PREFIX/opt/repeatmodeler/RepeatClassifier -consensi $FASTA -engine ncbi -pa $THREAD
