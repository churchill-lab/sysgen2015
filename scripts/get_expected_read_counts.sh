# From FASTQ files to The Table of Read Counts 'expected_read_counts.m4.txt'
# Petr Simecek, 9/21/2015
# Expected running time: 54 hours (192 FASTQ files, ~1.1TB data, 8GB RAM DO machine, cost $6.5 = 54h*0.12$/h) 
#
# This script will build kallisto index from 'emase.polled.transcripts.fa' and then for each sample in 'mouse.ids.txt' do the following
# 1) Download the FASTQ file from FTP server ($mouseID.fastq.gz)
# 2) Use kallisto-align and emase-zero to estimate the read counts ($mouseID.emase.m4.expected_read_counts)
# 3) Combine everything into one big table 'expected_read_counts.m4.txt' where each line is a transript, each column is a sample

set -x

# build kallisto index
kallisto index -i emase.pooled.transcripts.idx emase.pooled.transcripts.fa

# quantify expression using kallisto/EMASE
for f in `cat mouse.ids.txt`
do

  # download FASTQ file
  wget --directory-prefix=/kbdata "ftp://ftp.jax.org/dgatti/ShortCourse/FASTQ/$f.fastq.gz"

  # pseudo-align
  kallisto-align -f "$f.fastq.gz" -i emase.pooled.transcripts.idx -b "$f.pseudo-alignments.bin"

  # count
  emase-zero -v --model 4 -b "$f.pseudo-alignments.bin" -o "$f.emase.m4.expected_read_counts"  

  # delete FASTQ and tmp-file
  rm "$f.pseudo-alignments.bin" "$f.fastq.gz"

done


# check that all files have the same first column, if not throw an error
g=`head -n1 mouse.ids.txt`
cut -f1 "$g.emase.m4.expected_read_counts" > /tmp/cut1 
for f in `cat mouse.ids.txt`
do
  cut -f1 "$f.emase.m4.expected_read_counts" > /tmp/cut2 
  cmp --silent /tmp/cut1 /tmp/cut2 || echo "First columns of $g and $f are different." || exit 1
done

# get total expression columns from all files into one table 'expected_read_counts.m4.txt'
# (warning: not very efficient)
for f in `cat mouse.ids.txt`
do
  echo "Processing: $f"
  # extract 10th column and change the header to mouseID
  cut -f10 "$f.emase.m4.expected_read_counts" | sed "s/^sum/$f/" > /tmp/total
  # paste new column to the precious results
  paste /tmp/cut1 /tmp/total > /tmp/combined
  mv /tmp/combined /tmp/cut1
done
mv /tmp/cut1 expected_read_counts.m4.txt
rm /tmp/cut2 /tmp/total
