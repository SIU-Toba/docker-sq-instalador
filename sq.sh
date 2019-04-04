#!/bin/bash

if ! grep -q 'entorno_toba' /root/.bashrc; then
    SCRIPT_ENTORNO_TOBA=${TOBA_INSTALACION_DIR}/entorno_toba.env
    echo ". ${SCRIPT_ENTORNO_TOBA}" >> /root/.bashrc
    if [ -z "$PROYECTO_DIR" ]; then
	echo "cd ${TOBA_DIR};" >> /root/.bashrc
    else
	echo "cd ${PROYECTO_DIR};" >> /root/.bashrc
    fi
fi



# Need to remove this file or we get "java.awt.AWTError: Assistive Technology not found: org.GNOME.Accessibility.AtkWrapper" when running jasper reports
# See https://github.com/docker-library/tomcat/issues/80
# /docker-java-home -> /usr/lib/jvm/java-8-openjdk-amd64 -> /etc/java-8-openjdk
if [ -f /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/accessibility.properties ]
then
   rm /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/accessibility.properties
else
   echo "File does not exists: /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/accessibility.properties"
fi

if [ -f /etc/java-8-openjdk/accessibility.properties ]
then
   rm /etc/java-8-openjdk/accessibility.properties
else
   echo "File does not exists: /etc/java-8-openjdk/accessibility.properties"
fi
