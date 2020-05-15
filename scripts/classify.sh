#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
THREAD=$(expr $(sysctl -a | grep machdep.cpu | grep 'thread_count\|core_count'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        THREAD=$(expr $(lscpu | grep 'Thread(s)\|Core(s)\|Socket(s)'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)
fi

if [[ $THREAD -lt 8 ]]; then
    THREAD=4
fi

rm -rf consensus_out
mkdir consensus_out
cd $REPBOX_PREFIX/consensus_out
DIRECTORY=$(pwd)

### Repeat classification using RepeatClassifier for all de novo identified elements
LIBRARY1=$REPBOX_PREFIX/repeatmodeler_out/RM*/consensi.fa.classified
LIBRARY2=$REPBOX_PREFIX/sinescan_out/*.sine.fa.classified
LIBRARY3=$REPBOX_PREFIX/mitefinder_out/*.mite_finder.out.classified
LIBRARY4=$REPBOX_PREFIX/mitetracker_out/*/all.fasta.classified
LIBRARY5=$REPBOX_PREFIX/eahelitron_out/EAHeli_out.fa.classified

cat $LIBRARY1 $LIBRARY3 $LIBRARY4 $LIBRARY5 > merged-library.fa #&

PROT=$REPBOX_PREFIX/sequence.fasta
THREAD=8

## Clustering merged file using VSEARCH
cd $DIRECTORY
vsearch -sortbylength merged-library.fa --output merged-library.sorted.fa --log vsearch.log

## Sequences are clustered into a single fasta based on >=80% sequence similarity using VSEARCH
vsearch -cluster_fast merged-library.sorted.fa --id 0.95 --centroids my_centroids.fa --uc result.uc -consout final.nr.consensus.fa -msaout aligned.fasta --log vsearch2.log
sed 's/centroid=*//' final.nr.consensus.fa | sed  's/;seqs=[0-9]*$//' > final.nr.consensus_edit.fa
FASTA=$REPBOX_PREFIX/consensus_out/final.nr.consensus_edit.fa

### BLASTN: Removal of protein coding sequences that are not TEs
export BLASTDB=$BLASTDB:$HOMEBREW_PREFIX/Cellar/repeatmasker/4.1.0/libexec/Libraries/
blastp -query $PROT -db $HOMEBREW_PREFIX/Cellar/repeatmasker/4.1.0/libexec/Libraries/RepeatPeps.lib -outfmt '6 qseqid staxids bitscore std sscinames sskingdoms stitle' -max_target_seqs 25 -culling_limit 2 -num_threads $THREAD -evalue 1e-5 -out proteins.fa.vs.RepeatPeps.25cul2.1e5.blastp.out
perl $REPBOX_PREFIX/util/fastaqual_select.pl -f $FASTA -e <(awk '{print $1}' proteins.fa.vs.RepeatPeps.25cul2.1e5.blastp.out | sort | uniq) > transcripts.no_tes.fa
makeblastdb -in transcripts.no_tes.fa -dbtype nucl
blastn -task megablast -query $FASTA -db transcripts.no_tes.fa -outfmt '6 qseqid staxids bitscore std sscinames sskingdoms stitle' -max_target_seqs 25 -culling_limit 2 -num_threads 48 -evalue 1e-10 -out repeatmodeller_lib.vs.transcripts.no_tes.25cul2.1e10.megablast.out
perl $REPBOX_PREFIX/util/fastaqual_select.pl -f $FASTA -e <(awk '{print $1}' repeatmodeller_lib.vs.transcripts.no_tes.25cul2.1e25.megablast.out | sort | uniq) > $FASTA.fa.classified.filtered_for_CDS_repeats.fa

## Final run with RepeatMasker
rm -rf RMLAST
mkdir RMLAST

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
OUTPUT=RMLAST/ # echo $OUTPUT
LIBRARY=$(ls $REPBOX_PREFIX/consensus_out/*.fa.classified.filtered_for_CDS_repeats.fa)
NAME2=$(basename $GENOME)
sleep 3

## RepeatMasker command and parameters
RepeatMasker -e rmblast -pa $THREAD -lib $LIBRARY -gff -dir $OUTPUT -u $GENOME #&&
sleep 3

## Create summary file of .out
cd RMLAST
perl $HOMEBREW_PREFIX/opt/repeatmasker/libexec/util/buildSummary.pl $REPBOX_PREFIX/consensus_out/RMLAST/*.fa.out > Summary-Repbox.txt
sleep 3

perl $HOMEBREW_PREFIX/opt/repeatmasker/libexec/util/buildSummary.pl $REPBOX_PREFIX/repeatmasker_out/*.fa.out > Summary-RepeatMaskerModeler.txt
sleep 3
