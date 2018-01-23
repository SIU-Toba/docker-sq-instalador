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

find /var/local -maxdepth 3 -name composer.json -execdir composer install --no-interaction \;

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
	    if [ -z "$TOBA_PROYECTO_DIR" ]; then
		echo "cd ${TOBA_DIR};" >> /root/.bashrc
	    else
		echo "cd ${TOBA_PROYECTO_DIR};" >> /root/.bashrc
	    fi
	fi
fi





