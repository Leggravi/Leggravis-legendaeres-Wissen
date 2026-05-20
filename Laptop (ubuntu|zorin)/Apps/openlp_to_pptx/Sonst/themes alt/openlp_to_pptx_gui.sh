#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$HOME/venv"
PYTHON="$VENV/bin/python"

# ─────────────────────────────────────────────
# VENV CHECK
# ─────────────────────────────────────────────
if [[ ! -x "$PYTHON" ]]; then
    zenity --error \
        --title="Python fehlt" \
        --text="Bitte installieren:\npython3 -m venv ~/venv\nsource ~/venv/bin/activate\npip install python-pptx"
    exit 1
fi

# ─────────────────────────────────────────────
# OPTIONEN
# ─────────────────────────────────────────────
OPTIONS=$(zenity --forms \
    --title="Optionen" \
    --text="Zusatzoptionen" \
    --add-checklist="CCLI anzeigen?" \
    --add-checklist="Schwarzfolie vor Lied?" )

[[ -z "$OPTIONS" ]] && exit 0

CCLI=$(echo "$OPTIONS" | cut -d'|' -f1)
BLACK=$(echo "$OPTIONS" | cut -d'|' -f2)

# ─────────────────────────────────────────────
# AUSWAHL
# ─────────────────────────────────────────────
CHOICE=$(zenity --list \
    --title="Auswahl" \
    --column="Option" \
    "Ordner wählen" \
    "Dateien wählen")

[[ -z "$CHOICE" ]] && exit 0

START="$SCRIPT_DIR/"

if [[ "$CHOICE" == "Ordner wählen" ]]; then
    DIR=$(zenity --file-selection --directory --filename="$START")
    mapfile -t FILES < <(find "$DIR" -maxdepth 1 -iname "*.osz")
else
    INPUT=$(zenity --file-selection --multiple --separator="|" --filename="$START")
    IFS="|" read -ra FILES <<< "$INPUT"
fi

[[ ${#FILES[@]} -eq 0 ]] && exit 0

TOTAL=${#FILES[@]}
COUNT=0

# ─────────────────────────────────────────────
# PYTHON
# ─────────────────────────────────────────────
run_python() {
"$PYTHON" - "$1" "$2" "$CCLI" "$BLACK" <<'PYCODE'
import sys, os, zipfile, json, re
from pathlib import Path

from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.dml.color import RGBColor

FILE=sys.argv[1]
OUT=sys.argv[2]
SHOW_CCLI=sys.argv[3]=="TRUE"
BLACK=sys.argv[4]=="TRUE"

# ─────────────────────────
def extract(osz):
    p=Path("/tmp/openlp")/Path(osz).stem
    p.mkdir(parents=True,exist_ok=True)
    zipfile.ZipFile(osz).extractall(p)
    return p

def load(folder):
    for f in os.listdir(folder):
        if f.endswith(".osj") or f.endswith(".json"):
            return json.load(open(os.path.join(folder,f),encoding="utf-8"))
    raise Exception("keine osj")

def clean(t):
    t=re.sub(r'[\[\(\{].*?[\]\)\}]','',t)
    t=t.replace("<br/>","\n").replace("<br>","\n")
    return t.strip()

def theme(name):
    base=os.path.expanduser("~/.local/share/openlp/themes")
    f=os.path.join(base,name,name+".json")
    if not os.path.exists(f):
        return {}
    j=json.load(open(f))
    return j

def rgb(h):
    h=h.lstrip("#")
    return RGBColor(int(h[:2],16),int(h[2:4],16),int(h[4:],16))

def shadow(run):
    run.font.shadow = True

def footer(slide, text, font_size):
    box=slide.shapes.add_textbox(
        Inches(0.5),
        Inches(5.8),
        Inches(12),
        Inches(1)
    )
    tf=box.text_frame
    p=tf.paragraphs[0]
    p.text=text
    p.font.size=Pt(font_size*0.35)

def black_slide(prs):
    slide=prs.slides.add_slide(prs.slide_layouts[6])
    bg = slide.background
    fill = bg.fill
    fill.solid()
    fill.fore_color.rgb = RGBColor(0,0,0)

# ─────────────────────────
folder=extract(FILE)
data=load(folder)

theme_name=data[0].get("openlp_core",{}).get("service-theme","")
th=theme(theme_name)

font=th.get("font_main_name","Arial")
size=th.get("font_main_size",60)
color=rgb(th.get("font_main_color","#FFFFFF"))

prs=Presentation()
prs.slide_width=Inches(13.33)
prs.slide_height=Inches(7.5)

for item in data:
    if "serviceitem" not in item: continue
    s=item["serviceitem"]

    title=s["header"]["title"]

    footer_list=s["header"].get("footer",[])
    author=""
    ccli=""

    if len(footer_list)>1:
        author=footer_list[1].replace("Written by: ","")
    if len(footer_list)>0:
        ccli=footer_list[0]

    # ───────── BLACK
    if BLACK:
        black_slide(prs)

    # ───────── TITLE SLIDE
    slide=prs.slides.add_slide(prs.slide_layouts[6])

    tf=slide.shapes.add_textbox(
        Inches(1),Inches(2),
        prs.slide_width-Inches(2),
        Inches(2)
    ).text_frame

    tf.text=title
    p=tf.paragraphs[0]
    p.font.size=Pt(size*0.7)
    p.font.name=font
    shadow(p)

    # Autor
    if author:
        box=slide.shapes.add_textbox(Inches(1),Inches(4),Inches(10),Inches(1))
        tf2=box.text_frame
        tf2.text=author

    # ───────── SLIDES
    for verse in s["data"]:
        raw=verse.get("raw_slide","")
        if not raw: continue

        slide=prs.slides.add_slide(prs.slide_layouts[6])

        tf=slide.shapes.add_textbox(
            Inches(1),
            Inches(1),
            prs.slide_width-Inches(2),
            prs.slide_height*0.75
        ).text_frame

        tf.word_wrap=True
        tf.text=clean(raw)

        for p in tf.paragraphs:
            p.font.name=font
            p.font.size=Pt(size*0.5)
            p.font.color.rgb=color
            shadow(p)

        info=author
        if SHOW_CCLI:
            info += " | " + ccli

        footer(slide, info, size)

prs.save(OUT)
PYCODE
}

# ─────────────────────────────────────────────
# LOOP
# ─────────────────────────────────────────────
(
for f in "${FILES[@]}"; do
    BASENAME=$(basename "$f" .osz)
    DIR=$(dirname "$f")

    OUT="$DIR/${BASENAME}.pptx"
    DONE="$DIR/verarbeitet"
    mkdir -p "$DONE"

    echo "# $(basename "$f")"
    echo $(( COUNT * 100 / TOTAL ))

    run_python "$f" "$OUT"

    if [[ $? -eq 0 ]]; then
        mv "$f" "$DONE/"
    fi

    ((COUNT++))
    echo $(( COUNT * 100 / TOTAL ))
done
) | zenity --progress --auto-close --percentage=0

zenity --info --text="Fertig ✅"
