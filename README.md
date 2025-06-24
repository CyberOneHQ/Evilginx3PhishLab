# Evilginx3PhishLab

This repository includes a tested and production-ready setup script for deploying a phishing simulation environment using Evilginx3 (v3.3.0), Gophish, and Mailhog on Ubuntu 20.04. It is designed for testing and red team labs with your own domain and VPS.

## What's Included

- **Evilginx3 v3.3.0** – Go-based reverse proxy phishing framework with 2FA bypass support and Let's Encrypt auto-certification.
- **Gophish** – Campaign management and phishing delivery platform.
- **Mailhog** – Lightweight SMTP server and webmail UI for testing phishing emails.
- **Firewall (UFW)** – Configured to only allow necessary ports (22, 80, 443, 8800, 8025).
- **Service validation** – Confirms Evilginx3 binary exists, and Gophish and Mailhog services are running.

## Requirements

- A VPS (e.g., Vultr) running Ubuntu 20.04 x64
- Root SSH access
- A domain name with A-records pointing to your VPS:
  - `login.example.com`
  - `static.example.com`
- Ports 80 and 443 open to the internet

## Installation

SSH into your VPS as `root` and run:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/CyberOneHQ/Evilginx3PhishLab/refs/heads/main/install.sh)
