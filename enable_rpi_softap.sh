#!/bin/sh

# \brief 配置树莓派3B+的SoftAP功能, enable softap function for raspberrypi
# \usage sudo ./enable_rpi_softap.sh

echo "***************************************************"
echo "*      Enabling Raspberry Pi 3B+ SoftAP           *"
echo "***************************************************"

# --------------------------------------------------
# Step 0: 检查是否拥有 root 权限
# --------------------------------------------------
if [ "$(id -u)" != "0" ]; then
    echo "Error: This script must be run as root."
    exit 1
fi
echo "[INFO] Root privileges confirmed."

# --------------------------------------------------
# Step 1: 安装 hostapd 和 dnsmasq (如果尚未安装)
# --------------------------------------------------
echo "[INFO] Checking for hostapd and dnsmasq..."
if ! dpkg -s hostapd >/dev/null 2>&1 || ! dpkg -s dnsmasq >/dev/null 2>&1; then
    echo "[INFO] Installing hostapd and dnsmasq..."
    apt update
    apt install -y hostapd dnsmasq
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install hostapd or dnsmasq. Please check your internet connection and try again."
        exit 1
    fi
    echo "[INFO] hostapd and dnsmasq installed successfully."
else
    echo "[INFO] hostapd and dnsmasq are already installed."
fi

# --------------------------------------------------
# Step 2: 配置 hostapd
# --------------------------------------------------
echo "[INFO] Configuring hostapd..."

# 停止 hostapd 服务
systemctl stop hostapd.service >/dev/null 2>&1

# 备份旧的 hostapd 配置文件 (如果存在)
if [ -f "/etc/hostapd/hostapd.conf" ]; then
    echo "[INFO] Backing up existing /etc/hostapd/hostapd.conf to /etc/hostapd/hostapd.conf.bak"
    mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak
fi

# 创建新的 hostapd 配置文件
echo "[INFO] Creating new /etc/hostapd/hostapd.conf..."
cat << EOF > /etc/hostapd/hostapd.conf
interface=wlan0
country_code=CN
driver=nl80211
ssid=WiFi_PI
hw_mode=g
channel=2
ieee80211n=1
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=pipi0202
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

if [ $? -ne 0 ]; then
    echo "Error: Failed to create /etc/hostapd/hostapd.conf."
    exit 1
fi
echo "[INFO] /etc/hostapd/hostapd.conf created successfully."

# 启用并启动 hostapd 服务
echo "[INFO] Enabling and starting hostapd service..."
systemctl unmask hostapd.service >/dev/null 2>&1
systemctl enable hostapd.service >/dev/null 2>&1
systemctl start hostapd.service
if [ $? -ne 0 ]; then
    echo "Error: Failed to start hostapd service. Please check the configuration and try again."
    exit 1
fi
echo "[INFO] hostapd service started."

# --------------------------------------------------
# Step 3: 配置 DHCP 和 DNS (dnsmasq)
# --------------------------------------------------
echo "[INFO] Configuring dnsmasq..."

# 停止 dnsmasq 服务
systemctl stop dnsmasq.service >/dev/null 2>&1

# 备份旧的 dnsmasq 配置文件 (如果存在)
if [ -f "/etc/dnsmasq.conf" ]; then
    echo "[INFO] Backing up existing /etc/dnsmasq.conf to /etc/dnsmasq.conf.bak"
    mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
fi

# 创建新的 dnsmasq 配置文件
echo "[INFO] Creating new /etc/dnsmasq.conf..."
cat << EOF > /etc/dnsmasq.conf
# Interface to listen on
interface=wlan0

# DHCP range
# Start IP, End IP, Lease time
# Note: The subnet mask is derived from the static IP configured for wlan0.
dhcp-range=192.168.10.10,192.168.10.50,255.255.255.0,24h
EOF

if [ $? -ne 0 ]; then
    echo "Error: Failed to create /etc/dnsmasq.conf."
    exit 1
fi
echo "[INFO] /etc/dnsmasq.conf created successfully."

# --------------------------------------------------
# Step 4: 配置静态 IP 地址给 wlan0 (使用 dhcpcd)
# --------------------------------------------------
echo "[INFO] Configuring static IP for wlan0 using dhcpcd..."

# 备份旧的 dhcpcd 配置文件 (如果存在)
if [ -f "/etc/dhcpcd.conf" ]; then
    echo "[INFO] Backing up existing /etc/dhcpcd.conf to /etc/dhcpcd.conf.bak"
    cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak
fi

# 检查并移除 wlan0 的现有配置（如果存在）
# 使用 sed 删除包含 'interface wlan0' 及之后三行的内容
sed -i '/^interface wlan0/,+3d' /etc/dhcpcd.conf

# 在文件末尾添加新的 wlan0 配置
echo "[INFO] Adding new static IP configuration for wlan0 to /etc/dhcpcd.conf..."
cat << EOF >> /etc/dhcpcd.conf
interface wlan0
static ip_address=192.168.10.1/24
nohook wpa_supplicant
EOF

if [ $? -ne 0 ]; then
    echo "Error: Failed to update /etc/dhcpcd.conf."
    exit 1
fi
echo "[INFO] /etc/dhcpcd.conf updated successfully."

# --------------------------------------------------
# Step 5: 重启服务以应用配置
# --------------------------------------------------
echo "[INFO] Restarting services to apply changes..."
systemctl restart hostapd.service
systemctl enable dnsmasq.service
systemctl restart dnsmasq.service
systemctl restart dhcpcd.service # 确保 dhcpcd 也重启以应用静态IP

if [ $? -ne 0 ]; then
    echo "Warning: Some services might not have restarted correctly. Please check manually."
fi

echo ""
echo "***************************************************"
echo "*   Raspberry Pi SoftAP enabled successfully!     *"
echo "***************************************************"
echo ""
echo "Network details:"
echo "  SSID: WiFi_PI"
echo "  Password: pipi0202"
echo "  SoftAP IP Address: 192.168.10.1"
echo ""
echo "Note: Your Raspberry Pi's wlan0 interface is now in SoftAP mode."
echo "      You may need to reboot for all changes to take full effect."
echo "      To disable SoftAP and restore normal Wi-Fi connectivity, run: sudo ./disable_rpi_softap.sh"
echo ""
exit 0
