## Docker Images

During the course we use 3 docker images:
* [churchill/asesuite](https://hub.docker.com/r/churchill/asesuite/) to access butterfly terminal with kalisto, EMASE... preinstalled
* [churchill/doqtl](https://hub.docker.com/r/churchill/doqtl/) to access RStudio with DOQTL and DESeq2 preinstalled (derived from rocker/hadleyverse)
* [churchill/webapp](https://hub.docker.com/r/churchill/webapp/) to run eQTL, pQTL viewers (derived from ipython/scipystack)

See subfolders for Dockerfiles and [Docker Hub](https://hub.docker.com/r/churchill/webapp/) for build details.
At the time of the course, build codes have been "blkwyli6febvwfxyepkbovy", "b5wvc6vyvrcnfqofjwrwpee" and "byndh5qjqzaeepwuq8qznzg", respectively.

On any computer with docker software installed, you can download the images using the code below:

```{r}
  docker pull churchill/asesuite
  docker pull churchill/doqtl
  docker pull churchill/webapp
```

And run them as follows:

```{r}
  docker run -d -v /data:/data -p 8787:8787 -e USER=rstudio -e PASSWORD=sysgen churchill/doqtl
  docker run -dt -v /data:/data -p 43210:43210 -p 43211:43211  churchill/asesuite
  docker run -dt -v /data:/data -p 8888:8888 -p 8889:8889 churchill/webapp /usr/bin/start-app.sh
```
