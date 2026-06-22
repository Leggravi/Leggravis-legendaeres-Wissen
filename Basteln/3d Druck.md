[TOC]



------

# Probleme und ihre Lösung

| Date        | Problem                                          | Solution                                                     |
| ----------- | ------------------------------------------------ | ------------------------------------------------------------ |
| 17.06. 2026 | x-Endstop leuchtet zwar, aber sendet keine Daten | -> kabelwackelkontakt<br />Im Kabelsalat, der nach unten ging war rechts hinten ein Kabel locker/halb draußen \| einfach nach oben drücken |
| immer       | falsches z-offset                                | 1. im druckerinterface auf cornerleveling und die schrauben hochdrehen (einfach und schnell)<br />2. per pronterface verbinden und `M206 Z.7` den endstopp z wert 0 auf 0.7 setzen (-> beim drucken druckt es .7 tiefer)`M500` daten speichern (kompliziert und nervig)<br />3. im start g-code `G92 Z0.3`; Extr. bewegt sich nicht, denkt aber er ist bei .3 (einigermaßen zuverlässig) |
|             | Stringing                                        | Nasses Filament?<br />sonst: kleinere Temperatur, mehr Einzug <br />Auch: schnellere Bewegung, „coasting”/wiping |
|             | Druckbetthaftung                                 | mit Alkohol und Küchentuch reinigen<br />Sonst: höhere Betttemperatur (70°), dicke erste Schicht (0.3 mm), höhere Düsentemperatur (240°), langsames Drucken (30mm/s), niedriges z-offset (s.o.), |



# Artillery Hornet – Pronterface Quick Setup (Linux)

### 1. USB Verbindung prüfen

Drucker anschließen und Port finden:

```bash
ls /dev/ttyACM*
ls /dev/ttyUSB*
```

Typisch:

```
/dev/ttyACM0
```

------

## 2. Pronterface starten

cd ~/Documents/GitHub/
git clone https://github.com/kliment/Printrun.git
cd Printrun

```bash
cd ~/Documents/GitHub/Printrun/
source ~/venv/bin/activate.fish
./pronterface.py
```

------

# WICHTIGSTE PROBLEME

------

## 3. RECHTE (häufigster Fehler!)

Wenn kein Connect möglich ist:

```bash
sudo usermod -aG dialout $USER
```

Dann unbedingt:

- logout/login oder reboot

Prüfen:

```bash
groups
```

`dialout` muss enthalten sein.

------

## 4. DEPENDENCIES (zweithäufigster Fehler)

Wenn Pronterface crasht oder Module fehlen:

```bash
pip install pyserial numpy psutil wxPython pillow pyglet lxml platformdirs puremagic dbus-python
```

------

## Alternative: Auto-Fix Script

```python
import importlib
import sys
import subprocess

REQUIRED = [
    ("serial", "pyserial"),
    ("numpy", "numpy"),
    ("psutil", "psutil"),
    ("wx", "wxPython"),
    ("PIL", "pillow"),
    ("pyglet", "pyglet"),
    ("lxml", "lxml"),
    ("platformdirs", "platformdirs"),
    ("puremagic", "puremagic"),
    ("dbus", "dbus-python"),
]

def install(pkg):
    subprocess.call([sys.executable, "-m", "pip", "install", pkg])

for imp, pip in REQUIRED:
    try:
        importlib.import_module(imp)
    except Exception:
        install(pip)
```

Start:

```bash
python3 dependencies.py
```

------

## 5. wxPython Problem (häufig langsam/fehleranfällig)

```bash
pip install wxPython
```

oder stabiler:

```bash
sudo apt install python3-wxgtk4.0
```

------

## 6. Verbindung in Pronterface

- Port: `/dev/ttyACM0`
- Baudrate: `115200` oder `250000`
- Connect

------

## 7. Endstop Test

Nach Verbindung:

```text
M119
```

Erwartung:

- open = nicht gedrückt
- TRIGGERED = aktiv

------

## 8. Typisches Problem-Signal

Wenn Werte wechseln (open ↔ triggered):

- Kabelbruch (häufig)
- Stecker locker
- Mainboard Eingang instabil

------

## Minimal Workflow

```bash
cd Printrun
source ~/venv/bin/activate.fish
./pronterface.py
# connect
M119
```

