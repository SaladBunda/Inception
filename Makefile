NAME=wp_stack
COMPOSE=docker-compose -f srcs/docker-compose.yml

all: up

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean: clean
	docker system prune -af --volumes
	sudo rm -rf /home/ael-maaz/data/wordpress /home/ael-maaz/data/mariadb
	sudo mkdir -p /home/ael-maaz/data/wordpress
	sudo mkdir -p /home/ael-maaz/data/mariadb

re: fclean all

logs:
	$(COMPOSE) logs -f

ps:
	docker ps

wp-shell:
	docker exec -it wordpress bash

db-shell:
	docker exec -it mariadb mysql -u root -p
