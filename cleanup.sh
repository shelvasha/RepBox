#!/bin/bash

cd $REPBOX_PREFIX
echo "Current directory: $REPBOX_PREFIX"
echo "Restore project directory to default? [Y/N]"
read input
if [ $input = "Y" ]; then
    rm -rf $(ls -d *_out)
    rm $(ls genome/*.fai)
#    rm $(find . -type f -regex ".*\.bt2")
#    rm $(find . -type f -regex ".*\.tmap")
#    rm $(find . -type f -regex ".*\.bam")
#    rm $(find . -type f -regex ".*\.sam")
#    rm $(find . -type f -regex ".*\.rmdup.bed")

    echo "Repbox directory reset."

else
  echo "0 files were removed."
fi
