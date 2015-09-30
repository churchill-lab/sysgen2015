library(DOQTL)
library(devtools)
install_github("simecek/intermediate")
library(intermediate)

load("~/DO192_DataforSysGenCourse.Rdata")
#load("/hpcdata/cgd/ShortCourse2015/Rdata/DO192_DataforSysGenCourse.Rdata")


# Find the nearest SNP to the given position (of gene/protein)
nearest.snp.index <- function(chr, pos, snps) {
  dist.to.target <- abs(snps$Mb_NCBI38 - pos)
  min.dist <- min(dist.to.target[snps$Chr == chr])
  which(snps$Chr == chr & dist.to.target==min.dist)
}

# Find the SNP maximazing LOD score (autosomes only) 
argmax.lod <- function(scanone.fit)
  scanone.fit$lod$A$SNP_ID[which.max(scanone.fit$lod$A$lod)[1]]

# Mediation Scan
# 
##### target - numeric vector with gene/protein expression
##### mediator - matrix, each column is one gene/protein's expression
##### annotation - data.frame with mediator annotation, must include columns "chr" and "pos"
##### qtl.geno - matrix, haplotype probabilities at QTL we try to mediate
##### covar - additive covariates
##### method = c("ignore", "lod-diff", "double-lod-diff", "lod-ratio")

### Setting covariates
X <- model.matrix(~Sex*Diet, covariates.protein.192)
colnames(X)[2] <- "sex" # DOQTL requirement


### SCAN FOR Tmem68 eQTL and pQTL

## 1) Scan for eQTL
target.rna.index <- which(annotations.rna.192$Gene == "Tmem68")
annotations.rna.192[target.rna.index,]
scanone.rna <- scanone(expr.rna.192, pheno.col=target.rna.index, probs=probs.192, snps=snps.64K, addcovar=X[,-1])
plot(scanone.rna)

# effect plot for autosome with max. LOD
argmax.snp.rna <- argmax.lod(scanone.rna)
coefplot(scanone.rna, chr=snps.64K[argmax.snp.rna,"Chr"])



## 2) Scan for pQTL
target.protein.index <- which(annotations.protein.192$Associated.Gene.Name == "Tmem68")
scanone.protein <- scanone(expr.protein.192, pheno.col=target.protein.index, probs=probs.192, snps=snps.64K, addcovar=X[,-1])
plot(scanone.protein)

# effect plot for autosome with max. LOD
argmax.snp.protein <- argmax.lod(scanone.protein)
coefplot(scanone.protein, chr=snps.64K[argmax.snp.protein,"Chr"])

## 3) Mediation Scan - Condition distant pQTL on protein intermediates
y <- expr.protein.192[,target.protein.index]
geno.argmax.protein <- probs.192[,-1,argmax.snp.protein]

# trim annotation, calculate middle point
annot.protein <- annotations.protein.192[,c("Ensembl.Protein.ID", "Ensembl.Gene.ID", "Associated.Gene.Name")]
annot.protein$Chr <- annotations.protein.192$Chromosome.Name
annot.protein$Pos <- (annotations.protein.192$Gene.Start..bp. + annotations.protein.192$Gene.End..bp.)/2

med <- mediation.scan(target=y, mediator=expr.protein.192, annotation=annot.protein, 
                            covar=X[,-1], qtl.geno=geno.argmax.protein,method="double-lod-diff")

plot(med)
identify(med)


## 4) Mediation Scan - Condition distant pQTL on transcript intermediates

# trim annotation, calculate middle point
annot.rna <- annotations.rna.192[,c("EnsemblID", "Gene", "Chr")]
colnames(annot.rna) = c("Ensemble.Gene.ID","Associated.Gene.Name","Chr")
annot.rna$Pos <- (annotations.rna.192$Start.Mbp + annotations.rna.192$End.Mbp)/2

med <- mediation.scan(target=y, mediator=expr.rna.192, annotation=annot.rna, 
                            covar=X[,-1], qtl.geno=geno.argmax.protein)

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
