#/bin/bash
#
#  name:        test_ids_ubuntu.sh:
#  description: Test docker file to install Informix on variuos Ubuntu versions
#  url:         https://github.com/0x1fff/docker-informix
#
#  usage:       Please run as root!
#               ./test_ids_ubuntu.sh
#
#  notes:       Informix installation archives should be in $INST_ARCH_DIR
#

INST_ARCH_DIR=../ids_install/

for INST_ARCH in `ls -1 "${INST_ARCH_DIR}"` ; do
	
	cp "${INST_ARCH_DIR}/${INST_ARCH}" "${INST_ARCH}"
	for UB_VERS in 14.10 14.04 13.10 12.04 10.04 ; do 

cat <<EOF > Dockerfile
FROM ubuntu:${UB_VERS}
MAINTAINER Tomasz Gaweda
#ENV http_proxy http://172.17.42.1:8080/
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
COPY ${INST_ARCH} /${INST_ARCH}
COPY informix_install.sh /informix_install.sh
COPY informix_start.sh /informix_start.sh
RUN bash ./informix_install.sh ${INST_ARCH}
USER informix
RUN bash informix_start.sh
CMD ["/bin/bash"]
EOF
    	docker build . > "build_${INST_ARCH}_${UB_VERS}_docker.log"
    	echo "${INST_ARCH} + ${UB_VERS} status: $?"
	done

	rm "${INST_ARCH}"
done
