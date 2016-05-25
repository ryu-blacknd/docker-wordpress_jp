FROM php:5.6-apache

RUN a2enmod rewrite expires

RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mysqli opcache \
  && echo "127.0.0.1 develop.local" >> /etc/hosts

RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

ENV WORDPRESS_VERSION 4.5.2

RUN curl -o wordpress.tar.gz -SL https://ja.wordpress.org/wordpress-${WORDPRESS_VERSION}-ja.tar.gz \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
	&& rm wordpress.tar.gz \
  && usermod -u 1000 www-data \
	&& usermod -G staff,www-data www-data \
	&& chown -R www-data:www-data /usr/src/wordpress

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /var/www/html/wp-content

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
