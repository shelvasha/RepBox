#!/bin/bash
#title           :classify.sh
#description     :This script will cluster classified fasta file(s) output from RepeatModeler, MITEFinder, HelitronScanner and Sine_scan.
#author		 :Shelvasha Burkes-Patton
#date            :07/01/2020
#version         :1.0
#notes           :Run install.sh prior to using this script.
###### Questions and Issues Please See: https://github.com/shelvasha/repbox ######
#==============================================================================

echo "Clustering and classifying repeats ..."
cd $REPBOX_PREFIX

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
rm -rf consensus_out 2>/dev/null
mkdir consensus_out
cd $REPBOX_PREFIX/consensus_out
DIRECTORY=$(pwd)

LIBRARY1=$REPBOX_PREFIX/repeatmodeler_out/RM*/consensi.fa.classified
LIBRARY2=$REPBOX_PREFIX/sinescan_out/*.sine.fa.clean
LIBRARY3=$REPBOX_PREFIX/mitefinder_out/*.mite_finder.out.clean
LIBRARY4=$REPBOX_PREFIX/helitronscanner_out/*.hel.fa.clean

## Concatenation of all classified fasta(s) into one fasta.
cat $LIBRARY1 $LIBRARY2 $LIBRARY3 $LIBRARY4 > merged-library.fa

### Clustering - Classified repeats are merged into single
## Consensus fasta based on >=80% similarity of sequences
vsearch -sortbylength merged-library.fa --output merged-library.sorted.fa --log vsearch.log
vsearch -cluster_fast merged-library.sorted.fa --id 0.80 --centroids my_centroids.fa --uc result.uc -consout final.nr.consensus.fa -msaout aligned.fasta --log vsearch2.log
sed 's/centroid=*//' final.nr.consensus.fa | sed  's/;seqs=[0-9]*$//' > final.nr.consensus_edit.fa

### Classification of consensus fasta
FASTA=$REPBOX_PREFIX/consensus_out/final.nr.consensus_edit.fa
perl $HOMEBREW_PREFIX/opt/repeatmodeler/RepeatClassifier -consensi $FASTA -engine ncbi -pa $THREAD
FASTA=$REPBOX_PREFIX/consensus_out/final.nr.consensus_edit.fa.classified

### BLASTN - Removal of protein coding sequences that are not TEs by BLASTing library of known TE proteins ($PROT) to classified consensus TE fasta (final.nr.consensus_edit.fa.classified)
## This step is recommended if you have an annotated genome
#PROT=$REPBOX_PREFIX/sequence.fasta
#FASTA=$REPBOX_PREFIX/consensus_out/final.nr.consensus_edit.fa.classified
#export BLASTDB=$BLASTDB:$HOMEBREW_PREFIX/Cellar/repeatmasker/*/libexec/Libraries/
#blastp -query $PROT -db $HOMEBREW_PREFIX/Cellar/repeatmasker/*/libexec/Libraries/RepeatPeps.lib -outfmt '6 qseqid staxids bitscore std sscinames sskingdoms stitle' -max_target_seqs 25 -culling_limit 2 -num_threads $THREAD -evalue 1e-5 -out proteins.fa.vs.RepeatPeps.25cul2.1e5.blastp.out
#sleep 2
#perl $REPBOX_PREFIX/util/fastaqual_select.pl -f $FASTA -e <(awk '{print $1}' proteins.fa.vs.RepeatPeps.25cul2.1e5.blastp.out | sort | uniq) > transcripts.no_tes.fa
#sleep 2
#makeblastdb -in transcripts.no_tes.fa -dbtype nucl
#sleep 2
#blastn -task megablast -query $FASTA -db transcripts.no_tes.fa -outfmt '6 qseqid staxids bitscore std sscinames sskingdoms stitle' -max_target_seqs 25 -culling_limit 2 -num_threads 48 -evalue 1e-10 -out repeatmodeler_lib.vs.transcripts.no_tes.25cul2.1e10.megablast.out
#sleep 2
#perl $REPBOX_PREFIX/util/fastaqual_select.pl -f $FASTA -e <(awk '{print $1}' repeatmodeler_lib.vs.transcripts.no_tes.25cul2.1e10.megablast.out | sort | uniq) > $FASTA.fa.classified.filtered_for_CDS_repeats.fa
#sleep 2

## Runs RepeatMasker
rm -rf RMLAST
mkdir RMLAST

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
OUTPUT=RMLAST/
#LIBRARY=$(ls $REPBOX_PREFIX/consensus_out/*.fa.classified.filtered_for_CDS_repeats.fa)
LIBRARY=$(ls $FASTA)
sleep 3

## RepeatMasker command and parameters
RepeatMasker -e ncbi -pa $THREAD -lib $LIBRARY -gff -dir $OUTPUT -u $GENOME >repeatmask.log 2>repeatmask.log.2
sleep 3

## Creates summary file of .out
cd RMLAST
perl $HOMEBREW_PREFIX/opt/repeatmasker/libexec/util/buildSummary.pl $REPBOX_PREFIX/consensus_out/RMLAST/*.fa.out > Summary-Repbox.txt
sleep 3

perl $HOMEBREW_PREFIX/opt/repeatmasker/libexec/util/buildSummary.pl $REPBOX_PREFIX/repeatmasker_out/*.fa.out > Summary-RepeatMaskerModeler.txt
sleep 3
