[TOC]

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



