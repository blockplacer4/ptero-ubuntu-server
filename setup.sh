#!/bin/bash

sudo apt update && sudo apt upgrade -y

# Prompt for the root password twice
echo "Enter the new root password:"
read -s password1
echo
echo "Confirm the new root password:"
read -s password2
echo

# Check if the passwords match
if [ "$password1" != "$password2" ]; then
  echo "Error: the passwords do not match."
  exit 1
fi

# Change the root password
echo "root:$password1" | chpasswd

sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

systemctl restart sshd

# Delete all user accounts except root
for user in $(cut -d: -f1 /etc/passwd | grep -vE '^(root|halt|sync|shutdown)$'); do
  if [ "$user" != "ubuntu" ]; then
    userdel -r "$user"
  fi
done

# Execute the Pterodactyl bash script
bash <(curl -s https://pterodactyl-installer.se)
