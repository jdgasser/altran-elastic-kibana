FROM ubuntu:16.04
MAINTAINER Jean-Daniel Gasser <jean-daniel.gasser@altran.com>

# Update sources
RUN apt-get update -y
#install sudo
RUN apt-get install -y sudo

RUN apt-get install -y apt-transport-https software-properties-common wget 

#Install curl
RUN apt-get install -y curl

# Installation du drivers Java msql
RUN apt-get install -y libmysql-java

# install http
RUN apt-get install -y apache2 vim bash-completion unzip
RUN mkdir -p /var/lock/apache2 /var/run/apache2

# install mysql
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-client mysql-server

# install php
RUN apt-get install -y php7.0 php7.0-mysql libapache2-mod-php7.0 


#install net-tools (netstat/ifconfig etc)
RUN apt-get install -y net-tools

# install git
RUN apt-get install -y git

# install sshd
RUN apt-get install -y openssh-server openssh-client passwd
RUN mkdir -p /var/run/sshd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN echo 'root:root' | chpasswd

# Put your own public key at id_rsa.pub for key-based login.
RUN mkdir -p /root/.ssh && touch /root/.ssh/known_hosts && chmod 700 /root/.ssh
ADD known_hosts /root/.ssh/known_hosts

#install le nécessaire pour le déploiement continu sous rancher
RUN apt-get install -y python-setuptools
ADD rancher/ /rancher-gitlab-deploy
WORKDIR /rancher-gitlab-deploy
RUN python /rancher-gitlab-deploy/setup.py install
RUN ln -s /usr/local/bin/rancher-gitlab-deploy /usr/local/bin/upgrade

#install le nécessaire pour phpmyadmin (phpmyadmin sera installé dans le script d'install.sh
RUN apt-get install -y dbconfig-common dbconfig-mysql fontconfig-config fonts-dejavu-core javascript-common libfontconfig1 libfreetype6 libgd3 libjbig0 libjpeg-turbo8 libjpeg8 libjs-jquery libjs-sphinxdoc libjs-underscore libmcrypt4 libpng12-0 libtiff5 libvpx3 libxpm4 libxslt1.1 php-gd php-gettext php-mbstring php-mcrypt php-pear php-phpseclib php-tcpdf php-xml php7.0-gd php7.0-mbstring php7.0-mcrypt php7.0-xml

# Install Java8.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
  
# Installation et configuration d' Elasticsearch 6.x
# Ajout de la clé et du dépôt de package
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list 
RUN apt-get update

RUN apt-get install -y elasticsearch

# Installer Logstash
RUN apt-get install -y logstash

# Installation et configuration de Kibana 6.x
RUN apt-get install -y kibana
RUN touch /var/log/kibana.log
RUN chown kibana:kibana /var/log/kibana.log

  

  
#Divers
ADD script.sh /root/
ADD .bashrc /root/
ADD logstash.conf /etc/logstash/conf.d/
EXPOSE 22 80 443 9200 5106

#pour démarer les services et concerver le containeur ouvert
CMD script.sh && /usr/sbin/sshd -D
