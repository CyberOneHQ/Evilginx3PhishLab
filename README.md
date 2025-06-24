# Evilginx3 PhishLab

This setup script provisions a complete phishing simulation environment using Evilginx3, Gophish, and Mailhog on a Linux VPS. It is intended strictly for testing and research purposes in a controlled environment.

## Overview

The lab is designed to simulate real-world credential harvesting and MiTM (man-in-the-middle) scenarios for red team training or tool evaluation. It supports phishing infrastructure setup using a real domain and SSL with Let's Encrypt.

## Components Installed

- **Evilginx3** – HTTPS reverse proxy framework for phishing and session hijacking.
- **Gophish** – Phishing campaign and template manager (Admin UI exposed on port 8800).
- **Mailhog** – Lightweight SMTP server with a web UI for testing email delivery (port 8025).

## Requirements

- Ubuntu 20.04 x64
- Root access
- A domain name with two A-records:
  - `login.yourdomain.com`
  - `static.yourdomain.com`
- Ports 80 and 443 must be open for Let's Encrypt validation

## Usage

1. Point your domain and subdomains to the VPS IP.
2. SSH into your server as root.
3. Run the setup script:

   ```bash
   bash <(curl -sSL https://raw.githubusercontent.com/CyberOneHQ/Evilginx3PhishLab/refs/heads/main/install.sh)
