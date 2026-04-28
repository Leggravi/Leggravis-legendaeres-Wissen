# Erste Hilfe & chroot (von anderem system rein)

[TOC]

# 1. erste Hilfe

! bei autoremove etc gefahr, da automatsich vestätigt wird!

```bash
# Paketlisten aktualisieren
apt update

# System vollständig aktualisieren (inkl. Kernel-Abhängigkeiten)
apt full-upgrade -y

# Falls Pakete beschädigt sind → reparieren
apt --fix-broken install -y

# Nicht mehr benötigte Pakete entfernen
apt autoremove -y

# NVIDIA-DKMS Status prüfen
dkms status

# NVIDIA-Module für alle installierten Kernel neu bauen
dkms autoinstall

# initramfs für alle Kernel neu generieren
update-initramfs -u -k all

# GRUB neu generieren
update-grub
```

(evlt superuser:)

| Befehl    | Verhalten                                 |
| --------- | ----------------------------------------- |
| `sudo -i` | lädt Root-Umgebung wie bei direktem Login |
| `sudo su` | wechselt zu Root über `su`                |
| `sudo -s` | startet Root-Shell mit aktueller Umgebung |

Für Reparaturarbeiten ist `sudo -i` technisch am saubersten.

#### Logging

```shell
# Root-Shell starten
sudo -i

# Logdatei definieren (Zeitstempel verhindert Überschreiben)
LOG="/root/repair-$(date +%Y%m%d-%H%M%S).log"

# Alles ab hier wird geloggt (stdout + stderr)
exec > >(tee -a "$LOG") 2>&1

echo "===== Reparatur gestartet am $(date) ====="

# Paketlisten aktualisieren
apt update

# System vollständig aktualisieren (inkl. Kernel)
apt full-upgrade -y

# Kaputte Abhängigkeiten reparieren
apt --fix-broken install -y

# Nicht mehr benötigte Pakete entfernen
apt autoremove -y

# NVIDIA-DKMS Status prüfen
dkms status

# NVIDIA-Module für alle Kernel neu bauen
dkms autoinstall

# initramfs für alle Kernel neu generieren
update-initramfs -u -k all

# GRUB neu generieren
update-grub

echo "===== Reparatur beendet am $(date) ====="
echo "Log gespeichert unter: $LOG"
```

ganze session speichern: 

script -a /root/repair-session.log

##### Log später ansehen

```
less /root/repair-*.log
```





### Falls NVIDIA komplett neu aufgebaut werden soll (nur wenn nötig)

```
# Alle NVIDIA-Pakete entfernen
apt purge 'nvidia-*'
apt autoremove
# DKMS-Cache bereinigen
rm -rf /var/lib/dkms/nvidia
# NVIDIA Treiber neu installieren (Version ggf. anpassen)
apt install nvidia-driver-570
# Danach erneut initramfs bauen
update-initramfs -u -k all
# GRUB erneut aktualisieren
update-grub
```



# 2 Chroot



## Voraussetzung

Ubuntu ist unter folgendem Pfad gemountet:

```
/mnt/ubuntu
```

Falls nicht, zuerst mounten:

```
sudo mount /dev/nvme0n1p3 /mnt/ubuntu
```

"3" durch die korrekte Partition ersetzen. 

```
lsblk -f
```

zum automatisch booten folgende datei:

```
sudo nano /etc/fstab
```

dann ergänzen

/dev/nvme0n1p2 /mnt/zorin ext4 defaults 0 2

------

## 2.1. System-Verzeichnisse binden

Diese Befehle exakt so ausführen:

```
sudo mount --bind /dev /mnt/ubuntu/dev
sudo mount --bind /dev/pts /mnt/ubuntu/dev/pts
sudo mount --bind /proc /mnt/ubuntu/proc
sudo mount --bind /sys /mnt/ubuntu/sys
sudo mount --bind /run /mnt/ubuntu/run
```

Optional (empfohlen bei UEFI-System):

```
sudo mount --bind /sys/firmware/efi/efivars /mnt/ubuntu/sys/firmware/efi/efivars
```

------

## 2.2 In Ubuntu wechseln (chroot)

```
sudo chroot /mnt/ubuntu
```

Du befindest dich jetzt im Ubuntu-System.

Prüfen:

```
uname -r
```

