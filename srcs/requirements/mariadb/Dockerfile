FROM debian:bookworm

WORKDIR /mariadb

RUN apt update && apt install -y mariadb-server
COPY config/mariadb_config.sh .

RUN chmod 777 ./mariadb_config.sh
EXPOSE 3306


CMD ["./mariadb_config.sh"]
