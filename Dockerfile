FROM centos:7

# Add base dependencies, and update
RUN yum -y -q update && \
    yum groupinstall -y "development tools" && \
	  yum -y -q install which curl jq git openssl bind-utils wget zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel && \
    yum -y -q clean all

# Get Let's Encrypt WWW latest version from GitHub
#RUN cd /usr/local/bin && \
#		git clone https://github.com/sunwei/letsencrypt-www && \
#		mv ./letsencrypt-www ./www && \
#		cd www && \
#		mkdir hooks

WORKDIR /app
COPY . /app/

# Get Let's Encrypt WWW locally
RUN cd /usr/local/bin && \
		mkdir www && cd www && \
		yes | cp -rf /app/* ./

ENV PATH=/usr/local/bin/www:$PATH

CMD ["/app/docker-entrience.sh"]
