# DOCKER-VERSION 0.3.4
FROM        perl:5.30.2
MAINTAINER  Mark Musante mark.musante@gmail.com

WORKDIR /ifcomp-build
ADD ./IFComp/cpanfile /ifcomp-build

RUN apt-get update && apt-get install -y default-mysql-client build-essential

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cd /ifcomp-build && cpanm --installdeps --force .
RUN cpanm DBD::mysql
RUN cpanm Catalyst::Restarter

EXPOSE 3000

CMD cd /home/ifcomp/IFComp && ./script/docker_start.sh
