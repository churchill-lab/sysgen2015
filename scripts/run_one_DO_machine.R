
library("analogsea")
Sys.setenv(DO_PAT = "*** REPLACE THIS BY YOUR DIGITAL OCEAN API KEY ***")

d <- docklet_create(size = getOption("do_size", "8gb"), 
                    region = getOption("do_region", "nyc2"))

# pull images
d %>% docklet_pull("rocker/hadleyverse")
d %>% docklet_pull("simecek/addictioncourse2015")
d %>% docklet_pull("kbchoi/asesuite")
d %>% docklet_images()

# download files from Sanger, takes ~30mins
lines <- "mkdir -p /sanger;
chmod --recursive 755 /sanger;
wget --directory-prefix=/sanger ftp://ftp-mouse.sanger.ac.uk/REL-1505-SNPs_Indels/mgp.v5.merged.snps_all.dbSNP142.vcf.gz.tbi;
wget --directory-prefix=/sanger ftp://ftp-mouse.sanger.ac.uk/REL-1505-SNPs_Indels/mgp.v5.merged.snps_all.dbSNP142.vcf.gz"
cmd <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines))
analogsea:::do_system(d, cmd, verbose = TRUE)

# download KB's data files
lines <- "mkdir -p /kbdata;
chmod --recursive 755 /kbdata;
wget --directory-prefix=/kbdata ftp://ftp.jax.org/kb/individualized.transcriptome.fa.gz;
wget --directory-prefix=/kbdata ftp://ftp.jax.org/kb/rawreads.fastq.gz"
cmd <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines))
analogsea:::do_system(d, cmd, verbose = TRUE)

# run dockers
d %>% docklet_run("-d", " -v /sanger:/sanger", " -p 8787:8787", " -e USER=rstudio", " -e PASSWORD=rstudio ", "simecek/addictioncourse2015") %>% docklet_ps()
d %>% docklet_run("-dt", " -v /sanger:/sanger -v /kbdata:/kbdata", " -p 8080:8080 ", "kbchoi/asesuite") %>% docklet_ps()

# kill droplet
# droplet_delete(d)