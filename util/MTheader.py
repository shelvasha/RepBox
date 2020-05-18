from Bio.SeqIO.FastaIO import SimpleFastaParser
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
import argparse

parser = argparse.ArgumentParser(description='mitetrackerheaderclean -i all.fasta')
parser.add_argument('mfilename', metavar='all.gff', type=str)
args = parser.parse_args()
sample = open(args.mfilename + '.clean', 'w')
for record in SeqIO.parse(args.mfilename, "fasta"):

    name=record.id.split("|")[0]
    chr=record.id.split("|")[1]
    sequence=record.seq

    print(">" + name + "_CHR" +chr, file=sample)
    print(sequence, file=sample)
