## Links in Ubuntu erstellen

Es gibt mehrere Methoden, je nach Situation:

------

### 1. Symbolischer Link (Terminal) – funktioniert immer

```bash
ln -s /pfad/zum/ziel /pfad/zum/link
```

------

### 2. !!!Nautilus (Dateimanager) – Drag & Drop!! sehr gut!

- Datei/Ordner gedrückt halten und an Zielort ziehen
- Beim Loslassen: **„Link hierher erstellen"** wählen (statt Kopieren/Verschieben)

Falls das nicht erscheint: **Strg+Shift** während des Ziehens gedrückt halten.

------

### Warum klappt Strg+Shift+M nur manchmal?

- Funktioniert nur im **Nautilus-Dateimanager**, nicht überall
- Klappt nicht, wenn du keine Schreibrechte am **Zielort** (wo der Link landen soll) hast
- Bei manchen Ubuntu-Versionen ist die Funktion versteckt oder fehlt

------

**Empfehlung:** Der Terminal-Befehl `ln -s` ist die zuverlässigste Methode und funktioniert immer, solange der Ordner, in dem der Link erstellt wird, dir gehört.



### 2. Desktop-Verknüpfung (.desktop-Datei)

Für Programme oder Ordner auf dem Desktop:

```bash
nano ~/Desktop/meinlink.desktop
```

Inhalt:

```ini
[Desktop Entry]
Type=Link
Name=Mein Link
URL=/pfad/zum/ziel
Icon=folder
```

Dann ausführbar machen:

```bash
chmod +x ~/Desktop/meinlink.desktop
```

Danach Rechtsklick → *„Als vertrauenswürdig markieren"* (bei GNOME nötig).