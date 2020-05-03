#!/bin/bash
echo "Running Generic Repeat Finder..."

# MITE Detection
# "mite.fasta": representative sequences of each MITE family.
# "miteSet.fasta": all MITE sequences in each family; each family is separated by dashes.

cd $REPBOX_PREFIX/
rm -rf grf_out
mkdir grf_out
cd grf_out

GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
OUT_DIR=$(pwd)
if [[ "$OSTYPE" == "darwin"* ]]; then
    THREAD=$(sysctl -a | grep machdep.cpu| grep 'thread_count\|core_count'|grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}' | xargs -n 1 expr -1 +)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    THREAD=$(lscpu | grep 'Thread\|Core\|Socket'|grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}' | xargs -n 1 expr -1 +)
fi
#grf-main="$REPBOX_PREFIX/bin/GenericRepeatFinder/bin/grf-main"
#grf-mite-cluster="$REPBOX_PREFIX/bin/GenericRepeatFinder/bin/grf-mite-cluster"

$REPBOX_PREFIX/bin/GenericRepeatFinder/bin/grf-main -i $GENOME -o $OUT_DIR -c 1 --min_tr 10 -t $THREAD
$REPBOX_PREFIX/bin/cd-hit-v4.6.1/cd-hit-est -i $OUT_DIR/candidate.fasta -o $OUT_DIR/clusteredCandidate.fasta -c 0.90 -n 5 -d 0 -T $THREAD -aL 0.99 -s 0.8 -M 0 > $OUT_DIR/cd-hit-est.out
$REPBOX_PREFIX/bin/GenericRepeatFinder/bin/grf-mite-cluster -i $OUT_DIR/clusteredCandidate.fasta.clstr -g $GENOME -o $OUT_DIR
