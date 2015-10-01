####################################
#  Analysis of DO liver 192 RNA & Protein
# Part I Walk Through the Data Environment 
#
#  Copyright Gary A Churchill
#  created:    Sept 23, 2015 
#  modified:  Sept 26 _GAC
#################################

# load graphics package 
library(ggplot2)

# load the data
load("/data/Rdata/DO192_DataforSysGenCourse.Rdata")

###
# what is in the work environment?
ls()

####
# the rna expression data are in a large matrix 192 samples x 21454 genes
# the column names are Ensemble GeneID #s
class(expr.rna.192)
dim(expr.rna.192)   
rownames(expr.rna.192)
colnames(expr.rna.192)[1:20]

####
# how much missing data in expr? 
apply(is.na(expr.rna.192),1,sum)
# none - that is nice!

# covariates describe the characteristics of 192 samples
dim(covariates.rna.192)
head(covariates.rna.192)

#look at the group size in experiment design
with(covariates.rna.192,  table(factor(Sdinteraction, labels=c("FC", "FH", "MC", "MH"))))
#experimental design is balanced

#look at coat color frequencies
table(covariates.rna.192$Coat.Color)
# 13% of animals are white
# 16% of animals are black

# annotations describe the genes
dim(annotations.rna.192)
names(annotations.rna.192)
table(annotations.rna.192$Chr)
# note the sort-order of the output
class(annotations.rna.192$Chr)
# Chr is stored as a character variable but it will be handy to have a numeric
annotations.rna.192 <- transform(annotations.rna.192, Chr.num =  as.numeric(ifelse(Chr=="X", "20", Chr)))
class(annotations.rna.192$Chr.num)
table(annotations.rna.192$Chr.num)

# how many rna traits are mapped to Y chromosome or mitochondrial genome?
length(notYM)
sum(1-notYM)

##
# the protein expression data are in a large matrix
class(expr.protein.192)
dim(expr.protein.192)    # there are 8050 protein expression traits
rownames(expr.protein.192)   # note correspondence of row names with RNA data
colnames(expr.protein.192)[1:20]

###
# how much missing data in protein expr? 
apply(is.na(expr.protein.192),1,sum)
# not so nice as the RNA data
#
# what is the range of missing data across proteins?
qplot(apply(is.na(expr.protein.192),2,sum))
# some proteins have a lot of missing data - keep in mind
#
# proportion of proteins that have no missing data
sum((apply(is.na(expr.protein.192),2,sum))==0)/8050

# covariates describe the characteristics of 192 samples
dim(covariates.protein.192)
head(covariates.protein.192)
table(covariates.protein.192$Sdinteraction)
with(covariates.protein.192, table(Tag, Batch))
# every sample has a unique combination of tag and batch

# annotations describe the genes
dim(annotations.protein.192)
names(annotations.protein.192)
table(annotations.protein.192$Chromosome.Name)
# note the sort-order of the output
class(annotations.protein.192$Chromosome.Name)
# Chromosome.Name is stored as a character variable but it will be handy to have a numeric
annotations.protein.192 <- transform(annotations.protein.192, 
                                     Chr.num = as.numeric(ifelse(Chromosome.Name=="X", "20", Chromosome.Name)))
class(annotations.protein.192$Chr.num)
table(annotations.protein.192$Chr.num)

##
# genotype probabilities are stored in a 3D array
dim(probs.192)  #192 x 8 x 64000

# physical and genetic positions of the "pseudo-SNP" grid
# equally spaced on the genetic map
head(snps.64K)
table(snps.64K$Chr)   
class(snps.64K$Chr)
# note as before Chr is a character variable

##
#chromosome specific kinship matrices are stored as a list
length(K.LOCO.192)
class(K.LOCO.192[[1]])
dim(K.LOCO.192[[1]])

# heatmap view of a kinship matrix
image(K.LOCO.192[[3]])

# distribution of kinship values
qplot(K.LOCO.192[[1]][lower.tri(K.LOCO.192[[1]])], geom="histogram")

##
# sample names
head(samples.192)

