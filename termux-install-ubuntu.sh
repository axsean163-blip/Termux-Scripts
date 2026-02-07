#!/data/data/com.termux/files/usr/bin/bash

echo "Updating Termux packages..."
pkg update -y && pkg upgrade -y

echo "Installing required packages..."
pkg install -y proot-distro

echo "Installing Ubuntu..."
proot-distro install ubuntu

echo "Ubuntu installation completed!"
echo "To start Ubuntu, run: proot-distro login ubuntu"

echo "########################################################"

echo -e "An alias of 'ubuntu' can be added for quicker logins.\n"
echo -e "Then you'll only type: ubuntu"
echo -e "Instead of: proot-distro login ubuntu\n"

read -p "Add 'ubuntu' alias for quicker logins? (Y/n): " ans
ans=${ans:-y}

if [[ "$ans" =~ ^[Yy]$ ]]; then
    echo 'alias ubuntu="proot-distro login ubuntu"' >> ~/.bashrc
    echo -e "Alias 'ubuntu' added!\n"
    echo "~ \$ ubuntu"
else
    echo "To start Ubuntu, run: proot-distro login ubuntu"
fi
