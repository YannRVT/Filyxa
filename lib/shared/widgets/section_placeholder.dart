import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';

/// Section pas encore livrée : titre de la section et message « bientôt disponible ».
class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(FxSpace.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(FxSpace.md),
                  decoration: BoxDecoration(
                    color: FxColors.mintPale,
                    borderRadius: BorderRadius.circular(FxRadius.lg),
                  ),
                  child: Icon(icon, size: 32, color: FxColors.petrol),
                ),
                const SizedBox(height: FxSpace.md),
                Text(l10n.comingSoonTitle, style: text.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: FxSpace.sm),
                Text(
                  l10n.comingSoonBody,
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(color: FxColors.inkSoft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
