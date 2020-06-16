from Bio.SeqIO.FastaIO import SimpleFastaParser
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
import argparse
import numpy as np
import pandas as pd
import os

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
    print(i + "," + str(listElement.count(i)), file=sample)
sample.close()

os.mkdir('Families')
for i in families:
    TE = open('Families/' + str(args.mfilename)[0:16] + '_' + str(i).replace("/","-")+'.fasta', 'a')
#    print("Created TE family fasta file: " + i)
    for record in SeqIO.parse(args.mfilename, "fasta"):
        if record.id.split('#')[1] == str(i):
            print(">" + record.id, file=TE)
            print(record.seq, file=TE)
    TE.close()
