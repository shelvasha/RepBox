#!/bin/bash

cd $REPBOX_PREFIX
rm -rf consensus_out
mkdir consensus_out
cd consensus_out

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')

### Commented out due to HelitronScanner errors. If successfully implemented, add $HELSCAN to FASTAARRAY below.
# HELSCAN=$(ls $REPBOX_PREFIX/helitronscanner_out/helitronscanner_out*)
# GRF=$REPBOX_PREFIX/grf_out/mite.fasta 2>/dev/null

SINSCN=$(ls $REPBOX_PREFIX/sinescan_out/*-sinescan.fasta) 2>/dev/null
MITET=$(ls $REPBOX_PREFIX/mitetracker_out/*/all.{fas,fna,fa,fasta} 2>/dev/null) 2>/dev/null
MITEF=$(ls $REPBOX_PREFIX/mitefinder_out/$INDEXNAME.mite_finder.out) 2>/dev/null
FASTAARRAY=("$MITEF" "$SINSCN" "$MITET")

# Make an index with the reference genome
bowtie2-build -f $GENOME $INDEXNAME 2>/dev/null

for i in "${FASTAARRAY[@]}"
do
   :
   FASTA=$i
   OUT=$FASTA
   # Align Fasta reads to reference
   bowtie2 -f -x $INDEXNAME -U $FASTA -S $OUT.sam

   # Convert SAM to BAM
   samtools view -bS $OUT.sam > $OUT.bam

   # BAM to BED
   bedtools bamtobed -i $OUT.bam > $OUT.bed 2>/dev/null
   awk '! a[$1" "$2]++' $OUT.bed > $OUT.rmdup.bed

   # BED to GFF3
<<<<<<< HEAD
   $REPBOX_PREFIX/bin/gffread/gffread $OUT.rmdup.bed > $OUT.gff3 2>/dev/null
=======
   $REPBOX_PREFIX/bin/gffread/gffread $OUT.rmdup.bed > $OUT.gff3

   # rm *.bed
   # rm *.bam
   # rm *.sam

>>>>>>> master
done

###HELSCANGFF=$(ls $REPBOX_PREFIX/helitronscanner_out/*.gff3.)
###GRFGFF=$(ls $REPBOX_PREFIX/grf_out/mite*.gff3)
#REPGFF=$(ls $REPBOX_PREFIX/repeatmasker_out/*fa.out.gff) 2>/dev/null

SINEGFF=$(ls $REPBOX_PREFIX/sinescan_out/*.gff3) 2>/dev/null
MITEFGFF=$(ls $REPBOX_PREFIX/mitefinder_out/*.gff3) 2>/dev/null
EAHELGFF=$(ls $REPBOX_PREFIX/eahelitron_out/*.gff3) 2>/dev/null
MITEGFF=$(ls $REPBOX_PREFIX/mitetracker_out/*/all.gff3) 2>/dev/null

## Generation of consensus annotation
echo "Generating consensus GTF..."
$REPBOX_PREFIX/bin/gffcompare/gffcompare $EAHELGFF $MITEGFF $SINEGFF $MITEFGFF -D -T  2>/dev/null

## Generation of consensus FASTA
CONSGFF=$REPBOX_PREFIX/consensus_out/gffcmp.combined.gtf
echo "Generating consensus FASTA..."
sleep 3

$REPBOX_PREFIX/bin/gffread/gffread -w consensus_out.fa -g $GENOME $CONSGFF
sleep 3
echo "Consensus complete..."
