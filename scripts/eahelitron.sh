#!/bin/bash
echo "Running EAHelitron..."
if [[ "$OSTYPE" == "darwin"* ]]; then
THREAD=$(expr $(sysctl -a | grep machdep.cpu | grep 'thread_count\|core_count'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        THREAD=$(expr $(lscpu | grep 'Thread(s)\|Core(s)\|Socket(s)'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)
fi

if [[ $THREAD -lt 8 ]]; then
    THREAD=4
fi

cd $REPBOX_PREFIX/
rm -rf eahelitron_out
mkdir eahelitron_out
cd eahelitron_out

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')
DIRECTORY=$(pwd)

EAHelitron=$HOME"/Repbox/bin/EAHelitron/EAHelitron"
perl $EAHelitron $GENOME
bedtools getfasta -fi $GENOME -bed EAHeli*.bed -name > EAHeli_out.fa
FASTA=$REPBOX_PREFIX/eahelitron_out/EAHeli_out.fa
perl $HOMEBREW_PREFIX/opt/repeatmodeler/RepeatClassifier -consensi $FASTA -engine ncbi -pa $THREAD
