#!/bin/bash

cd $REPBOX_PREFIX
rm -rf consensus_out
mkdir consensus_out
cd consensus_out

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')

#HELSCAN=$(ls $REPBOX_PREFIX/helitronscanner_out/helitronscanner_out*) -- Commented out due to HelitronScanner errors.
# If successfully implemented, add $HELSCAN to FASTAARRAY below.

GRF=$REPBOX_PREFIX/grf_out/mite.fasta
SINSCN=$(ls $REPBOX_PREFIX/sinescan_out/$INDEXNAME-sinescan.fasta)
MITEF=$(ls $REPBOX_PREFIX/mitefinder_out/$INDEXNAME.mite_finder.out)
FASTAARRAY=("$GRF" "$SINSCN" "$MITEF")

# Make an index with the reference genome
bowtie2-build -f $GENOME $INDEXNAME

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
   bedtools bamtobed -i $OUT.bam > $OUT.bed

   # BED to GFF3
   $REPBOX_PREFIX/bin/gffread/gffread $OUT.bed > $OUT.gff3
done

###HELSCANGFF=$(ls $REPBOX_PREFIX/helitronscanner_out/*.gff3.)
###GRFGFF=$(ls $REPBOX_PREFIX/grf_out/mite*.gff3)

SINEGFF=$(ls $REPBOX_PREFIX/sinescan_out/$INDEXNAME-sinescan*.gff3)
MITEFGFF=$(ls $REPBOX_PREFIX/mitefinder_out/*.gff3)
EAHELGFF=$(ls $REPBOX_PREFIX/eahelitron_out/*.gff3)
MITEGFF=$(ls $REPBOX_PREFIX/mitetracker_out/$INDEXNAME/all.gff3)
REPGFF=$(ls $REPBOX_PREFIX/repeatmasker_out/*fa.out.gff)

## Generation of consensus annotation
echo "Generating consensus GTF..."
$REPBOX_PREFIX/bin/gffcompare/gffcompare $EAHELGFF $GRFGFF $MITEGFF $SINEGFF $MITEFGFF $REPGFF  2>/dev/null

## Generation of consensus FASTA
CONSGFF=$REPBOX_PREFIX/consensus_out/gffcmp.combined.gtf
echo "Generating consensus FASTA..."
sleep 2

$REPBOX_PREFIX/bin/gffread/gffread -w consensus_out.fa -g $GENOME $CONSGFF
sleep 2
echo "Consensus complete..."
