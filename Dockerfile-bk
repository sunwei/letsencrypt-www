FROM centos:7

# Add base dependencies, and update
RUN yum -y -q update && \
    yum groupinstall -y "development tools" && \
	yum -y -q install which curl jq git openssl bind-utils wget zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel && \
    yum -y -q clean all

RUN cd /home && \
    wget https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz && \
    tar -zxvf Python-2.7.8.tgz && \
    cd Python-2.7.8 && \
    ./configure && \
    make && \
    make install && \
    yum -y -q clean all
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "pip-install.py" && \
    python pip-install.py && \
    pip install -U pip

# Install aliyun cli...
RUN	pip install aliyuncli && \
    pip install aliyun-python-sdk-alidns

# Add qshell
RUN cd /usr/local/bin && \
    wget https://dn-devtools.qbox.me/2.1.5/qshell-linux-x64 -O qshell && \
    chmod +x qshell && \
    qshell -v && \
    yum -y -q clean all

# Add qshell to the path
ENV PATH=/usr/local/bin/qshell:$PATH

#  install python requests library dependencies
RUN pip install dns-lexicon

# Get dehydrated
RUN cd /usr/local/bin && \
		git clone https://github.com/lukas2511/dehydrated && \
		cd dehydrated && \
		mkdir hooks

# Add Dehdrated to the path
ENV PATH=/usr/local/bin/dehydrated:$PATH

# Our container start point
CMD ["/app/issue.sh"]

WORKDIR /app

# Add our custom hooks
COPY hooks/ /usr/local/bin/dehydrated/hooks/

# Add configs
COPY configs/config.prod /app/

# Add scripts
COPY scripts/* /app/
