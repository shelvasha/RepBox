#!/bin/bash
echo "Running RepeatMasker..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    THREAD=$(sysctl -a | grep machdep.cpu| grep 'thread_count\|core_count'|grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}' | xargs -n 1 expr -1 +)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    THREAD=$(lscpu | grep 'Thread\|Core\|Socket'|grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}' | xargs -n 1 expr -1 +)
fi

cd $REPBOX_PREFIX
DIRECTORY=$REPBOX_PREFIX/repeatmodeler_out/RM*
LIBRARY=$(ls $DIRECTORY/*.classified)
GENOME=$(ls $HOME/Repbox/genome/*.{fas,fna,fa,fasta} 2>/dev/null)

## Creating Repeatmasker Directories
# echo "creating repeatmasker directories..."
rm -rf repeatmasker_out
mkdir repeatmasker_out
cd repeatmasker_out
OUTPUT=$(pwd)

## Testing Directories
RepeatMasker -pa $THREAD -e ncbi -s -lib $LIBRARY -gff -dir $OUTPUT -u $GENOME
