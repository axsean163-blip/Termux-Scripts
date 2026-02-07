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

echo "An alias Of 'ubuntu' can be added for quicker logins. In this case you will only have to type \n'ubuntu' \n indead of\n 'proot-distro login ubuntu'.
"

read -p "Add 'ubuntu' alias for quicker logins? (Y/n): " ans
ans=${ans:-y}

if [[ "$ans" =~ ^[Yy]$ ]]; then
    echo 'alias="proot-distro login Ubuntu"'>>~/.bashrc
    echo "Alias 'ununtu' Added! For now on just yoe in that to begin:

~ $ ubuntu"
else
    echo "Update canceled."
fi

