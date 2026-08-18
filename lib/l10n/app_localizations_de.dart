// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocDe extends AppLoc {
  AppLocDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'VoiceLoop';

  @override
  String get sourceLanguage => 'Quellsprache';

  @override
  String get targetLanguage => 'Zielsprache';

  @override
  String get history => 'Verlauf';

  @override
  String get historyEmpty => 'Keine Sitzungen';

  @override
  String get historyEmptyHint =>
      'Starten Sie die Aufnahme und Übersetzungen werden hier angezeigt';

  @override
  String get sessionDetail => 'Sitzungsdetails';

  @override
  String get sessionEmpty => 'Keine Nachrichten';

  @override
  String get sessionEmptyHint =>
      'Noch keine Übersetzungsnachrichten in dieser Sitzung';

  @override
  String get settings => 'Einstellungen';

  @override
  String get languageSettings => 'Spracheinstellungen';

  @override
  String get modelSettings => 'Modell-Einstellungen';

  @override
  String get asrModel => 'ASR-Modell';

  @override
  String get ttsModel => 'TTS-Modell';

  @override
  String get translationEngine => 'Übersetzungs-Engine';

  @override
  String get translationEngineLabel => 'Übersetzungs-Engine';

  @override
  String get behaviorSettings => 'Verhaltenseinstellungen';

  @override
  String get autoTranslate => 'Auto-Übersetzung';

  @override
  String get autoTranslateHint => 'Automatisch nach Erkennung übersetzen';

  @override
  String get autoSpeak => 'Auto-Vorlesen';

  @override
  String get autoSpeakHint => 'Audio nach Übersetzung automatisch abspielen';

  @override
  String get mirrorMode => 'Spiegelmodus';

  @override
  String get mirrorModeHint =>
      'Gegenüberliegende Übersetzungsschnittstelle aktivieren';

  @override
  String get tapToStart => 'Tippen zum Starten der Aufnahme';

  @override
  String get listening => 'Höre zu...';

  @override
  String get recognizing => 'Erkenne...';

  @override
  String get translating => 'Übersetze...';

  @override
  String get speaking => 'Spreche...';

  @override
  String get originalText => 'Original';

  @override
  String get translatedText => 'Übersetzung';

  @override
  String get noTranslationYet => 'Übersetzung wird hier angezeigt';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get delete => 'Löschen';

  @override
  String get export => 'Exportieren';

  @override
  String get share => 'Teilen';

  @override
  String get messages => 'Nachrichten';

  @override
  String get swapLanguages => 'Sprachen tauschen';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get recordPermissionDenied => 'Mikrofonberechtigung erforderlich';

  @override
  String get modelNotDownloaded =>
      'Modell nicht heruntergeladen, bitte in den Einstellungen herunterladen';

  @override
  String get initFailed =>
      'Initialisierung fehlgeschlagen, bitte Modelldateien prüfen';

  @override
  String get exportSuccess => 'Export erfolgreich';

  @override
  String get exportFailed => 'Export fehlgeschlagen';

  @override
  String get deleteConfirm => 'Möchten Sie diese Sitzung wirklich löschen?';

  @override
  String get deleteSessionSuccess => 'Sitzung gelöscht';
}
