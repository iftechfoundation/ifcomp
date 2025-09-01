# DOCKER-VERSION 0.3.4
FROM        perl:5.34
MAINTAINER  Mark Musante mark.musante@gmail.com

RUN apt-get update && apt-get install -y \
    default-mysql-client \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/IFComp-Build
COPY IFComp/cpanfile .
RUN curl -L http://cpanmin.us | perl - App::cpanminus \
    && cpanm -q -n --with-develop --installdeps --force .

WORKDIR /opt/IFComp
ENV CATALYST_CONFIG_LOCAL_SUFFIX=dev
EXPOSE 3000
CMD ["bash", "/opt/IFComp-Dev/script/docker_start.sh"]
