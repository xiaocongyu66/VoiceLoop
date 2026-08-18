// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocFr extends AppLoc {
  AppLocFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'VoiceLoop';

  @override
  String get sourceLanguage => 'Langue source';

  @override
  String get targetLanguage => 'Langue cible';

  @override
  String get history => 'Historique';

  @override
  String get historyEmpty => 'Aucune session';

  @override
  String get historyEmptyHint =>
      'Commencez l\'enregistrement et les traductions apparaîtront ici';

  @override
  String get sessionDetail => 'Détails de la session';

  @override
  String get sessionEmpty => 'Aucun message';

  @override
  String get sessionEmptyHint =>
      'Aucun message de traduction dans cette session';

  @override
  String get settings => 'Paramètres';

  @override
  String get languageSettings => 'Paramètres de langue';

  @override
  String get modelSettings => 'Paramètres du modèle';

  @override
  String get asrModel => 'Modèle ASR';

  @override
  String get ttsModel => 'Modèle TTS';

  @override
  String get translationEngine => 'Moteur de traduction';

  @override
  String get translationEngineLabel => 'Moteur de traduction';

  @override
  String get behaviorSettings => 'Paramètres de comportement';

  @override
  String get autoTranslate => 'Traduction auto';

  @override
  String get autoTranslateHint =>
      'Traduire automatiquement après la reconnaissance';

  @override
  String get autoSpeak => 'Lecture auto';

  @override
  String get autoSpeakHint =>
      'Lire automatiquement l\'audio après la traduction';

  @override
  String get mirrorMode => 'Mode miroir';

  @override
  String get mirrorModeHint => 'Activer l\'interface de traduction face à face';

  @override
  String get tapToStart => 'Touchez pour commencer l\'enregistrement';

  @override
  String get listening => 'Écoute...';

  @override
  String get recognizing => 'Reconnaissance...';

  @override
  String get translating => 'Traduction...';

  @override
  String get speaking => 'Lecture...';

  @override
  String get originalText => 'Original';

  @override
  String get translatedText => 'Traduction';

  @override
  String get noTranslationYet => 'La traduction apparaîtra ici';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get delete => 'Supprimer';

  @override
  String get export => 'Exporter';

  @override
  String get share => 'Partager';

  @override
  String get messages => 'messages';

  @override
  String get swapLanguages => 'Inverser les langues';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get recordPermissionDenied => 'Permission de microphone requise';

  @override
  String get modelNotDownloaded =>
      'Modèle non téléchargé, veuillez le télécharger dans les paramètres';

  @override
  String get initFailed =>
      'Échec de l\'initialisation, vérifiez les fichiers de modèle';

  @override
  String get exportSuccess => 'Export réussi';

  @override
  String get exportFailed => 'Échec de l\'export';

  @override
  String get deleteConfirm => 'Voulez-vous vraiment supprimer cette session?';

  @override
  String get deleteSessionSuccess => 'Session supprimée';
}
