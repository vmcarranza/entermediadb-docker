#!/bin/bash -x
#To run this script: sudo ./create.sh xyzcorp 8888
SITE=$1
PORT=$2

ENDPOINT=/media/emsites/${SITE}

# Create entermedia user if needed
groupadd entermedia > /dev/null
useradd -g entermedia entermedia > /dev/null
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Make site mount area 
sudo mkdir -p ${ENDPOINT}/webapp
sudo mkdir -p ${ENDPOINT}/data
sudo mkdir -p ${ENDPOINT}/logs${PORT}
sudo mkdir -p ${ENDPOINT}/elastic
sudo echo "sudo docker start ${SITE}${PORT}" > ${ENDPOINT}/start.sh
sudo echo "sudo docker exec -it ${SITE}${PORT} /opt/entermediadb/tomcat/bin/shutdown.sh" > ${ENDPOINT}/stop.sh
sudo chmod 755 ${ENDPOINT}/*.sh

# Fix permissions
sudo chown -R entermedia. "${ENDPOINT}"

# Run Create Docker Instance
sudo docker run -d --name ${SITE}${PORT} \
	-p $PORT:$PORT \
	-e USERID=$USERID \
	-e GROUPID=$GROUPID \
	-e CLIENT_NAME=$SITE \
	-e INSTANCE_PORT=${PORT} \
	-v ${ENDPOINT}/webapp:/opt/entermediadb/webapp \
	-v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
	-v ${ENDPOINT}/logs${PORT}:/opt/entermediadb/tomcat/logs \
	-v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
	entermediadb/entermediadb9:latest
