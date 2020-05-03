#!/bin/bash
echo "Running SineFinder..."

cd $REPBOX_PREFIX/

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')
FASTA=$(basename $GENOME)

rm -rf sinescan_out
mkdir sinescan_out
cd sinescan_out

DIRECTORY=$(pwd)

# An example : perl SINE_Scan_process.pl -g genome_file(fasta) -d workdir -s 123 -o species_name;
perl $REPBOX_PREFIX/bin/SINE_Scan-v1*/SINE_Scan_process.pl -g $GENOME -d $DIRECTORY -o sine_$INDEXNAME
mv $INDEXNAME*-matches.fasta $INDEXNAME-sinescan.fasta
