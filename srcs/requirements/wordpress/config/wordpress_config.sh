#!/bin/bash

set -e

WORDPRESS_VERSION=6.5.2
WORDPRESS_DIR=/var/www/html


DATABASE_NAME="wordpress"
DATABASE_USERNAME="testuser"
DATABASE_PASSWORD="password"
DATABASE_HOST="mariadb:3306"
DATABASE_UTF="utf8mb4"
DATABASE_COLLAT=""


# Site Information
SITE_TITLE="My WordPress Site"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin_password"
ADMIN_EMAIL="admin@example.com"
SEARCH_ENGINE="false"  # Set to 'true' to discourage search engines

echo "📦 Installing WordPress $WORDPRESS_VERSION..."

# Only download if not already installed
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

#     echo "⚙️ Generating wp-config.php..."
#     cat > ${WORDPRESS_DIR}/wp-config.php <<EOF
# <?php
# define( 'DB_NAME', 'wordpress' );
# define( 'DB_USER', 'testuser' );
# define( 'DB_PASSWORD', 'password' );
# define( 'DB_HOST', 'mariadb:3306' );
# define( 'DB_CHARSET', 'utf8mb4' );
# define( 'DB_COLLATE', '' );

# define( 'AUTH_KEY',         '$(openssl rand -base64 32)' );
# define( 'SECURE_AUTH_KEY',  '$(openssl rand -base64 32)' );
# define( 'LOGGED_IN_KEY',    '$(openssl rand -base64 32)' );
# define( 'NONCE_KEY',        '$(openssl rand -base64 32)' );
# define( 'AUTH_SALT',        '$(openssl rand -base64 32)' );
# define( 'SECURE_AUTH_SALT', '$(openssl rand -base64 32)' );
# define( 'LOGGED_IN_SALT',   '$(openssl rand -base64 32)' );
# define( 'NONCE_SALT',       '$(openssl rand -base64 32)' );

# \$table_prefix = 'wp_';
# define( 'WP_DEBUG', false );
# if ( ! defined( 'ABSPATH' ) ) {
#     define( 'ABSPATH', __DIR__ . '/' );
# }
# require_once ABSPATH . 'wp-settings.php';
# EOF

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

	wp config create --dbname=$DATABASE_NAME --dbuser=$DATABASE_USERNAME --dbpass=$DATABASE_PASSWORD --dbhost=$DATABASE_HOST --dbprefix=wp_ --allow-root


    wp core install --path=$WORDPRESS_DIR --url="http://localhost" --title="$SITE_TITLE" --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASSWORD" --admin_email="$ADMIN_EMAIL" --skip-email --allow-root

    # Set Search Engine Visibility
    wp option update blog_public 0 --allow-root # Set to 1 to allow search engines to index
fi
# Modify PHP-FPM to listen on TCP port 9000
echo "🛠️ Modifying PHP-FPM configuration to listen on TCP port 9000..."
sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

echo "🚀 Launching php-fpm in foreground..."
exec php-fpm8.2 -F
