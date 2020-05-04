#!/bin/bash

# SINE_Scan installation commands
sudo cpan Bio::AlignIO Bio::Align Bio::PairwiseStatistics Bio::SimpleAlign Getopt::Long File::Basename Get::Sdt Bio::SeqIO Bio::Seq Bio::Tools::Run::StandAloneBlast Bio::SearchIO Statistics::Basic Parallel::ForkManager
#brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/86a44a0a552c673a05f11018459c9f5faae3becc/Formula/python@2.rb
brew install dos2unix

f=$(which makeblastdb)
b=$(which blastn)
c=$(which cd-hit)
M=$(which muscle)
e=$(which stretcher)
l=$(which bedtools)
a=$REPBOX_PREFIX/bin/SINE_Scan-v1.1.1/SINE-FINDER.py

d=$REPBOX_PREFIX/bin/SINE_Scan-v1.1.1
S=$REPBOX_PREFIX/bin/SINE_Scan-v1.1.1/SINEBase/SineDatabase.fasta
R=$REPBOX_PREFIX/bin/SINE_Scan-v1.1.1/RNABase/RNAsbase.fasta

perl $REPBOX_PREFIX/bin/SINE_Scan-v1*/SINE_Scan_Installer.pl -d $d -f $f -b $b -c $c -e $e -M $M -l $l -a $a -S $S -R $R
