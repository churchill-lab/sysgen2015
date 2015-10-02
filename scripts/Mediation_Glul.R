####################################
# Mediation Analysis Example: Glul 
#  DO liver 192
#  Copyright Gary A Churchill
#  created:       Sept 22, 2015
#  last modified: Sept 23, 2015 
#
#
############

############
#setup
library(DOQTL)
library(ggplot2)

#load("/data/Rdata/DO192_DataforSysGenCourse_old.Rdata")
load("/data/Rdata/DO192_DataforSysGenCourse.Rdata")

# it will be handy to have Sex and Diet and available as numeric variables
# 0 = Female 1 = male
Sex <- as.numeric(factor(covariates.rna.192$Sex))-1
#
# 0 = chow  1 = HF
Diet <- as.numeric(factor(covariates.rna.192$Diet))-1

#create numerical indices for chromosome annotations
annotations.rna.192 <- transform(annotations.rna.192, Chr.num =  as.numeric(ifelse(Chr=="X", "20", Chr)))
annotations.protein.192 <- transform(annotations.protein.192, 
                                     Chr.num = as.numeric(ifelse(Chromosome.Name=="X", "20", Chromosome.Name)))
#end setup
############

#################
# select rna & protein traits for analysis


#reminder - what covariates are available
head(covariates.protein.192)
head(covariates.rna.192)

###
#create a dataframe with gene of interest, Glul
mydata <- transform(covariates.rna.192,
                    Glul.r = expr.rna.192[,which(annotations.rna.192$Gene == "Glul")],
                    Glul.p = expr.protein.192[,which(annotations.protein.192$Associated.Gene.Name == "Glul")],
                    Sex = as.factor(Sex), Diet = as.factor(Diet), 
                    SexDiet = factor(Sdinteraction, labels=c("FC", "FH", "MC", "MH")), 
                    Parity = as.factor(Gen), Black = (Coat.Color=="black"), White = (Coat.Color=="white"),
                    Prot.Tag = covariates.protein.192$Tag, Prot.Batch = covariates.protein.192$Batch)
mydata <- mydata[,-c(3,4,6)]
str(mydata)  


# boxplots suggest a diet effect on Glul - stronger in males
qplot(SexDiet, color=Sex, shape=Diet, Glul.r, data=mydata) + geom_boxplot()
qplot(SexDiet, color=Sex, shape=Diet, Glul.p, data=mydata) + geom_boxplot()

# run the sex diet ANOVA to confirm diet and sex effects
anova(lm(Glul.r ~ Sex*Diet, data=mydata))
anova(lm(Glul.p ~ Sex*Diet, data=mydata))

#check for Tag and Batch effects on Protein
anova(lm(Glul.p ~ Prot.Tag, data=mydata))
anova(lm(Glul.p ~ Prot.Batch, data=mydata))
#p-values near 1.0 suggest data have been normalized.  

# scatterplot RNA and Prot
qplot(Glul.r, Glul.p, color=Sex, shape=Diet, data=mydata) + geom_smooth(method="lm", se=FALSE)

#correlation of RNA and Prot is 0.69
with(mydata, cor(Glul.r, Glul.p))


#end select
############

############
# genome scan analysis of Glul 

# location of Glul is Chr 1 at 153.9Mb
annotations.rna.192[which(annotations.rna.192$Gene == "Glul"),]

###
# create a covariate data structure
covs <- data.frame(cbind(Sex, Diet))
rownames(covs) <- rownames(mydata)

###
# mediation analysis of Glul.r and Glul.p
# is carried out in 4-steps using genome scans
# RNA ~ Q
# Prot ~ Q
# RNA ~ Q | Prot
# Prot ~ Q | RNA

###
# genome scans note:  no kinship correction - checked and it doesn't seem to matter much
# step1 scan Glul RNA
Glul.r.scan <- scanone(pheno=mydata, pheno.col="Glul.r", probs=probs.192,
                       addcovar=covs, snps=snps.64K)
plot(Glul.r.scan)

# #look at the structure of scan output
str(Glul.r.scan)
# whooey!

#find the lod peak
indx.maxr <- with(Glul.r.scan$lod$A, which(lod==max(lod)))
Glul.r.scan$lod$A[indx.maxr,]
# LOD score at peak is 16.91

####
# step2 scan Glul Prot
Glul.p.scan <- scanone(pheno=mydata, pheno.col="Glul.p", probs=probs.192,
                       addcovar=covs, snps=snps.64K)
plot(Glul.p.scan)

#find the lod peak
indx.maxp <- with(Glul.p.scan$lod$A, which(lod==max(lod)))
Glul.p.scan$lod$A[indx.maxr,]
# note peak location is the same, LOD score is lower 12.82

####
# step3 scan Glul RNA conditioned ob Prot

# modify covs for conditional scan
covs <- data.frame(cbind(covs[,1:2],mydata$Glul.p))
#
Glul.r.condp.scan <- scanone(pheno=mydata, pheno.col="Glul.r", probs=probs.192,
                             addcovar=covs, snps=snps.64K)
plot(Glul.r.condp.scan)

# check the peak lod
indx.maxr.p <- with(Glul.r.condp.scan$lod$A, which(lod==max(lod)))
Glul.r.condp.scan$lod$A[indx.maxr.p,]
# peak marker is still on 10, very close, but LOD dropped to 6.87
Glul.r.condp.scan$lod$A[indx.maxr,]
#at original peak, LOD drops to 6.76

####
# step4 scan Glul Prot conditioned on RNA

# modify covs for conditional scan
covs <- data.frame(cbind(covs[,1:2],mydata$Glul.r))
#
Glul.p.condr.scan <- scanone(pheno=mydata, pheno.col="Glul.p", probs=probs.192, 
                             addcovar=covs, snps=snps.64K)
plot(Glul.p.condr.scan)

# check the peak lod
indx.maxp.r <- with(Glul.p.condr.scan$lod$A, which(lod==max(lod)))
Glul.p.condr.scan$lod$A[indx.maxp.r,]
# new peak marker is on chr 2
Glul.p.condr.scan$lod$A[indx.maxr,]
#at original peak LOD drops to 2.67

# Notes:
# there is a shared LOD peak at 17.16Mb for Glul RNA and Prot on Chr 10
# peak SNP_ID is 10_30766019
# the LOD score for RNA (16.91) is higher than for Prot (12.82)
#
# conditioning the RNA trait on protein reduces the LOD from 16.91 to 6.87
# conditioning the Prot trait on RNA reduces LOD from 12.82 to 2.67
#
# consistent with model Q10 -> Glul.r -> Glul.p

# ###
# # clean up if needed
# rm(list=ls(pattern="Glul.*"))
# rm(covs)
# ls()

#closing the plots will save memory too
graphics.off()

# end mediation analysis
####################


####################
# repeat mediation at peak marker using linear model fitting

###
# get the genoprobs at peak marker
Q10 <- probs.192[,,"10_30766019"]
head(Q10)

# look at the frequency of founder alleles at the peak marker
# expect 24 = 192/8
apply(Q10,2,sum)
# note low frequency of B6 and excess of CAST

#add Q10 genoprobs into mydata
mydata <- data.frame(cbind(mydata[,1:8], Q10))
names(mydata)

###
# check for missing data!  
# important to remove all cases with missing data before fitting lm's
sum(is.na(mydata$Glul.r))
sum(is.na(mydata$Glul.p))
# there are none in this example. phew!

#here is what to do if you have missing data
miss.indx <- which(is.na(mydata$Glul.r)|is.na(mydata$Glul.p))
mydata <- mydata[-miss.indx,]
# note that this will put your "mydata" out of register with the other
# data objects in this environment
#  also note to self - should have paid attention to this in genome scans!!!

###
# linear model tests

#linear model fit of Glul.r  
# Q -> RNA ?
anova(lm(Glul.r ~ Sex*Diet, data=mydata),
      lm(Glul.r ~ -1 + A + B + C + D + E + F + G + H + Sex*Diet, data=mydata))

#linear model fit of Glul.p
# Q -> Prot ?
anova(lm(Glul.p ~ Sex*Diet, data=mydata),
      lm(Glul.p ~ -1 + A + B + C + D + E + F + G + H + Sex*Diet, data=mydata))

#linear model fit of Glul RNA condtioned on Prot
# Q -> RNA | Prot ?
anova(lm(Glul.r ~ Glul.p+Sex*Diet, data=mydata),
      lm(Glul.r ~ Glul.p+A + B + C + D + E + F + G + H + Sex*Diet, data=mydata))

#linear model fit of Glul Prot condtioned on RNA
# Q -> Prot | RNA ?
anova(lm(Glul.p ~ Glul.r+Sex*Diet, data=mydata),
      lm(Glul.p ~ Glul.r+A + B + C + D + E + F + G + H + Sex*Diet, data=mydata))

###
#compare model coefficients
RNA.coef <- coefficients(lm(Glul.r ~ -1 + A + B + C + D + E + F + G + H + Sex*Diet, data=mydata))[1:8]
Prot.coef <- coefficients(lm(Glul.p ~ -1 + A + B + C + D + E + F + G + H + Sex*Diet, data=mydata))[1:8]

ggplot(data.frame(RNA.coef, Prot.coef), aes(x=RNA.coef, y=Prot.coef)) + 
  geom_text(label=names(RNA.coef)) + 
  geom_smooth(method="lm")  

# end repeat
####################


####################
# challenge:  Glul is on chromosome 1, but the QTL is on chromosome 10.
#  there must be a trans acting factor that is driving the variation in Glul expression
# can you find it?  

