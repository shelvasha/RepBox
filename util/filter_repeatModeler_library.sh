#!/bin/bash

# Protocol Filter RepeatModeler Library - © Copyright 2016, Blaxter Lab, University of Edinburgh. Revision 3d81c050.
# BLASTN - Removal of protein coding sequences that are not TEs by BLASTing library of known TE proteins ($PROT) to classified consensus TE fasta (final.nr.consensus_edit.fa.classified)
# This step is recommended if you have an annotated genome

cd $HOMEBREW_PREFIX/Cellar/repeatmasker/*/libexec/Libraries/
PROT=$REPBOX_PREFIX/Oryza_sativa.IRGSP-1.0.cds.all.fa
FASTA=$REPBOX_PREFIX/consensus_out/final.nr.consensus_edit.fa.classified
export BLASTDB=$BLASTDB:$HOMEBREW_PREFIX/Cellar/repeatmasker/*/libexec/Libraries/
blastp -query $PROT -db $HOMEBREW_PREFIX/Cellar/repeatmasker/*/libexec/Libraries/RepeatPeps.lib -outfmt '6 qseqid staxids bitscore std sscinames sskingdoms stitle' -max_target_seqs 25 -culling_limit 2 -num_threads $THREAD -evalue 1e-5 -out proteins.fa.vs.RepeatPeps.25cul2.1e5.blastp.out
perl $REPBOX_PREFIX/util/fastaqual_select.pl -f transcripts.fa -e <(awk '{print $1}' proteins.fa.vs.RepeatPeps.25cul2.1e5.blastp.out | sort | uniq) > transcripts.no_tes.fa
makeblastdb -in transcripts.no_tes.fa -dbtype nucl
blastn -task megablast -query $FASTA -db transcripts.no_tes.fa -outfmt '6 qseqid staxids bitscore std sscinames sskingdoms stitle' -max_target_seqs 25 -culling_limit 2 -num_threads 48 -evalue 1e-10 -out repeatmodeler_lib.vs.transcripts.no_tes.25cul2.1e10.megablast.out
perl $REPBOX_PREFIX/util/fastaqual_select.pl -f $FASTA -e <(awk '{print $1}' repeatmodeler_lib.vs.transcripts.no_tes.25cul2.1e25.megablast.out | sort | uniq) > $FASTA.fa.classified.filtered_for_CDS_repeats.fa
