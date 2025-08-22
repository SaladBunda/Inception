#!/bin/bash

set -e


DATABASE_UTF="utf8mb4"
DATABASE_COLLAT=""


# Site Information
SITE_TITLE="My WordPress Site"

SEARCH_ENGINE="false"  

echo "📦 Installing WordPress $WORDPRESS_VERSION..."

if [ ! -f "${WORDPRESS_DIR}/wp-config.php" ]; then
    mkdir -p $WORDPRESS_DIR

    echo "⬇️  Downloading WordPress..."
    curl -s -o wordpress.tar.gz https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz
    tar -xzf wordpress.tar.gz
    rm wordpress.tar.gz

    echo "🧹 Cleaning existing WordPress directory..."
    find ${WORDPRESS_DIR} -mindepth 1 -delete

    echo "📁 Copying WordPress files to $WORDPRESS_DIR..."
    cp -r wordpress/* $WORDPRESS_DIR
    rm -rf wordpress

    echo "🛠️  Setting permissions..."
    chown -R www-data:www-data $WORDPRESS_DIR
    chmod -R 755 $WORDPRESS_DIR
else
    echo "✅ WordPress already installed. Skipping setup."
fi


curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html

if ! wp core is-installed --path=$WORDPRESS_DIR --allow-root; then

	echo "📋 Running WP-CLI to configure WordPress..."

	wp config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --dbhost=$DB_HOST --dbprefix=wp_ --allow-root


    wp core install --path=$WORDPRESS_DIR --url="http://localhost" --title="$SITE_TITLE" --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASSWORD" --admin_email="$ADMIN_EMAIL" --skip-email --allow-root

    wp option update blog_public 0 --allow-root 

	wp user create $EDITOR_USER editor@example.com --role=editor --user_pass=$EDITOR_PASSWORD --allow-root
fi
echo "🛠️ Modifying PHP-FPM configuration to listen on TCP port 9000..."
sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

echo "🚀 Launching php-fpm in foreground..."
exec php-fpm8.2 -F
