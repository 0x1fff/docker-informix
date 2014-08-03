docker-informix
===============

Docker container for IBM Informix Dynamic Server.

Recently IBM announced developement platform called [Bluemix](http://bluemix.net/). 
The idea is that you get to develop applications in the cloud using IBM and third party-provided Cloud hosted components. 
It's a PaaS, much like Red Hat OpenShift and Heroku. 
On Bluemix Informix is missing (there is PostgreSQL, MySQL, MongoDB) so I have created the Docker 
file which creates Docker container with Informix ready to be installed on other Cloud Providers 
(Rackspace, Yandex, Google Cloud Platform).

usage
----------


```bash
## Install Docker and clone this repository
curl -s https://get.docker.io/ubuntu/ | sudo sh
git clone https://github.com/0x1fff/docker-informix.git

# Donload from IBM Informix installation files and copy it to repository
cp iif.12.10.FC3IE.linux-x86_64.tar docker-informix

# Edit docker file if necesary
$EDITOR Dockerfile

# Build docker image
sudo docker build docker-informix
```


Versions tested with this script
--------------------------------------------------

| Informix Version (x86_64)     | Ubuntu 14.10       | Ubuntu 14.04       | Ubuntu 13.10       | Ubuntu 13.04   | Ubuntu 12.10   | Ubuntu 12.04       | Ubuntu 10.04       |
| :-----------------------------|:------------------:|:------------------:|:------------------:|:--------------:|:--------------:|:------------------:|:------------------:|
| 12.10.FC3 Innovator Edition   | :white_check_mark: | :white_check_mark: | :white_check_mark: | :x: 1          | :x: 1          | :white_check_mark: | :x:                |
| 12.10.FC3 Developer Edition   | :white_check_mark: | :white_check_mark: | :white_check_mark: | :x: 1          | :x: 1          | :white_check_mark: | :x:                |
| 12.10.FC3 Time Limited        | :white_check_mark: | :white_check_mark: | :white_check_mark: | :x: 1          | :x: 1          | :white_check_mark: | :x:                |
| 11.70.FC8 Developer Edition   | :white_check_mark: | :white_check_mark: | :white_check_mark: | :x: 1          | :x: 1          | :white_check_mark: | :white_check_mark: |
| 11.70.FC8 Innovator Edition   | :white_check_mark: | :white_check_mark: | :white_check_mark: | :x: 1          | :x: 1          | :white_check_mark: | :white_check_mark: |
| 11.70.FC8 Time Limited        | :white_check_mark: | :white_check_mark: | :white_check_mark: | :x: 1          | :x: 1          | :white_check_mark: | :white_check_mark: |
| 11.50.FC9 Developer Edition   | :x: 2              | :x: 2              | :x: 2              | :x: 1          | :x: 1          | :x: 2              | :x: 2              |
| 11.50.FC9 Time Limited        | :x: 2              | :x: 2              | :x: 2              | :x: 1          | :x: 1          | :x: 2              | :x: 2              |



 ### Legend:

 * :white_check_mark: - Installation completed succesfully
 * :x: - Instalation failed
 * :pushpin: - Notes
 
 ### Notes:

 1. Ubuntu 13.04 was supported to 2014-01-27 and 12.10 was supported to 2014-05-16 after this dates 
    script installing Informix was unable to upgrade distribution and install dependencies using apt-get.
 
 2. Installing IDS 11.50 leads to this error:

```
Install, IsRoot, err, CUSTOM_BEAN_ERROR_BEGIN
securityService:Error invoking isCurrentUserAdmin Got exception: com.installshield.util.ProcessExecException: /tmp/ismp001/gushellsupport.sh^@: cannot execute
CUSTOM_BEAN_ERROR_END
```
[Maybe it would work on older versions of Ubuntu](http://www-01.ibm.com/support/docview.wss?uid=swg27013343#linux).

How building container looks
---------------------------------

````
Step 0 : FROM ubuntu:14.10
....
Step 7 : RUN bash ./informix_install.sh iif.12.10.FC3IE.linux-x86_64.tar
 ---> Running in 077d39c2dde5
###############################################
# IBM Informix Installation script for Ubuntu #
###############################################
>>>    OS version: Ubuntu Utopic Unicorn (development branch)
>>>    Upgrading OS and installing dependencies for Informix
....
>>>    Create group and user for Informix
>>>    Uncompress Informix Archive: iif.12.10.FC3IE.linux-x86_64.tar
>>>    Launch silent install ...
>>>    Postconfig onconfig ...
>>>    Postconfig sqlhost ...
>>>    Include tcp support ...
>>>    Create informix user environnement
>>>    Create directory structure
>>>    Chown directory structure
###############################################
#         Installation completed              #
###############################################
 * Switch to Informix user with: su - informix
 * Initialize engine with: oninit -ivy
 * Check if engine is Online with: onstat -l
###############################################
 ---> 1f538523a259
....
Step 9 : RUN bash start_ifx.sh
 ---> Running in 38b1272b8cb0
16:10:18  Parameter's user-configured value was adjusted. (MAX_PDQPRIORITY)
16:10:18  IBM Informix Dynamic Server Started.
16:10:18  Warning: The IBM IDS Innovator-C Edition license restriction limits
16:10:18  the total shared memory size for this server to 2097152 KB.
16:10:18  The maximum allowable shared memory was reset to this size to start the database server. 
16:10:18  Requested shared memory segment size rounded from 4308KB to 4788KB
Reading configuration file '/opt/IBM/Informix/etc/onconfig.dev'...succeeded
Creating /INFORMIXTMP/.infxdirs...succeeded
Allocating and attaching to shared memory...succeeded
Creating resident pool 4310 kbytes...succeeded
Creating infos file "/opt/IBM/Informix/etc/.infos.dev"...succeeded
Linking conf file "/opt/IBM/Informix/etc/.conf.dev"...succeeded
Initializing rhead structure...rhlock_t 16384 (512K)... rlock_t (2656K)...
16:10:19  Could not disable priority aging: errno = 13[0m[91m
16:10:19  Requested shared memory segment size rounded from 110629KB to 110632KB
16:10:20  Successfully added a bufferpool of page size 2K.
16:10:20  Event alarms enabled.  ALARMPROG = '/opt/IBM/Informix/etc/alarmprogram.sh'
16:10:20  Booting Language <c> from module <>
16:10:20  Loading Module <CNULL>[0m[91m
16:10:20  Booting Language <builtin> from module <>
16:10:20  Loading Module <BUILTINNULL>
Writing to infos file...succeeded
Initialization of Encryption...succeeded
Initializing ASF...succeeded
Initializing Dictionary Cache and SPL Routine Cache...succeeded
Bringing up ADM VP...succeeded
Creating VP classes...succeeded
Forking main_loop thread...succeeded
Initializing DR structures...succeeded
Forking 1 'soctcp' listener threads...succeeded
Starting tracing...succeeded
Initializing 8 flushers...succeeded
Initializing log/checkpoint information...succeeded
Initializing dbspaces...succeeded
Opening primary chunks...succeeded
Validating chunks...succeeded
Creating database partition...succeeded
Initialize Async Log Flusher...succeeded
Starting B-tree Scanner...succeeded
Init ReadAhead Daemon...succeeded
Initializing DBSPACETEMP list...succeeded
Init Auto Tuning Daemon...succeeded
Checking database partition index...succeeded
Initializing dataskip structure...succeeded
Checking for temporary tables to drop...succeeded
Updating Global Row Counter...succeeded
Forking onmode_mon thread...succeeded
Creating periodic thread...succeeded
Creating periodic thread...succeeded
Starting scheduling system...succeeded
Verbose output complete: mode = 5
 ---> 1c4a3b6d3c1a
Removing intermediate container 38b1272b8cb0
Step 10 : CMD ["/bin/bash"]
 ---> Running in bb012ac1b80b
 ---> 82ba3d102924
Removing intermediate container bb012ac1b80b
Successfully built 82ba3d102924
````

What is missing in this repository
------------------------------------------
 - No start scripts for container
 - DATA_DIR should be outside Docker container
 - Install some additional tools for Informix
    - Perl, PHP, Python bindings
    - Various tools for administrators form IIDUG (alternative for dbaccess)


Available Informix Editions for Docker (x86_64 versions only)
----------------------------------------------------------------------

You can [download Informix from IBM](http://www-01.ibm.com/software/data/informix/downloads.html).

All versions listed below are distributed with Chinese Simplified, Chinese Traditional, 
Czech, English, French, German, Hungarian, Italian, Japanese, Korean, Polish, Portuguese Brazilian, 
Russian, Slovakian, Spanish language support.


<dl>
  <dt>iif.12.10.FC3TL.linux-x86_64.tar</dt>
  <dd>
  	<ul>
  		<li><em>Version:</em> 12.10FC3TL - Informix Enterprise Time-Limited Edition for Linux x86_64</li>
  		<li><em>Release date: </em> 2014-03-06</li>
  		<li><em>md5sum:</em> b6d5207f28c3a84ed21df04ec8c5a1f3</li>
  	</ul>
  </dd>

  <dt>iif.12.10.FC3DE.linux-x86_64.tar</dt>
  <dd>
  	<ul>
  		<li><em>Version:</em> 12.10FC3DE - Informix Developer Edition for Linux x86_64</li>
  		<li><em>Release date:</em> 2014-03-06</li>
  		<li><em>md5sum:</em> ef4263fcc70af7ce7baf3425ddb7befc</li>
  	</ul>
  </dd>

  <dt>iif.12.10.FC3IE.linux-x86_64.tar</dt>
  <dd>
  	<ul>
  		<li><em>Version:</em> 12.10FC3IE - Informix Innovator-C Edition for Linux x86_64</li>
  		<li><em>Release date:</em> 2014-03-06</li>
  		<li><em>md5sum:</em> 8559309f1f3fdd2937fb947b9253ba41</li>
  	</ul>
  </dd>


  <dt>iif.11.70.FC8TL.linux-x86_64.tar</dt>
  <dd>
  	<ul>
  		<li><em>Version: </em>11.70FC8TL - Informix Ultimate Time-Limited Edition for Linux x86_64</li>
  		<li><em>Release date: </em>2014-01-09</li>
  		<li><em>md5sum:</em> a2be166dae9961319c5a520db46760a2</li>
  	</ul>
  </dd>


  <dt>iif.11.70.FC8DE.linux-x86_64.tar</dt>
  <dd>
  	<ul>
  		<li><em>Version:</em> 11.70FC8DE - Informix Developer Edition for Linux x86_64</li>
  		<li><em>Release date:</em> 2014-01-09</li>
  		<li><em>md5sum:</em> d69e49913d91a721107be56067b9366c</li>
  	</ul>
  </dd>

  <dt>iif.11.70.FC8IE.linux-x86_64.tar</dt>
  <dd>
  	<ul>
  		<li><em>Version:</em> 11.70FC8IE - Informix Innovator-C Edition for Linux x86_64</li>
  		<li><em>Release date:</em> 2014-01-09</li>
  		<li><em>md5sum:</em> 9aa034ecfa89f31934135b0c01b81062</li>
  	</ul>
  </dd>

  <dt>iif.11.50.FC9TL.linux-x86_64.tar</dt>
  <dd>
  	<ul>
  		<li><em>Version:</em> 1.50FC9TL - Informix Ultimate Edition Time-Limited for Linux x86_64</li>
  		<li><em>Release date:</em> 2011-08-15</li>
  		<li><em>md5sum:</em> e00d53686ef83d6c4806750ef64a5c89</li>
  	</ul>
  </dd>

  <dt>iif.11.50.FC9DE.linux-x86_64.tar</dt>
  <dd>
  	<ul>
  		<li><em>Version:</em> 11.50FC9DE - Informix Developer Edition for Linux x86_64</li>
  		<li><em>Release date:</em> 2011-08-15</li>
  		<li><em>md5sum:</em> 22d12d7834164d52a0a06d81f12950cf</li>
  	</ul>
  </dd>

</dl>



Additional references:
--------------------------

 * [Supported platforms for Informix](http://www-01.ibm.com/support/docview.wss?uid=swg27013343#linux).
 * [Building docker images using http cache](http://stackoverflow.com/questions/22030931/how-to-rebuild-dockerfile-quick-by-using-cache)
 * [IBM Informix Download page](http://www-01.ibm.com/software/data/informix/downloads.html)
 * [Other Informix install script](https://github.com/zephilou/ubuntu-14.04)

Informix tools which may be usefull:
---------------------------------------

 - https://github.com/rgburnett/informixutils
 - https://github.com/fzilic/informix-util
 - https://github.com/sqrt529/informix_locks
 - https://github.com/rgburnett/imigrate/

 License:
---------------------

License Apache License Version 2.0, January 2004 (https://tldrlegal.com/ ; http://choosealicense.com/)

