#!/usr/bin/env bash
# openlp_to_pptx.sh
# Konvertiert alle .osz-Dateien in einem gewählten Ordner zu .pptx
# und verschiebt die verarbeiteten .osz in einen Unterordner.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/openlp_to_pptx.py"

# ── Prüfen ob das Python-Skript daneben liegt ────────────────────────────────
if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    zenity --error \
        --title="Fehler" \
        --text="openlp_to_pptx.py nicht gefunden!\nErwartet unter:\n$PYTHON_SCRIPT"
    exit 1
fi

# ── Ordner wählen (startet im Skript-Verzeichnis) ───────────────────────────
CHOSEN_DIR=$(zenity --file-selection \
    --directory \
    --title="Ordner mit .osz-Dateien wählen" \
    --filename="$SCRIPT_DIR/")

if [[ -z "$CHOSEN_DIR" ]]; then
    exit 0   # Abbruch durch Nutzer
fi

# ── .osz-Dateien suchen ──────────────────────────────────────────────────────
mapfile -t OSZ_FILES < <(find "$CHOSEN_DIR" -maxdepth 1 -iname "*.osz" | sort)

if [[ ${#OSZ_FILES[@]} -eq 0 ]]; then
    zenity --warning \
        --title="Keine Dateien" \
        --text="Keine .osz-Dateien in:\n$CHOSEN_DIR"
    exit 0
fi

# ── Unterordner für verarbeitete .osz anlegen ────────────────────────────────
DONE_DIR="$CHOSEN_DIR/verarbeitet"
mkdir -p "$DONE_DIR"

# ── Konvertierung mit Fortschrittsbalken ─────────────────────────────────────
TOTAL=${#OSZ_FILES[@]}
COUNT=0
ERRORS=()

(
for OSZ in "${OSZ_FILES[@]}"; do
    BASENAME=$(basename "$OSZ" .osz)
    PPTX_OUT="$CHOSEN_DIR/${BASENAME}.pptx"

    echo "# Konvertiere: $BASENAME.osz …"
    echo $(( COUNT * 100 / TOTAL ))

    python3 "$PYTHON_SCRIPT" "$OSZ" -o "$PPTX_OUT" 2>/tmp/openlp_err.txt

    if [[ $? -eq 0 ]]; then
        mv "$OSZ" "$DONE_DIR/"
    else
        ERRORS+=("$BASENAME: $(cat /tmp/openlp_err.txt | tail -1)")
    fi

    (( COUNT++ ))
    echo $(( COUNT * 100 / TOTAL ))
done

echo "100"
) | zenity --progress \
    --title="OSZ → PPTX" \
    --text="Starte Konvertierung …" \
    --percentage=0 \
    --auto-close \
    --width=450

# ── Ergebnis anzeigen ────────────────────────────────────────────────────────
if [[ ${#ERRORS[@]} -eq 0 ]]; then
    zenity --info \
        --title="Fertig ✅" \
        --text="$TOTAL Datei(en) erfolgreich konvertiert.\n\nPPTX gespeichert in:\n$CHOSEN_DIR\n\nOSZ archiviert in:\n$DONE_DIR"
else
    ERROR_MSG=$(printf '%s\n' "${ERRORS[@]}")
    zenity --warning \
        --title="Teilweise Fehler ⚠️" \
        --text="$(( TOTAL - ${#ERRORS[@]} )) von $TOTAL erfolgreich.\n\nFehler:\n$ERROR_MSG"
fi
