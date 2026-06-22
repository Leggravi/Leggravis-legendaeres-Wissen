[TOC]

# Lokales AI-Setup (Ollama + Open WebUI + Aider)

## 0. Überblick (was du hier eigentlich gebaut hast)

Du hast ein lokales KI-Stack aufgebaut, bestehend aus drei Schichten:

- **Ollama** → Modell-Server (führt LLMs lokal aus)
- **Open WebUI** → Weboberfläche für Chat & Modelle
- **Aider** → Coding-Agent mit Git-Integration

Architektur:

```
Open WebUI (Browser)
        ↓
   Ollama API (11434)
        ↓
   lokale Modelle (Qwen etc.)

Aider (Terminal)
        ↓
   Ollama API
        ↓
   Git-Repository + Dateien
```

------

# 1. Nutzung (das ist das, was du eigentlich wissen willst)

## 1.1 Open WebUI (GUI / Chat)

**Start:**

```
http://localhost:8080
```

**Was du hier machst:**

- Chatten mit Modellen
- Dateien / PDFs analysieren
- Modelle wechseln
- Prompting ohne Terminal

**Wichtig:**
 Open WebUI ist nur UI → keine eigene Intelligenz.

------

## 1.2 Aider (Coding-Agent)

Aider arbeitet **direkt im Codeprojekt** und verändert Dateien.

### Start im Projekt:

```
cd dein-projekt
aider --model ollama/qwen2.5-coder:7b
```

### Standard-Workflow:

```
/add .
```

Dann z. B.:

```
Analysiere die Projektstruktur und verbessere sie
```

oder:

```
Refaktoriere diesen Code sauber und modular
```

### Was Aider kann:

- Dateien lesen und ändern
- Git commits erstellen
- Multi-file Refactoring
- Code generieren

### Was Aider NICHT kann:

- ohne Git arbeiten
- automatisch ganze Systeme verstehen ohne Kontext
- große Monorepos sinnvoll handhaben

------

## 1.3 Ollama (Backend)

Nur relevant im Hintergrund:

- API läuft auf:

  ```
  http://localhost:11434
  ```

- Modelle anzeigen:

  ```
  curl http://localhost:11434/api/tags
  ```

------

## 1.4 Modellwahl (wichtig)

Du hast aktuell:

### Chat / Reasoning

- `qwen3:8b`
  - gute allgemeine Antworten
  - Erklärung, Denken, Text

### Coding / Agenten

- `qwen2.5-coder:7b`
  - deutlich besser für Aider
  - versteht Code-Strukturen besser
  - stabiler bei Änderungen

------

# 2. Installation (kompakt & korrekt)

## 2.1 System vorbereiten

```
sudo apt update
sudo apt install docker.io git curl pipx -y
```

Docker aktivieren:

```
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

→ danach **neu einloggen**

------

## 2.2 Ollama installieren

```
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable ollama
sudo systemctl start ollama
```

Modelle:

```
ollama pull qwen3:8b
ollama pull qwen2.5-coder:7b
```

Test:

```
curl http://localhost:11434/api/tags
```

------

## 2.3 Open WebUI (empfohlene Linux-Variante)

```
docker run -d \
  --network=host \
  -e OLLAMA_BASE_URL=http://localhost:11434 \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

Aufrufen:

```
http://localhost:8080
```

------

## 2.4 Aider installieren

```
pipx install aider-chat
```

Ollama verbinden:

```
export OLLAMA_API_BASE=http://127.0.0.1:11434
```

------

# 3. Typische Probleme (wichtig in der Praxis)

## Docker / WebUI

### Problem: UI verbindet sich nicht zu Ollama

Fix:

```
--network=host
```

oder:

```
http://localhost:11434
```

------

## Aider

### Problem: „not in git repo“

Fix:

```
git init
```

------

### Problem: zu großes Repo

Fix:

- in Unterordner gehen
- oder gezielt Dateien hinzufügen:

```
/add main.py
```

------

## Ollama

### Problem: keine Verbindung

Fix:

```
sudo systemctl restart ollama
```

------

# 4. Best Practices

## 4.1 Aider richtig verwenden

Nicht:

```
/add .
im 9000-Dateien Repo
```

Sondern:

```
kleine, klare Projekte
```

------

## 4.2 Modellwahl

| Zweck           | Modell           |
| --------------- | ---------------- |
| Chat / Erklären | qwen3:8b         |
| Coding / Aider  | qwen2.5-coder:7b |

------

## 4.3 Architekturdenken

- Ollama = Motor
- WebUI = Dashboard
- Aider = Entwickler-Agent

Kein Tool ersetzt das andere.

------

# 5. Fazit

Du hast jetzt ein vollständiges lokales AI-System:

- ChatGPT-artige Oberfläche (WebUI)
- Coding-Agent (Aider)
- lokale LLMs (Ollama)
- GPU-Acceleration aktiv

Der wichtigste Unterschied zu „echten AI-Agents“ ist:

> Deine Modelle haben keine Automatik – sie brauchen Tools (Aider/WebUI), um in Systeme eingreifen zu können
