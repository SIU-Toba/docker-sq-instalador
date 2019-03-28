#!/bin/bash

if [ -z "$TOBA_ES_PRODUCCION" ]; then
    export TOBA_ES_PRODUCCION=0
fi
if [ -z "$TOBA_INSTANCIA" ]; then
    if [ "$TOBA_ES_PRODUCCION" == "0" ]; then
        export TOBA_INSTANCIA=desarrollo
    else
        export TOBA_INSTANCIA=produccion
    fi
fi
if [ -z "$TOBA_BASE_HOST" ]; then
    export TOBA_BASE_HOST=pg
fi
if [ -z "$TOBA_BASE_USER" ]; then
    export TOBA_BASE_USER=postgres
fi
if [ -z "$TOBA_BASE_PASS" ]; then
    export TOBA_BASE_PASS=postgres
fi
if [ -z "$TOBA_BASE_PORT" ]; then
    export TOBA_BASE_PORT=5432
fi
if [ $ESPERAR_PG ]; then
	${TOBA_DIR}/bin/connection_test ${TOBA_BASE_HOST} ${TOBA_BASE_PORT} ${TOBA_BASE_USER} ${TOBA_BASE_PASS} postgres;
fi
if [ -z "$PARAMETRO_INSTALADOR_CREAR_DB" ]; then
	export PARAMETRO_INSTALADOR_CREAR_DB=--crear-db
else
	export PARAMETRO_INSTALADOR_CREAR_DB=
fi

find ${PROYECTO_DIR} -name composer.json -execdir composer install --no-interaction \;

if [ $JASPER_INICIAR ]; then
    echo "------------Ininciando JASPER-------------";
    java -jar ${PROYECTO_DIR}/vendor/siu-toba/jasper/JavaBridge/WEB-INF/lib/JavaBridge.jar SERVLET:$JASPER_PORT &
else
   echo "-------------No se esta iniciando JASPER--------------------";
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

#Instala el proyecto y lo saca de modo mantenimiento
${PROYECTO_DIR}/bin/instalador proyecto:instalar -m -n --no-progress ${PARAMETRO_INSTALADOR_CREAR_DB}

if [ -z "$TOBA_INSTALACION_DIR" ]; then
	#Publica el alias
	ln -s ${PROYECTO_DIR}/config/alias.conf /etc/apache2/sites-enabled/alias.conf;
else
	#Permite a Toba guardar los logs
	chown -R www-data ${TOBA_INSTALACION_DIR}/i__${TOBA_INSTANCIA}

	#Permite al usuario HOST editar los archivos
	chmod -R a+w ${TOBA_INSTALACION_DIR}

	#Publica el alias de toba
	ln -s ${TOBA_INSTALACION_DIR}/toba.conf /etc/apache2/sites-enabled/toba.conf;

	if ! grep -q 'entorno_toba' /root/.bashrc; then
	    SCRIPT_ENTORNO_TOBA=${TOBA_INSTALACION_DIR}/entorno_toba.env
	    echo ". ${SCRIPT_ENTORNO_TOBA}" >> /root/.bashrc
	    if [ -z "$PROYECTO_DIR" ]; then
		echo "cd ${TOBA_DIR};" >> /root/.bashrc
	    else
		echo "cd ${PROYECTO_DIR};" >> /root/.bashrc
	    fi
	fi
fi





