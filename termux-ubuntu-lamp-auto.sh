#!/data/data/com.termux/files/usr/bin/bash
echo "==============================================="
echo "      Ultimate Auto-LAMP Installer"
echo "==============================================="

# 1️⃣ Ask MySQL root password
read -s -p "Enter MySQL root password for phpMyAdmin: " MYSQL_PASS
echo

# 2️⃣ Update Termux
pkg update -y && pkg upgrade -y
pkg install -y proot-distro wget nano tsu

# 3️⃣ Install Ubuntu if missing
if ! proot-distro list | grep -q ubuntu; then
    echo "[INFO] Installing Ubuntu..."
    proot-distro install ubuntu
fi

# 4️⃣ Create LAMP startup script inside Ubuntu
proot-distro login ubuntu -- bash -c "cat > ~/start-lamp.sh << 'EOF'
#!/bin/bash
echo '==============================================='
echo '   Starting LAMP Server...'
echo '==============================================='

# Start Apache
apachectl start

# Start MariaDB
if ! pgrep mysqld > /dev/null; then
    nohup mysqld_safe >/dev/null 2>&1 &
    sleep 5
fi

echo '==============================================='
echo ' LAMP Server started!'
echo ' Open in browser:'
echo '   http://localhost'
echo '   http://localhost/phpmyadmin'
echo '==============================================='
EOF"

proot-distro login ubuntu -- bash -c "chmod +x ~/start-lamp.sh"

# 5️⃣ Install LAMP stack inside Ubuntu
proot-distro login ubuntu -- bash -c "apt update && apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y apache2 mariadb-server php php-mysql libapache2-mod-php phpmyadmin

# Link phpMyAdmin to web root
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# PHP test page
echo '<?php phpinfo(); ?>' > /var/www/html/info.php"

# 6️⃣ Configure MySQL root user
proot-distro login ubuntu -- bash -c "mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PASS}';\"
mysql -e \"DELETE FROM mysql.user WHERE User='';\"
mysql -e \"DROP DATABASE IF EXISTS test;\"
mysql -e \"FLUSH PRIVILEGES;\""

# 7️⃣ Start Apache and MariaDB initially
proot-distro login ubuntu -- bash -c "apachectl start
nohup mysqld_safe >/dev/null 2>&1 & sleep 5"

# 8️⃣ Give Apache permission to use port 80
proot-distro login ubuntu -- bash -c "chown -R www-data:www-data /var/www/html"

# 9️⃣ Add Termux alias for one-command launch
if ! grep -q 'alias lamp=' ~/.bashrc; then
    echo \"alias lamp='proot-distro login ubuntu -- bash -c \\\"~/start-lamp.sh; exec bash\\\"'\" >> ~/.bashrc
    source ~/.bashrc
fi

echo "==============================================="
echo "✅ Ultimate LAMP setup complete!"
echo "Use command: lamp"
echo "Access in browser:"
echo "  PHP Test:       http://localhost"
echo "  phpMyAdmin:     http://localhost/phpmyadmin"
echo "MySQL root password: (the one you entered)"
echo "==============================================="
