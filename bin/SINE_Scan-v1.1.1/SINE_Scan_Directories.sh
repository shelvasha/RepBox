#!/bin/bash

# SINE_Scan installation commands
#sudo cpan Bio::AlignIO Bio::Align Bio::PairwiseStatistics Bio::SimpleAlign Getopt::Long File::Basename Get::Sdt Bio::SeqIO Bio::Seq Bio::Tools::Run::StandAloneBlast Bio::SearchIO Statistics::Basic Parallel::ForkManager
#brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/86a44a0a552c673a05f11018459c9f5faae3becc/Formula/python@2.rb

f=$HOMEBREW_PREFIX/Cellar/blast/*/bin/makeblastdb
b=$HOMEBREW_PREFIX/Cellar/blast/*/bin/blastn
c=$REPBOX_PREFIX/bin/cd-hit*/cd-hit
M=$HOMEBREW_PREFIX/Cellar/muscle/*/bin/muscle
e=$HOMEBREW_PREFIX/Cellar/emboss/*/bin/stretcher
l=$HOMEBREW_PREFIX/Cellar/bedtools/*/bin/bedtools
a=$REPBOX_PREFIX/bin/SINE_Scan-v1*/SINE-FINDER.py

#d=$REPBOX_PREFIX/bin/SINE_Scan-v1*
#S=$REPBOX_PREFIX/bin/SINE_Scan-v1*/SINEBase/SineDatabase.fasta
#R=$REPBOX_PREFIX/bin/SINE_Scan-v1*/RNABase/RNAsbase.fasta

perl $REPBOX_PREFIX/bin/SINE_Scan-v1*/SINE_Scan_Installer.pl -f $f -b $b -c $c -e $e -M $M -l $l -a $a && rm PL_pipeline/*.py.rej
