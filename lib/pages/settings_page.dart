import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/languages.dart';
import '../core/extensions/context_extensions.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/asr_model_info.dart';
import '../models/tts_model_info.dart';
import '../providers/model_download_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/language_selector.dart';

const _vadModelId = 'silero-vad';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAllDownloadStatuses();
    });
  }

  void _checkAllDownloadStatuses() {
    for (final m in AsrModels.all()) {
      ref.read(modelDownloadProvider(m.id).notifier).checkDownloaded();
    }
    for (final m in TtsModels.all()) {
      ref.read(modelDownloadProvider(m.id).notifier).checkDownloaded();
    }
    ref.read(modelDownloadProvider(_vadModelId).notifier).checkDownloaded();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLoc.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SettingsSection(
            title: l.languageSettings,
            icon: Icons.language_rounded,
            children: [
              LanguageSelector(
                value: AppLanguages.byCode(settings.sourceLanguage),
                onChanged: (lang) {
                  if (lang != null) notifier.updateSourceLang(lang.code.name);
                },
                label: l.sourceLanguage,
              ),
              const SizedBox(height: 12),
              LanguageSelector(
                value: AppLanguages.byCode(settings.targetLanguage),
                onChanged: (lang) {
                  if (lang != null) notifier.updateTargetLang(lang.code.name);
                },
                label: l.targetLanguage,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: l.modelSettings,
            icon: Icons.model_training_rounded,
            children: [
              Text(
                l.asrModel,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...AsrModels.all().map(
                (m) => _AsrModelCard(
                  model: m,
                  isSelected: settings.asrModelId == m.id,
                  onSelect: () => notifier.updateAsrModel(m.id),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.ttsModel,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...TtsModels.all().map(
                (m) => _TtsModelCard(
                  model: m,
                  isSelected: settings.ttsModelId == m.id,
                  onSelect: () => notifier.updateTtsModel(m.id),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.vadModel,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const _VadModelCard(),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: l.translationEngine,
            icon: Icons.translate_rounded,
            children: [
              _DropdownTile<TranslationEngine>(
                label: l.translationEngineLabel,
                value: settings.translationEngine,
                items: const [
                  DropdownMenuItem(
                    value: TranslationEngine.mlKit,
                    child: Text('ML Kit'),
                  ),
                  DropdownMenuItem(
                    value: TranslationEngine.appleTranslation,
                    child: Text('Apple Translation'),
                  ),
                  DropdownMenuItem(
                    value: TranslationEngine.systemTranslator,
                    child: Text('System Translator'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) notifier.updateTranslationEngine(v);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: l.behaviorSettings,
            icon: Icons.tune_rounded,
            children: [
              SwitchListTile(
                title: Text(l.autoTranslate),
                subtitle: Text(l.autoTranslateHint),
                value: settings.autoTranslate,
                onChanged: (v) => notifier.toggleAutoTranslate(),
              ),
              SwitchListTile(
                title: Text(l.autoSpeak),
                subtitle: Text(l.autoSpeakHint),
                value: settings.autoSpeak,
                onChanged: (v) => notifier.toggleAutoSpeak(),
              ),
              SwitchListTile(
                title: Text(l.mirrorMode),
                subtitle: Text(l.mirrorModeHint),
                value: settings.mirrorMode,
                onChanged: (v) => notifier.toggleMirrorMode(),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AsrModelCard extends ConsumerWidget {
  final AsrModelInfo model;
  final bool isSelected;
  final VoidCallback onSelect;

  const _AsrModelCard({
    required this.model,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLoc.of(context)!;
    final state = ref.watch(modelDownloadProvider(model.id));
    return _ModelCard(
      name: model.name,
      languages: model.languages.join(', '),
      sizeMb: model.sizeMb,
      downloadState: state,
      modelId: model.id,
      isSelected: isSelected,
      onSelect: onSelect,
      l: l,
    );
  }
}

class _TtsModelCard extends ConsumerWidget {
  final TtsModelInfo model;
  final bool isSelected;
  final VoidCallback onSelect;

  const _TtsModelCard({
    required this.model,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLoc.of(context)!;
    final state = ref.watch(modelDownloadProvider(model.id));
    return _ModelCard(
      name: model.name,
      languages: model.language,
      sizeMb: model.sizeMb,
      downloadState: state,
      modelId: model.id,
      isSelected: isSelected,
      onSelect: onSelect,
      l: l,
    );
  }
}

class _VadModelCard extends ConsumerWidget {
  const _VadModelCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLoc.of(context)!;
    final state = ref.watch(modelDownloadProvider(_vadModelId));
    return _ModelCard(
      name: 'Silero VAD',
      languages: '-',
      sizeMb: 2,
      downloadState: state,
      modelId: _vadModelId,
      isSelected: false,
      onSelect: () {},
      l: l,
      selectable: false,
    );
  }
}

class _ModelCard extends ConsumerWidget {
  final String name;
  final String languages;
  final int sizeMb;
  final ModelDownloadState downloadState;
  final String modelId;
  final bool isSelected;
  final VoidCallback onSelect;
  final AppLoc l;
  final bool selectable;

  const _ModelCard({
    required this.name,
    required this.languages,
    required this.sizeMb,
    required this.downloadState,
    required this.modelId,
    required this.isSelected,
    required this.onSelect,
    required this.l,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final notifier = ref.read(modelDownloadProvider(modelId).notifier);

    final isDownloaded = downloadState.status == DownloadStatus.completed;
    final isDownloading = downloadState.status == DownloadStatus.downloading;
    final isFailed = downloadState.status == DownloadStatus.failed;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: isSelected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: cs.primary, width: 2),
            )
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isDownloaded && selectable) {
            onSelect();
          } else if (!isDownloaded && !isDownloading) {
            notifier.download();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l.currentModel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildActionIcon(
                    context,
                    notifier,
                    isDownloaded,
                    isDownloading,
                    isFailed,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _InfoChip(
                    icon: Icons.language_rounded,
                    label: l.supportedLanguages,
                    value: languages,
                  ),
                  _InfoChip(
                    icon: Icons.storage_rounded,
                    label: l.modelSize,
                    value: '$sizeMb MB',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isDownloading) ...[
                LinearProgressIndicator(
                  value: downloadState.progress,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l.downloading} ${(downloadState.progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ] else if (isDownloaded)
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: cs.primary),
                    const SizedBox(width: 4),
                    Text(
                      l.modelDownloaded,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                      ),
                    ),
                    if (selectable) ...[
                      const SizedBox(width: 8),
                      Text(
                        l.selectModel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                )
              else if (isFailed)
                Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: cs.error),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l.downloadFailed,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.error,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  l.modelNotDownloaded,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(
    BuildContext context,
    ModelDownloadNotifier notifier,
    bool isDownloaded,
    bool isDownloading,
    bool isFailed,
  ) {
    if (isDownloading) {
      return IconButton(
        icon: const Icon(Icons.stop_rounded),
        tooltip: l.downloading,
        onPressed: () => notifier.cancel(),
      );
    }
    if (isDownloaded) {
      return IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: l.deleteModel,
        onPressed: () => notifier.delete(),
      );
    }
    return IconButton(
      icon: const Icon(Icons.download),
      tooltip: l.downloadModel,
      onPressed: () => notifier.download(),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownTile({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: const Icon(Icons.expand_more_rounded),
          borderRadius: BorderRadius.circular(16),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
