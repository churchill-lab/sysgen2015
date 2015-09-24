# Install pieces of Matt's eQTL and pQTL viewers
FROM ipython/scipystack
MAINTAINER Petr Simecek <petrs@jax.org>

# Install addition Python packages
RUN pip install h5py
RUN pip install flask
RUN pip install flask-compress
RUN pip install flask-cors

# Install wget
RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

# HDF5 installation
RUN wget http://www.hdfgroup.org/ftp/HDF5/current/bin/linux-centos6-x86_64/hdf5-1.8.15-patch1-linux-centos6-x86_64-shared.tar.gz
RUN tar xvfz hdf5-1.8.15-patch1-linux-centos6-x86_64-shared.tar.gz && \
    cp -R hdf5-1.8.15-patch1-linux-centos6-x86_64-shared/* /usr/ && \
    rm -Rf hdf*

# Copy the data over from ftp.jax.org.
RUN mkdir -p /data
RUN mkdir -p /data/webapp
RUN wget --recursive --no-parent --directory-prefix=/data ftp://ftp.jax.org/dgatti/ShortCourse2015/webapp/
RUN mv /data/ftp.jax.org/dgatti/ShortCourse2015/webapp /data
RUN rm -rf /data/ftp.jax.org

EXPOSE 888
ENTRYPOINT ["butterfly.server.py"]
CMD ["--unsecure", "--port=8888", "--host=0.0.0.0"]

EXPOSE 8889
ENTRYPOINT ["butterfly.server.py"]
CMD ["--unsecure", "--port=8889", "--host=0.0.0.0"]

RUN chmod -r 755 /data/webapp

CMD /data/webapp/run-eqtl.sh
CMD /data/webapp/run-pqtl.sh

