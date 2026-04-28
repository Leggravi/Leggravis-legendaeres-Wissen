[TOC]

https://claude.ai/chat/b5105a01-1602-485a-abeb-9a0500225d21

# Tipps

Im Browser bleibt der Download manchmal hängen. Und wie downloadet man YoutubeVideos usw?
-> einfach den Youtube Link kopieren (oder beim angefangene download rechtsklick -> **Downloadlink kopieren**)
Bei Spotify wird nach alternativen gesucht

> [!WARNING] 
>
> SPotify funktioniert zurzeit nicht
> Musst entsprechenden SOng/Album auf Youtube suchen!

## Install

```
sudo apt update && sudo apt install aria2 zenity ffmpeg
#! yt-dlp nicht über apt
sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod +x /usr/local/bin/yt-dlp
# yt-dlp -U !sollte die neuchste Version sein!
```

## New

`download` in der Konsole eingeben 
macht alles automatisch
(skript im usr/local/bin ordner)

- Playlists
- normale Downloads
- Youtube, Spotify
- alles



## Old

```bash
systemd-inhibit aria2c -c -x 8 -s 8 ["link"]
```

 > [!IMPORTANT]
 > Link am besten in Anführungszeichen packen! ("")

-> man kann wann anders weitermachen mit dem download
-> gut für schlechte Verbindung, Unterbrechung und große Downloads!



# Skript (im Ordner)

```bash
#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║           ULTIMATER DOWNLOADER v2.0                         ║
# ║  YouTube • Spotify • Instagram • TikTok • Playlists • MP3  ║
# ╚══════════════════════════════════════════════════════════════╝
set -o pipefail   # Pipes schlagen fehl wenn ein Teilbefehl fehlschlägt
# KEIN set -e – damit einzelne Track-Fehler nicht das ganze Script beendenE
# Wichtig: Subshell-Fehler nicht das ganze Script killen
trap 'true' ERR

DOWNLOAD_DIR="$HOME/Downloads"
COOKIES_FILE="$HOME/.config/yt-dlp/cookies.txt"  # optional, für private Inhalte

# ── Hilfsfunktionen ────────────────────────────────────────────

notify() {
    # Versuche zenity, sonst notify-send, sonst echo
    if command -v zenity &>/dev/null; then
        zenity --info --title="Downloader" --text="$1" --width=400 2>/dev/null || true
    elif command -v notify-send &>/dev/null; then
        notify-send "Downloader" "$1"
    else
        echo "[INFO] $1"
    fi
}

error_exit() {
    if command -v zenity &>/dev/null; then
        zenity --error --title="Fehler" --text="$1" --width=400 2>/dev/null || true
    else
        echo "[FEHLER] $1" >&2
    fi
    exit 1
}

progress_term() {
    # Öffnet ein Terminal-Fenster für den Download-Fortschritt
    local CMD="$1"
    local TITLE="$2"
    if command -v gnome-terminal &>/dev/null; then
        gnome-terminal --title="$TITLE" -- bash -c "$CMD; echo; echo '✔ Fertig! Dieses Fenster schließt in 5 Sekunden...'; sleep 5"
    elif command -v xterm &>/dev/null; then
        xterm -title "$TITLE" -e bash -c "$CMD; echo; echo '✔ Fertig! Dieses Fenster schließt in 5 Sekunden...'; sleep 5" &
    else
        eval "$CMD"
    fi
}

# ── Abhängigkeits-Check ────────────────────────────────────────

check_deps() {
    local MISSING=()
    command -v yt-dlp   &>/dev/null || MISSING+=("yt-dlp")
    command -v aria2c   &>/dev/null || MISSING+=("aria2c")
    command -v ffmpeg   &>/dev/null || MISSING+=("ffmpeg")

    if [ ${#MISSING[@]} -gt 0 ]; then
        local MSG="Fehlende Programme: ${MISSING[*]}\n\nInstallieren mit:\nsudo apt install ${MISSING[*]}\n\n(yt-dlp ggf. via: pip install yt-dlp)"
        if command -v zenity &>/dev/null; then
            zenity --question \
                --title="Abhängigkeiten fehlen" \
                --text="$MSG\n\nTrotzdem fortfahren?" \
                --width=450 2>/dev/null || exit 1
        else
            echo "[WARNUNG] Fehlende Programme: ${MISSING[*]}"
        fi
    fi
}

# ── URL erkennen ───────────────────────────────────────────────

detect_type() {
    local URL="$1"
    if   echo "$URL" | grep -qiE "spotify\.com/(track|album|playlist|artist)"; then
        echo "spotify"
    elif echo "$URL" | grep -qiE "instagram\.com"; then
        echo "instagram"
    elif echo "$URL" | grep -qiE "tiktok\.com"; then
        echo "tiktok"
    elif echo "$URL" | grep -qiE "youtube\.com/playlist|list="; then
        echo "yt_playlist"
    elif echo "$URL" | grep -qiE "youtube\.com|youtu\.be|vimeo\.com|twitch\.tv|dailymotion\.com|soundcloud\.com|bandcamp\.com"; then
        echo "yt_single"
    elif yt-dlp --simulate "$URL" &>/dev/null 2>&1; then
        echo "yt_single"
    else
        echo "file"
    fi
}

# ── Spotify: Titel via oEmbed (kein Login, kein API-Key nötig) ─

spotify_get_title() {
    # oEmbed liefert {"title": "Songname"} – funktioniert ohne Login
    local ID
    ID=$(echo "$1" | grep -oP '(?<=track/)[A-Za-z0-9]+' | head -1)
    [ -z "$ID" ] && return
    curl -sL --max-time 8 \
        "https://open.spotify.com/oembed?url=https://open.spotify.com/track/$ID" \
        2>/dev/null | \
    python3 -c "
import sys,json
try:
    t=json.load(sys.stdin).get('title','').strip()
    if t and t.lower() not in ('spotify',''):
        print(t)
except: pass
" 2>/dev/null || true
}

spotify_get_playlist_name() {
    local TYPE="playlist"
    echo "$1" | grep -qi "album" && TYPE="album"
    local ID
    ID=$(echo "$1" | grep -oP "(?<=${TYPE}/)[A-Za-z0-9]+" | head -1)
    [ -z "$ID" ] && echo "Spotify_Playlist" && return
    local NAME
    NAME=$(curl -sL --max-time 8 \
        "https://open.spotify.com/oembed?url=https://open.spotify.com/${TYPE}/${ID}" \
        2>/dev/null | \
    python3 -c "
import sys,json
try:
    t=json.load(sys.stdin).get('title','').strip()
    print(t if t and t.lower()!='spotify' else 'Spotify_Playlist')
except:
    print('Spotify_Playlist')
" 2>/dev/null) || NAME=""
    echo "${NAME:-Spotify_Playlist}"
}

# ── YouTube: Top 5 Treffer suchen ─────────────────────────────

youtube_search_top5() {
    # Gibt "VIDEO_ID\tTitel" pro Zeile aus
    yt-dlp "ytsearch5:$1" \
        --print "%(id)s	%(title)s" \
        --flat-playlist --no-warnings \
        2>/dev/null | head -5 || true
}

# ── Auswahl-Dialog: Suchbegriff → YouTube-URL ─────────────────

spotify_confirm_single() {
    local QUERY="$1"
    local DISPLAY="$2"

    local RESULTS
    RESULTS=$(youtube_search_top5 "$QUERY")

    # Keine Treffer → manuelle Eingabe anbieten
    if [ -z "$RESULTS" ]; then
        QUERY=$(zenity --entry \
            --title="Keine Treffer" \
            --text="Keine YouTube-Treffer für:\n\"$QUERY\"\n\nAnderen Suchbegriff eingeben:" \
            --entry-text="$QUERY" --width=500 2>/dev/null) || return 1
        RESULTS=$(youtube_search_top5 "$QUERY")
        [ -z "$RESULTS" ] && return 1
    fi

    # Auswahlliste bauen
    local LIST_ARGS=()
    while IFS=$'\t' read -r VID_ID VID_TITLE; do
        LIST_ARGS+=("$VID_ID" "$VID_TITLE")
    done <<< "$RESULTS"
    LIST_ARGS+=("__SKIP__"   "⏭  Überspringen")
    LIST_ARGS+=("__MANUAL__" "✏  Anderen Suchbegriff eingeben")

    local SEL
    SEL=$(zenity --list \
        --title="Treffer bestätigen" \
        --text="🎵 $DISPLAY\n\nYouTube-Treffer wählen:" \
        --column="ID" --column="Titel" \
        "${LIST_ARGS[@]}" \
        --hide-column=1 --height=350 --width=680 2>/dev/null) || return 1

    case "$SEL" in
        "__SKIP__")   echo "SKIP" ;;
        "__MANUAL__")
            local NEW
            NEW=$(zenity --entry --title="Suchen" \
                --text="Suchbegriff:" --entry-text="$QUERY" \
                --width=500 2>/dev/null) || return 1
            spotify_confirm_single "$NEW" "$DISPLAY"
            ;;
        *)  echo "https://www.youtube.com/watch?v=$SEL" ;;
    esac
}

# ── Spotify Handler ────────────────────────────────────────────

handle_spotify() {
    local URL="$1"

    local SPOTIFY_TYPE="Track"
    echo "$URL" | grep -qi "playlist" && SPOTIFY_TYPE="Playlist"
    echo "$URL" | grep -qi "album"    && SPOTIFY_TYPE="Album"
    echo "$URL" | grep -qi "artist"   && SPOTIFY_TYPE="Artist"

    # ══ Einzelner Track ══════════════════════════════════════════
    if [ "$SPOTIFY_TYPE" = "Track" ]; then

        # Titel holen (Ladehinweis im Hintergrund)
        (zenity --info --title="Spotify" \
            --text="🔍 Lese Track-Infos..." \
            --timeout=10 --width=280 2>/dev/null) &
        local ZPID=$!
        local TRACK_META
        TRACK_META=$(spotify_get_title "$URL")
        kill $ZPID 2>/dev/null || true

        # Bestätigungs-/Korrekturdialog – immer zeigen
        local MSG="⚠ Titel nicht erkannt – bitte eingeben (Künstler - Titel):"
        [ -n "$TRACK_META" ] && MSG="✅ Erkannt! Bei Bedarf anpassen:"

        TRACK_META=$(zenity --entry \
            --title="Spotify → YouTube Suche" \
            --text="$MSG" \
            --entry-text="${TRACK_META}" \
            --width=560 2>/dev/null) || return 0
        [ -z "$TRACK_META" ] && return 0

        # YouTube suchen + Bestätigen
        local YT_URL
        YT_URL=$(spotify_confirm_single "$TRACK_META" "$TRACK_META") || return 0
        [ -z "$YT_URL" ] || [ "$YT_URL" = "SKIP" ] && return 0

        # Download DIREKT (blockierend – kein progress_term, der läuft im Hintergrund!)
        echo "⬇ Lade: $TRACK_META"
        yt-dlp \
            -x --audio-format mp3 --audio-quality 0 \
            --embed-thumbnail \
            --add-metadata \
            --postprocessor-args "ffmpeg:-id3v2_version 3" \
            -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" \
            "$YT_URL" && \
        notify "✅ Fertig!\n$TRACK_META\n→ $DOWNLOAD_DIR" || \
        notify "⚠ Fehler beim Download von:\n$TRACK_META"

    # ══ Playlist / Album ═════════════════════════════════════════
    else
        # Playlist-Name holen
        (zenity --info --title="Spotify $SPOTIFY_TYPE" \
            --text="🔍 Lese Playlist-Name..." \
            --timeout=10 --width=280 2>/dev/null) &
        local ZPID=$!
        local PLAYLIST_NAME
        PLAYLIST_NAME=$(spotify_get_playlist_name "$URL")
        kill $ZPID 2>/dev/null || true

        # Zielordner
        local SAFE_NAME
        SAFE_NAME=$(echo "$PLAYLIST_NAME" | tr '/:*?"<>|\\' '_' | \
            sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | cut -c1-80)
        [ -z "$SAFE_NAME" ] && SAFE_NAME="Spotify_Playlist"
        local PLAYLIST_DIR="$DOWNLOAD_DIR/$SAFE_NAME"
        mkdir -p "$PLAYLIST_DIR"

        # ── Trackliste: Spotify blockiert automatisches Auslesen ohne Login ──
        # → Benutzer trägt Tracks ein (Copy-Paste aus Spotify funktioniert gut)
        local TRACKS_RAW
        TRACKS_RAW=$(zenity --text-info \
            --title="📋 Trackliste: $PLAYLIST_NAME" \
            --editable \
            --width=660 --height=520 \
            --ok-label="▶ Download starten" \
            --cancel-label="Abbrechen" \
            2>/dev/null <<'EOF'
# Trackliste eingeben – eine Zeile pro Track
# Format: Künstler - Titel
# Tipp: Spotify-Playlist öffnen, alle Titel markieren (Strg+A),
#       kopieren und hier einfügen – dann Zeilen bereinigen

EOF
        ) || return 0

        # Kommentare + Leerzeilen entfernen
        TRACKS_RAW=$(echo "$TRACKS_RAW" | \
            grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*$')

        if [ -z "$TRACKS_RAW" ]; then
            zenity --warning --title="Keine Tracks" \
                --text="Keine Tracks eingegeben." --width=300 2>/dev/null || true
            return 0
        fi

        local TRACK_COUNT TRACK_NUM=0 DOWNLOADED=0 SKIPPED=0
        TRACK_COUNT=$(echo "$TRACKS_RAW" | wc -l)

        while IFS= read -r TRACK; do
            [ -z "$TRACK" ] && continue
            TRACK_NUM=$((TRACK_NUM + 1))

            local YT_URL=""
            YT_URL=$(spotify_confirm_single "$TRACK" \
                "$TRACK  [$TRACK_NUM/$TRACK_COUNT]") || true

            if [ -z "$YT_URL" ] || [ "$YT_URL" = "SKIP" ]; then
                SKIPPED=$((SKIPPED + 1))
                continue
            fi

            echo "⬇ [$TRACK_NUM/$TRACK_COUNT] $TRACK"
            if yt-dlp \
                -x --audio-format mp3 --audio-quality 0 \
                --embed-thumbnail \
                --add-metadata \
                --postprocessor-args "ffmpeg:-id3v2_version 3" \
                -o "$PLAYLIST_DIR/$(printf '%02d' "$TRACK_NUM")_%(title)s.%(ext)s" \
                "$YT_URL"; then
                DOWNLOADED=$((DOWNLOADED + 1))
            else
                SKIPPED=$((SKIPPED + 1))
                zenity --warning --title="Fehler bei Track $TRACK_NUM" \
                    --text="⚠ Fehler:\n$TRACK\n\nWeiter mit nächstem..." \
                    --timeout=4 --width=350 2>/dev/null || true
            fi
        done <<< "$TRACKS_RAW"

        # ZIP anbieten
        if zenity --question \
            --title="✅ Fertig – $DOWNLOADED/$TRACK_COUNT geladen" \
            --text="$DOWNLOADED Tracks heruntergeladen, $SKIPPED übersprungen.\n\nOrdner: $PLAYLIST_DIR\n\nAls ZIP packen?" \
            --ok-label="Ja, ZIP erstellen" --cancel-label="Nein, Ordner reicht" \
            --width=420 2>/dev/null; then
            local ZIP_FILE="$DOWNLOAD_DIR/${SAFE_NAME}.zip"
            (cd "$DOWNLOAD_DIR" && zip -r "$ZIP_FILE" "$SAFE_NAME/")
            notify "✅ $PLAYLIST_NAME\n$DOWNLOADED Tracks\n→ $ZIP_FILE"
        else
            notify "✅ $PLAYLIST_NAME\n$DOWNLOADED Tracks\n→ $PLAYLIST_DIR"
        fi
    fi
}


# ── Instagram Handler ──────────────────────────────────────────

handle_instagram() {
    local URL="$1"

    local CHOICE
    CHOICE=$(zenity --list \
        --title="Instagram Download" \
        --column="Option" \
        "Video/Reels herunterladen" \
        "Foto(s) herunterladen" \
        "Story herunterladen" \
        --height=230 --width=350 2>/dev/null) || exit 0

    local COOKIES_ARG=""
    [ -f "$COOKIES_FILE" ] && COOKIES_ARG="--cookies '$COOKIES_FILE'"

    local OUT_DIR="$DOWNLOAD_DIR/Instagram_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUT_DIR"

    local CMD
    case "$CHOICE" in
        "Video/Reels herunterladen"|"Story herunterladen")
            CMD="cd '$OUT_DIR' && yt-dlp \
                $COOKIES_ARG \
                -f 'best' \
                --write-thumbnail \
                -o '%(uploader)s_%(upload_date)s_%(id)s.%(ext)s' \
                '$URL'"
            ;;
        "Foto(s) herunterladen")
            CMD="cd '$OUT_DIR' && yt-dlp \
                $COOKIES_ARG \
                --write-thumbnail \
                --skip-download \
                -o '%(uploader)s_%(upload_date)s_%(id)s.%(ext)s' \
                '$URL'"
            ;;
    esac

    progress_term "$CMD" "Instagram Download"
    notify "Instagram Download abgeschlossen!\nOrdner: $OUT_DIR"
}

# ── TikTok Handler ─────────────────────────────────────────────

handle_tiktok() {
    local URL="$1"

    local CHOICE
    CHOICE=$(zenity --list \
        --title="TikTok Download" \
        --column="Option" \
        "Video (mit Wasserzeichen entfernen)" \
        "Nur Audio (MP3)" \
        --height=200 --width=350 2>/dev/null) || exit 0

    local OUT_DIR="$DOWNLOAD_DIR/TikTok_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUT_DIR"

    local CMD
    case "$CHOICE" in
        "Video (mit Wasserzeichen entfernen)")
            # yt-dlp kann TikTok ohne Wasserzeichen via h264 Format
            CMD="cd '$OUT_DIR' && yt-dlp \
                -f 'download_addr-0/h264/best' \
                --add-metadata \
                -o '%(creator)s_%(title).50s_%(id)s.%(ext)s' \
                '$URL'"
            ;;
        "Nur Audio (MP3)")
            CMD="cd '$OUT_DIR' && yt-dlp \
                -x --audio-format mp3 \
                --embed-thumbnail \
                --add-metadata \
                -o '%(creator)s_%(title).50s_%(id)s.%(ext)s' \
                '$URL'"
            ;;
    esac

    progress_term "$CMD" "TikTok Download"
    notify "TikTok Download abgeschlossen!\nOrdner: $OUT_DIR"
}

# ── YouTube Playlist Handler ───────────────────────────────────

handle_yt_playlist() {
    local URL="$1"

    # Playlist-Info holen
    local PLAYLIST_TITLE
    PLAYLIST_TITLE=$(yt-dlp --flat-playlist --print playlist_title "$URL" 2>/dev/null | head -1) || PLAYLIST_TITLE="Playlist"

    local CHOICE
    CHOICE=$(zenity --list \
        --title="Playlist: $PLAYLIST_TITLE" \
        --text="Playlist erkannt!\n\"$PLAYLIST_TITLE\"\n\nDownload-Format wählen:" \
        --column="Option" \
        "Video 1080p" \
        "Video 720p" \
        "Nur Audio (MP3) – mit Cover & Tags" \
        "Nur Audio (FLAC)" \
        --height=280 --width=450 2>/dev/null) || exit 0

    local SAFE_TITLE
    SAFE_TITLE=$(echo "$PLAYLIST_TITLE" | tr '/:*?"<>|\\' '_' | cut -c1-60)
    local OUT_DIR="$DOWNLOAD_DIR/${SAFE_TITLE}"
    mkdir -p "$OUT_DIR"

    local ARIA_ARGS="--downloader aria2c --downloader-args 'aria2c:-x 8 -s 8 -k 1M'"
    local CMD

    case "$CHOICE" in
        "Video 1080p")
            CMD="cd '$OUT_DIR' && yt-dlp \
                -f 'bv*[ext=mp4][vcodec^=avc][height<=1080]+ba[ext=m4a]/bv*[ext=mp4][height<=1080]+ba[ext=m4a]/bv*[height<=1080]+ba' \
                --merge-output-format mp4 \
                $ARIA_ARGS \
                --embed-thumbnail \
                --convert-thumbnails jpg \
                --add-metadata \
                -o '%(playlist_index)02d_%(title)s.%(ext)s' \
                '$URL'"
            ;;
        "Video 720p")
            CMD="cd '$OUT_DIR' && yt-dlp \
                -f 'bv*[ext=mp4][vcodec^=avc][height<=720]+ba[ext=m4a]/bv*[ext=mp4][height<=720]+ba[ext=m4a]/bv*[height<=720]+ba' \
                --merge-output-format mp4 \
                $ARIA_ARGS \
                --embed-thumbnail \
                --convert-thumbnails jpg \
                --add-metadata \
                -o '%(playlist_index)02d_%(title)s.%(ext)s' \
                '$URL'"
            ;;
        "Nur Audio (MP3) – mit Cover & Tags")
            CMD="cd '$OUT_DIR' && yt-dlp \
                -x --audio-format mp3 --audio-quality 0 \
                --embed-thumbnail \
                --add-metadata \
                --parse-metadata 'title:%(meta_title)s' \
                --parse-metadata 'uploader:%(meta_artist)s' \
                --postprocessor-args 'ffmpeg:-id3v2_version 3' \
                $ARIA_ARGS \
                -o '%(playlist_index)02d_%(title)s.%(ext)s' \
                '$URL'"
            ;;
        "Nur Audio (FLAC)")
            CMD="cd '$OUT_DIR' && yt-dlp \
                -x --audio-format flac \
                --embed-thumbnail \
                --add-metadata \
                $ARIA_ARGS \
                -o '%(playlist_index)02d_%(title)s.%(ext)s' \
                '$URL'"
            ;;
    esac

    # Als ZIP anbieten?
    local ZIP_AFTER
    ZIP_AFTER=$(zenity --question \
        --title="Als ZIP?" \
        --text="Playlist nach Download als ZIP packen?" \
        --ok-label="Ja, ZIP erstellen" \
        --cancel-label="Nein, als Ordner lassen" \
        --width=350 2>/dev/null && echo "yes" || echo "no")

    progress_term "$CMD" "Playlist Download: $PLAYLIST_TITLE"

    if [ "$ZIP_AFTER" = "yes" ]; then
        local ZIP_FILE="$DOWNLOAD_DIR/${SAFE_TITLE}.zip"
        (cd "$DOWNLOAD_DIR" && zip -r "$ZIP_FILE" "$SAFE_TITLE/")
        notify "Playlist als ZIP gespeichert!\n$ZIP_FILE"
    else
        notify "Playlist heruntergeladen!\nOrdner: $OUT_DIR"
    fi
}

# ── YouTube Einzel-Video Handler ───────────────────────────────

handle_yt_single() {
    local URL="$1"

    # Video-Titel holen
    local VIDEO_TITLE
    VIDEO_TITLE=$(yt-dlp --get-title "$URL" 2>/dev/null) || VIDEO_TITLE="Video"

    local CHOICE
    CHOICE=$(zenity --list \
        --title="Video: $VIDEO_TITLE" \
        --text="Video erkannt!\n\"$VIDEO_TITLE\"\n\nFormat wählen:" \
        --column="Option" \
        "🎬 Video 1080p (beste Qualität)" \
        "🎬 Video 720p" \
        "🎬 Video 480p" \
        "🎵 Audio MP3 (mit Cover & Tags)" \
        "🎵 Audio FLAC (verlustlos)" \
        "🎵 Audio M4A (original)" \
        --height=320 --width=450 2>/dev/null) || exit 0

    local ARIA_ARGS="--downloader aria2c --downloader-args 'aria2c:-x 8 -s 8 -k 1M'"
    local CMD

    case "$CHOICE" in
        "🎬 Video 1080p (beste Qualität)")
            CMD="systemd-inhibit yt-dlp \
                -f 'bv*[ext=mp4][vcodec^=avc][height<=1080]+ba[ext=m4a]/bv*[ext=mp4][height<=1080]+ba[ext=m4a]/bv*[height<=1080]+ba' \
                --merge-output-format mp4 \
                $ARIA_ARGS \
                --add-metadata \
                --embed-thumbnail \
                --convert-thumbnails jpg \
                -o '$DOWNLOAD_DIR/%(title)s.%(ext)s' \
                '$URL'"
            ;;
        "🎬 Video 720p")
            CMD="systemd-inhibit yt-dlp \
                -f 'bv*[ext=mp4][vcodec^=avc][height<=720]+ba[ext=m4a]/bv*[ext=mp4][height<=720]+ba[ext=m4a]/bv*[height<=720]+ba' \
                --merge-output-format mp4 \
                $ARIA_ARGS \
                --add-metadata \
                --embed-thumbnail \
                --convert-thumbnails jpg \
                -o '$DOWNLOAD_DIR/%(title)s.%(ext)s' \
                '$URL'"
            ;;
        "🎬 Video 480p")
            CMD="systemd-inhibit yt-dlp \
                -f 'bv*[ext=mp4][vcodec^=avc][height<=480]+ba[ext=m4a]/bv*[ext=mp4][height<=480]+ba[ext=m4a]/bv*[height<=480]+ba' \
                --merge-output-format mp4 \
                $ARIA_ARGS \
                --add-metadata \
                --embed-thumbnail \
                --convert-thumbnails jpg \
                -o '$DOWNLOAD_DIR/%(title)s.%(ext)s' \
                '$URL'"
            ;;
        "🎵 Audio MP3 (mit Cover & Tags)")
            CMD="systemd-inhibit yt-dlp \
                -x --audio-format mp3 --audio-quality 0 \
                --embed-thumbnail \
                --add-metadata \
                --parse-metadata 'title:%(meta_title)s' \
                --parse-metadata 'uploader:%(meta_artist)s' \
                --postprocessor-args 'ffmpeg:-id3v2_version 3' \
                $ARIA_ARGS \
                -o '$DOWNLOAD_DIR/%(title)s.%(ext)s' \
                '$URL'"
            ;;
        "🎵 Audio FLAC (verlustlos)")
            CMD="systemd-inhibit yt-dlp \
                -x --audio-format flac \
                --embed-thumbnail \
                --add-metadata \
                $ARIA_ARGS \
                -o '$DOWNLOAD_DIR/%(title)s.%(ext)s' \
                '$URL'"
            ;;
        "🎵 Audio M4A (original)")
            CMD="systemd-inhibit yt-dlp \
                -x --audio-format m4a \
                --embed-thumbnail \
                --add-metadata \
                $ARIA_ARGS \
                -o '$DOWNLOAD_DIR/%(title)s.%(ext)s' \
                '$URL'"
            ;;
    esac

    progress_term "$CMD" "Download: $VIDEO_TITLE"
    notify "Download abgeschlossen!\n$DOWNLOAD_DIR"
}

# ── Normaler Datei-Download ────────────────────────────────────

handle_file() {
    local URL="$1"
    local CMD="systemd-inhibit aria2c \
        -c -x 8 -s 8 \
        --min-split-size=5M \
        --max-tries=0 \
        --retry-wait=5 \
        --timeout=30 \
        --file-allocation=trunc \
        --dir='$DOWNLOAD_DIR' \
        '$URL'"
    progress_term "$CMD" "Datei-Download"
    notify "Download abgeschlossen!\n$DOWNLOAD_DIR"
}

# ══════════════════════════════════════════════════════════════
#  MAIN
# ══════════════════════════════════════════════════════════════

check_deps

URL="$1"

# URL-Eingabe falls nicht als Argument übergeben
if [ -z "$URL" ]; then
    if command -v zenity &>/dev/null; then
        URL=$(zenity --entry \
            --title="⬇ Ultimater Downloader" \
            --text="URL einfügen:\n(YouTube, Spotify, Instagram, TikTok, Direktlinks...)" \
            --width=650 2>/dev/null)
    else
        read -rp "URL eingeben: " URL
    fi
    [ -z "$URL" ] && exit 0
fi

# Whitespace bereinigen
URL=$(echo "$URL" | tr -d '[:space:]')

cd "$DOWNLOAD_DIR"

# Typ erkennen und Handler aufrufen
TYPE=$(detect_type "$URL")

case "$TYPE" in
    "spotify")    handle_spotify "$URL"    ;;
    "instagram")  handle_instagram "$URL"  ;;
    "tiktok")     handle_tiktok "$URL"     ;;
    "yt_playlist") handle_yt_playlist "$URL" ;;
    "yt_single")  handle_yt_single "$URL"  ;;
    "file")       handle_file "$URL"       ;;
    *)
        error_exit "URL nicht erkannt oder nicht unterstützt:\n$URL"
        ;;
esac
```

