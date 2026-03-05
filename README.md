# Evilginx3PhishLab

A ready-to-deploy phishing lab environment using Evilginx3 (v3.3.0), Gophish, and Mailhog for security researchers, red teams, and penetration testers.

**This setup is for authorized testing only. Do not use for unauthorized access.**

---

## What's Included

- **Evilginx3 v3.3.0** - Reverse proxy phishing framework with MiTM and 2FA bypass capabilities
- **Gophish v0.12.1** - Phishing campaign management and email delivery
- **Mailhog** - Local SMTP server with web UI for capturing test emails
- **UFW Firewall** - Configured to allow only essential ports
- **Systemd services** - All three tools run as managed services
- **Pre-loaded phishlets** - 11 ready-to-use phishlets for common targets

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
5. Send a test email - it will appear in the Mailhog UI

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

## Included Phishlets

The `phishlets/` directory contains 11 pre-configured phishlets ready for use with Evilginx3 v3.3.0.

### Native Evilginx3 (min_ver 3.0.0+)

| Phishlet | Target | Key Tokens | Source |
|----------|--------|------------|--------|
| `microsoft-live.yaml` | login.live.com | SDIDC, JSHP | SimplerHacking |
| `microsoft-o365-adfs.yaml` | login.microsoftonline.com + ADFS | ESTSAUTH, ESTSAUTHPERSISTENT | SimplerHacking |
| `okta.yaml` | Okta tenants (template) | idx | SimplerHacking |
| `twitter.yaml` | twitter.com / X | kdt, auth_token, ct0, twid | SimplerHacking |
| `linkedin.yaml` | linkedin.com (with evilpuppet) | li_at | SimplerHacking/Rencora |

### Evilginx2-Compatible (work in v3 via backward compat)

| Phishlet | Target | Key Tokens | Source |
|----------|--------|------------|--------|
| `o365.yaml` | login.microsoftonline.com | ESTSAUTH, ESTSAUTHPERSISTENT | An0nUD4Y |
| `google.yaml` | accounts.google.com | SID, HSID, SSID, GAPS | An0nUD4Y |
| `github.yaml` | github.com | user_session, _gh_sess | audibleblink |
| `facebook.yaml` | facebook.com | c_user, xs, sb | An0nUD4Y |
| `instagram.yaml` | instagram.com | sessionid | charlesbel |
| `aws.yaml` | signin.aws.amazon.com | aws-creds, JSESSIONID | An0nUD4Y |

### Notes

- **Okta** requires replacing `<okta-tenant-placeholder>` with your target's tenant name
- **O365 ADFS** requires replacing `example.com` with the actual ADFS domain
- Phishlets sourced from [simplerhacking/Evilginx3-Phishlets](https://github.com/simplerhacking/Evilginx3-Phishlets), [rencora/evilginx3-phishlet-templates](https://github.com/rencora/evilginx3-phishlet-templates), and [cybersecurityteampk/evilginx3-phishlets-2025](https://github.com/cybersecurityteampk/evilginx3-phishlets-2025)

---

## Security Notes

- Gophish admin is bound to `127.0.0.1` - always access via SSH tunnel
- Mailhog SMTP is bound to localhost - only accessible from the server itself
- Services run under a dedicated `phishlab` user, not root
- Change the default Gophish password immediately after first login
- This lab is intended for **authorized security testing only**

---

## License

MIT
