# DOCKER-VERSION 0.3.4
FROM        perl:5.30.2
MAINTAINER  Mark Musante mark.musante@gmail.com

WORKDIR /ifcomp-build
ADD ./IFComp/cpanfile /ifcomp-build

RUN apt-get update && apt-get install -y apt-utils \
    default-mysql-client \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    apache2

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cd /ifcomp-build && cpanm -q -n --with-develop --installdeps --force .

COPY dev/001-ifcomp.conf /etc/apache2/sites-available
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN a2enmod proxy proxy_http rewrite headers && \
    a2dissite 000-default && \
    a2ensite 001-ifcomp
RUN sed -i 's/Listen 80/Listen 3000/' /etc/apache2/ports.conf

EXPOSE 3000

CMD cd /home/ifcomp/IFComp && ./script/docker_start.sh
