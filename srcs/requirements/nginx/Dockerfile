FROM debian:bookworm

WORKDIR /nginx

RUN apt update && apt install -y nginx openssl \
	net-tools

COPY config/nginx_config.sh .

COPY config/nginx.conf /etc/nginx

RUN chmod 777 ./nginx_config.sh

EXPOSE 443


CMD ["./nginx_config.sh"]
