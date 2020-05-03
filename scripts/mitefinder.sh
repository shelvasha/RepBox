#!/bin/bash
echo "Running MiteFinder..."

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')

cd $REPBOX_PREFIX/
rm -rf mitefinder_out
mkdir mitefinder_out
cd mitefinder_out

miteFinder="$REPBOX_PREFIX/bin/miteFinder/miteFinder"
$miteFinder -input $GENOME -output $INDEXNAME.mite_finder.out -pattern_scoring $REPBOX_PREFIX/bin/miteFinder/profile/pattern_scoring.txt
