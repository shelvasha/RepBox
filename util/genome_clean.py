from Bio.SeqIO.FastaIO import SimpleFastaParser
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
import argparse

parser = argparse.ArgumentParser(description='genome_clean -i <genome>.fa')
parser.add_argument('mfilename', metavar='<genome>.fa', type=str)
args = parser.parse_args()
sample = open(args.mfilename + '.clean', 'w')

for record in SeqIO.parse(args.mfilename, "fasta"):
    name=record.id.replace("|", "_")
    sequence=record.seq
    print(">" + name, file=sample)
    print(sequence, file=sample)
sample.close()

# grep -rl "|" ori_Avena_eriantha.fa.out.gff | xargs sed -i "" 's/|/_/g'
