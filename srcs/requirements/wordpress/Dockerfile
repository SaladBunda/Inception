FROM debian:bookworm


ARG WORDPRESS_VERSION=6.5.2

ARG WORDPRESS_DIR=/var/www/html

ENV WORDPRESS_DIR /var/www/html


RUN apt update && apt install -y \
	curl \
	tar \
	php \
	php-fpm \
	php-mysql \
	php-pdo \
	php-mbstring \
	unzip \
	less \
	net-tools \
	nano \
	&& apt clean


WORKDIR /wordpress

COPY config/wordpress_config.sh .

RUN chmod 755 wordpress_config.sh



EXPOSE 9000

CMD ["./wordpress_config.sh"]
