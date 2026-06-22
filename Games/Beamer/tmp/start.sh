#!/bin/bash
# 🎮 Wikinger Spieleabend – Installationsscript
# Startet beide Websites im Browser

echo "🎮 Wikinger Spieleabend – Starten"
echo "=================================="
echo ""

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Start-Seite
START_URL="file://$SCRIPT_DIR/index.html"

echo "📱 Öffne Startseite:"
echo "   $START_URL"
echo ""

# Versuche den Browser zu öffnen
if command -v xdg-open &> /dev/null; then
    xdg-open "$START_URL"
elif command -v open &> /dev/null; then
    open "$START_URL"
elif command -v start &> /dev/null; then
    start "$START_URL"
else
    echo "⚠️  Browser konnte nicht automatisch geöffnet werden."
    echo "   Öffne manuell: $START_URL"
fi

echo ""
echo "✅ Alternativ:"
echo "   1. Beamer-Website:   file://$SCRIPT_DIR/beamer.html"
echo "   2. Moderator-Website: file://$SCRIPT_DIR/moderator.html"
echo ""
echo "📖 Weitere Infos: QUICK_START.txt"
