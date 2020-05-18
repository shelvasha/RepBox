from Bio.SeqIO.FastaIO import SimpleFastaParser
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
import argparse

parser = argparse.ArgumentParser(description='eahelitronheaderclean -i *.sine.fa')
parser.add_argument('mfilename', metavar='<filename>EAHeli_out', type=str)
args = parser.parse_args()
sample = open(args.mfilename + '.clean', 'w')

for record in SeqIO.parse(args.mfilename, "fasta"):
    name=record.id.split(":")[0]
    chr=record.id.split(":")[2]
    sequence=record.seq
    #print(record.id.split(":"))
    if name.startswith(('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')):
        print(">HELITRON_" + name + chr, file=sample)
    else:
        print(">" + name + "_" + chr, file=sample)
    print(sequence, file=sample)
sample.close()
