#!/usr/bin/bash

CURRENT=$(cd $(dirname $0);pwd)

cd $CURRENT

#software update
brew upgrade fastp
brew upgrade spades
brew upgrade quast

#count the number of fastq-files
read_num=`find *fastq* | wc -l`

#single-end
if [[ read_num -eq 1 ]]; then
    read=`find *fastq*`

    fastp -i $read -o fastp_out.fastq.gz
    echo "===== fastp done! ====="

    spades.py --careful --cov-cutoff auto -s fastp_out.fastq.gz -o spades_assembled
    echo "===== SPAdes done! ====="

    quastpy_path=`which quast.py`
    python $quastpy_path -o quast_output spades_assembled/contigs.fasta
    echo "===== QUAST done! ====="

#pair-end
elif [[ read_num -eq 2 ]]; then
    left_read=`find *R1*fastq*`
    right_read=`find *R2*fastq*`

    fastp -i $left_read -I $right_read -o fastp_out_left.fastq.gz -O fastp_out_right.fastq.gz
    echo "===== fastp done! ====="

    spades.py --careful --cov-cutoff auto -1 fastp_out_left.fastq.gz -2 fastp_out_right.fastq.gz -o spades_assembled
    echo "===== SPAdes done! ====="

    quastpy=`which quast.py`
    python $quastpy -o quast_output spades_assembled/contigs.fasta
    echo "===== QUAST done! ====="

#no files
elif [[ read_num -eq 0 ]]; then
    echo "===== No fastq-files in your directry! ====="

#too many files
else
    echo "===== Too many fastq-files in your directry! ====="
fi
