from Bio.SeqIO.FastaIO import SimpleFastaParser
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
import argparse

parser = argparse.ArgumentParser(description='sineheaderclean -i *.sine.fa')
parser.add_argument('mfilename', metavar='<filename>.sine.fa', type=str)
args = parser.parse_args()
sample = open(args.mfilename + '.clean', 'w')
count=1

for record in SeqIO.parse(args.mfilename, "fasta"):
    name=count
    sequence=record.seq
    print(">SINEFINDER_" + name, file=sample)
    print(sequence, file=sample)
    count=count+1
sample.close()
