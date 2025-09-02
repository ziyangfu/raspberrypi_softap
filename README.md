```bash
pi@raspberrypi:~ $ sudo ./enable_rpi_softap.sh 
***************************************************
*      Enabling Raspberry Pi 3B+ SoftAP           *
***************************************************
[INFO] Root privileges confirmed.
[INFO] Checking for hostapd and dnsmasq...
[INFO] hostapd and dnsmasq are already installed.
[INFO] Configuring hostapd...
[INFO] Backing up existing /etc/hostapd/hostapd.conf to /etc/hostapd/hostapd.conf.bak
[INFO] Creating new /etc/hostapd/hostapd.conf...
[INFO] /etc/hostapd/hostapd.conf created successfully.
[INFO] Enabling and starting hostapd service...
[INFO] hostapd service started.
[INFO] Configuring dnsmasq...
[INFO] Creating new /etc/dnsmasq.conf...
[INFO] /etc/dnsmasq.conf created successfully.
[INFO] Configuring static IP for wlan0 using dhcpcd...
[INFO] Backing up existing /etc/dhcpcd.conf to /etc/dhcpcd.conf.bak
[INFO] Adding new static IP configuration for wlan0 to /etc/dhcpcd.conf...
[INFO] /etc/dhcpcd.conf updated successfully.
[INFO] Restarting services to apply changes...

***************************************************
*   Raspberry Pi SoftAP enabled successfully!     *
***************************************************

Network details:
  SSID: WiFi_PI
  Password: pipi0202
  SoftAP IP Address: 192.168.10.1

Note: Your Raspberry Pi's wlan0 interface is now in SoftAP mode.
      You may need to reboot for all changes to take full effect.
      To disable SoftAP and restore normal Wi-Fi connectivity, run: sudo ./disable_rpi_softap.sh

```
