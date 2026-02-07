#!/data/data/com.termux/files/usr/bin/bash

# Apache2 vhost management tool for Termux

APACHE_CONF_DIR="$PREFIX/etc/apache2/sites-available"
APACHE_ENABLED_DIR="$PREFIX/etc/apache2/sites-enabled"

usage() {
    echo "Usage: apache-vhost [list|add|edit|enable|disable|remove] [vhost_name]"
    echo
    echo "Commands:"
    echo "  list                List all vhosts"
    echo "  add <name>          Create a new vhost"
    echo "  edit <name>         Edit an existing vhost"
    echo "  enable <name>       Enable a vhost"
    echo "  disable <name>      Disable a vhost"
    echo "  remove <name>       Remove a vhost"
    exit 1
}

reload_apache() {
    read -p "Reload Apache now? [Y/n] " answer
    answer=${answer:-Y}
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        apachectl restart
        echo "[INFO] Apache reloaded"
    else
        echo "[INFO] Remember to reload Apache later with 'apachectl restart'"
    fi
}

list_vhosts() {
    echo "Available vhosts:"
    ls "$APACHE_CONF_DIR"
}

add_vhost() {
    local name="$1"
    local conf="$APACHE_CONF_DIR/$name.conf"
    if [[ -f "$conf" ]]; then
        echo "VHost '$name' already exists!"
        exit 1
    fi

    read -p "DocumentRoot path (absolute): " docroot
    mkdir -p "$docroot"

    cat > "$conf" << VHOST
<VirtualHost *:8080>
    ServerName $name
    DocumentRoot $docroot
    <Directory $docroot>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
VHOST

    echo "VHost '$name' created at $conf"
    reload_apache
}

edit_vhost() {
    local name="$1"
    local conf="$APACHE_CONF_DIR/$name.conf"
    if [[ ! -f "$conf" ]]; then
        echo "VHost '$name' does not exist!"
        exit 1
    fi
    nano "$conf"
    reload_apache
}

enable_vhost() {
    local name="$1"
    local conf="$APACHE_CONF_DIR/$name.conf"
    if [[ ! -f "$conf" ]]; then
        echo "VHost '$name' does not exist!"
        exit 1
    fi
    ln -sf "$conf" "$APACHE_ENABLED_DIR/$name.conf"
    echo "VHost '$name' enabled"
    reload_apache
}

disable_vhost() {
    local name="$1"
    rm -f "$APACHE_ENABLED_DIR/$name.conf"
    echo "VHost '$name' disabled"
    reload_apache
}

remove_vhost() {
    local name="$1"
    rm -f "$APACHE_CONF_DIR/$name.conf"
    rm -f "$APACHE_ENABLED_DIR/$name.conf"
    echo "VHost '$name' removed"
    reload_apache
}

# Main
if [[ $# -lt 1 ]]; then usage; fi

CMD="$1"
VHOST_NAME="$2"

case "$CMD" in
    list) list_vhosts ;;
    add) [[ -z "$VHOST_NAME" ]] && usage; add_vhost "$VHOST_NAME" ;;
    edit) [[ -z "$VHOST_NAME" ]] && usage; edit_vhost "$VHOST_NAME" ;;
    enable) [[ -z "$VHOST_NAME" ]] && usage; enable_vhost "$VHOST_NAME" ;;
    disable) [[ -z "$VHOST_NAME" ]] && usage; disable_vhost "$VHOST_NAME" ;;
    remove) [[ -z "$VHOST_NAME" ]] && usage; remove_vhost "$VHOST_NAME" ;;
    *) usage ;;
esac
