#
#  url:         https://github.com/0x1fff/docker-informix
#

FROM debian:wheezy
MAINTAINER Tomasz Gaweda
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

ENV http_proxy http://172.17.42.1:8080/

RUN    apt-get update && apt-get -y install wget                            \
	&& wget -q http://172.17.42.1:9090/iif.12.10.FC4DE.linux-x86_64.tar     \
	&& wget -q http://172.17.42.1:9090/docker-informix/informix_install.sh  \
	&& wget -q http://172.17.42.1:9090/docker-informix/informix_start.sh    \
	&& wget -q http://172.17.42.1:9090/docker-informix/informix_stop.sh     \
	&& bash ./informix_install.sh iif.*.linux-x86_64.tar                    \
	&& rm iif.*.linux-x86_64.tar

RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# EXPOSE 9088

VOLUME ["/home/informix/data"]
USER informix
CMD /bin/bash informix_start.sh ; /bin/bash ; /bin/bash informix_stop.sh
