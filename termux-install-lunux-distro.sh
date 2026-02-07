#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ================================
# Termux Multi-Linux Installer
# ================================

echo "Updating Termux packages..."
pkg update -y && pkg upgrade -y

echo "Installing required packages..."
pkg install -y proot-distro

# -------------------------------
# Functions
# -------------------------------
install_distro() {
    local distro=$1
    echo "Installing $distro..."
    if proot-distro list | grep -q "^$distro\$"; then
        echo "$distro is already installed."
    else
        if proot-distro install "$distro"; then
            echo "$distro installation completed successfully!"
        else
            echo "Installation failed. Retrying..."
            proot-distro install "$distro" || { echo "Failed to install $distro after retry."; return 1; }
        fi
    fi

    # Alias setup
    read -p "Add '$distro' alias for quick login? (Y/n): " ans
    ans=${ans:-y}
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        if ! grep -q "alias $distro=" ~/.bashrc; then
            echo "alias $distro=\"proot-distro login $distro\"" >> ~/.bashrc
            echo "Alias '$distro' added! Use '$distro' to login."
        else
            echo "Alias '$distro' already exists."
        fi
    fi
}

uninstall_distro() {
    local distro=$1
    if proot-distro list | grep -q "^$distro\$"; then
        read -p "Are you sure you want to uninstall $distro? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            proot-distro remove "$distro"
            sed -i "/alias $distro=/d" ~/.bashrc
            echo "$distro uninstalled and alias removed."
        else
            echo "Uninstall canceled."
        fi
    else
        echo "$distro is not installed."
    fi
}

show_menu() {
    echo "=============================="
    echo " Termux Linux Installer Menu"
    echo "=============================="
    echo "1) Install Ubuntu"
    echo "2) Install Debian"
    echo "3) Install Arch Linux"
    echo "4) Install Fedora"
    echo "5) Install Kali Linux"
    echo "6) Install Alpine Linux"
    echo "7) Uninstall a distro"
    echo "0) Exit"
    echo "=============================="
    read -p "Choose an option: " choice
}

# -------------------------------
# Main loop
# -------------------------------
while true; do
    show_menu
    case $choice in
        1) install_distro "ubuntu" ;;
        2) install_distro "debian" ;;
        3) install_distro "archlinux" ;;
        4) install_distro "fedora" ;;
        5) install_distro "kali" ;;
        6) install_distro "alpine" ;;
        7)
            echo "Installed distros:"
            proot-distro list
            read -p "Enter distro name to uninstall: " distro_to_remove
            uninstall_distro "$distro_to_remove"
            ;;
        0) echo "Exiting."; break ;;
        *) echo "Invalid choice. Try again." ;;
    esac
    echo
done
