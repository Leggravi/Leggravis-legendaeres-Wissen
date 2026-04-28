#!/usr/bin/env bash

# Prüfen ob zenity existiert
if ! command -v zenity &> /dev/null; then
    echo "Zenity ist nicht installiert."
    exit 1
fi

# Datei wählen
INPUT=$(zenity --file-selection \
    --title="SRT-Datei auswählen" \
    --file-filter="SRT files | *.srt")

[ -z "$INPUT" ] && exit 0

# Maximale Zeichenlänge abfragen
MAXLEN=$(zenity --entry \
    --title="Zeilenlänge" \
    --text="Maximale Zeichen pro Untertitelblock:" \
    --entry-text="40")

# Validierung
if ! [[ "$MAXLEN" =~ ^[0-9]+$ ]]; then
    zenity --error --text="Ungültige Zeichenlänge."
    exit 1
fi

# Output-Datei definieren
DIR=$(dirname "$INPUT")
BASE=$(basename "$INPUT" .srt)
OUTPUT="$DIR/${BASE}_split.srt"

awk -v maxlen="$MAXLEN" '

function to_ms(ts,    h,m,s,ms) {
    split(ts, a, "[:,]")
    return (((a[1]*60 + a[2])*60 + a[3])*1000 + a[4])
}

function to_ts(ms,    h,m,s,rest) {
    h = int(ms / 3600000)
    rest = ms % 3600000
    m = int(rest / 60000)
    rest %= 60000
    s = int(rest / 1000)
    ms = rest % 1000
    return sprintf("%02d:%02d:%02d,%03d", h, m, s, ms)
}

function split_text(text, arr,    words,wcount,line,n,i) {
    n=0
    wcount = split(text, words, " ")
    line=""
    for (i=1;i<=wcount;i++) {
        if (length(line words[i]) + 1 <= maxlen) {
            line = (line==""?words[i]:line" "words[i])
        } else {
            arr[++n]=line
            line=words[i]
        }
    }
    if (line!="") arr[++n]=line
    return n
}

BEGIN { out_index=1 }

{
    if ($0 ~ /^[0-9]+$/) { next }

    if ($0 ~ /-->/) {
        split($0,t," --> ")
        start_ms = to_ms(t[1])
        end_ms = to_ms(t[2])
        duration = end_ms - start_ms
        text=""
        next
    }

    if ($0 != "") {
        text = (text==""?$0:text" "$0)
        next
    }

    if ($0=="" && text!="") {

        parts = split_text(text, arr)
        if (parts < 1) parts=1
        part_dur = duration / parts

        for (i=1;i<=parts;i++) {
            s = start_ms + (i-1)*part_dur
            e = start_ms + i*part_dur

            print out_index
            print to_ts(int(s)) " --> " to_ts(int(e))
            print arr[i]
            print ""

            out_index++
        }

        text=""
    }
}

' "$INPUT" > "$OUTPUT"

zenity --info --text="Fertig.\n\nGespeichert als:\n$OUTPUT"
