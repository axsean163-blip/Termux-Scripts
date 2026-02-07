#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "Updating Termux packages..."
pkg update -y && pkg upgrade -y

echo "Installing required packages..."
pkg install -y proot-distro

# Check if Ubuntu is already installed
if proot-distro list | grep -q ubuntu; then
    echo "Ubuntu is already installed."
else
    echo "Installing Ubuntu..."
    proot-distro install ubuntu
    echo "Ubuntu installation completed!"
fi

echo "To start Ubuntu, run: proot-distro login ubuntu"

echo "########################################################"
echo -e "You can add an alias 'ubuntu' for quicker logins.\n"
echo -e "Then you'll only type: ubuntu"
echo -e "Instead of: proot-distro login ubuntu\n"

read -p "Add 'ubuntu' alias for quicker logins? (Y/n): " ans
ans=${ans:-y}

if [[ "$ans" =~ ^[Yy]$ ]]; then
    # Add alias if not already present
    if ! grep -qxF 'alias ubuntu="proot-distro login ubuntu"' ~/.bashrc; then
        echo 'alias ubuntu="proot-distro login ubuntu"' >> ~/.bashrc
        echo -e "Alias 'ubuntu' added!\n"
        # Make alias available immediately
        source ~/.bashrc
        echo "You can now type: ~ \$ ubuntu"
    else
        echo "Alias 'ubuntu' already exists in ~/.bashrc"
    fi
else
    echo "To start Ubuntu, run: proot-distro login ubuntu"
fi
