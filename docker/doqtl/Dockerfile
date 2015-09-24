## Based on rocker / hadleyverse maintained by Carl Boettiger and Dirk Eddelbuettel
FROM rocker/hadleyverse

MAINTAINER "Daniel Gatti" dan.gatti@jax.org

# install additional BioC scripts
RUN install2.r --error qtl
# DOQTL and dependencies.
RUN Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite(c("annotate", "annotationTools", "biomaRt", "Biobase", "BiocGenerics", "corpcor", "doParallel", "foreach", "fpc", "ggbio", "hwriter", "IRanges", "iterators", "mclust", "MUGAExampleData", "QTLRel", "regress", "rhdf5", "Rsamtools", "RUnit", "XML"), ask=FALSE)'
RUN Rscript -e 'install.packages(pkgs = "devtools", dependencies = TRUE)'
RUN Rscript -e 'library(devtools); install_github(repo = "dmgatti/DOQTL")'
# Create directory structure.
RUN mkdir -p /data
RUN mkdir -p /data/emase
RUN mkdir -p /data/eQTL
RUN mkdir -p /data/pQTL
RUN mkdir -p /data/Rdata
RUN mkdir -p /data/scripts
RUN mkdir -p /data/tutorials
RUN chmod --recursive 755 /data
# Copy the expression, protein, probs, K & snps data.
RUN wget --directory-prefix=/data/Rdata ftp://ftp.jax.org/dgatti/ShortCourse2015/DO192_DataforSysGenCourse.Rdata
RUN wget --directory-prefix=/data/Rdata ftp://ftp.jax.org/dgatti/ShortCourse2015/DO192_DataforSysGenCourse_update.Rdata
# Copy the eQTL data.
RUN wget --directory-prefix=/data/eQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/eQTL/eQTL_for_viewer.h5
RUN wget --directory-prefix=/data/eQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/eQTL/eQTL_for_viewer.h5
RUN wget --directory-prefix=/data/eQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/eQTL/eQTL_summary.csv
# Copy the pQTL data.
RUN wget --directory-prefix=/data/pQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/pQTL/pQTL_for_viewer.h5
RUN wget --directory-prefix=/data/pQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/pQTL/pQTL_for_viewer.h5
RUN wget --directory-prefix=/data/pQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/pQTL/pQTL_summary.csv
# DOQTL tutorial.
RUN wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/DO.circle.figure.png
RUN wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/DO.impute.founders.png
RUN wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/DOQTL_workshop_2015.html
RUN wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/DOQTL_workshop_2015.R
RUN wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/DOQTL_workshop_2015.Rmd
RUN wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/haplotype_probs.png
# Data for EMASE/Kallisto
RUN wget --directory-prefix=/data/emase ftp://ftp.jax.org/dgatti/ShortCourse2015/emase/emase.pooled.transcripts.fa
RUN wget --directory-prefix=/data/emase ftp://ftp.jax.org/dgatti/ShortCourse2015/emase/mouse.ids.txt
RUN wget --directory-prefix=/data/emase ftp://ftp.jax.org/dgatti/ShortCourse2015/emase/rawreads.fastq.gz
# Symbolic link from /data to home/data
RUN ln -s /data ~/data
