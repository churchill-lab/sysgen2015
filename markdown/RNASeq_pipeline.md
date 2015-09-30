# RNA-Seq Analysis Pipeline at Systems Genetics Short Course 2015
### KB Choi, Narayanan Raghupathy, The Jackson Laboratory

## g2gtools

### Creating custom genomes

From reference chr1 genome, create a chain with CAST/EiJ indels inputed.

```
cd /data/emase
g2gtools vcf2chain \ 
-f mm10.chr1.fa \ 
-i sanger.indels.CCF.chr1.vcf.gz \ 
-o REF-to-CAST_EiJ.chr1.chain \ 
-s CAST_EiJ
```

Now, add the CAST/EiJ snps.

```
g2gtools patch \
-i mm10.chr1.fa \
-v sanger.snps.CCF.chr1.vcf.gz \
-o CAST_EiJ.snponly.chr1.fa \
-s CAST_EiJ

g2gtools transform \
-i CAST_EiJ.snponly.chr1.fa \
-c REF-to-CAST_EiJ.chr1.chain \
-o CAST_EiJ.chr1.fa
```

### Creating custom transcript sequences

Move CAST/EiJ polymorphisms to transcripts and covert to DB format. 

```
g2gtools convert \
-i ensembl.annot.chr1.gtf \
-c REF-to-CAST_EiJ.chr1.chain \
-o CAST_EiJ.chr1.gtf 
g2gtools gtf2db \
-i CAST_EiJ.chr1.gtf \
-o CAST_EiJ.chr1.db
```

Finally, make FASTA file with CAST/EiJ transcripts. 

```
g2gtools extract --transcripts \
-i CAST_EiJ.chr1.fa \
-db CAST_EiJ.chr1.db \
> CAST_EiJ.transcripts.chr1.fa

# Or transcripts for more CC founders
# DO NOT RUN (files missing)
#create-hybrid \
# -F C57BL6J.transcripts.fa,CAST_EiJ.transcripts.fa \
# -s B,F \
# -o BxC.fa \
# --create-bowtie-index
```

## kallisto, emase

Indexing target sequences

```
kallisto index \
-i individualized.transcriptome.idx \
individualized.transcriptome.fa.gz
```

Identifying the origin of raw reads

```
kallisto-to-emase \
-i pseudo-alignments.EC.bin \
-a pseudo-alignments.EC.h5
```

Quantifying allele-specific/total expression

``` 
emase-zero -v --model 4 \
-b pseudo-alignments.EC.bin \
-o emase.m4.transcripts.cnt
```

Loading alignments into the EMASE framework

```
kallisto-to-emase \
-i pseudo-alignments.EC.bin \
-a pseudo-alignments.EC.h5

ipython
```

## Genome reconstruction By RNA-Seq (GBRS)

```
gbrs -e emase.m2.genes.tpm \
-x founder.alignment.specificity.npz \
-t transition.prob.DO.G7.F.npz \
-g gene_ids.npz
```

Interpolate to 64K grid.

```
interpolate-genoprob
-p gene_pos.npz \
-g marker_grid.64k.txt \
-i gbrs.gamma.npz \
-o gbrs.gamma.ongrid.npz
```

Draw genome and start http server to view it.

```
draw-diploid-genome \
-p gbrs.gamma.ongrid.npz \
-o sample-x.genome.png
-n sample-x 
start-http-server 
```

Now you can open a new tab and at the same URL, port 43211, see the genotype plot.

