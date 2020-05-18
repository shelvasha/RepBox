#!/bin/bash
echo "Running MiteFinder..."
if [[ "$OSTYPE" == "darwin"* ]]; then
THREAD=$(expr $(sysctl -a | grep machdep.cpu | grep 'thread_count\|core_count'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        THREAD=$(expr $(lscpu | grep 'Thread(s)\|Core(s)\|Socket(s)'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)
fi

if [[ $THREAD -lt 8 ]]; then
    THREAD=4
fi

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')

cd $REPBOX_PREFIX/
rm -rf mitefinder_out
mkdir mitefinder_out
cd mitefinder_out

miteFinder="$REPBOX_PREFIX/bin/miteFinder/miteFinder"
$miteFinder -input $GENOME -output $INDEXNAME.mite_finder.out -pattern_scoring $REPBOX_PREFIX/bin/miteFinder/profile/pattern_scoring.txt -threshold 0.5

python3 $REPBOX_PREFIX/util/MFheader.py $REPBOX_PREFIX/mitefinder_out/*.mite_finder.out
FASTA=$REPBOX_PREFIX/mitefinder_out/*.mite_finder.out.clean
perl $HOMEBREW_PREFIX/opt/repeatmodeler/RepeatClassifier -consensi $FASTA -engine ncbi -pa $THREAD
