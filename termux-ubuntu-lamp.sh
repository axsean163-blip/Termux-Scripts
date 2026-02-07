#!/data/data/com.termux/files/usr/bin/bash

echo "==============================================="
echo "   Secure LAMP Installer for Termux Ubuntu"
echo "==============================================="

# 1️⃣ Update Termux packages
echo "[1] Updating Termux packages..."
pkg update -y && pkg upgrade -y

# 2️⃣ Install required Termux packages
echo "[2] Installing required packages..."
pkg install -y proot-distro wget nano

# 3️⃣ Install Ubuntu if not installed
if ! proot-distro list | grep -q ubuntu; then
    echo "[3] Installing Ubuntu..."
    proot-distro install ubuntu
else
    echo "[INFO] Ubuntu already installed"
fi

# 4️⃣ Ask user for MySQL root password
read -s -p "Enter a password for MySQL root user: " MYSQL_ROOT_PASS
echo

# 5️⃣ Create LAMP startup script inside Ubuntu
echo "[4] Creating LAMP startup script inside Ubuntu..."
proot-distro login ubuntu -- bash -c 'cat > ~/start-lamp.sh << "EOF"
#!/bin/bash
echo "==============================================="
echo "   Starting LAMP Server..."
echo "==============================================="

# Start Apache
echo "[INFO] Starting Apache..."
apachectl start

# Start MariaDB
echo "[INFO] Starting MariaDB..."
if ! pgrep mysqld > /dev/null; then
    nohup mysqld_safe >/dev/null 2>&1 &
    sleep 5
fi

echo "==============================================="
echo " LAMP Server started!"
echo " Access in browser:"
echo "   PHP Test:       http://localhost:8080/info.php"
echo "   phpMyAdmin:     http://localhost:8080/phpmyadmin"
echo "==============================================="
EOF'

# Make the startup script executable
proot-distro login ubuntu -- bash -c 'chmod +x ~/start-lamp.sh'

# 6️⃣ Install LAMP stack inside Ubuntu
echo "[5] Installing LAMP stack inside Ubuntu..."
proot-distro login ubuntu -- bash -c "apt update && apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y apache2 mariadb-server php php-mysql libapache2-mod-php phpmyadmin

# Link phpMyAdmin to web root
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Create PHP test page
echo '<?php phpinfo(); ?>' > /var/www/html/info.php"

# 7️⃣ Secure MySQL root password and remove anonymous users
echo "[6] Securing MariaDB..."
proot-distro login ubuntu -- bash -c "mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASS}';\"
mysql -e \"DELETE FROM mysql.user WHERE User='';\"
mysql -e \"DROP DATABASE IF EXISTS test;\"
mysql -e \"FLUSH PRIVILEGES;\""

# 8️⃣ Start services initially
echo "[7] Starting Apache and MariaDB..."
proot-distro login ubuntu -- bash -c "apachectl start
nohup mysqld_safe >/dev/null 2>&1 & sleep 5"

# 9️⃣ Add Termux alias for one-command launch
echo "[8] Adding Termux alias 'lamp'..."
if ! grep -q "alias lamp=" ~/.bashrc; then
    echo "alias lamp='proot-distro login ubuntu -- bash -c \"~/start-lamp.sh; exec bash\"'" >> ~/.bashrc
    source ~/.bashrc
fi

echo "==============================================="
echo "✅ Secure LAMP installation complete!"
echo "MySQL root password: (hidden for security)"
echo "Type 'lamp' in Termux to start Ubuntu + LAMP server"
echo "Then open in browser:"
echo "  PHP Test:       http://localhost:8080/info.php"
echo "  phpMyAdmin:     http://localhost:8080/phpmyadmin"
echo "==============================================="
