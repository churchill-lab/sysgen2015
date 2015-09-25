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

# Create directory structure.
RUN mkdir -p /data
RUN mkdir -p /data/eQTL
RUN mkdir -p /data/pQTL
RUN mkdir -p /data/webapp
RUN wget --recursive --no-parent --directory-prefix=/data ftp://ftp.jax.org/dgatti/ShortCourse2015/webapp/
RUN mv /data/ftp.jax.org/dgatti/ShortCourse2015/webapp /data
RUN rm -rf /data/ftp.jax.org

# Copy the eQTL data.
RUN wget --directory-prefix=/data/eQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/eQTL/eQTL_for_viewer.h5
RUN wget --directory-prefix=/data/eQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/eQTL/eQTL_for_viewer.h5
RUN wget --directory-prefix=/data/eQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/eQTL/eQTL_summary.csv
# Copy the pQTL data.
RUN wget --directory-prefix=/data/pQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/pQTL/pQTL_for_viewer.h5
RUN wget --directory-prefix=/data/pQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/pQTL/pQTL_for_viewer.h5
RUN wget --directory-prefix=/data/pQTL ftp://ftp.jax.org/dgatti/ShortCourse2015/pQTL/pQTL_summary.csv
RUN chmod --recursive 755 /data

EXPOSE 8888
EXPOSE 8889

RUN chmod 755 /data/webapp/run-eqtl.sh
RUN chmod 755 /data/webapp/run-pqtl.sh

CMD['python', '/data/webapp/eqtl-viewer/src/application.py', 'eqtl.cfg']
CMD['python', '/data/webapp/pqtl-viewer/src/application.py', 'pqtl.cfg']

