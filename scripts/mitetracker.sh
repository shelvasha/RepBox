#!/bin/bash
echo "Running MITE-Tracker..."

if [[ "$OSTYPE" == "darwin"* ]]; then
THREAD=$(expr $(sysctl -a | grep machdep.cpu | grep 'thread_count\|core_count'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        THREAD=$(expr $(lscpu | grep 'Thread(s)\|Core(s)\|Socket(s)'| grep -Eo '[0-9]{1,4}'| xargs | awk '{ for(j=i=1; i<=NF;i++) j*=$i; print j; j=0}') - 1)
fi

if [[ $THREAD -lt 8 ]]; then
    THREAD=4
fi

export HOME
GENOME=$(ls $REPBOX_PREFIX/genome/*.{fas,fna,fa,fasta} 2>/dev/null)
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')

cd $REPBOX_PREFIX/
rm -rf mitetracker_out
mkdir mitetracker_out
cd mitetracker_out

#virtualenv -p python3 venv
#source venv/bin/activate
#pip3 install -r $REPBOX_PREFIX/bin/MITE-Tracker/requirements.txt

cd $REPBOX_PREFIX/bin/MITE-Tracker/
rm -rf results
mkdir results
cd results
rm -rf $INDEXNAME
mkdir $INDEXNAME
cd $REPBOX_PREFIX/bin/MITE-Tracker/

## Running MITE-Tracker within python3 virtual environment
python3 -m MITETracker -g $GENOME -w $THREAD -j $INDEXNAME
mv ~/Repbox*/bin/MITE-Tracker/results/$INDEXNAME $REPBOX_PREFIX/mitetracker_out
