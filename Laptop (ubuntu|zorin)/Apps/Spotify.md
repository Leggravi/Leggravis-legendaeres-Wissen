[TOC]

# Spicetify

Am einfachsten funktioniert Spicetify mit der **APT-Version von Spotify**.

## Spotify Installation via APT (Ubuntu / Debian)

### ⚠️ Wichtiger Hinweis

Die Installation von Spotify über APT funktioniert nur auf neueren Systemen (z. B. Ubuntu 24.04 / Zorin OS 18 oder neuer), da das Paket aktuelle Systembibliotheken benötigt (`libc6 >= 2.39`).

Auf älteren Versionen wie Ubuntu 22.04 schlägt die Installation fehl.

------

## 📦 Voraussetzungen

System aktualisieren:

```
sudo apt update
sudo apt upgrade
```

Benötigte Tools installieren:

```
sudo apt install curl gnupg
```

------

## ⚠️ Falls Spotify bereits als Flatpak installiert ist

Spicetify funktioniert deutlich zuverlässiger mit der APT-Version.

Prüfen:

```
flatpak list | grep Spotify
```

Falls vorhanden:

```
flatpak uninstall com.spotify.Client
```

------

## 🔑 Schritt 1: Spotify GPG-Key hinzufügen

```
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 5384CE82BA52C83A

gpg --export 5384CE82BA52C83A | sudo tee /etc/apt/keyrings/spotify.gpg > /dev/null

sudo chmod 644 /etc/apt/keyrings/spotify.gpg
```

------

## 📁 Schritt 2: Spotify Repository hinzufügen

⚠️ HTTPS verwenden:

```
echo "deb [signed-by=/etc/apt/keyrings/spotify.gpg] https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
```

------

## 🔄 Schritt 3: Paketlisten aktualisieren

```
sudo apt update
```

Wenn keine GPG-Fehler erscheinen, ist das Repository korrekt eingerichtet.

------

## 🎵 Schritt 4: Spotify installieren

```
sudo apt install spotify-client
```

------

## 🚀 Schritt 5: Spotify einmal starten

```
spotify
```

- einloggen
- kurz offen lassen
- wieder schließen

Dadurch werden die benötigten Konfigurationsdateien erzeugt.

------

# Spicetify installieren

## 📥 Installation

Offizielle Anleitung:

- [Spicetify Getting Started](https://spicetify.app/docs/getting-started?utm_source=chatgpt.com#linux)
- [Spicetify Homepage](https://spicetify.app/?utm_source=chatgpt.com#install)

Installation:

```
curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
```

Marketplace mit installieren: `Y`

------

## ⚙️ Spotify-Pfade setzen

```
spicetify config spotify_path /usr/share/spotify
spicetify config prefs_path ~/.config/spotify/prefs
```

------

## 🔓 Schreibrechte für Spotify setzen

Damit Spicetify die Spotify-Dateien patchen darf:

```
sudo chown -R $USER:$USER /usr/share/spotify
sudo chmod -R a+rw /usr/share/spotify/Apps
```

------

## 🛠️ Backup + Apply

Spotify vorher schließen:

```
pkill -f spotify
```

Dann:

```
spicetify restore backup
```

danach:

```
spicetify backup apply
```

und zuletzt:

```
spicetify apply
```

------

## 🚀 Spotify starten

```
spotify
```

Links in der Sidebar sollte jetzt der Marketplace sichtbar sein.

------

# Troubleshooting

## ❌ Fehler: `NO_PUBKEY 5384CE82BA52C83A`

GPG-Key fehlt oder wurde falsch gespeichert.

→ Schritt „Spotify GPG-Key hinzufügen“ erneut durchführen.

------

## ❌ Fehler: `libc6 (>= 2.39)`

Das System ist zu alt (z. B. Ubuntu 22.04).

### Lösungen

- auf Ubuntu 24.04 upgraden
- oder Spotify via Flatpak/Snap installieren
   (Spicetify funktioniert dort aber oft problematischer)

------

## ❌ Fehler: `Unable to locate package spotify-client`

Repository nicht korrekt eingebunden.

Prüfen:

```
cat /etc/apt/sources.list.d/spotify.list
```

Dann erneut:

```
sudo apt update
```

------

## ❌ Fehler: `permission denied`

Beispiel:

```
fatal unlinkat /usr/share/spotify/Apps/xpui.spa: permission denied
```

Lösung:

```
sudo chown -R $USER:$USER /usr/share/spotify
sudo chmod -R a+rw /usr/share/spotify/Apps
```

------

## ❌ Schwarzes Spotify-Fenster nach Spicetify

Zurücksetzen:

```
spicetify restore
```

Danach erneut:

```
spicetify apply
```

------

## ❌ GTK-Warnungen beim Start

Beispiel:

```
Failed to load module "canberra-gtk-module"
```

Optional fixbar mit:

```
sudo apt install libcanberra-gtk-module libcanberra-gtk3-module
```

Diese Warnungen sind normalerweise harmlos

# Spicitify

am einfachsten über die **apt-Version**:

## Spotify Installation via APT (Ubuntu / Debian)

### ⚠️ Wichtiger Hinweis

Die Installation von Spotify über APT funktioniert **nur auf neueren Systemen** (z. B. Ubuntu 24.04 oder neuer), da das Paket aktuelle Systembibliotheken benötigt (`libc6 >= 2.39`).

Auf älteren Versionen wie Ubuntu 22.04 schlägt die Installation fehl.

------

### 📦 Voraussetzungen

Stelle sicher, dass dein System aktuell ist:

```bash
sudo apt update
sudo apt upgrade
```

Optional (meist bereits vorhanden):

```bash
sudo apt install curl gnupg
```

------

### 🔑 Schritt 1: GPG-Key hinzufügen

Der Repository-Key muss korrekt importiert und in ein binäres Format umgewandelt werden:

```bash
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 5384CE82BA52C83A
gpg --export 5384CE82BA52C83A | sudo tee /etc/apt/keyrings/spotify.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/spotify.gpg
```

------

### 📁 Schritt 2: Spotify-Repository hinzufügen

```bash
echo "deb [signed-by=/etc/apt/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
```

------

### 🔄 Schritt 3: Paketliste aktualisieren

```bash
sudo apt update
```

Wenn hier keine GPG-Fehler erscheinen, ist alles korrekt eingerichtet.

------

### 🎵 Schritt 4: Spotify installieren

```bash
sudo apt install spotify-client
```

------

### 🚀 Schritt 5: Spotify starten

```bash
spotify
```

oder über das Anwendungsmenü.

------

### 🧪 Troubleshooting

#### ❌ Fehler: `NO_PUBKEY 5384CE82BA52C83A`

→ GPG-Key fehlt oder ist falsch gespeichert
→ Schritt 1 erneut durchführen

------

#### ❌ Fehler: `libc6 (>= 2.39)`

→ System ist zu alt (z. B. Ubuntu 22.04)

**Lösungen:**

- System auf Ubuntu 24.04 upgraden
- oder alternative Installationsmethoden nutzen (Flatpak/Snap)

------

#### ❌ Paket nicht gefunden

```bash
E: Unable to locate package spotify-client
```

→ Repository nicht korrekt eingebunden
→ Schritt 2 und 3 prüfen

------

## Install Spicitify

https://spicetify.app/docs/getting-started#linux
https://spicetify.app/#install

```
curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
```



