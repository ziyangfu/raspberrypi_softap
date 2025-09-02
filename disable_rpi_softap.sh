#!/bin/sh

# \brief 禁用树莓派3B+的SoftAP功能，恢复正常Wi-Fi联网;To disable SoftAP and restore normal Wi-Fi connectivity
# \usage sudo ./disable_rpi_softap.sh

echo "***************************************************"
echo "*      Disabling Raspberry Pi 3B+ SoftAP          *"
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
# Step 1: 停止并禁用 SoftAP 相关的服务
# --------------------------------------------------
echo "[INFO] Stopping and disabling SoftAP services (hostapd, dnsmasq)..."

# 停止 hostapd 服务
systemctl stop hostapd.service >/dev/null 2>&1
# 禁用 hostapd 服务
systemctl disable hostapd.service >/dev/null 2>&1
# 取消 mask (如果之前被 mask 了)
systemctl unmask hostapd.service >/dev/null 2>&1

# 停止 dnsmasq 服务
systemctl stop dnsmasq.service >/dev/null 2>&1
# 禁用 dnsmasq 服务 (如果之前被 enable 了)
systemctl disable dnsmasq.service >/dev/null 2>&1

echo "[INFO] SoftAP services stopped and disabled."

# --------------------------------------------------
# Step 2: 恢复 /etc/hostapd/hostapd.conf 配置 (如果存在备份)
# --------------------------------------------------
echo "[INFO] Restoring original hostapd configuration..." 
if [ -f "/etc/hostapd/hostapd.conf.bak.100" ]; then  # 取消从备份中恢复功能
    echo "[INFO] Restoring /etc/hostapd/hostapd.conf from backup..."
    mv /etc/hostapd/hostapd.conf.bak /etc/hostapd/hostapd.conf
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to restore /etc/hostapd/hostapd.conf."
    else
        echo "[INFO] /etc/hostapd/hostapd.conf restored."
    fi
else
    # 如果没有备份，则移除当前创建的配置文件
    if [ -f "/etc/hostapd/hostapd.conf" ]; then
        echo "[INFO] No backup found for /etc/hostapd/hostapd.conf. Removing the SoftAP configuration..."
        rm -f /etc/hostapd/hostapd.conf
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to remove /etc/hostapd/hostapd.conf."
        else
            echo "[INFO] SoftAP hostapd configuration removed."
        fi
    fi
fi

# --------------------------------------------------
# Step 3: 恢复 /etc/dnsmasq.conf 配置 (如果存在备份)
# --------------------------------------------------
echo "[INFO] Restoring original dnsmasq configuration..."
if [ -f "/etc/dnsmasq.conf.bak.100" ]; then  # 取消从备份中恢复功能
    echo "[INFO] Restoring /etc/dnsmasq.conf from backup..."
    mv /etc/dnsmasq.conf.bak /etc/dnsmasq.conf
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to restore /etc/dnsmasq.conf."
    else
        echo "[INFO] /etc/dnsmasq.conf restored."
    fi
else
    # 如果没有备份，则移除当前创建的配置文件
    if [ -f "/etc/dnsmasq.conf" ]; then
        echo "[INFO] No backup found for /etc/dnsmasq.conf. Removing the SoftAP configuration..."
        rm -f /etc/dnsmasq.conf
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to remove /etc/dnsmasq.conf."
        else
            echo "[INFO] SoftAP dnsmasq configuration removed."
        fi
    fi
fi

# --------------------------------------------------
# Step 4: 恢复 /etc/dhcpcd.conf 配置 (如果存在备份)
# --------------------------------------------------
echo "[INFO] Restoring original dhcpcd configuration..."
if [ -f "/etc/dhcpcd.conf.bak.100" ]; then  # 取消从备份中恢复功能
    echo "[INFO] Restoring /etc/dhcpcd.conf from backup..."
    mv /etc/dhcpcd.conf.bak /etc/dhcpcd.conf
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to restore /etc/dhcpcd.conf."
    else
        echo "[INFO] /etc/dhcpcd.conf restored."
    fi
else
    # 如果没有备份，则移除当前添加的 wlan0 配置
    if [ -f "/etc/dhcpcd.conf" ]; then
        echo "[INFO] No backup found for /etc/dhcpcd.conf. Removing the static IP configuration for wlan0..."
        # 尝试移除之前添加的 'interface wlan0' 配置块
        # 注意：这里的 sed 命令是基于 enable 脚本的添加方式，可能会有遗漏
        sed -i '/^interface wlan0/,+3d' /etc/dhcpcd.conf
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to remove the static IP configuration for wlan0 from /etc/dhcpcd.conf."
        else
            echo "[INFO] Static IP configuration for wlan0 removed from /etc/dhcpcd.conf."
        fi
    fi
fi

# --------------------------------------------------
# Step 5: 重启 dhcpcd 服务以应用可能恢复的配置
# --------------------------------------------------
echo "[INFO] Restarting dhcpcd service to apply changes..."
systemctl restart dhcpcd.service
if [ $? -ne 0 ]; then
    echo "Warning: dhcpcd service might not have restarted correctly. Please check manually."
fi

echo ""
echo "***************************************************"
echo "*   Raspberry Pi SoftAP disabled successfully!    *"
echo "***************************************************"
echo ""
echo "Your Raspberry Pi's wlan0 interface should now be free to connect to other Wi-Fi networks."
echo "It's recommended to reboot your Raspberry Pi to ensure all changes are fully applied."
echo "To enable SoftAP again, run: sudo ./enable_rpi_softap.sh"
echo ""
exit 0
