#!/bin/bash

cd $REPBOX_PREFIX
#rm -rf gffcheck_out
#mkdir gffcheck_out
cd gffcheck_out

PATH=$PATH$(find $REPBOX_PREFIX/bin -type d -exec echo ":{}" \; | tr -d '\n')

read -p "Enter FASTA location: "  FASTA
read -p "Enter Reference Annotation: "  REF

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)

INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')

#bowtie2-build -f $GENOME $DIRECTORY$INDEXNAME >/dev/null

OUT=$FASTA

DIRECTORY=$(pwd)

# Align Fasta reads to reference
bowtie2 -f -x $INDEXNAME -U $FASTA -S $OUT.sam

# Convert SAM to BAM
samtools view -bS $OUT.sam > $OUT.bam

# BAM to BED
bedtools bamtobed -i $OUT.bam > $OUT.bed
awk '! a[$1" "$2]++' $OUT.bed > $OUT.rmdup.bed

# BED to GFF3
$REPBOX_PREFIX/bin/gffread/gffread $OUT.rmdup.bed > $OUT.gff3

$REPBOX_PREFIX/bin/gffcompare/gffcompare  $OUT.gff3 $REF -D -T  2>/dev/null

#rm *.bed
#rm *.bam
#rm *.sam
#rm *.bt2
