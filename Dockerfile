FROM ubuntu:latest

RUN sed -i "s|archive.ubuntu.com|mirrors.aliyun.com|g" /etc/apt/sources.list

RUN apt-get update
RUN apt-get -y dist-upgrade

# Install openssh server
RUN apt-get install -y openssh-server

# Configure openssh server
RUN mkdir /var/run/sshd
RUN echo 'root:123456a' |chpasswd
RUN echo 'PermitRootLogin yes' > /etc/ssh/sshd_config

RUN export LANG=C.UTF-8 && \
apt-get install -y software-properties-common && \
add-apt-repository -y ppa:nginx/stable && \
LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y && \
apt-get update

RUN export LANG=C.UTF-8 && \
    apt-get install -y nginx php7.0-fpm python-pip git vim zip zsh wget && \
    apt-get install -y php7.0-dev php7.0-mysql php7.0-mcrypt php7.0-intl php7.0-curl php7.0-gd \
    php7.0-zip php7.0-mbstring php7.0-dom php7.0-odbc php-redis php-pear pkg-config libssl-dev libsslcommon2-dev && \
    pip install supervisor && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp

#RUN pecl install mongodb && echo "extension=mongodb.so" >> `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"`

#Install ZSH
RUN /bin/bash -c 'git clone https://github.com/robbyrussell/oh-my-zsh.git /home/root/.oh-my-zsh && \
    cp /home/root/.oh-my-zsh/templates/zshrc.zsh-template /home/root/.zshrc && \
    sed -i "s|# DISABLE_AUTO_UPDATE|DISABLE_AUTO_UPDATE|g" /home/root/.zshrc && \
    sudo chsh -s /bin/zsh root'

RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx

# Define mountable directories.
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

ADD docker/nginx/sites-available/default /etc/nginx/sites-available
ADD docker/php/7.0/fpm/pool.d/www.conf /etc/php/7.0/fpm/pool.d/www.conf
ADD docker/supervisord.conf /etc/supervisord.conf
RUN mkdir /run/php && chown www-data:www-data /run/php

# Define default command.
CMD supervisord -c /etc/supervisord.conf

# Expose ports.
EXPOSE 80  443 22
