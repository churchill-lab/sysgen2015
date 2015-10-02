## ---- results='hide', message=FALSE--------------------------------------
library(DOQTL)
library(rhdf5)

## ----warning=FALSE-------------------------------------------------------
load("/data/Rdata/DO192_DataforSysGenCourse.Rdata")

## ----warning=FALSE-------------------------------------------------------
rm(annotations.protein.192, covariates.protein.192, expr.protein.192)

## ----warnings=FALSE------------------------------------------------------
expr.rna.192[1:5,1:6]

## ----warning=FALSE-------------------------------------------------------
hist(expr.rna.192[,1], breaks = 20, main = colnames(expr.rna.192)[1])

## ----warning=FALSE-------------------------------------------------------
image(1:ncol(probs.192), 1:20, t(probs.192[20:1,,1]), axes = F, ann = F,
      breaks = c(-0.25, 0.25, 0.75, 1.25), col = c("white", "grey50", "black"))
box()
abline(v = 0:9+0.5, col = "grey80")
abline(h = 0:20+0.5, col = "grey80")
mtext(side = 3, line = 0.5, at = 1:8, text = LETTERS[1:8], cex = 1.5)
mtext(side = 2, line = 0.5, at = 20:1, text = rownames(probs.192)[1:20], las = 1)

## ----eval=FALSE----------------------------------------------------------
## K = kinship.probs(probs = probs.192, snps = snps.64K, bychr = TRUE)

## ----warning=FALSE-------------------------------------------------------
covar = model.matrix(~Sex + Diet, data = covariates.rna.192)[,-1]
colnames(covar)[1] = "sex"
rownames(covar) = rownames(expr.rna.192)

## ----warning=FALSE-------------------------------------------------------
row = which(annotations.rna.192$Gene == "Lrtm1")
ensid = annotations.rna.192$EnsemblID[row]
annotations.rna.192[row,]

## ----warning=FALSE-------------------------------------------------------
pheno.col = which(colnames(expr.rna.192) == ensid)
colnames(expr.rna.192)[pheno.col]

## ----warning=FALSE-------------------------------------------------------
qtl = scanone(pheno = expr.rna.192, pheno.col = pheno.col, probs = probs.192, K = K.LOCO.192,
             addcovar = covar, snps = snps.64K)

## ----warning=FALSE-------------------------------------------------------
plot(qtl, main = paste(ensid, "Lrtm1"))

## ----warning=FALSE-------------------------------------------------------
load("/data/eQTL/eQTL_perms.Rdata")
thr = quantile(perms, 0.95)

## ----warning=FALSE-------------------------------------------------------
hist(perms, breaks = 20)
abline(v = thr, col = "red", lwd = 2)

## ----warning=FALSE-------------------------------------------------------
plot(qtl, main = paste(ensid, "Lrtm1"), sig.thr = thr)

## ----warning=FALSE-------------------------------------------------------
coefplot(qtl, chr = 14, main = paste(ensid, "Lrtm1"))

## ----warning=FALSE-------------------------------------------------------
coefplot(qtl, chr = 7, main = paste(ensid, "Lrtm1"))

## ----warning=FALSE-------------------------------------------------------
assoc = assoc.map(pheno = expr.rna.192, pheno.col = pheno.col, probs = probs.192, K = K.LOCO.192[[14]],
                  addcovar = covar, snps = snps.64K, chr = 14, start = 28, end = 32)
tmp = assoc.plot(assoc, thr = 10, show.sdps = TRUE, highlight = "Lrtm1")

## ----eval=FALSE----------------------------------------------------------
## row = which(annotations.rna.192$Gene == "MyFavoriteGene")
## ensid = annotations.rna.192$EnsemblID[row]
## annotations.rna.192[row,]
## pheno.col = which(colnames(expr.rna.192) == ensid)

## ----eval=FALSE----------------------------------------------------------
## perms = scanone.perm(pheno = expr.rna.192, pheno.col = 1, probs = probs.192,
##                     addcovar = covar, snps = snps.64K, nperm = 1000)
## 
## # Load in DOQTL.
## library(DOQTL)
## 
## # Load in the data.
## load("/hpcdata/cgd/DO192_DataforSysGenCourse.Rdata")
## load("/hpcdata/cgd/DO192_DataforSysGenCourse_update.Rdata")
## 
## # Create the covariates.
## covar = covariates.rna.192[,c(1,2,5)]
## covar = data.frame(lapply(covar, factor))
## covar = model.matrix(~Sex + Diet, data = covar)[,-1]
## rownames(covar) = rownames(covariates.rna.192)
## colnames(covar)[1] = "Sex"
## 
## # Remove the data that we don't need from memory.
## rm(annotations.protein.192, annotations.rna.192, expr.protein.192,
##    expr.rna.192, samples.192, covariates.rna.192, covariates.protein.192)
## 
## annotations.rna.new = annotations.rna.new[colnames(expr.rna.192),]
## 
## # Set the output directory.
## setwd("/hpcdata/dgatti/ShortCourse/eQTL")
## 
## for(i in 1:ncol(expr.rna.192)) {
## 
##   start.time = proc.time()[3]
##   qtl = scanone(pheno = expr.rna.192, pheno.col = i,
##         probs = probs.192, K = K.LOCO.192, addcovar = covar,
##         snps = snps.64K)
##   saveRDS(qtl, file = paste0(colnames(expr.rna.192)[i], "_",
##           annotations.rna.new$Gene[i], "_QTL.rds"))
## 
##   print(paste(i, proc.time()[3] - start.time))
## 
## } # for(i)

## ----eval=FALSE----------------------------------------------------------
## # Loadin DOQTL.
## library(DOQTL)
## 
## # Load in the data.
## load("/hpcdata/cgd/DO192_DataforSysGenCourse.Rdata")
## load("/hpcdata/cgd/DO192_DataforSysGenCourse_update.Rdata")
## 
## # Remove the data that we don't need.
## rm(annotations.rna.192, expr.rna.192, annotations.protein.192, expr.protein.192,
##    samples.192, covariates.rna.192, covariates.protein.192)
## 
## # Set the output directory.
## setwd("/hpcdata/dgatti/ShortCourse/eQTL")
## 
## # Load in the permutations.
## load(file = "eQTL_perms.Rdata")
## thr = quantile(perms, 1.0 - c(0.63, 0.05))
## 
## # Get the files.
## files = dir(pattern = "_QTL.rds$")
## 
## # Extract the protein IDs.
## gene.ids = strsplit(files, split = "_")
## gene.ids = sapply(gene.ids, "[", 1)
## stopifnot(rownames(annotations.rna.new) == colnames(expr.rna.192))
## 
## # Create a QTL results data.frame.
## result = data.frame(Ensembl_ID = annotations.rna.new$EnsemblID,
##                Symbol = annotations.rna.new$Gene,
##                Gene_Chr = annotations.rna.new$Chr,
##                Gene_Midpoint = 0.5 * (annotations.rna.new$End.Mbp + annotations.rna.new$Start.Mbp),
##                QTL_Chr = rep("", nrow(annotations.rna.new)),
##                QTL_Pos = rep(0, nrow(annotations.rna.new)),
##                QTL_LOD = rep(0, nrow(annotations.rna.new)),
##                p.gw = rep(0, nrow(annotations.rna.new)),
##                stringsAsFactors = FALSE)
## 
## # Make sure that the order of the proteins in the results file
## # matches the order of the proteins in the files.
## result = result[match(gene.ids, result$Ensembl_ID),]
## stopifnot(gene.ids == result$Ensembl_ID)
## 
## # Extract the LOD and coefficients for each protein.
## for(i in 1:length(files)) {
## 
##   print(paste(i, "of", length(files)))
##   qtl = readRDS(files[i])
## 
##   # Get the LOD score and coefficients.
##   lod = c(qtl$lod$A$lod, qtl$lod$X$lod)
##   coef.columns = (ncol(qtl$coef$A) - 7):ncol(qtl$coef$A)
##   coef = rbind(qtl$coef$A[,coef.columns], qtl$coef$X[,coef.columns])
## 
##   # Make a QTL plot.
##   outfile = paste0(protein.ids[i], "_", annotations.protein.192$Associated.Gene.Name[i],
##             "_QTL.png")
##   title = paste(protein.ids[i], annotations.protein.192$Associated.Gene.Name[i])
##   png(outfile, width = 1000, height = 800, res = 128)
##   plot(qtl, sig.thr = thr, sig.color = c("orange", "red"),
##        main = title)
##   dev.off()
## 
##   # Harvest the maximum autosomal peak.
##   max.qtl = qtl$lod$A[which.max(qtl$lod$A[,7]),]
## 
##   result$QTL_Chr[i] = max.qtl$Chr[1]
##   result$QTL_Pos[i] = max.qtl$Mb_NCBI38[1]
##   result$QTL_LOD[i] = max.qtl$lod[1]
##   result$p.gw[i]    = mean(perms >= max.qtl[1,7])
## 
##   # Create a coefficient plot on the chromosome with the maximum QTL.
##   max.chr = max.qtl[1,2]
##   outfile = sub("QTL", paste0("chr", max.chr), outfile)
##   png(outfile, width = 1000, height = 800, res = 128)
##   coefplot(qtl, chr = max.chr, main = title)
##   dev.off()
## 
## } # for(i)
## 
## write.csv(result, file = "eQTL_summary.csv", quote = FALSE, row.names = FALSE)

## ----eval=FALSE----------------------------------------------------------
## # Load in libraries.
## # Perform the pQTL mapping.
## library(DOQTL)
## library(rhdf5)
## 
## # Load in the data.
## load("/hpcdata/cgd/DO192_DataforSysGenCourse.Rdata")
## load("/hpcdata/cgd/DO192_DataforSysGenCourse_update.Rdata")
## 
## # Remove the data that we don't need.
## rm(annotations.rna.192, expr.rna.192, annotations.protein.192, expr.protein.192,
##    samples.192, covariates.rna.192, covariates.protein.192)
## 
## # Set the output directory.
## setwd("/hpcdata/dgatti/ShortCourse/eQTL")
## 
## # Get the files.
## files = dir(pattern = "_QTL.rds$")
## 
## # Extract the gene IDs.
## gene.ids = strsplit(files, split = "_")
## gene.ids = sapply(gene.ids, "[", 1)
## stopifnot(rownames(annotations.rna.new) == colnames(expr.rna.192))
## 
## # We will use this to split the data up by chormosome.
## chrlist = factor(snps.64K$Chr, levels = c(1:19, "X"))
## 
## # Pre-calulate the breaks points on each chromosome.
## out.snps = split(snps.64K, chrlist)
## brks = vector("list", length(levels(chrlist)))
## names(brks) = levels(chrlist)
## brklen = vector("list", length(levels(chrlist)))
## names(brklen) = levels(chrlist)
## 
## for(c in 1:length(out.snps)) {
## 
##   pos = out.snps[[c]]$Mb_NCBI38
##   brks[[c]] = cut(out.snps[[c]]$Mb_NCBI38, round(nrow(out.snps[[c]]) / 10))
##   brks[[c]] = factor(as.numeric(brks[[c]]))
##   keep = table(brks[[c]])
##   brklen[[c]] = c(0, cumsum(keep)[-length(keep)])
##   keep = round(keep / 2) + cumsum(c(0, keep[-length(keep)]))
##   out.snps[[c]] = out.snps[[c]][keep,]
## 
## } # for(c)
## 
## # Create a LOD matrix.
## lod = matrix(0, nrow = sum(sapply(out.snps, nrow)),
##       ncol = length(files), dimnames = list(
##       unlist(sapply(out.snps, rownames)), gene.ids))
## coef = array(0, c(nrow(lod), 8, ncol(lod)),
##        dimnames = list(rownames(lod), LETTERS[1:8], colnames(lod)))
## 
## # Extract the LOD and coefficients for each gene.
## for(i in 1:length(files)) {
## 
##   print(paste(i, "of", length(files)))
##   qtl = readRDS(files[i])
## 
##   # Get the LOD score and coefficients and split them up by chromosome.
##   local.lod = c(qtl$lod$A$lod, qtl$lod$X$lod)
##   local.lod = split(local.lod, chrlist)
##   coef.columns = (ncol(qtl$coef$A) - 7):ncol(qtl$coef$A)
##   local.coef = data.frame(rbind(qtl$coef$A[,coef.columns], qtl$coef$X[,coef.columns]))
##   local.coef = split(local.coef, chrlist)
## 
##   # Loop through each chromosome.
##   for(c in 1:length(local.lod)) {
## 
##     # Subset the LOD scores.
##     spl = split(local.lod[[c]], brks[[c]])
##     max.idx = sapply(spl, which.max) + brklen[[c]]
##     local.lod[[c]] = local.lod[[c]][max.idx]
## 
##     # Subset the coefficients.
##     local.coef[[c]] = local.coef[[c]][max.idx,]
## 
##   } # for(c)
## 
##   # Combine the LOD and coef results.
##   local.lod  = unsplit(local.lod,  rep(1:length(local.lod),
##                sapply(local.lod, length)))
##   local.coef = unsplit(local.coef, rep(1:length(local.coef),
##                sapply(local.coef, nrow)))
## 
##   # Center the coefficients.
##   colnames(local.coef)[1] = "A"
##   local.coef = as.matrix(local.coef)
##   local.coef[,1] = 0
##   local.coef = local.coef - rowMeans(local.coef)
## 
##   # Add the LOD and coef to the large arrays.
##   lod[,i]   = local.lod
##   coef[,,i] = local.coef
## 
## } # for(i)
## 
## out.snps = unsplit(out.snps, rep(1:length(out.snps), sapply(out.snps, nrow)))
## 
## # Keep only unique genes.
## lod  = lod[,!duplicated(colnames(lod))]
## coef = coef[,,!duplicated(dimnames(coef)[[3]])]
## 
## # Write out the data as an HDF5 file.
## h5filename = "eQTL_for_viewer.h5"
## chunk = 500
## h5createFile(file = h5filename)
## h5createGroup(file = h5filename, group = "lod")
## h5createDataset(file = h5filename, dataset = "/lod/lod", dim = dim(lod),
##                 chunk = c(nrow(lod), chunk))
## h5write(obj = lod,  file = h5filename, name = "/lod/lod")
## h5write(obj = out.snps[,1:3], file = h5filename, name = "/lod/markers")
## h5write(obj = colnames(lod), file = h5filename, name = "/lod/genes")
## h5createGroup(file = h5filename, group = "coef")
## h5createDataset(file = h5filename, dataset = "/coef/coef", dim = dim(coef),
##                 chunk = c(nrow(lod), 8, chunk))
## h5write(obj = coef, file = h5filename, name = "/coef/coef")
## h5write(obj = colnames(coef), file = h5filename, name = "/coef/founders")
## h5write(obj = dimnames(coef)[[3]], file = h5filename, name = "/coef/genes")
## H5close()
## 
## h5ls(h5filename)

## ----eval = FALSE,warnings=FALSE-----------------------------------------
## library(rhdf5)
## h5ls("eQTL_for_viewer.h5")

