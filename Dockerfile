FROM wordpress:5.5.3

ENV WOOCOMMERCE_VERSION 3.5.5
ENV BTCPAY_PLUGIN_VERSION 3.0.15

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip wget \
    && wget https://downloads.wordpress.org/plugin/woocommerce.$WOOCOMMERCE_VERSION.zip -O /tmp/temp.zip \
    && wget https://downloads.wordpress.org/plugin/btcpay-for-woocommerce.$BTCPAY_PLUGIN_VERSION.zip -O /tmp/temp2.zip \
    && cd /usr/src/wordpress/wp-content/plugins \
    && unzip /tmp/temp.zip \
    && unzip /tmp/temp2.zip \
    && rm /tmp/temp.zip \
    && rm /tmp/temp2.zip \
    && rm -rf /var/lib/apt/lists/*

# Install the gmp, mcrypt and soap extensions
RUN apt-get update -y
RUN apt-get install -y libgmp-dev libxml2-dev
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/
RUN docker-php-ext-configure gmp
RUN docker-php-ext-install gmp
RUN docker-php-ext-install soap

# Download WordPress CLI
RUN curl -L "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar" > /usr/bin/wp && \
    chmod +x /usr/bin/wp

RUN { \
		echo 'file_uploads = On'; \
		echo 'post_max_size=100M'; \
		echo 'upload_max_filesize=100M'; \
	} > /usr/local/etc/php/conf.d/uploads.ini


COPY docker-entrypoint.sh /usr/local/bin/
VOLUME ["/var/www/html"]
