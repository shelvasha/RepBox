from Bio.SeqIO.FastaIO import SimpleFastaParser
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
import argparse
import numpy as np
import pandas as pd

parser = argparse.ArgumentParser(description='parsify -i <file>.fasta')
parser.add_argument('mfilename', metavar='<filename>.fasta', type=str)
args = parser.parse_args()
sample = open(args.mfilename + '.table', 'w')
listElement = []
for record in SeqIO.parse(args.mfilename, "fasta"):
    listElement.append(record.id.split('#')[1])
    #print(record.seq)
    #print(sequence, file=sample)

families = (set(listElement))
for i in families:
    print(i + "," + str(listElement.count(i)))
sample.close()
