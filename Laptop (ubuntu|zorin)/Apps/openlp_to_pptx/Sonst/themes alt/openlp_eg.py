import requests
from bs4 import BeautifulSoup
import os
import re
import xml.etree.ElementTree as ET
from datetime import datetime
from urllib.parse import urljoin

BASE_URL = "https://www.evangeliums.net"
LIST_URL = f"{BASE_URL}/lieder/liederbuch_jesus_unsere_freude.html"

OUTPUT_DIR = "Jesus unsere Freude"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def sanitize_filename(name):
    return re.sub(r'[\\/*?:"<>|]', "_", name)

def fetch_page(url):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                      "AppleWebKit/537.36 (KHTML, like Gecko) "
                      "Chrome/117.0.0.0 Safari/537.36"
    }
    resp = requests.get(url, headers=headers)
    resp.raise_for_status()
    return BeautifulSoup(resp.text, "html.parser")


def parse_song_page(song_page):
    """
    Gibt (verses, meta) zurueck:
      verses = [(1, 'Strophe 1 Text'), (2, '...'), ...]
      meta   = {'melodie': '...', 'ccli': '...', 'tags': [...], 'info_url': '...'}
    """
    # ── Strophen: aus card-body[-1], nur <p> mit <strong>N)</strong> ──────────
    text_divs = song_page.find_all("div", class_="card-body")
    verses = []

    if text_divs:
        text_div = text_divs[-1]
        for p in text_div.find_all("p"):
            strong = p.find("strong")
            if not strong:
                continue
            # Strophennummer pruefen: "1) ", "2) ", ...
            m = re.match(r'^(\d+)\)\s*$', strong.get_text().strip())
            if not m:
                continue
            verse_num = int(m.group(1))

            # p.get_text() OHNE separator: \n steckt schon in den NavigableStrings
            # nach jedem <br> → kein Doppelumbruch
            raw = p.get_text()

            # "N)  Erste Zeile\nZweite Zeile\n..." → Nummer vorne abschneiden
            raw = re.sub(r'^\d+\)\s*', '', raw).strip()

            if raw:
                verses.append((verse_num, raw))

    # ── Metadaten: aus div.well ───────────────────────────────────────────────
    meta = {}
    well = song_page.find("div", class_="well")
    if well:
        well_text = well.get_text(separator="\n")

        m = re.search(r'Melodie:\s*\n?\s*(.+?)(?:\n|$)', well_text)
        if m:
            meta['melodie'] = m.group(1).strip()

        m = re.search(r'CCLI-Nr\.:\s*\n?\s*(\d+)', well_text)
        if m:
            meta['ccli'] = m.group(1).strip()

        m = re.search(r'Info:\s*\n?\s*(https?://\S+)', well_text)
        if m:
            meta['info_url'] = m.group(1).strip()

        tags = [a.get_text().strip()
                for a in well.find_all('a', href=re.compile(r'suche\.php\?tag='))]
        if tags:
            meta['tags'] = tags

    return verses, meta


def create_openlp_xml(title, text_authors, melody_author, verses, meta):
    song = ET.Element("song", {
        "xmlns": "http://openlyrics.info/namespace/2009/song",
        "version": "0.8",
        "createdIn": "OpenLP 3.1.0rc4",
        "modifiedIn": "OpenLP 3.1.0rc4",
        "modifiedDate": datetime.now().isoformat(timespec="seconds")
    })

    props = ET.SubElement(song, "properties")

    titles_elem = ET.SubElement(props, "titles")
    ET.SubElement(titles_elem, "title").text = title

    auth_elem = ET.SubElement(props, "authors")
    for a in text_authors:
        if a:
            ET.SubElement(auth_elem, "author", {"type": "words"}).text = a
    if melody_author:
        ET.SubElement(auth_elem, "author", {"type": "music"}).text = melody_author

    if meta.get('ccli'):
        ET.SubElement(props, "ccliNo").text = meta['ccli']

    if meta.get('tags'):
        themes_elem = ET.SubElement(props, "themes")
        for tag in meta['tags']:
            ET.SubElement(themes_elem, "theme").text = tag

    #if meta.get('info_url'):
    #    ET.SubElement(props, "comments").text = meta['info_url']

    lyrics_elem = ET.SubElement(song, "lyrics")
    for verse_num, text in verses:
        v_elem = ET.SubElement(lyrics_elem, "verse", {"name": f"v{verse_num}"})
        l_elem = ET.SubElement(v_elem, "lines")
        
        # kompletter Text mit normalen Zeilenumbrüchen
        l_elem.text = text

    return ET.ElementTree(song)


def main():
    print("Lade Liedliste...")
    soup = fetch_page(LIST_URL)
    table = soup.find("table")
    if not table:
        print("Keine Tabelle gefunden!")
        return

    rows = table.find_all("tr")[1:]
    print(f"   {len(rows)} Eintraege gefunden.")

    for row in rows:
        cols = row.find_all("td")
        if len(cols) < 3:
            continue

        title_link = cols[1].find("a")
        if not title_link:
            continue

        title = title_link.text.strip()
        href = title_link.get("href", "").strip()
        if not href:
            continue

        url = href if href.startswith("http") else urljoin(LIST_URL, href)
        author_raw = cols[2].text.strip().replace("\n", " ").strip()

        print(f"-> {title} ({author_raw})")
        try:
            song_page = fetch_page(url)
        except requests.HTTPError as e:
            print(f"   HTTP-Fehler: {e}")
            continue
        except requests.RequestException as e:
            print(f"   Netzwerkfehler: {e}")
            continue

        verses, meta = parse_song_page(song_page)

        if not verses:
            print(f"   Keine Strophen gefunden.")
            # Debug
            divs = song_page.find_all("div", class_="card-body")
            if divs:
                print(f"   [DEBUG]: {repr(divs[-1].get_text()[:300])}")
            continue

        text_authors = [a.strip() for a in author_raw.split(',') if a.strip()]
        melody_author = meta.get('melodie', '')

        xml_tree = create_openlp_xml(title, text_authors, melody_author, verses, meta)
        filename = os.path.join(OUTPUT_DIR, sanitize_filename(f"{title}.xml"))
        ET.indent(xml_tree.getroot())
        xml_tree.write(filename, encoding="utf-8", xml_declaration=True)
        print(f"   Gespeichert ({len(verses)} Strophen): {filename}")

if __name__ == "__main__":
    main()