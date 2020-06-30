from Bio.SeqIO.FastaIO import SimpleFastaParser
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
import argparse

parser = argparse.ArgumentParser(description='mitefinderheaderclean -i MITEFinder.out')
parser.add_argument('mfilename', metavar='<filename>.mitefinder.out', type=str)
args = parser.parse_args()
sample = open(args.mfilename + '.clean', 'w')
count=1

for record in SeqIO.parse(args.mfilename, "fasta"):
    name=record.id.replace("|", "_")
    sequence=record.seq
    print(">" + "MITEFINDER_" + str(count) + "_" + name, file=sample)
    print(sequence, file=sample)
    count=count+1
sample.close()
