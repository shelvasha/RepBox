#!/bin/bash

## Repeat classification using RepeatClassifier
if [[ "$OSTYPE" == "darwin"* ]]; then
THREAD=$(expr $(sysctl -a | grep machdep.cpu | grep 'thread_count\|core_count'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        THREAD=$(expr $(lscpu | grep 'Thread(s)\|Core(s)\|Socket(s)'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)
fi

if [[ $THREAD -lt 8 ]]; then
    THREAD=4
fi

cd $REPBOX_PREFIX/consensus_out
FASTA="consensus_out.fa"
DIRECTORY=$(pwd)

perl $HOMEBREW_PREFIX/opt/repeatmodeler/RepeatClassifier -consensi $FASTA -engine ncbi -pa $THREAD

## RepeatClassifier with override
# perl $HOMEBREW_PREFIX/opt/repeatmodeler/RepeatClassifier -rmblast_dir $HOMEBREW_PREFIX/opt/rmblast/bin -repeatmasker_dir $HOMEBREW_PREFIX/opt/repeatmasker/libexec -consensi $FASTA -engine ncbi &
# From this we have a classified .fa for RepeatModeler, the de novo consensus and TransposonPSI
# From here we need to concatenate all libraries, followed by clustering using VSEARCH:

# Format files to single-line
LIBRARY="$REPBOX_PREFIX/consensus_out/consensus_out.fa.classified"
NAME=$(basename $LIBRARY)

# RepeatModeler Output
LIBRARY1="$REPBOX_PREFIX/repeatmodeler_out/RM*/consensi.fa.classified"

# De novo Consensus
LIBRARY2="$REPBOX_PREFIX/consensus_out/consensus_out.fa.classified"
cat $LIBRARY1 $LIBRARY2 > merged-library.fa #&

## Clustering merged file using VSEARCH
cd $DIRECTORY
vsearch -sortbylength merged-library.fa --output merged-library.sorted.fa --log vsearch.log

## Sequences are clustered into a single fasta based on >=70% sequence similarity using VSEARCH
vsearch -cluster_fast merged-library.sorted.fa --id 0.70 --centroids my_centroids.fa --uc result.uc -consout final.nr.consensus.fa -msaout aligned.fasta --log vsearch2.log

sed 's/centroid=*//' final.nr.consensus.fa | sed  's/;seqs=[0-9]*$//' > final.nr.consensus_edit.fa

## Final run with RepeatMasker
mkdir RMLAST

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
OUTPUT=RMLAST/ # echo $OUTPUT
LIBRARY=$(ls $REPBOX_PREFIX/consensus_out/final.nr.consensus_edit.fa)
NAME2=$(basename $GENOME)
sleep 3

## RepeatMasker command and parameters
RepeatMasker -e rmblast -pa $THREAD -lib $LIBRARY -gff -dir $OUTPUT -u $GENOME #&&
sleep 3

## Create summary file of .out
perl $HOMEBREW_PREFIX/opt/repeatmasker/libexec/util/buildSummary.pl RMLASt/*.fa.out > Summary-Repbox.txt
sleep 3

perl $HOMEBREW_PREFIX/opt/repeatmasker/libexec/util/buildSummary.pl $REPBOX_PREFIX/repeatmasker_out/*.fa.out > Summary-RepeatMaskerModeler.txt
sleep 3
