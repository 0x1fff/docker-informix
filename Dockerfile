FROM debian:wheezy
MAINTAINER Tomasz Gaweda
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

COPY iif.*.linux-x86_64.tar /
COPY informix_install.sh /informix_install.sh
COPY informix_start.sh /informix_start.sh
COPY informix_stop.sh /informix_stop.sh
RUN chmod +x *.sh
RUN cd / && bash ./informix_install.sh iif.*.linux-x86_64.tar
RUN rm iif.*.linux-x86_64.tar
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN apt-get update \
    && apt-get install -y curl tar \
    && (curl -s -k -L -C - -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.tar.gz | tar xfz - -C /opt) \
    && mv /opt/jdk1.7.0_71/jre /opt/jre1.7.0_71 \
    && mv /opt/jdk1.7.0_71/lib/tools.jar /opt/jre1.7.0_71/lib/ext \
    && rm -Rf /opt/jdk1.7.0_71 \
    && ln -s /opt/jre1.7.0_71 /opt/java \
    && ln -s /opt/java/bin/java /usr/bin

ENV JAVA_HOME /opt/java

RUN apt-get install -y supervisor
COPY /daemonizer.jar /daemonizer.jar
COPY /supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 9088
VOLUME ["/home/informix/data"]
CMD ["/usr/bin/supervisord"]
