/**
 * SIMPLE BUZZER-IMPLEMENTIERUNG
 * Tastendrücke 1, 2, 3 = Teams 1, 2, 3
 */

let buzzerCallback = null;

document.addEventListener('keydown', (e) => {
  if (['1', '2', '3'].includes(e.key)) {
    e.preventDefault();
    if (buzzerCallback) {
      buzzerCallback(e.key);
    }
  }
});

// Helper: Zeit formatieren
function formatTime(totalSeconds) {
  const s = Math.max(0, Math.floor(totalSeconds));
  return `${String(Math.floor(s / 60)).padStart(2,'0')}:${String(s % 60).padStart(2,'0')}`;
}
