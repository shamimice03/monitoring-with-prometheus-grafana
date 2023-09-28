#!/bin/bash
set -x  # Enable debugging output

sudo yum update -y
sudo yum install -y https://dl.grafana.com/enterprise/release/grafana-enterprise-10.0.0-1.x86_64.rpm
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server