#!/bin/bash
# XRAY-Multilang Installer by DarkAndreas — v1.0 Global

# 🧾 Root check
[[ $EUID -ne 0 ]] && { echo "❌ Run as root!"; exit 1; }

# 🛠️ Install dependencies
apt update -y
apt install curl wget unzip jq -y

# 📥 Download XRAY core
mkdir -p /usr/local/xray /etc/xray /var/log/xray
wget -O /usr/local/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /usr/local/xray/xray.zip -d /usr/local/xray/
chmod +x /usr/local/xray/xray

# 🧬 Get templates and tools from GitHub
REPO="https://raw.githubusercontent.com/DarkAndreas/xray-multilang-vless/main"
mkdir -p /etc/xray /opt/langhelp /opt/user-tools /opt/templates

# 📦 Download templates
wget -qO /etc/xray/config.json "$REPO/templates/config_template.json"
wget -qO /opt/templates/env_template "$REPO/templates/env_template"

# 📁 Download localization system
wget -qO /opt/langhelp/langhelp.sh "$REPO/langhelp/langhelp.sh"
for code in ru en he hy az ka bg it pt th fa nl el ms; do
  wget -qO /opt/langhelp/help_"$code" "$REPO/langhelp/help_$code"
done

# 👥 Download user tools
for script in mainuser newuser rmuser userlist sharelink; do
  wget -qO /opt/user-tools/"$script".sh "$REPO/user-tools/$script.sh"
  chmod +x /opt/user-tools/"$script".sh
done

# 🧠 Run language help
bash /opt/langhelp/langhelp.sh

# 🔐 Register XRAY systemd service
cat <<EOF > /etc/systemd/system/xray.service
[Unit]
Description=Xray Multilang Service
After=network.target

[Service]
ExecStart=/usr/local/xray/xray run -config /etc/xray/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable xray
systemctl restart xray

echo "✅ XRAY Multilang установлен! 🎉"
echo "📦 Команды пользователей: /opt/user-tools/"
