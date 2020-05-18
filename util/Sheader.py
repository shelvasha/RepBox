from Bio.SeqIO.FastaIO import SimpleFastaParser
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
import argparse

parser = argparse.ArgumentParser(description='sineheaderclean -i *.sine.fa')
parser.add_argument('mfilename', metavar='<filename>.sine.fa', type=str)
args = parser.parse_args()
sample = open(args.mfilename + '.clean', 'w')

for record in SeqIO.parse(args.mfilename, "fasta"):
    chr=record.id.split("|")[0]
    start=record.id.split("|")[1].split("-")[0]
    end=record.id.split("|")[1].split("-")[1]
    sequence=record.seq
    if chr.startswith(('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')):
        print(">SINE_" + "Chr" + chr + "_" + start + "_" + end, file=sample)
    else:
        print(">" + chr, file=sample)
    print(sequence, file=sample)
sample.close()
