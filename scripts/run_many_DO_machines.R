library("analogsea")
library(parallel)
library(doParallel)
Sys.setenv(DO_PAT = "*** REPLACE THIS BY YOUR DIGITAL OCEAN API KEY ***")

participants <- read.csv("participant_list_addiction_course.csv", as.is=TRUE)
N = nrow(participants)

# create a droplet for each participant
droplet_list <- list()

# parallelization would cause API error
for(i in 1:N) {
  print(i)
  # start i-th machine
  droplet_list[[i]] <- docklet_create(size = getOption("do_size", "8gb"),
                                      region = getOption("do_region", "nyc2"))
}

cl <- makeCluster(N)
registerDoParallel(cl)


# pulling docker images
foreach(i = 1:N, .packages="analogsea") %dopar% {
  
  # select droplet
  d = droplet_list[[i]]
  
  # pull docker images
  d %>% docklet_pull("rocker/hadleyverse")
  d %>% docklet_pull("churchill/doqtl")
  d %>% docklet_pull("churchill/asesuite")
  d %>% docklet_pull("ipython/scipystack")
  d %>% docklet_pull("churchill/webapp")
  d %>% docklet_images()
}

# download files to /data folder, takes ~1 hour
foreach(i = 1:N, .packages="analogsea") %dopar% {
  
  # select droplet
  d = droplet_list[[i]]
  
  lines <- "wget https://raw.githubusercontent.com/churchill-lab/sysgen2015/master/scripts/download_data_from_ftp.sh
            /bin/bash download_data_from_ftp.sh
            rm download_data_from_ftp.sh"
  cmd <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines))
  analogsea:::do_system(d, cmd, verbose = TRUE)
}

stopCluster(cl)

# start docker containers
for(i in 1:N) {
  print(i)
  # select droplet
  d = droplet_list[[i]]
  
  d %>% docklet_run("-d", " -v /data:/data", " -p 8787:8787", " -e USER=rstudio", " -e PASSWORD=sysgen ", "churchill/doqtl")
  d %>% docklet_run("-dt", " -v /data:/data", " -p 43210:43210 -p 43211:43211 ", "churchill/asesuite") %>% docklet_ps()
  
}

# start webapp containers (memory intensive, better do not use with kallisto)
#for(i in 1:N) {
#  d = droplet_list[[i]]
#  d %>% docklet_run("-dt", " -v /data:/data", " -p 8888:8888 -p 8889:8889 ", "churchill/webapp /usr/bin/start-app.sh") %>% docklet_ps()
#}


### Create participant table with links
participants$DO_machine <- sapply(droplet_list, function(x) x$name)
participants$link_RStudio <- sapply(droplet_list, function(x) paste0("http://",analogsea:::droplet_ip(x),":8787"))
participants$link_terminal <- sapply(droplet_list, function(x) paste0("http://",analogsea:::droplet_ip(x),":43210"))

library(xtable)
sanitize.text.function <- function(x) {
  idx <- substr(x, 1, 7) == "http://"
  x[idx] <- paste0('<a href="',x[idx],'">',sub("^http://","",x[idx]),'</a>')
  x
}
cols <- c("BadgeName", "DO_machine", "link_RStudio", "link_terminal")
print(xtable(participants[,cols], caption="Digital Ocean Machines"),
      type = "html", sanitize.text.function = sanitize.text.function,
      file = "dolist.html", include.rownames=FALSE)

### Send emails to course participants
library(mailR)


for (i in 1:N) {
  email_body <- paste0("Dear ",participants$first_Name[i],",\n\n",
                       "During the workshop, you will need an access to RStudio and terminal ",
                       "running on your personal Digital Ocean machine. You can access the machine ",
                       "directly in your browser:\n\n",
                       participants$link_RStudio[i]," (RStudio, user:rstudio, password:sysgen)\n",
                       participants$link_terminal[i]," (terminal, user:root, password:sysgen)\n\n",
                       "After the workshop you can run this docker image either on your personal machine or host it ",
                       "on Digital Ocean (as we did). Further instructions can be found on https://github.com/churchill-lab/sysgen2015.\n\n",
                       "Best regards,\n\n","Petr Simecek")
  
  send.mail(from = "REPLACE THIS BY YOUR_GMAIL@gmail.com",
            to = participants$Email_Address[i],
            replyTo = "REPLACE THIS BY YOUR_EMAIL",
            subject = "Short Course On The Genetics Of Addiction - Digital Ocean Machine Access",
            body = email_body,
            smtp = list(host.name = "smtp.gmail.com", port = 465, 
                        user.name = "REPLACE THIS BY YOUR_GMAIL@gmail.com", 
                        passwd = "***YOUR PASSWORD***", ssl = TRUE),
            authenticate = TRUE,
            send = TRUE)
}