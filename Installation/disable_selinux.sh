#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Check if SELinux is enabled
if [ -f /etc/selinux/config ]; then
  # Backup the SELinux configuration file
  cp /etc/selinux/config /etc/selinux/config.bak

  # Disable SELinux by modifying the configuration file
  sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

  echo "SELinux has been disabled. Please reboot your system to apply the changes."
else
  echo "SELinux does not appear to be installed or configured on your system."
fi