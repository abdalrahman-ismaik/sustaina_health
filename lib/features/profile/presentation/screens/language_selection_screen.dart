import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.language),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.primary.withOpacity(0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.language,
                    size: 40,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.selectYourPreferredLanguage,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your preferred language for the app interface',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Language Options
            Text(
              'Available Languages',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Language List
            Expanded(
              child: ListView.builder(
                itemCount: LocaleNotifier.supportedLocales.length,
                itemBuilder: (context, index) {
                  final locale = LocaleNotifier.supportedLocales[index];
                  final isSelected = locale.languageCode == currentLocale.languageCode;
                  final displayName = localeNotifier.getLocaleDisplayName(locale);
                  
                  return _LanguageOption(
                    locale: locale,
                    displayName: displayName,
                    isSelected: isSelected,
                    onTap: () async {
                      await localeNotifier.setLocale(locale);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Language changed to $displayName',
                              style: TextStyle(color: colorScheme.onPrimary),
                            ),
                            backgroundColor: colorScheme.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
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

class _LanguageOption extends StatelessWidget {
  final Locale locale;
  final String displayName;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.locale,
    required this.displayName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected 
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
            ? colorScheme.primary 
            : colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected 
              ? colorScheme.primary 
              : colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _getLanguageIcon(locale.languageCode, isSelected, colorScheme),
        ),
        title: Text(
          displayName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _getLanguageDescription(locale.languageCode),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: colorScheme.primary,
              size: 24,
            )
          : Icon(
              Icons.circle_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
      ),
    );
  }

  Widget _getLanguageIcon(String languageCode, bool isSelected, ColorScheme colorScheme) {
    IconData iconData;
    switch (languageCode) {
      case 'ar':
        iconData = Icons.language;
        break;
      case 'en':
        iconData = Icons.language;
        break;
      default:
        iconData = Icons.language;
    }
    
    return Icon(
      iconData,
      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      size: 24,
    );
  }

  String _getLanguageDescription(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'العربية - Right-to-left language';
      case 'en':
        return 'English - Left-to-right language';
      default:
        return 'Language pack';
    }
  }
}
