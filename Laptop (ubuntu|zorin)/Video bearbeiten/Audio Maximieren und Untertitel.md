[TOC]

# Wenn das Video Fertig ist

# Audio aus Video extrahieren (FFmpeg) + Bearbeitung in Audacity (maximieren)

Kompakte Anleitung:

- Audio aus Video extrahieren
- In Audacity bearbeiten
- Audio wieder ins Video einsetzen

------

## Voraussetzungen / Installation (Ubuntu)

```bash
sudo apt update
sudo apt install ffmpeg audacity zenity
```

- **ffmpeg** → Audio extrahieren & wieder einsetzen
- **audacity** → Audio bearbeiten
- **zenity** → Grafisches Dateiauswahlfenster im Terminal

------

## Durchführung / Vorgehen

### 1️⃣ Video grafisch auswählen & Audio extrahieren

Diesen Block komplett ins Terminal einfügen:

```bash
set VIDEO $(zenity --file-selection --title="Video auswählen")

ffmpeg -i "$VIDEO" -vn -acodec pcm_s16le -ar 48000 -ac 2 audio_raw.wav
```

➡ Es öffnet sich ein Dateifenster.
➡ Ergebnis: `audio_raw.wav`

alt: 

VIDEO=$(zenity --file-selection --title="Video auswählen")

ffmpeg -i "$VIDEO" -vn -acodec pcm_s16le -ar 48000 -ac 2 audio_raw.wav

------

### 2️⃣ Audio in Audacity bearbeiten

```bash
audacity audio_raw.wav
```

Audio maximieren:

1. **Effekt → Normalisieren** (z.B. -1 dB)
2. Optional: **Kompressor** für gleichmäßigere Lautstärke
3. Optional: **Limiter**, falls Peaks auftreten

Exportieren als:

- WAV (empfohlen)
  Dateiname: `audio_edited.wav`

### Länger:

#### 1️⃣ Normalize (erstmal sauber machen)

Effekt → **Normalize**

- Remove DC offset ✔
- Normalize peak to: **-1.0 dB**

Das gibt dir sauberen Headroom.

------

#### 2️⃣ Kompressor anwenden (wichtigster Schritt)

Effekt → **Compressor**

Empfohlene Einstellungen:

- Threshold: **-18 dB**
- Ratio: **3:1**
- Attack: 5 ms
- Release: 100 ms
- Make-up Gain: ✔
- Compress based on Peaks ❌ (nicht anhaken)

Das drückt laute Stellen runter → Durchschnittspegel steigt.

------

#### 3️⃣ Danach nochmal normalisieren

Wieder auf -1 dB normalisieren.

------

#### 4️⃣ Optional: Limiter (für mehr Lautheit)

Effekt → **Limiter**

- Type: Soft Limit
- Input Gain: +3 dB
- Limit to: -1 dB

Das gibt dir nochmal Lautheit ohne Clipping.

------

### 3️⃣ Bearbeitetes Audio wieder ins Video einsetzen

Diesen Block ins Terminal einfügen:

```bash
VIDEO=$(zenity --file-selection --title="Originalvideo auswählen")
AUDIO=$(zenity --file-selection --title="Bearbeitete Audio-Datei auswählen")

ffmpeg -i "$VIDEO" -i "$AUDIO" -map 0:v -map 1:a -c:v copy -c:a aac -b:a 192k video_final.mp4
```

➡ Es öffnen sich Auswahlfenster.
➡ Ergebnis: `video_final.mp4`



# Untertitel

super App:

vibe 

```
#alte Version
curl -sSf https://thewh1teagle.github.io/vibe/installer.sh | sh -s v3.0.14
```

dann als srt oder vtt importieren



### zum splitten

[File](subtitle-splitt.sh)  subtitle-split ausführen (im gleichen ordner)



remove von html tags:

```
sed -E 's/<[^>]+>//g' input.srt > cleaned.srt
```

