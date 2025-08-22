#!/bin/bash
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chmod 777 /run/mysqld

touch conf.sql


echo "FLUSH PRIVILEGES;" > conf.sql

# echo "USE mariadb;" >> conf.sql

echo "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" >> conf.sql

echo "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';" >> conf.sql

echo "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' ;" >> conf.sql

echo "FLUSH PRIVILEGES;" >> conf.sql


echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" >> conf.sql

echo "FLUSH PRIVILEGES;" >> conf.sql

echo "🚀 Starting MariaDB in background..."
mysqld --user=mysql --skip-networking --skip-grant-tables &
pid="$!"

# Wait for server socket to exist
echo "⏳ Waiting for MySQL socket..."
for i in {1..30}; do
  if [ -S /run/mysqld/mysqld.sock ]; then
    break
  fi
  sleep 1
done

echo "✅ Running SQL initialization..."
mysql -u root < conf.sql

echo "🧹 Cleaning up temporary server..."
kill "$pid"
wait "$pid"

echo "🔁 Starting MariaDB normally..."
exec mysqld --user=mysql --bind-address=0.0.0.0