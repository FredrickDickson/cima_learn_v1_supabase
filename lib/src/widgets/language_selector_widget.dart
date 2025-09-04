import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/enhanced_localization_service.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final bool showFlag;
  final bool showFullName;
  
  const LanguageSelectorWidget({
    Key? key,
    this.showFlag = true,
    this.showFullName = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedLocalizationService>(
      builder: (context, localizationService, child) {
        return PopupMenuButton<Locale>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showFlag) ...[
                Text(
                  EnhancedLocalizationService.getCountryFlag(
                    localizationService.currentLanguageCode,
                  ),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
              ],
              if (showFullName)
                Text(
                  EnhancedLocalizationService.getLanguageName(
                    localizationService.currentLanguageCode,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
          onSelected: (Locale locale) {
            localizationService.setLocale(locale);
          },
          itemBuilder: (BuildContext context) {
            return EnhancedLocalizationService.supportedLocales.map((Locale locale) {
              final isSelected = locale == localizationService.currentLocale;
              
              return PopupMenuItem<Locale>(
                value: locale,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        EnhancedLocalizationService.getCountryFlag(locale.languageCode),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              EnhancedLocalizationService.getLanguageName(locale.languageCode),
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                              ),
                            ),
                            Text(
                              _getLocalizedLanguageName(locale.languageCode),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          tooltip: EnhancedLocalizationService.t('language'),
        );
      },
    );
  }

  String _getLocalizedLanguageName(String languageCode) {
    // Return the language name in its native script
    switch (languageCode) {
      case 'en': return 'English';
      case 'fr': return 'Français';
      case 'es': return 'Español';
      case 'pt': return 'Português';
      case 'ar': return 'العربية';
      case 'zh': return '中文';
      case 'de': return 'Deutsch';
      case 'ru': return 'Русский';
      case 'ja': return '日本語';
      default: return languageCode.toUpperCase();
    }
  }
}