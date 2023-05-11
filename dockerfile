# Using base ubuntu image
FROM ubuntu:20.04

# Base install
RUN apt update --fix-missing
# RUN  DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && echo Asia/Kolkata > /etc/timezone
RUN apt install -y \
      software-properties-common \
      git \
      zip \
      gcc \
      g++ \
      unzip \
      curl \
      ca-certificates \
      lsb-release \
      libicu-dev \
      supervisor \
      nginx \
      nano \
      cron \
      imagemagick

RUN add-apt-repository ppa:ondrej/php

# Install php8.2-fpm
RUN apt install -y \
      php8.2 \
      php8.2-fpm \
      php8.2-common \
      php8.2-pdo \
      php8.2-mysql \
      php8.2-zip \
      php8.2-gd \
      php8.2-mbstring \
      php8.2-curl \
      php8.2-xml \
      php8.2-bcmath \
      php8.2-intl \
      php8.2-imagick \
      mysql-client 

RUN php -v

# Install modules
RUN php -m


# Add Composer
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
#RUN composer global require hirak/prestissimo
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="./vendor/bin:$PATH"

COPY opcache.ini $PHP_INI_DIR/conf.d/
COPY php.ini $PHP_INI_DIR/conf.d/

RUN chown -R www-data:www-data /var/lib/nginx

# Setup Crond and Supervisor by default
RUN crontab -l | { cat; echo "* * * * * php /var/www/artisan schedule:run >> /dev/null 2>&1"; } | crontab -
# RUN echo '*  *  *  *  * /usr/local/bin/php  /var/www/artisan schedule:run >> /dev/null 2>&1' > /etc/crontabs/root && mkdir /etc/supervisor.d
ADD master.ini /etc/supervisor.d/
ADD default.conf /etc/nginx/conf.d/
ADD nginx.conf /etc/nginx/

# Setup Working Dir
WORKDIR /var/www/html

CMD ["/usr/bin/supervisord"]