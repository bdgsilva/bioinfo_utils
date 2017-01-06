#!/usr/bin/env python
# -*- coding: utf-8 -*-

from Bio import SeqIO
import argparse

def processFasta(original, redundands,outputfile):
    handle=open(original, "rU")
    original_seq = SeqIO.parse(handle,'fasta')
    id = 1
    mapIds = {}
    for record in original_seq:
        mapIds[id] = (record.id,str(record.seq))
        id +=1
    original_seq.close()

    handle2=open(redundands,"rU")
    redundands_seq = SeqIO.parse(handle2,'fasta')
    output = open(outputfile,'w')

    for record_red in redundands_seq:
        if not int(record_red.id) in mapIds:
            print("ERROR: %s redundans ID larger than number of scaffolds in original file." % record_red.id)
            exit(1)
        else:
            output.write(">" + mapIds[int(record_red.id)][0] + "_redundans-" + record_red.id + "\n" + mapIds[int(record_red.id)][1] + "\n")
    handle2.close()
    output.close()


def main():
    parser = argparse.ArgumentParser(description='Script to replace fasta headers generated by redundans by the previous ones.')
    parser.add_argument(dest='fasta_file1', metavar='fastaFile1', help='Original FASTA file inputted in redundans sorted ny scaffold length in decreasing order.')
    parser.add_argument(dest='fasta_file2', metavar='fastaFile2', help='Redundans output file.')
    parser.add_argument(dest='outputFile', metavar='outputFile', help='File to write corrected output.')
    args = parser.parse_args()

    processFasta(args.fasta_file1,args.fasta_file2,args.outputFile)

if __name__ == "__main__":
    main()