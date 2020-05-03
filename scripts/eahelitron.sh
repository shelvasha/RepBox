#!/bin/bash
echo "Running EAHelitron..."

cd $REPBOX_PREFIX/
rm -rf eahelitron_out
mkdir eahelitron_out
cd eahelitron_out

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')
DIRECTORY=$(pwd)

EAHelitron=$HOME"/Repbox/bin/EAHelitron/EAHelitron"
perl $EAHelitron $GENOME
