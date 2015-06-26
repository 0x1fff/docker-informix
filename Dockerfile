FROM debian:wheezy
MAINTAINER Tomasz Gaweda
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

COPY iif.11.50.FC7DE.linux-x86_64.tar /iif.11.50.FC7DE.linux-x86_64.tar
COPY informix_install.sh /informix_install.sh
COPY informix_start.sh /informix_start.sh
COPY informix_stop.sh /informix_stop.sh
RUN chmod +x *.sh
RUN cd / && bash ./informix_install.sh iif.*.linux-x86_64.tar
RUN rm iif.*.linux-x86_64.tar
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

EXPOSE 9088

VOLUME ["/home/informix/data"]
USER informix
CMD /bin/bash informix_start.sh ; /bin/bash ; /bin/bash informix_stop.sh
