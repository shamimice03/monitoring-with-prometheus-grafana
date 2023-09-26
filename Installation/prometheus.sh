#!/bin/bash
set -x  # Enable debugging output

# Update the package list and upgrade installed packages
sudo yum update -y

# Upgrade the system to the latest available packages
sudo yum upgrade -y

# Install wget
sudo yum install wget -y

# Create a system group for Prometheus
sudo groupadd --system prometheus

# Create a system user for Prometheus with /sbin/nologin shell
sudo useradd -s /sbin/nologin --system -g prometheus prometheus

# Create necessary directories for Prometheus configuration and data
sudo mkdir -p /var/lib/prometheus
sudo mkdir -p /etc/prometheus/rules
sudo mkdir -p /etc/prometheus/rules.s
sudo mkdir -p /etc/prometheus/files_sd

# Create a temporary directory for downloading and extracting Prometheus binaries
wget https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz -P /tmp
tar xvf "/tmp/prometheus-2.46.0.linux-amd64.tar.gz" --strip-components=1 -C /tmp

# Move Prometheus binaries and configuration files to appropriate locations
sudo mv -f /tmp/prometheus /usr/local/bin
sudo mv -f /tmp/promtool /usr/local/bin
sudo mv -f /tmp/prometheus.yml /etc/prometheus/

# Define the service unit file path
SERVICE_UNIT_FILE="/etc/systemd/system/prometheus.service"

# Check if the service unit file already exists
if [ -e "$SERVICE_UNIT_FILE" ]; then
    echo "Service unit file $SERVICE_UNIT_FILE already exists."
    exit 1
fi

# Use a here document to create the Prometheus service unit file
sudo tee "$SERVICE_UNIT_FILE" > /dev/null <<EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries \\
  --web.listen-address=0.0.0.0:9090 \\
  --web.external-url=
SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Change ownership of Prometheus configuration and data directories
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

# Set appropriate permissions for directories
sudo chmod -R 775 /etc/prometheus
sudo chmod -R 775 /var/lib/prometheus

# Reload systemd to apply the new unit file
sudo systemctl daemon-reload

# Start Prometheus service and enable it to start at boot
sudo systemctl start prometheus
sudo systemctl enable prometheus