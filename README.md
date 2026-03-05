# Evilginx3PhishLab

A ready-to-deploy phishing lab environment using Evilginx3 (v3.3.0), Gophish, and Mailhog for security researchers, red teams, and penetration testers.

**This setup is for authorized testing only. Do not use for unauthorized access.**

---

## What's Included

- **Evilginx3 v3.3.0** — Reverse proxy phishing framework with MiTM and 2FA bypass capabilities
- **Gophish v0.12.1** — Phishing campaign management and email delivery
- **Mailhog** — Local SMTP server with web UI for capturing test emails
- **UFW Firewall** — Configured to allow only essential ports
- **Systemd services** — All three tools run as managed services

---

## Requirements

- Ubuntu 20.04+ x64 VPS
- Root SSH access
- A registered domain with DNS A-records pointing to the VPS IP:
  - `yourdomain.com` (or a subdomain like `login.yourdomain.com`)
- Ports 80 and 443 open to the public internet

---

## Installation

SSH into your server as root and run:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/CyberOneHQ/Evilginx3PhishLab/main/install.sh)
```

You will be prompted for your domain. Alternatively, pass it as an argument:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/CyberOneHQ/Evilginx3PhishLab/main/install.sh) login.yourdomain.com
```

The script is idempotent and can be re-run safely.

---

## Post-Install Setup

### 1. Configure Evilginx3

Evilginx requires interactive configuration on first use. Stop the background service and run it manually:

```bash
systemctl stop evilginx
/opt/evilginx2/dist/evilginx -p /opt/evilginx2/phishlets
```

Inside the evilginx prompt, paste the commands from `/root/evilginx_setup_commands.txt`:

```
config domain login.yourdomain.com
config ip <YOUR_IP>
config redirect_url https://login.microsoftonline.com/
config autocert on
phishlets hostname microsoft login.yourdomain.com
phishlets enable microsoft
```

Once configured, exit and restart the service:

```bash
systemctl start evilginx
```

### 2. Access Gophish Admin

Gophish admin is bound to `127.0.0.1` for security. Access it via SSH tunnel:

```bash
ssh -L 8800:127.0.0.1:8800 root@YOUR_SERVER_IP
```

Then open `http://localhost:8800` in your browser.

The initial admin password is printed in the Gophish service log:

```bash
journalctl -u gophish | grep password
```

### 3. Connect Gophish to Mailhog

1. Open the Gophish admin UI
2. Navigate to **Sending Profiles**
3. Create a new profile with SMTP host: `localhost:1025`
4. No authentication required
5. Send a test email — it will appear in the Mailhog UI

### 4. View Captured Emails

Open `http://YOUR_SERVER_IP:8025` to access the Mailhog web UI.

---

## Services

| Service   | Command                        | Port(s)          |
|-----------|--------------------------------|------------------|
| Evilginx  | `systemctl status evilginx`    | 80, 443          |
| Gophish   | `systemctl status gophish`     | 8800 (localhost)  |
| Mailhog   | `systemctl status mailhog`     | 8025 (UI), 1025 (SMTP, localhost) |

Manage services with:

```bash
systemctl start|stop|restart|status <service>
journalctl -u <service> -f    # follow logs
```

---

## Firewall Rules

| Port | Service            |
|------|--------------------|
| 22   | SSH                |
| 80   | HTTP (Evilginx)   |
| 443  | HTTPS (Evilginx)  |
| 8800 | Gophish (localhost only) |
| 8025 | Mailhog Web UI     |

SMTP port 1025 is bound to localhost only and not exposed externally.

---

## Security Notes

- Gophish admin is bound to `127.0.0.1` — always access via SSH tunnel
- Mailhog SMTP is bound to localhost — only accessible from the server itself
- Services run under a dedicated `phishlab` user, not root
- Change the default Gophish password immediately after first login
- This lab is intended for **authorized security testing only**

---

## License

MIT
