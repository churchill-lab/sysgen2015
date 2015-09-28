####################################
#  First Pass analysis of DO liver 192
#  Part II:  Are RNA and Protein correlated?
#
#  Copyright Gary A Churchill
#  created:    Sept 23, 2015 
#  modified:
############
#set up the environment

# load graphics package 
library(ggplot2)

# load the data
load("/data/Rdata/DO192_DataforSysGenCourse.Rdata")

#end setup
####################################
# Are protein and rna expression correlated?

####
# create a matrix of rna expr data corresponding to each protein
# 
# create an index of proteins that have a corresponding rna expression trait
idx.protein <- which(annotations.protein.192$Ensembl.Gene.ID %in% annotations.rna.192$EnsemblID)

# create an index of rna traits to match the protein index
idx.rna     <- match(annotations.protein.192$Ensembl.Gene.ID[idx.protein], annotations.rna.192$EnsemblID)

#check that the Ensembl Gene IDs of the two indices match
all(annotations.protein.192$Ensembl.Gene.ID[idx.protein] == annotations.rna.192$EnsemblID[idx.rna])

#look at how many rna and protein expression traits are matched
length(idx.rna)
length(unique(idx.rna))
length(idx.protein)
length(unique(idx.protein))
# there are 8045 proteins corresponding to 7939 RNAs

####
#compute the pairwise correlations
# using a loop - clunky but it works
cor.ProtRNA <- NULL
for(i in 1:length(idx.protein)){
  cor.ProtRNA <- c(cor.ProtRNA,
                   cor(expr.rna.192[,idx.rna[i]], expr.protein.192[,idx.protein[i]], use="complete.obs"))
}

# plot the distribution of correlation values
qplot(cor.ProtRNA, binwidth=0.02)
#  this picture is worth a thousand words
#
# another way to draw the same plot
#  ggplot()+geom_histogram(aes(x=cor.ProtRNA), binwidth=0.02)

#interesting that some of the correlations are negative
# what is the names of the most negatively correlated gene?
annotations.protein.192$Associated.Gene.Name[idx.protein[which(cor.ProtRNA < -0.5)]]

#plot rna x prot expression
i <- which(cor.ProtRNA < -0.5)
qplot(expr.rna.192[,idx.rna[i]], expr.protein.192[,idx.protein[i]], 
      color=covariates.protein.192$Sex, shape=covariates.protein.192$Sex) + 
  geom_point(size=4) + geom_smooth(method="lm", se=FALSE) +
  ggtitle(annotations.protein.192$Associated.Gene.Name[idx.protein[i]])
# the indexing makes this a little convoluted

######
#look at a Protein x RNA scatterplot of your favorite gene

# find index corresponding to a gene name in protein array
p.indx <- which(annotations.protein.192$Associated.Gene.Name == "Glul")

# get the Ensembl Gene ID to find corresponding rna
r.indx <- annotations.protein.192[p.indx, "Ensembl.Gene.ID"]

#draw the plot
qplot(expr.rna.192[,r.indx], expr.protein.192[,p.indx], 
      color=covariates.protein.192$Sex, shape=covariates.protein.192$Sex) + 
  geom_point(size=4) + geom_smooth(method="lm", se=FALSE) +
  ggtitle(annotations.protein.192$Associated.Gene.Name[p.indx])

###
# if you can't recall correct gene symbol, use grep to help search the annotations
grep("Glu*", annotations.protein.192$Associated.Gene.Name, value=TRUE)

#end of protein rna correlations
######
