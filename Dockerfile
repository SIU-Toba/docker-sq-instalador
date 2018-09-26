FROM siutoba/docker-web:v1.5
MAINTAINER esassone@siu.edu.ar

#--------------------------------------------- ENCODIGN es_AR.URF-8 -----------------------------------------
RUN echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
RUN apt-get clean && apt-get update
RUN apt-get -y install locales
RUN locale-gen es_AR.UTF-8
RUN update-locale LANG=es_AR.UTF-8
RUN localedef -i es_AR  -c -f UTF-8 -A /usr/share/locale/locale.alias es_AR.UTF-8
ENV LANG es_AR.UTF-8

#--------------------------------------------- PHP CONFIG -----------------------------------------

RUN docker-php-ext-install sockets
RUN docker-php-ext-install soap

RUN printf "error_reporting = E_ALL\n" >> /usr/local/etc/php/php.ini
RUN printf "display_errors=On\n" >> /usr/local/etc/php/php.ini
RUN printf "output_buffering=4096\n" >> /usr/local/etc/php/php.ini

#--------------------------------------------- NODE Y NVM -----------------------------------------
#change it to your required node version
ENV NODE_VERSION 0.10
#needed by nvm install
ENV NVM_DIR /home/node/.nvm

RUN git clone https://github.com/creationix/nvm.git ~/.nvm && cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`
RUN . ~/.nvm/nvm.sh && nvm install $NODE_VERSION
RUN echo ". ~/.nvm/nvm.sh" >> ~/.bashrc
#---------------------------------------- CRONTAB -------------------------------------------------
RUN apt-get clean && apt-get update
RUN apt-get update && apt-get -y install cron 

#--------------------------------------------- JAVA (Dejar al final este bloque) -----------------------------------------

RUN mkdir -p /usr/share/man/man1
RUN apt-get clean && apt-get update
RUN apt-get install -y --no-install-recommends openjdk-8-jre-headless
RUN echo "deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty multiverse \
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-updates multiverse \
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse" | tee /etc/apt/sources.list.d/multiverse.list 
RUN apt-get clean && apt-get update
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_FRONTEND teletype
RUN apt-get install -y --reinstall --allow-unauthenticated ttf-mscorefonts-installer

#--------------------------------------------------------------------------------------------------

COPY sq.sh /entrypoint.d/

ENV JASPER_HOST jasper
ENV JASPER_PORT 8081

#En lugar de utilizar http://localhost:puerto usa http://ip_interna, para poder hacer comunicaciones internas server-to-server
#RUN echo "UseCanonicalName On" >> /etc/apache2/apache2.conf

RUN chmod +x /entrypoint.d/*.sh

