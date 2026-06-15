import 'dart:html' as html;

void enterFullscreen() {
  html.document.documentElement?.requestFullscreen();
}

void exitFullscreen() {
  html.document.exitFullscreen();
}
