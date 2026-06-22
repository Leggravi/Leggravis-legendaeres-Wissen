#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════
#  openlp_to_pptx_gui.sh  —  OpenLP OSZ → PPTX (Ultimate)
# ═══════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PY_SCRIPT="$SCRIPT_DIR/openlp_to_pptx.py"
VENV="$HOME/venv"
PYTHON="$VENV/bin/python"

# ─── 0. CHECKS ───────────────────────────────────────
if [[ ! -x "$PYTHON" ]]; then
    zenity --error --title="Python fehlt" --width=440 \
        --text="Kein venv unter:\n$VENV\n\nEinrichten:\n  python3 -m venv ~/venv\n  source ~/venv/bin/activate\n  pip install python-pptx lxml"
    exit 1
fi
if ! "$PYTHON" -c 'import pptx, lxml' >/dev/null 2>&1; then
    zenity --error --title="Fehlende Abhängigkeiten" --width=520 \
        --text="Das Python-venv fehlt benötigte Pakete:\npython-pptx und/oder lxml.\n\nInstallieren mit:\n  source ~/venv/bin/activate\n  pip install python-pptx lxml"
    exit 1
fi
if [[ ! -f "$PY_SCRIPT" ]]; then
    zenity --error --title="Skript fehlt" --width=400 \
        --text="Nicht gefunden:\n$PY_SCRIPT"
    exit 1
fi

# ─── 1. PRESET AUSWAHL ──────────────────────────────
PRESET=$(zenity --list --title="Modus wählen" \
    --text="Welche Einstellungen sollen verwendet werden?" \
    --column="Modus" \
    "Standard — Kein CCLI, keine Zwischenfolie, ganze Strophe, Originalschrift" \
    "BK — Zwischenfolie, max. 4 Zeilen, Schriftgröße wählbar" \
    "Custom — Alle Einstellungen manuell wählen" \
    --height=260 --width=520 2>/dev/null)
[[ -z "$PRESET" ]] && exit 0

# ─── DEFAULTS ────────────────────────────────────────
EXTRA=()   # Python-Argumente
FONT_SIZE=""
SHADOW_OFFSET="0.04"
SPLIT_MODE="shrink"
MAX_LINES=4
CORNER="bl"
EFFECTS="outline"
FOOTER_MODE="song"

# ─── 2. EINSTELLUNGEN JE NACH PRESET ─────────────────

ask_font_size() {
    local default="${1:-100}"
    FS=$(zenity --list --title="Schriftgröße" \
        --text="Schriftgröße wählen:" \
        --column="Option" \
        "Schriftgröße wählen" \
        "Schriftgröße aus Datei" \
        --height=210 --width=360 2>/dev/null)
    [[ -z "$FS" ]] && return 1
    if [[ "$FS" == "Schriftgröße wählen" ]]; then
        SZ=$(zenity --entry --title="Schriftgröße" --width=320 \
            --text="Schriftgröße in pt (z.B. 75 für OpenLP-150):" \
            --entry-text="$default" 2>/dev/null)
        [[ -z "$SZ" ]] && return 1
        FONT_SIZE="$SZ"
    fi
    return 0
}

ask_split_mode() {
    SM=$(zenity --list --title="Langer Text" \
        --text="Was tun wenn eine Strophe nicht auf eine Folie passt?" \
        --column="Methode" \
        "Schrift verkleinern" \
        "Auf mehrere Folien aufteilen (Wortgrenzen)" \
        "Maximale Zeilenanzahl pro Folie" \
        --height=250 --width=460 2>/dev/null)
    [[ -z "$SM" ]] && return 1
    case "$SM" in
        "Schrift verkleinern")                SPLIT_MODE="shrink" ;;
        "Auf mehrere Folien aufteilen"*)      SPLIT_MODE="pages" ;;
        "Maximale Zeilenanzahl pro Folie")
            SPLIT_MODE="maxlines"
            ML=$(zenity --entry --title="Max. Zeilen" --width=320 \
                --text="Maximale Anzahl Zeilen pro Folie:" \
                --entry-text="$MAX_LINES" 2>/dev/null)
            [[ -z "$ML" ]] && return 1
            MAX_LINES="$ML"
            ;;
    esac
    return 0
}

ask_corner() {
    CO=$(zenity --list --title="Footer-Position" \
        --text="In welcher Ecke soll der Footer erscheinen?" \
        --column="Ecke" \
        "Links unten" \
        "Rechts unten" \
        "Links oben" \
        "Rechts oben" \
        --height=250 --width=360 2>/dev/null)
    [[ -z "$CO" ]] && return 1
    case "$CO" in
        "Links unten")  CORNER="bl" ;;
        "Rechts unten") CORNER="br" ;;
        "Links oben")   CORNER="tl" ;;
        "Rechts oben")  CORNER="tr" ;;
    esac
    return 0
}

ask_effects() {
    EF=$(zenity --list --title="Texteffekte" \
        --text="Welche Effekte sollen auf den Text angewendet werden?" \
        --column="Effekt" \
        "Nur Umriss" \
        "Schatten + Umriss (empfohlen)" \
        "Nur Schatten" \
        "Keine Effekte" \
        --height=260 --width=380 2>/dev/null)
    [[ -z "$EF" ]] && return 1
    case "$EF" in
        "Schatten + Umriss"*) EFFECTS="both" ;;
        "Nur Schatten")       EFFECTS="shadow" ;;
        "Nur Umriss")         EFFECTS="outline" ;;
        "Keine Effekte")      EFFECTS="none" ;;
    esac
    return 0
}

ask_shadow_offset() {
    SO=$(zenity --entry --title="Schattenversatz" --width=360 \
        --text="Schattenversatz in Inches (z.B. 0.04 für schwach, 0.08 für stark):" \
        --entry-text="$SHADOW_OFFSET" 2>/dev/null)
    [[ -z "$SO" ]] && return 1
    SHADOW_OFFSET="$SO"
    return 0
}

ask_ccli() {
    CI=$(zenity --entry --title="CCLI" --width=360 \
        --text="CCLI-Nummer (leer = aus Datei):" \
        --entry-text="" 2>/dev/null)
    [[ -n "$CI" ]] && EXTRA+=("--ccli" "$CI")
    return 0
}

ask_footer_mode() {
    FM=$(zenity --list --title="Footer auf Textfolien" \
        --text="Footer auf den Liedfolien:" \
        --column="Option" \
        "Nur Liedname + Strophe" \
        "Kein Footer" \
        --height=220 --width=420 2>/dev/null)
    [[ -z "$FM" ]] && return 1
    case "$FM" in
        "Nur Liedname + Strophe") FOOTER_MODE="song" ;;
        "Kein Footer")              FOOTER_MODE="none" ;;
    esac
    return 0
}

case "$PRESET" in

    "Standard"*)
        # Feste Defaults, keine weiteren Abfragen
        SPLIT_MODE="shrink"
        CORNER="bl"
        EFFECTS="both"
        ;;

    "BK"*)
        EXTRA+=("--black-slides")
        SPLIT_MODE="maxlines"
        CORNER="tr"
        ask_font_size 50  || exit 0
        ask_effects        || exit 0
        # CCLI Auswahl
        CCLI_CHOICE=$(zenity --list --title="CCLI für BK" \
            --text="CCLI-Nummer wählen:" \
            --column="Option" \
            "Keine" \
            "23023797 (BK-Lizenz)" \
            "Aus Datei" \
            --height=220 --width=360 2>/dev/null)
        [[ -z "$CCLI_CHOICE" ]] && exit 0
        case "$CCLI_CHOICE" in
            "Keine") ;;
            "23023797 (BK-Lizenz)") EXTRA+=("--show-ccli") EXTRA+=("--ccli" "23023797") ;;
            "Aus Datei") EXTRA+=("--show-ccli"); ask_ccli || exit 0 ;;
        esac
        # Anzeige-Stil
        STYLE=$(zenity --list --title="BK-Stil" \
            --text="Farbe und Hintergrund für BK wählen:" \
            --column="Option" \
            "Standard (Theme-Text)" \
            "Beamer: Weiß auf Schwarz" \
            "BK-Kontrast: Gelb auf Schwarz" \
            --height=240 --width=380 2>/dev/null)
        [[ -z "$STYLE" ]] && exit 0
        case "$STYLE" in
            "Beamer: Weiß auf Schwarz") EXTRA+=("--beamer") ;;
            "BK-Kontrast: Gelb auf Schwarz") EXTRA+=("--yellow-on-black") ;;
        esac
        ;;

    "Custom"*)
        # Schwarzfolien
        SW=$(zenity --list --title="Schwarzfolien" \
            --text="Schwarze Trennfolie vor jedem Lied?" \
            --column="Antwort" \
            "Ja" "Nein" \
            --height=200 --width=320 2>/dev/null)
        [[ -z "$SW" ]] && exit 0
        [[ "$SW" == "Ja" ]] && EXTRA+=("--black-slides")

        # CCLI
        CW=$(zenity --list --title="CCLI" \
            --text="CCLI-Nummer im Footer?" \
            --column="Antwort" \
            "Ja" "Nein" \
            --height=200 --width=320 2>/dev/null)
        [[ -z "$CW" ]] && exit 0
        if [[ "$CW" == "Ja" ]]; then
            EXTRA+=("--show-ccli")
            CI=$(zenity --entry --title="CCLI" --width=360 \
                --text="CCLI-Nummer (leer = aus Datei):" \
                --entry-text="" 2>/dev/null)
            [[ -n "$CI" ]] && EXTRA+=("--ccli" "$CI")
        fi

        ask_effects        || exit 0
        ask_font_size 50   || exit 0
        ask_split_mode     || exit 0
        ask_corner         || exit 0
        ask_footer_mode    || exit 0
        ask_shadow_offset  || exit 0
        ;;
esac

# Argumente zusammenbauen
EXTRA+=("--effects" "$EFFECTS")
EXTRA+=("--corner"  "$CORNER")
EXTRA+=("--split-mode" "$SPLIT_MODE")
EXTRA+=("--footer-mode" "$FOOTER_MODE")
EXTRA+=("--shadow-offset" "$SHADOW_OFFSET")
[[ -n "$FONT_SIZE"         ]] && EXTRA+=("--font-size" "$FONT_SIZE")
[[ "$SPLIT_MODE" == "maxlines" ]] && EXTRA+=("--max-lines" "$MAX_LINES")

# ─── 3. DATEIAUSWAHL ────────────────────────────────
MODE=$(zenity --list --title="Dateiauswahl" \
    --text="Was konvertieren?" \
    --column="Option" \
    "Ordner (alle .osz darin)" \
    "Einzelne Dateien" \
    --height=210 --width=340 2>/dev/null)
[[ -z "$MODE" ]] && exit 0

if [[ "$MODE" == "Ordner (alle .osz darin)" ]]; then
    INPUT=$(zenity --file-selection --directory \
        --title="Ordner wählen" \
        --filename="$SCRIPT_DIR/" 2>/dev/null)
    [[ -z "$INPUT" ]] && exit 0
    mapfile -t FILES < <(find "$INPUT" -maxdepth 1 -iname "*.osz" | sort)
else
    INPUT=$(zenity --file-selection --multiple --separator="|" \
        --title=".osz-Dateien wählen (Strg+Klick für mehrere)" \
        --filename="$SCRIPT_DIR/" 2>/dev/null)
    [[ -z "$INPUT" ]] && exit 0
    IFS="|" read -ra ALL_FILES <<< "$INPUT"
    FILES=()
    for f in "${ALL_FILES[@]}"; do
        [[ "${f,,}" == *.osz ]] && FILES+=("$f")
    done
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
    zenity --warning --title="Keine Dateien" \
        --text="Keine .osz-Dateien gefunden." --width=300
    exit 0
fi

# ─── 4. KONVERTIERUNG ───────────────────────────────
TOTAL=${#FILES[@]}
COUNT=0
ERRORS_FILE=$(mktemp)

(
for f in "${FILES[@]}"; do
    BASENAME=$(basename "$f")
    BASENAME="${BASENAME%.[Oo][Ss][Zz]}"
    DIR=$(dirname "$f")
    DONEDIR="$DIR/verarbeitet"
    OUT="$DIR/${BASENAME}.pptx"

    echo "# ($((COUNT+1))/$TOTAL) $(basename "$f")"
    echo $(( COUNT * 100 / TOTAL ))
    mkdir -p "$DONEDIR"

    TMPLOG=$(mktemp)
    "$PYTHON" "$PY_SCRIPT" "${EXTRA[@]}" -o "$OUT" "$f" >"$TMPLOG" 2>&1

    if [[ $? -eq 0 ]]; then
        mv "$f" "$DONEDIR/"
    else
        ERR=$(grep -v '^[📂🎵 ]' "$TMPLOG" | tail -3 | tr '\n' ' ')
        printf '❌ %s: %s\n' "$BASENAME" "$ERR" >> "$ERRORS_FILE"
    fi
    rm -f "$TMPLOG"

    ((COUNT++))
    echo $(( COUNT * 100 / TOTAL ))
done
echo "100"
) | zenity --progress \
    --title="OSZ → PPTX" --text="Starte …" \
    --percentage=0 --auto-close --width=500 2>/dev/null

PIPE_EXIT=${PIPESTATUS[0]}
ERRORS=$(cat "$ERRORS_FILE"); rm -f "$ERRORS_FILE"
ERR_COUNT=0
[[ -n "$ERRORS" ]] && ERR_COUNT=$(printf '%s' "$ERRORS" | wc -l)

[[ $PIPE_EXIT -ne 0 ]] && {
    zenity --warning --title="Abgebrochen" --text="Konvertierung abgebrochen." --width=300
    exit 1
}

SUCCESS=$(( TOTAL - ERR_COUNT ))
if [[ $ERR_COUNT -eq 0 ]]; then
    zenity --info --title="Fertig ✅" --width=400 \
        --text="${TOTAL} Datei(en) konvertiert.\nPPTX liegt im Quellordner.\nOriginal .osz → ./verarbeitet/"
else
    zenity --warning --title="Teilerfolg ⚠️" --width=500 \
        --text="${SUCCESS} von ${TOTAL} ok.\n\nFehler:\n${ERRORS}"
fi