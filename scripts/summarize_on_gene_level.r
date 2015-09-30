# From Transcript Read Counts 'expected_read_counts.m4.txt' to Filtered, Sample Normalized Gene Counts 'DO192_DataforSysGenCourse_update.Rdata'
# Petr Simecek, 9/24/2015
# Expected running time: 1-2 minutes
#
# This script 
# 1) Load Ensembl Gene and Transcript annotation and Transcript-level read counts
# 2) Summarize from Transcript-level to Gene-level
# 3) Match samples order and annotation to previous format

library(dplyr)

# read emase results
emase <- read.csv("/data/emase/expected_read_counts.m4.txt", sep="\t", as.is=TRUE)

# read Ensembl annotation
transcripts <- read.csv("/data/emase/ensembl_mysql_tables/mouse_transcripts.txt", sep="\t", as.is=TRUE)
genes <- read.csv("/data/emase/ensembl_mysql_tables/mouse_genes.txt", sep="\t", as.is=TRUE)

# combine annotation and emase
stopifnot(emase$Transcript %in% transcripts$trancript_ensembl_id) # all transcripts are supposed to be annotated
idx <- match(emase$Transcript, transcripts$trancript_ensembl_id)  # match annotation to transcripts in dataset
transcript.gene.emase <- cbind(transcripts[idx,1:2], emase)       # add Ensembl transcript and gene ID to read counts
stopifnot(transcript.gene.emase$trancript_ensembl_id == transcript.gene.emase$Transcript)

# summarize from transcript level to gene level
emase.gene <- transcript.gene.emase %>% 
  group_by(ensembl_id) %>% 
  select(-Transcript) %>% select(-trancript_ensembl_id) %>%
  summarise_each(funs(sum))
emase.gene <- as.data.frame(emase.gene) # from tbl_df to data.frame

# normalize each sample to 75% quantile
dt <- as.matrix(emase.gene[,-1]) # from data.frame to matrix
quantile75 <- apply(dt, 2, quantile, probs=0.75)
tdt <- t(dt) / quantile75 * mean(quantile75)

# filter for minimal expression, it should be at least 0.001
MINIMAL_EXPRESSION <- 0.001
mean.exp <- apply(tdt, 2, mean)
nonzeroes <- apply(tdt>0, 2, sum)
sel <- mean.exp > MINIMAL_EXPRESSION
filtered.dt <- tdt[,sel]
colnames(filtered.dt) <- emase.gene$ensembl_id[sel]
stopifnot(!any(is.na(match(colnames(filtered.dt),genes$ensembl_id))))
annot.filtered.dt <- genes[match(colnames(filtered.dt),genes$ensembl_id),]

# match the sample order to format of original 192 file
load("/data/Rdata/DO192_DataforSysGenCourse_old.Rdata")
annotations.rna <-  annot.filtered.dt[,c(1,2,4,5,6,3,7)]
names(annotations.rna) <- c(names(annotations.rna.192)[1:6],"Strand") 
annotations.rna$Nonzeros <- nonzeroes[sel]
annotations.rna$Mean.per.Expr <- mean.exp[sel]
rownames(annotations.rna) <- annotations.rna$EnsemblID
annotations.rna$Start.Mbp <- annotations.rna$Start.Mbp / 10^6
annotations.rna$End.Mbp <- annotations.rna$End.Mbp / 10^6

expr.rna <- filtered.dt[match(samples.192, rownames(filtered.dt)),]
covariates.rna <- covariates.rna.192[,c("Sex", "Diet", "Batch", "Gen", "Coat.Color")]

save(expr.rna, annotations.rna, file="/data/Rdata/DO192_DataforSysGenCourse_update.Rdata")


