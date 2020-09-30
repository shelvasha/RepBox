from Bio.SeqIO.FastaIO import SimpleFastaParser
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
import argparse

parser = argparse.ArgumentParser(description='mitefParse.py -i MITEFinder.out')
parser.add_argument('mfilename', metavar='<filename>.mitefinder.out', type=str)
args = parser.parse_args()
sample = open('mitefinder.gff3', 'w')
print("#gff-version 3", file=sample)

for record in SeqIO.parse(args.mfilename, "fasta"):
#    print(crecord)
#    print("%s %i" % (record.id, len(record)))
#    print("%s" % (record.id).split("|"))


### Chromosome or scaffold value
    chr=record.id.split("|")[1]
#    chr="1"
    source="MITEFinder"
#    type= record.id.split("|")[0]
    type= "MITE"
    start=record.id.split("|")[2]
    end=record.id.split("|")[5]
#    score=record.id.split("|")[9][10:]
    score="."
    strand="+"
    phase="."
    TSD1=int(record.id.split("|")[2]) - int(record.id.split("|")[6][1])
    TSD2=int(record.id.split("|")[3]) - 10
    TSD3=int(record.id.split("|")[4]) + 10
    TSD4=int(record.id.split("|")[5]) + int(record.id.split("|")[6][1])
    s=","
    attributes=[str(TSD1),str(TSD2),str(TSD3),str(TSD4)]
    print (chr +"\t"+ source + "\t" + type + "\t" + start + "\t" + end + "\t" + score + "\t" + strand + "\t" + phase + "\t" "ID=mite_"+ record.id.split("|")[7] +";" + "TSD="+s.join(attributes), file = sample)

sample.close()
