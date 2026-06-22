import json
import xml.etree.ElementTree as ET
from xml.dom import minidom
import os
import sys
import re
import requests
from bs4 import BeautifulSoup
from urllib.parse import quote
from difflib import get_close_matches

BASE_URL = "https://www.evangeliums.net"


# -------------------------------
# 🔤 Dateiname
# -------------------------------
def safe_filename(text):
    text = re.sub(r'[^\w\säöüÄÖÜß-]', '', text)
    return text.strip()


# -------------------------------
# 🌐 Suche
# -------------------------------
def search_song(title):
    try:
        search_url = f"{BASE_URL}/lieder/suche.php?suche={quote(title)}"
        r = requests.get(search_url, timeout=10)
        soup = BeautifulSoup(r.text, "html.parser")

        links = soup.find_all("a", href=re.compile(r"/lieder/"))

        candidates = []
        for link in links:
            name = link.text.strip()
            href = link.get("href")

            if name and href and "/lieder/" in href:
                candidates.append((name, BASE_URL + href))

        if not candidates:
            return None, "❌ keine Treffer"

        names = [c[0] for c in candidates]
        match = get_close_matches(title, names, n=1, cutoff=0.6)

        if match:
            for name, url in candidates:
                if name == match[0]:
                    return url, f"✅ gefunden ({name})"

        return candidates[0][1], f"⚠️ unscharf ({candidates[0][0]})"

    except Exception as e:
        return None, f"❌ Fehler bei Suche: {e}"


# -------------------------------
# 👤 Autoren extrahieren
# -------------------------------
def extract_authors_from_page(url):
    authors = {"words": None, "music": None, "translation": None}

    try:
        r = requests.get(url, timeout=10)
        soup = BeautifulSoup(r.text, "html.parser")
        text = soup.get_text("\n")

        m = re.search(r'Text:\s*(.+)', text)
        if m:
            authors["words"] = m.group(1).strip()

        m = re.search(r'Melodie:\s*(.+)', text)
        if m:
            authors["music"] = m.group(1).strip()

        m = re.search(r'Übersetzung:\s*(.+)', text)
        if m:
            authors["translation"] = m.group(1).strip()

    except:
        pass

    return authors


# -------------------------------
# 🎵 Song → XML
# -------------------------------
def song_to_openlyrics(song, output_dir, index, total, url=None):
    title = song.get("title", "Unbekannt")
    verses = song.get("verses", [])
    verse_order_json = song.get("verseOrder")

    authors_data = {"words": None, "music": None, "translation": None}

    if url:
        authors_data = extract_authors_from_page(url)

    root = ET.Element("song", attrib={
        "xmlns": "http://openlyrics.info/namespace/2009/song",
        "version": "0.8"
    })

    properties = ET.SubElement(root, "properties")

    titles = ET.SubElement(properties, "titles")
    ET.SubElement(titles, "title").text = title

    # 👤 AUTHORS (FIX!)
    authors_elem = ET.SubElement(properties, "authors")

    added = False

    if authors_data["words"]:
        ET.SubElement(authors_elem, "author", {"type": "words"}).text = authors_data["words"]
        added = True

    if authors_data["music"]:
        ET.SubElement(authors_elem, "author", {"type": "music"}).text = authors_data["music"]
        added = True

    if authors_data["translation"]:
        ET.SubElement(authors_elem, "author", {"type": "translation"}).text = authors_data["translation"]
        added = True

    # 🔥 CRITICAL FIX: niemals leer!
    if not added:
        ET.SubElement(authors_elem, "author").text = "Unbekannt"

    # 🎶 Lyrics
    lyrics = ET.SubElement(root, "lyrics")

    verse_names = []
    for idx, v in enumerate(verses):
        verse_name = f"v{idx+1}"  # OpenLP-style (wichtig!)
        verse_names.append(verse_name)

        verse = ET.SubElement(lyrics, "verse", attrib={"name": verse_name})
        lines = ET.SubElement(verse, "lines")
        lines.text = v.get("text", "").strip()

    # VerseOrder
    if verse_order_json:
        indices = verse_order_json.split(",")

        valid_names = []
        for i in indices:
            try:
                idx = int(i)
                if 0 <= idx < len(verse_names):
                    valid_names.append(verse_names[idx])
            except:
                pass

        if valid_names:
            ET.SubElement(properties, "verseOrder").text = " ".join(valid_names)
    else:
        if verse_names:
            ET.SubElement(properties, "verseOrder").text = verse_names[0]

    # speichern
    xml_str = minidom.parseString(
        ET.tostring(root, "utf-8")
    ).toprettyxml(indent="  ")

    filename = safe_filename(title) or f"song_{index}"
    filepath = os.path.join(output_dir, f"{filename}.xml")

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(xml_str)

    return filepath


# -------------------------------
# 🚀 MAIN
# -------------------------------
def json_to_openlyrics(json_file, output_dir):
    with open(json_file, "r", encoding="utf-8") as f:
        songs = json.load(f)

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    total = len(songs)

    for i, song in enumerate(songs, start=1):
        title = song.get("title", "Unbekannt")

        url, status = search_song(title)

        try:
            song_to_openlyrics(song, output_dir, i, total, url)
            print(f"[{i}-{total}] {title} → {status}")
        except Exception as e:
            print(f"[{i}-{total}] {title} → ❌ Fehler: {e}")


# -------------------------------
# ▶️ Start
# -------------------------------
if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Benutzung: python script.py input.json output_dir")
    else:
        json_to_openlyrics(sys.argv[1], sys.argv[2])