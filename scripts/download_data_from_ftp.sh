# make /data folder and subfolders
mkdir -p /data
mkdir -p /data/eQTL
mkdir -p /data/pQTL
mkdir -p /data/Rdata
mkdir -p /data/scripts
mkdir -p /data/tutorials

# Copy the expression, protein, probs, K & snps data.
wget --directory-prefix=/data/Rdata ftp://ftp.jax.org/dgatti/ShortCourse2015/DO192_DataforSysGenCourse.Rdata

# Copy the eQTL data.
wget --directory-prefix=/data/eQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/eQTL/eQTL_for_viewer.h5
wget --directory-prefix=/data/eQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/eQTL/eQTL_perms.Rdata
wget --directory-prefix=/data/eQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/eQTL/eQTL_summary.csv

# Copy the pQTL data.
wget --directory-prefix=/data/pQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/pQTL/pQTL_for_viewer.h5
wget --directory-prefix=/data/pQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/pQTL/pQTL_perms.Rdata
wget --directory-prefix=/data/pQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/pQTL/pQTL_summary.csv

# DOQTL tutorial.
wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/DO.circle.figure.png
wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/DO.impute.founders.png
wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/DOQTL_workshop_2015.html
wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/DOQTL_workshop_2015.R
wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/DOQTL_workshop_2015.Rmd
wget --directory-prefix=/data/tutorials ftp://ftp.jax.org/dgatti/ShortCourse2015/tutorials/haplotype_probs.png

# Data for EMASE/Kallisto
wget --recursive --level=20 --directory-prefix=/data ftp://ftp.jax.org/dgatti/ShortCourse2015/emase/
mv /data/ftp.jax.org/dgatti/ShortCourse2015/emase /data/emase
rm -rf /data/ftp.jax.org

# Symbolic link from /data to home/data
ln -s /data ~/data

# webapp 
wget --recursive --level=20 --directory-prefix=/data ftp://ftp.jax.org/dgatti/ShortCourse2015/webapp/
mv /data/ftp.jax.org/dgatti/ShortCourse2015/webapp /data/webapp
rm -rf /data/ftp.jax.org

# set privilages - everybody can do everything
chmod --recursive 777 /data
