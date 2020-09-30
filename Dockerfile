# DOCKER-VERSION 0.3.4
FROM        perl:5.30.2
MAINTAINER  Mark Musante mark.musante@gmail.com

WORKDIR /ifcomp-build
ADD ./IFComp/cpanfile /ifcomp-build

RUN apt-get update && apt-get install -y default-mysql-client build-essential
RUN apt-get install -y libpng-dev libjpeg-dev

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cd /ifcomp-build && cpanm -q -n --with-develop --installdeps --force .

EXPOSE 3000

CMD cd /home/ifcomp/IFComp && ./script/docker_start.sh
