const { app, BrowserWindow, ipcMain, screen } = require('electron');
const path = require('path');

// Try to improve transparent visuals (may help on some distros)
app.commandLine.appendSwitch('enable-transparent-visuals');

let bgWindow, uiWindow;

function createWindows() {
  const displays = screen.getAllDisplays();
  const primary = displays[0].bounds;

  // Background window - frameless but draggable via CSS region
  bgWindow = new BrowserWindow({
    x: primary.x,
    y: primary.y,
    width: primary.width,
    height: primary.height,
    frame: false,
    transparent: true,
    resizable: true,
    movable: true,
    fullscreenable: true,
    skipTaskbar: true,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });
  bgWindow.setIgnoreMouseEvents(false); // allow interaction if needed
  bgWindow.loadFile(path.join(__dirname, 'background.html'));

  // UI window
  uiWindow = new BrowserWindow({
    width: 540,
    height: 820,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });
  uiWindow.loadFile(path.join(__dirname, 'ui.html'));
}

app.whenReady().then(createWindows);

ipcMain.on('update-vanta', (ev, cfg) => {
  if (bgWindow && !bgWindow.isDestroyed()) bgWindow.webContents.send('update-vanta', cfg);
});

ipcMain.handle('get-displays', () => {
  return screen.getAllDisplays().map((d, i) => ({
    index: i,
    id: d.id,
    bounds: d.bounds,
    size: d.size,
    scaleFactor: d.scaleFactor
  }));
});

ipcMain.on('move-bg-to-display', (ev, idx) => {
  const displays = screen.getAllDisplays();
  const d = displays[idx];
  if (!d || !bgWindow) return;
  const b = d.bounds;
  bgWindow.setBounds({ x: b.x, y: b.y, width: b.width, height: b.height });
  try { if (uiWindow && !uiWindow.isDestroyed()) uiWindow.focus(); } catch(e) {}
});

ipcMain.on('toggle-bg-fullscreen', () => {
  if (!bgWindow) return;
  bgWindow.setFullScreen(!bgWindow.isFullScreen());
});

ipcMain.on('maximize-bg', () => { if (bgWindow) bgWindow.maximize(); });

app.on('window-all-closed', () => app.quit());
