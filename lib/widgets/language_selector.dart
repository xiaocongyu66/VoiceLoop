import 'package:flutter/material.dart';

import '../core/constants/languages.dart';
import '../core/extensions/context_extensions.dart';

class LanguageSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: value != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Center(
                  child: Text(
                    value!.flag,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LanguageInfo>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: const Icon(Icons.expand_more_rounded),
          borderRadius: BorderRadius.circular(16),
          items: AppLanguages.all.map((lang) {
            return DropdownMenuItem<LanguageInfo>(
              value: lang,
              child: Row(
                children: [
                  Text(lang.flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(lang.name, style: context.textTheme.bodyLarge),
                        Text(
                          lang.nativeName,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
