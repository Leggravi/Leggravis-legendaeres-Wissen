cd ./Documents/prank
#!/bin/bash

IFACE="wlo1"
IP="192.168.50.1/24"

cleanup() {
    echo
    echo "[*] Stoppe Prank-Hotspot…"

    sudo systemctl stop hostapd dnsmasq

    sudo ip addr flush dev $IFACE

    echo "[*] Starte NetworkManager neu…"
    sudo systemctl start NetworkManager

    echo "[✓] WLAN wieder normal aktiv."
    exit 0
}

# Ctrl+C / SIGTERM abfangen
trap cleanup SIGINT SIGTERM

echo "[*] Stoppe NetworkManager…"
sudo systemctl stop NetworkManager

echo "[*] Konfiguriere Interface $IFACE…"
sudo ip addr flush dev $IFACE
sudo ip addr add $IP dev $IFACE
sudo ip link set $IFACE up

echo "[*] Starte hostapd & dnsmasq…"
sudo systemctl start hostapd
sudo systemctl start dnsmasq

echo "[*] Starte Captive-Portal-Webserver…"
echo "[*] Beenden mit Ctrl+C"

# Webserver starten (blockierend!)
sudo python3 server.py

