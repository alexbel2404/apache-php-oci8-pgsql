FROM romeoz/docker-apache-php:7.3

RUN apt-get update && \
    apt-get install php7.3-dev unzip libaio1 -y && \
    rm -rf /var/lib/apt/lists/*

# Oracle instantclient
ADD instantclient-basiclite-linux.x64-12.2.0.1.0.zip /tmp/
ADD instantclient-sdk-linux.x64-12.2.0.1.0.zip /tmp/
ADD instantclient-sqlplus-linux.x64-12.2.0.1.0.zip /tmp/

RUN unzip /tmp/instantclient-basiclite-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
    unzip /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
    unzip /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
    ln -s /usr/local/instantclient_12_2 /usr/local/instantclient && \
    ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so && \
    ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus && \
    mkdir -p /usr/local/instantclient/network/ADMIN && \
    echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc && \
    echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /etc/apache2/envvars && \
    echo 'export ORACLE_HOME="/usr/local/instantclient"' >> /root/.bashrc && \
    echo 'export ORACLE_HOME="/usr/local/instantclient"' >> /etc/apache2/envvars && \
    echo 'export TNS_ADMIN="/usr/local/instantclient/network/ADMIN"' >> /root/.bashrc && \
    echo 'export TNS_ADMIN="/usr/local/instantclient/network/ADMIN"' >> /etc/apache2/envvars && \
    echo 'umask 002' >> /root/.bashrc && \
    echo 'instantclient,/usr/local/instantclient' | pecl install oci8 && \
    echo "extension=oci8.so" > /etc/php/7.3/apache2/conf.d/php-oci8.ini && \
    echo "extension=oci8.so" > /etc/php/7.3/cli/conf.d/php-oci8.ini

WORKDIR /var/www/app/

ADD app/index.php /var/www/app/index.php

EXPOSE 80 443

# By default, simply start apache.
CMD ["/sbin/entrypoint.sh"]