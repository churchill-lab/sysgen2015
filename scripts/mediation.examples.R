######################################
#                                    #
#     pQTL & Mediation Module        #
#        October 2, 2015             #
#  Short Course on Systems Genetics  #
#                                    #
######################################



### First, we need to load in some R packages and our data
options(stringsAsFactors = F)
library(DOQTL)
library(devtools)
install_github("simecek/intermediate")
install_github("kbroman/qtlcharts")
library(intermediate)
library(qtlcharts)


load("/data/DO192_DataforSysGenCourse.Rdata")  ###Load in the dataset


### Setting covariates
X <- model.matrix(~Sex*Diet, covariates.protein.192)
colnames(X)[2] <- "sex" # DOQTL requirement


### SCAN for Tmem68 eQTL and pQTL

## 1) Scan for eQTL
my.gene = "Tmem68"  ### Input your gene of interest
target.rna.index <- which(annotations.rna.192$Gene == my.gene)
annotations.rna.192[target.rna.index,]  ### Show information for the gene of interest
scanone.rna <- scanone(expr.rna.192, pheno.col=target.rna.index, probs=probs.192, snps=snps.64K, addcovar=X[,-1])
plot(scanone.rna)


# A little function to find the SNP maximizing LOD score (autosomes only) 
argmax.lod <- function(scanone.fit)
  scanone.fit$lod$A$SNP_ID[which.max(scanone.fit$lod$A$lod)[1]]


# Let's plot the founder coefficients for the autosome with max. LOD
argmax.snp.rna <- argmax.lod(scanone.rna)
coefplot(scanone.rna, chr=snps.64K[argmax.snp.rna,"Chr"])



## 2) Scan for pQTL
target.protein.index <- which(annotations.protein.192$Associated.Gene.Name == my.gene)
scanone.protein <- scanone(expr.protein.192, pheno.col=target.protein.index, probs=probs.192, snps=snps.64K, addcovar=X[,-1])
plot(scanone.protein)

# effect plot for autosome with max. LOD
argmax.snp.protein <- argmax.lod(scanone.protein)
coefplot(scanone.protein, chr=snps.64K[argmax.snp.protein,"Chr"])



# Mediation Scan
# 
##### target - numeric vector with gene/protein expression
##### mediator - matrix, each column is one gene/protein's expression
##### annotation - data.frame with mediator annotation, must include columns "chr" and "pos"
##### qtl.geno - matrix, haplotype probabilities at QTL we try to mediate
##### covar - additive covariates
##### method = c("ignore", "lod-diff", "double-lod-diff", "lod-ratio")


## 3) Mediation Scan - Condition distant pQTL on protein intermediates
y <- expr.protein.192[,target.protein.index]
geno.argmax.protein <- probs.192[,-1,argmax.snp.protein]

# trim annotation, calculate middle point
annot.protein <- annotations.protein.192[,c("Ensembl.Protein.ID", "Ensembl.Gene.ID", "Associated.Gene.Name")]
annot.protein$Chr <- annotations.protein.192$Chromosome.Name
annot.protein$Pos <- (annotations.protein.192$Gene.Start..bp. + annotations.protein.192$Gene.End..bp.)/2

med <- mediation.scan(target=y, mediator=expr.protein.192, annotation=annot.protein, 
                            covar=X[,-1], qtl.geno=geno.argmax.protein,method="double-lod-diff")
kplot(med) #Interactive Plot
plot(med)
identify(med)


## 4) Mediation Scan - Condition distant pQTL on transcript intermediates

# trim annotation, calculate middle point
annot.rna <- annotations.rna.192[,c("EnsemblID", "Gene", "Chr")]
colnames(annot.rna) = c("Ensemble.Gene.ID","Associated.Gene.Name","Chr")
annot.rna$Pos <- (annotations.rna.192$Start.Mbp + annotations.rna.192$End.Mbp)/2

med <- mediation.scan(target=y, mediator=expr.rna.192, annotation=annot.rna, 
                            covar=X[,-1], qtl.geno=geno.argmax.protein)

kplot(med)  #Interactive Plot
plot(med)
identify(med)


#### Other example proteins to scan

##  Ndufaf1
##  Mtr
##  Cct7
##  Glul
##  Xrcc6
##  Elp3
##  Aven
##  Klc4
