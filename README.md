# Evilginx3PhishLab

This project provides a ready-to-deploy phishing lab environment using Evilginx3 (v3.3.0), Gophish, and Mailhog, built for security researchers, red teams, and penetration testers who need to simulate credential phishing and man-in-the-middle (MiTM) scenarios — including the ability to bypass multi-factor authentication (2FA) in controlled environments.

---

##  Purpose

The goal of this lab is to create a self-contained environment for:

- Simulating real-world phishing techniques
- Testing 2FA bypass methods using Evilginx3
- Running phishing email campaigns via Gophish
- Capturing and analyzing emails using Mailhog
- Practicing red team tradecraft in a legal and authorized manner

This setup is **not intended** for production deployment or unauthorized testing.

---

##  What's Included

- **Evilginx3 v3.3.0**  
  Reverse proxy phishing framework with native DNS/HTTP support and Let's Encrypt integration.
- **Gophish**  
  Phishing campaign automation and delivery platform.
- **Mailhog**  
  Lightweight SMTP server with webmail UI for testing and validation.
- **Firewall (UFW)**  
  Configured to allow only essential ports (22, 80, 443, 8800, 8025).
- **Verification checks**  
  Confirms all services are properly installed and running.

---

##  System Requirements

- Ubuntu 20.04 x64 VPS (tested on Vultr)
- Root SSH access
- A registered domain with A-records pointing to the VPS:
  - `login.yourdomain.com`
  - `static.yourdomain.com`
- Ports 80 and 443 open to the public internet

---

## ⚙️ Installation

SSH into your server as root and run:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/CyberOneHQ/Evilginx3PhishLab/refs/heads/main/install.sh)
