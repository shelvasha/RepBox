from Bio.SeqIO.FastaIO import SimpleFastaParser
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
import argparse

parser = argparse.ArgumentParser(description='mitefinderheaderclean -i MITEFinder.out')
parser.add_argument('mfilename', metavar='<filename>.mitefinder.out', type=str)
args = parser.parse_args()
sample = open(args.mfilename + '.clean', 'w')

for record in SeqIO.parse(args.mfilename, "fasta"):
    chr=record.id.split("|")[1]
    tsdlength=record.id.split("|")[6]
    mismatchsite=record.id.split("|")[7]
    sequence=record.seq

    print(">MITE_" + "Chr" + chr + "_" + tsdlength + "_" + mismatchsite, file=sample)
    print(sequence, file=sample)
sample.close()
