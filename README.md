docker-informix
===================

Debian/Ubuntu based docker container with IBM Informix Dynamic Server.

The Informix Database Server is offered in a number of editions, including free developer editions, editions for small and mid-sized business, 
and editions supporting the complete feature set and designed to be used in support of the largest enterprise applications. 
If you are confused which version of Informix choose use [Informix feature description](http://www.ibm.com/developerworks/data/library/techarticle/dm-0801doe/index.html#table).

Informix is generally considered to be optimized for environments with very low or no database administration, 
including use as an embedded database. It has a long track record of supporting very high transaction rates 
and providing uptime characteristics needed for mission critical applications such as manufacturing lines 
and reservation systems. Informix has been widely deployed in the retail sector, where the low administration 
overhead makes it useful for in-store deployments.

To use this project you have to [download Informix installation files from IBM Informix Download page](http://www-01.ibm.com/software/data/informix/downloads.html) on your own (registration required).

Recently IBM announced cloud platform called [Bluemix](http://bluemix.net/), but there is no Informix Database Software on this service (there is PostgreSQL, MySQL, MongoDB) so I have created this project to provide Docker container with Informix. 

I am not sure if this container is production ready. I am using it for my developement and testing.


Building Informix container image (Ubuntu host)
---------------------------------------------

```bash
## Remove standard Ubuntu Docker installation and install most recent Docker
sudo apt-get purge docker.io
curl -s https://get.docker.io/ubuntu/ | sudo sh

## Create enviroment for docker-informix container build
mkdir informix_build
cd informix_build
git clone https://github.com/0x1fff/docker-informix.git

## Download IBM Informix installation files from IBM and copy it
cp iif.*.linux-x86_64.tar .

## Start HTTP server with Informix image
python -m SimpleHTTPServer 9090 &
PY_HTTP=$!

## Build docker image (Dockerfile may require minor changes)
sudo docker build -t docker-informix docker-informix

## Shutdown HTTP server
kill $PY_HTTP
```


Starting Informix container (Ubuntu host)
---------------------------------------------

### Creating Informix with volume and expose it on port 9088
```bash
sudo docker run -it -v "/home/informix/data/" -p 9088:9088 --name informix docker-informix
```


### The same as above but create also new empty "test" database

```bash
sudo docker run -it -v "/home/informix/data/" -p 9088:9088 --name informix -e DB_USER=test -e DB_PASS=test -e DB_NAME=test docker-informix
```

### Using created container (Informix Database)

```
johny@ThinkPad:~/$ docker ps -a
CONTAINER ID        IMAGE                    COMMAND             CREATED             STATUS                     PORTS               NAMES
00e73b00c498        docker-informix:latest   "/bin/bash"         About an hour ago   Exited (0) 6 seconds ago                       informix   

johny@ThinkPad:~/$ docker start 00e73b00c498
00e73b00c498

johny@ThinkPad:~/$ docker attach 00e73b00c498

IDS-12.10 dev: 
IDS-12.10 dev: 
IDS-12.10 dev: 
```

Connect to your Informix database
---------------------------------------

For connecting to Informix Database you can use [SQLWorkbench/J](http://www.sql-workbench.net/) with additional 
JDBC Drivers which are in Informix Bundle or can be downloaded separetly from [IBM Informix JDBC Driver Download Page](http://www14.software.ibm.com/webapp/download/search.jsp?go=y&rs=ifxjdbc).

JDBC connect string

````
jdbc:informix-sqli://127.0.0.1:9088/test:INFORMIXSERVER=dev;user=test;password=test;CLIENT_LOCALE=en_US.utf8;DB_LOCALE=en_US.utf8
````

Available and supported Informix Editions for Docker (x86_64 versions only)
----------------------------------------------------------------------------------

 * 12.10FC4TL - Informix Enterprise Time-Limited Edition for Linux x86_64 (iif.12.10.FC4TL.linux-x86_64.tar)
 * 12.10FC4DE - Informix Developer Edition for Linux x86_64 (iif.12.10.FC4DE.linux-x86_64.tar)
 * 12.10FC4IE - Informix Innovator-C Edition for Linux x86_64 (iif.12.10.FC4IE.linux-x86_64.tar)
 * 11.70FC8DE - Informix Developer Edition for Linux x86_64 (iif.11.70.FC8DE.linux-x86_64.tar)
 * 11.70FC8IE - Informix Innovator-C Edition for Linux x86_64 (iif.11.70.FC8IE.linux-x86_64.tar)
 * 11.50FC9DE - Informix Developer Edition for Linux x86_64 (iif.11.50.FC9DE.linux-x86_64.tar)


| Informix Version (x86_64)     | Ubuntu 14.10       | Ubuntu 14.04       | Debian 7 (wheezy)  |
| :-----------------------------|:------------------:|:------------------:|:------------------:|
| 12.10.FC4 Time Limited        | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| 12.10.FC4 Innovator Edition   | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| 12.10.FC4 Developer Edition   | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| 11.70.FC8 Developer Edition   | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| 11.70.FC8 Innovator Edition   | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| 11.70.FC8 Time Limited        | :white_check_mark: | :white_check_mark: | :white_check_mark: |


### Legend:

 * :white_check_mark: - Installation completed succesfully
 * :x: - Instalation failed
 * :pushpin: - Notes
 
### Additional notes:

1. Informix installation script supports only Informix 11.70 and later.

2. Informix installation script supports only Debian 7 Wheezy and Ubuntu 14.04 LTS+ OS.

3. It is known that Informix installation script runs smoothly on Ubuntu 13.10, Ubuntu 12.04 but I will not support it officialy.
   Other versions of Ubuntu (Ubuntu 13.04, Ubuntu 12.10, Ubuntu 10.04) are not working due to end of support from Canoncial. 

4. If your Informix version is released after 11.50FC9DE it will be probably also supported.

For more information about this refer to [supported platforms for Informix](http://www-01.ibm.com/support/docview.wss?uid=swg27013343#linux) on IBM website 
and [Ubuntu LTS Release cycle](https://wiki.ubuntu.com/LTS).

How container building looks like
-----------------------------------

````
johny@ThinkPad:~/Pulpit/projects/github$ sudo docker build -t docker-informix docker-informix 
Sending build context to Docker daemon 154.6 kB
Sending build context to Docker daemon 
Step 0 : FROM debian:wheezy
 ---> f6fab3b798be
Step 1 : MAINTAINER Tomasz Gaweda
 ---> Running in 94c33b1c5cf3
 ---> 327f8ea65618
Removing intermediate container 94c33b1c5cf3
Step 2 : RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
 ---> Running in 2bd5145f5f0d
 ---> d144b00bcda7
Removing intermediate container 2bd5145f5f0d
Step 3 : ENV http_proxy http://172.17.42.1:8080/
 ---> Running in 0918c5880aca
 ---> 4b1e343d3cdf
Removing intermediate container 0918c5880aca
Step 4 : RUN apt-get update && apt-get -y install wget
 ---> Running in c062c68e30a6
Get:1 http://security.debian.org wheezy/updates Release.gpg [836 B]
Get:2 http://security.debian.org wheezy/updates Release [102 kB]
Get:3 http://http.debian.net wheezy Release.gpg [1655 B]
Get:4 http://http.debian.net wheezy-updates Release.gpg [836 B]
Get:5 http://http.debian.net wheezy Release [168 kB]
Get:6 http://security.debian.org wheezy/updates/main amd64 Packages [287 kB]
...
...
...
Setting up wget (1.13.4-3+deb7u2) ...
###############################################
# IBM Informix Installation script for Debian #
###############################################
>>>    OS version: Debian 7.7
>>>    Linux Kernel version: Linux 064f0e1ce709 3.13.0-43-generic #72-Ubuntu SMP Mon Dec 8 19:35:06 UTC 2014 x86_64 GNU/Linux
>>>    Upgrading OS and installing dependencies for Informix 12.10
Get:1 http://security.debian.org wheezy/updates Release.gpg [836 B]
Get:2 http://security.debian.org wheezy/updates Release [102 kB]
Get:3 http://security.debian.org wheezy/updates/main amd64 Packages [287 kB]
...
...
...
Setting up mksh (40.9.20120630-7) ...
update-alternatives: using /bin/mksh to provide /bin/ksh (ksh) in auto mode
Setting up pdksh (40.9.20120630-7) ...
>>>    Create group and user for Informix
>>>    Uncompress Informix Archive: iif.12.10.FC4DE.linux-x86_64.tar
>>>    Launch silent install ...
...
...
...
>>>    Postconfig onconfig ...
>>>    Postconfig sqlhost ...
>>>    Include tcp support ...
>>>    Create informix user environnement
>>>    Chown Informix binary directory structure
>>>    Create data directory
>>>    Deleting unpacked files
>>>    Deleting downloaded packages
###############################################
#         Installation completed              #
###############################################
 ---> 0882dd952081
Removing intermediate container 101f906ac264
Step 5 : RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
 ---> Running in c25b3c8037fd
 ---> b4039e0f53c3
Removing intermediate container c25b3c8037fd
Step 6 : VOLUME /home/informix/data
 ---> Running in b3c5b5e5b3e0
 ---> 3fb24892267c
Removing intermediate container b3c5b5e5b3e0
Step 7 : USER informix
 ---> Running in d08eecd141bb
 ---> 5cc434bd8078
Removing intermediate container d08eecd141bb
Step 8 : CMD [ /bin/bash informix_start.sh ; /bin/bash ; /bin/bash informix_stop.sh ]
 ---> Running in 77efa4c00477
 ---> 65982dbe23da
Removing intermediate container 77efa4c00477
Successfully built 65982dbe23da
````

How does starting container for the first time looks like?
--------------------------------------------------------------

```
johny@ThinkPad:~/$ sudo docker run -it -v "/home/informix/data/" -p 9088:9088 --name informix -e DB_USER=test -e DB_PASS=test -e DB_NAME=test docker-informix
>>>    Create data directory structure in /home/informix//data/ (ifx initialization)
>>>    Create user "test"...
>>>    Starting up the IBM Informix Database (dev) ... 
*** Startup of dev SUCCESS ***
>>>    Create database "test"...
>>>    Grant DBA to database "test" for user "test"...
IBM Informix Dynamic Server Version 12.10.FC4DE Software Serial Number AAA#B000000
  #################################################
  # Informix container login information:          
  #   database:    test                  
  #   user:        test                  
  #   password:    test                  
  #################################################

IDS-12.10 dev: exit
>>>    Stopping the IBM Informix Database (dev) ... 
*** Shutdown of dev SUCCESS ***
```


How does resuming stopped container looks like?
-----------------------------------------------------------------------

```
johny@ThinkPad:~/$ docker ps -a
CONTAINER ID        IMAGE                    COMMAND                CREATED             STATUS                     PORTS               NAMES
c7cc39dd2e7f        docker-informix:latest   "/bin/sh -c '/bin/ba   5 minutes ago       Exited (0) 2 seconds ago                       informix           


johny@ThinkPad:~/$ docker start -ai c7cc39dd2e7f
>>>    Starting up the IBM Informix Database (dev) ... 
*** Startup of dev SUCCESS ***
IBM Informix Dynamic Server Version 12.10.FC4DE Software Serial Number AAA#B000000
  #################################################
  # Informix container login information:          
  #   database:    test                  
  #   user:        test                  
  #   password:    test                  
  #################################################

IDS-12.10 dev: exit
>>>    Stopping up the IBM Informix Database (dev) ... 
*** Shutdown of dev SUCCESS ***
```


Is docker-informix container ready for production use?
--------------------------------------------------------

This Dockerfile is created with "best practices" in mind but if you would like to deploy it as production you 
should read more about "data only container pattern" and docker volumes from this links [1](https://docs.docker.com/userguide/dockervolumes/), [2](https://groups.google.com/forum/#!msg/docker-user/EUndR1W5EBo/4hmJau8WyjAJ), [3](http://container42.com/2014/11/03/docker-indepth-volumes/), [4](http://container42.com/2014/11/18/data-only-container-madness/), you may also want to use docker links [5](http://learning-continuous-deployment.github.io/docker/images/dockerfile/database/persistence/volumes/linking/container/2015/05/29/docker-and-databases/).

If you are planing to run it on production you should also change configuration of Informix Database - now it is almost default. 
For more informations please refer to [Informix Innovator-C - quick start guide](http://www.informix-dba.com/p/informix-innovator-c-quick-start-guide.html).


What is missing in this repository
------------------------------------------

 * Perl, PHP, Python bindings
 * Various tools from [IIDUG Software Repository](http://www.iiug.org/software/) (alternatives for default IBM tools)


Informix tools which may be usefull but are not installed by default
-----------------------------------------------------------------------

 - https://github.com/rgburnett/informixutils
 - https://github.com/fzilic/informix-util
 - https://github.com/sqrt529/informix_locks
 - https://github.com/rgburnett/imigrate/


Additional references
--------------------------
 
 * [Building docker images using http cache](http://stackoverflow.com/questions/22030931/how-to-rebuild-dockerfile-quick-by-using-cache)
 * [Exposing Dockerized services](http://stackoverflow.com/questions/22111060/difference-between-expose-and-publish-in-docker)
 * [Other Informix install script](https://github.com/zephilou/ubuntu-14.04)
 * [Building good Docker images](http://jonathan.bergknoff.com/journal/building-good-docker-images)
 * [6 tips for building good Docker images](http://container-solutions.com/2014/11/6-dockerfile-tips-official-images/)
 * [Sandboxing proprietary applications in Docker](http://www.jann.cc/2014/09/06/sandboxing_proprietary_applications_with_docker.html)


License:
---------------------

License Apache License Version 2.0, January 2004 (https://tldrlegal.com/ ; http://choosealicense.com/)

