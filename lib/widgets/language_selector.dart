import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/languages.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends ConsumerWidget {
  final LanguageInfo? value;
  final ValueChanged<LanguageInfo?> onChanged;
  final String? label;

  const LanguageSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLoc.of(context)!;

    return GestureDetector(
      onTap: () => _showLanguageSheet(context, l),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            if (value != null)
              Text(value!.flag, style: const TextStyle(fontSize: 22))
            else
              Icon(Icons.language, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  Text(
                    value != null
                        ? '${value!.name} · ${value!.nativeName}'
                        : l.selectLanguage,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, AppLoc l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx2, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx2).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    l.selectLanguage,
                    style: Theme.of(ctx2).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: AppLanguages.all.length,
                itemBuilder: (ctx3, index) {
                  final lang = AppLanguages.all[index];
                  final isSelected = value?.code == lang.code;
                  return ListTile(
                    leading: Text(
                      lang.flag,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      lang.nativeName,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(lang.name),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(ctx3).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      onChanged(lang);
                      Navigator.pop(ctx3);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
