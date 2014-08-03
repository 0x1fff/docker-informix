FROM ubuntu:14.10
MAINTAINER Tomasz Gaweda
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
COPY iif.12.10.FC3DE.linux-x86_64.tar /iif.12.10.FC3DE.linux-x86_64.tar
COPY informix_install.sh /informix_install.sh
COPY informix_start.sh /informix_start.sh
RUN bash ./informix_install.sh iif.12.10.FC3DE.linux-x86_64.tar
USER informix
RUN bash informix_start.sh
CMD ["/bin/bash"]
