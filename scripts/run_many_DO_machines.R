library("analogsea")
library(parallel)
library(doParallel)
Sys.setenv(DO_PAT = "*** REPLACE THIS BY YOUR DIGITAL OCEAN API KEY ***")

participants <- read.csv("participant_list_addiction_course.csv", as.is=TRUE)
N = nrow(participants)

cl <- makeCluster(N)
registerDoParallel(cl)

droplet_list <- foreach(i=1:N, .packages="analogsea") %dopar% {
  
  # start machine
  d <- docklet_create(size = getOption("do_size", "8gb"), 
                      region = getOption("do_region", "nyc2"))
  
  d
}

# pulling docker images
foreach(i = 1:N, .packages="analogsea") %dopar% {
  
  # select droplet
  d = droplet_list[[i]]
  
  # pull docker images 
  d %>% docklet_pull("rocker/hadleyverse")
  d %>% docklet_pull("simecek/addictioncourse2015")
  d %>% docklet_pull("kbchoi/asesuite")
  d %>% docklet_images()
}

# downloading Sanger data
foreach(i = 1:N, .packages="analogsea") %dopar% {
  
  # select droplet
  d = droplet_list[[i]]
  
  lines <- "mkdir -p /sanger;
  chmod --recursive 755 /sanger;
  wget --directory-prefix=/sanger ftp://ftp-mouse.sanger.ac.uk/REL-1505-SNPs_Indels/mgp.v5.merged.snps_all.dbSNP142.vcf.gz.tbi;
  wget --directory-prefix=/sanger ftp://ftp-mouse.sanger.ac.uk/REL-1505-SNPs_Indels/mgp.v5.merged.snps_all.dbSNP142.vcf.gz"
  cmd <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines))
  analogsea:::do_system(d, cmd, verbose = TRUE)

}

# downloading KB's data
foreach(i = 1:N, .packages="analogsea") %dopar% {
  
  # select droplet
  d = droplet_list[[i]]
  
  lines <- "mkdir -p /kbdata;
  chmod --recursive 755 /kbdata;
  wget --directory-prefix=/kbdata ftp://ftp.jax.org/kb/individualized.transcriptome.fa.gz;
  wget --directory-prefix=/kbdata ftp://ftp.jax.org/kb/rawreads.fastq.gz"
  cmd <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines))
  analogsea:::do_system(d, cmd, verbose = TRUE)
  
}

# start the dockers
foreach(i = 1:N, .packages="analogsea") %dopar% {
  
  # select droplet
  d = droplet_list[[i]]
  
  d %>% docklet_run("-d", " -v /sanger:/sanger", " -p 8787:8787", " -e USER=rstudio", " -e PASSWORD=rstudio ", "simecek/addictioncourse2015") %>% docklet_ps()
  d %>% docklet_run("-dt", " -v /sanger:/sanger -v /kbdata:/kbdata", " -p 8080:8080 ", "kbchoi/asesuite") %>% docklet_ps()
  
}

stopCluster(cl)

### Create participant table with links
participants$DO_machine <- sapply(droplet_list, function(x) x$name)
participants$link_RStudio <- sapply(droplet_list, function(x) paste0("http://",analogsea:::droplet_ip(x),":8787"))
participants$link_terminal <- sapply(droplet_list, function(x) paste0("http://",analogsea:::droplet_ip(x),":8080"))

library(xtable)
sanitize.text.function <- function(x) {
  idx <- substr(x, 1, 7) == "http://"
  x[idx] <- paste0('<a href="',x[idx],'">',sub("^http://","",x[idx]),'</a>')
  x
}
cols <- c("badgeName", "DO_machine", "link_RStudio", "link_terminal")
print(xtable(participants[,cols], caption="Digital Ocean Machines"), 
      type = "html", sanitize.text.function = sanitize.text.function,
      file = "dolist.html", include.rownames=FALSE)

### Send emails to course participants
library(mailR)


for (i in 1:N) {
  email_body <- paste0("Dear ",participants$first_Name[i],",\n\n",
                       "During the workshop, you will need an access to RStudio and/or terminal ",
                       "running on your personal Digital Ocean machine. You can access the machine ",
                       "directly in your browser:\n\n",
                       participants$link_RStudio[i]," (RStudio, user:rstudio, password:rstudio)\n",
                       participants$link_terminal[i]," (terminal, user:root, password:root)\n\n",
                       "After the workshop you can run this docker image either on your personal machine or host it ",
                       "on Digital Ocean (as we did). Further instructions can be found on https://github.com/simecek/AddictionCourse2015.\n\n",
                       "Best regards,\n\n","Petr Simecek")
  
  send.mail(from = "REPLACE THIS BY YOUR_GMAIL@gmail.com",
            to = participants$email_Address[i],
            replyTo = "REPLACE THIS BY YOUR_EMAIL",
            subject = "Short Course On The Genetics Of Addiction - Digital Ocean Machine Access",
            body = email_body,
            smtp = list(host.name = "smtp.gmail.com", port = 465, 
                        user.name = "REPLACE THIS BY YOUR_GMAIL@gmail.com", 
                        passwd = "***YOUR PASSWORD***", ssl = TRUE),
            authenticate = TRUE,
            send = TRUE)
}