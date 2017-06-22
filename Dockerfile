FROM kbase/kbase:sdkbase.latest
MAINTAINER KBase Developer
# -----------------------------------------
# In this section, you can install any system dependencies required
# to run your App.  For instance, you could place an apt-get update or
# install line here, a git checkout to download code, or run any other
# installation scripts.

RUN apt-get update && apt-get install -y sysstat

# Here we install a python coverage tool and an
# https library that is out of date in the base image.

RUN pip install coverage

# update security libraries in the base image
RUN pip install cffi --upgrade \
    && pip install pyopenssl --upgrade \
    && pip install ndg-httpsclient --upgrade \
    && pip install pyasn1 --upgrade \
    && pip install requests --upgrade \
    && pip install 'requests[security]' --upgrade

# ---------------------------------------------------------

# download Cufflinks software and untar it
ENV VERSION='2.2.1'
ENV DEST=/opt/cufflinks

RUN cd /opt && \
    mkdir -p $DEST && \
    wget "http://cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-${VERSION}.Linux_x86_64.tar.gz" && \
    tar -xzvf cufflinks-${VERSION}.Linux_x86_64.tar.gz && \
    rm cufflinks-${VERSION}.Linux_x86_64.tar.gz && \
    cd cufflinks-${VERSION}.Linux_x86_64 && \
	cp `find . -maxdepth 1 -perm -111 -type f` ${DEST} && \
	cd ../ && \
	rm -rf cufflinks-${VERSION}.Linux_x86_64

ENV PATH $PATH:${DEST}

# ---------------------------------------------------------

# download gffread script
RUN cd /kb/dev_container/modules && \
    mkdir gffread && cd gffread && \
    wget http://ccb.jhu.edu/software/stringtie/dl/gffread-0.9.9.Linux_x86_64.tar.gz &&\
    tar xvfz gffread-0.9.9.Linux_x86_64.tar.gz && \
    cd gffread-0.9.9.Linux_x86_64 && \
    mkdir /kb/deployment/bin/gffread && \
    cp -R gffread /kb/deployment/bin/gffread/gffread

# ---------------------------------------------------------

COPY ./ /kb/module
RUN mkdir -p /kb/module/work
RUN chmod -R a+rw /kb/module

WORKDIR /kb/module

RUN make all

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]
