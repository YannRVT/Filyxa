import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n.dart';
import 'theme.dart';

/// Ordre des branches du routeur ; le Scanner est au centre sur téléphone.
enum ShellTab { library, studio, scanner, suppliers, account }

class _Destination {
  const _Destination(this.tab, this.icon, this.selectedIcon);

  final ShellTab tab;
  final IconData icon;
  final IconData selectedIcon;

  String label(AppLocalizations l10n) => switch (tab) {
        ShellTab.library => l10n.navLibrary,
        ShellTab.studio => l10n.navStudio,
        ShellTab.scanner => l10n.navScanner,
        ShellTab.suppliers => l10n.navSuppliers,
        ShellTab.account => l10n.navAccount,
      };
}

const _destinations = [
  _Destination(ShellTab.library, Icons.grid_view_outlined, Icons.grid_view),
  _Destination(ShellTab.studio, Icons.layers_outlined, Icons.layers),
  _Destination(ShellTab.scanner, Icons.document_scanner_outlined, Icons.document_scanner),
  _Destination(ShellTab.suppliers, Icons.local_shipping_outlined, Icons.local_shipping),
  _Destination(ShellTab.account, Icons.person_outline, Icons.person),
];

/// Navigation adaptative :
/// - téléphone : onglets en bas, bouton Scanner central mis en avant ;
/// - tablette : barre latérale pétrole réduite aux icônes ;
/// - ordinateur (≥ 1024 px) : barre latérale pétrole complète avec le logo.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _go(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < FxBreakpoints.tablet) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: _BottomBar(current: navigationShell.currentIndex, onSelect: _go),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          _SideBar(
            current: navigationShell.currentIndex,
            onSelect: _go,
            expanded: width >= FxBreakpoints.desktop,
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.current, required this.onSelect});

  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: FxColors.white,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: FxColors.line))),
          height: 68,
          child: Row(
            children: [
              for (var i = 0; i < _destinations.length; i++)
                Expanded(
                  child: _destinations[i].tab == ShellTab.scanner
                      ? _ScanButton(
                          label: _destinations[i].label(l10n),
                          selected: current == i,
                          onTap: () => onSelect(i),
                        )
                      : _BottomItem(
                          destination: _destinations[i],
                          label: _destinations[i].label(l10n),
                          selected: current == i,
                          onTap: () => onSelect(i),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.destination,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? FxColors.petrol : FxColors.inkSoft;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? destination.selectedIcon : destination.icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton Scanner central : pastille pétrole, accessible au pouce.
class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Center(
        child: Material(
          color: selected ? FxColors.petrolDark : FxColors.petrol,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox.square(
              dimension: 56,
              child: Icon(Icons.document_scanner_outlined, color: FxColors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideBar extends StatelessWidget {
  const _SideBar({required this.current, required this.onSelect, required this.expanded});

  final int current;
  final ValueChanged<int> onSelect;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scannerIndex = _destinations.indexWhere((d) => d.tab == ShellTab.scanner);
    return Container(
      width: expanded ? 232 : 76,
      color: FxColors.petrol,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 28),
              child: expanded
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/brand/filyxa-logo-light.png',
                        height: 32,
                        semanticLabel: 'Filyxa',
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/brand/filyxa-symbol.svg',
                      height: 32,
                      semanticsLabel: 'Filyxa',
                    ),
            ),
            for (var i = 0; i < _destinations.length; i++)
              if (_destinations[i].tab != ShellTab.scanner)
                _SideItem(
                  destination: _destinations[i],
                  label: _destinations[i].label(l10n),
                  selected: current == i,
                  expanded: expanded,
                  onTap: () => onSelect(i),
                ),
            const Spacer(),
            _SideScanButton(
              label: _destinations[scannerIndex].label(l10n),
              expanded: expanded,
              selected: current == scannerIndex,
              onTap: () => onSelect(scannerIndex),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.destination,
    required this.label,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final _Destination destination;
  final String label;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? FxColors.white : const Color(0xFFCFE7E2);
    final item = Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: selected ? FxColors.mint.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(FxRadius.sm),
          child: InkWell(
            borderRadius: BorderRadius.circular(FxRadius.sm),
            onTap: onTap,
            child: CustomPaint(
              painter: selected ? const _StitchPainter() : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    Icon(selected ? destination.selectedIcon : destination.icon, color: color, size: 20),
                    if (expanded) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return expanded ? item : Tooltip(message: label, child: item);
  }
}

class _SideScanButton extends StatelessWidget {
  const _SideScanButton({
    required this.label,
    required this.expanded,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool expanded;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: selected ? FxColors.emerald : FxColors.emeraldInk,
      borderRadius: BorderRadius.circular(FxRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(FxRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.document_scanner_outlined, color: FxColors.white, size: 20),
              if (expanded) ...[
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(color: FxColors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: expanded ? button : Tooltip(message: label, child: button),
    );
  }
}

/// Point de couture : trait vertical en pointillés menthe qui marque la page active.
class _StitchPainter extends CustomPainter {
  const _StitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FxColors.mint
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const dash = 5.0;
    const gap = 4.0;
    const x = -10.0;
    for (var y = 6.0; y < size.height - 6; y += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset(x, (y + dash).clamp(0, size.height - 6)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
