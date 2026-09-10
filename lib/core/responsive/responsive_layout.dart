import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'breakpoints.dart';

class ContentContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ContentContainer({
    super.key,
    required this.child,
    this.maxWidth = 720.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class NavigationDestinationItem {
  final Widget icon;
  final Widget selectedIcon;
  final String label;

  const NavigationDestinationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class ResponsiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestinationItem> destinations;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isTablet(context);

    if (isTablet) {
      return Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              backgroundColor: context.surfaceColor,
              indicatorColor: context.accentColor.withValues(alpha: 0.16),
              selectedIconTheme: IconThemeData(color: context.accentColor),
              unselectedIconTheme: IconThemeData(color: context.textTertiaryColor),
              selectedLabelTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.accentColor,
              ),
              unselectedLabelTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.textTertiaryColor,
              ),
              destinations: destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: context.dividerColor, width: 0.8),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: context.surfaceColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: context.accentColor.withValues(alpha: 0.16),
          destinations: destinations
              .map(
                (d) => NavigationDestination(
                  icon: d.icon,
                  selectedIcon: d.selectedIcon,
                  label: d.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class AdaptiveTwoPane extends StatelessWidget {
  final Widget primary;
  final Widget secondary;
  final double primaryWidth;
  final Widget? emptySecondary;

  const AdaptiveTwoPane({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryWidth = 360.0,
    this.emptySecondary,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isTablet(context);

    if (!isTablet) {
      return primary;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: primaryWidth,
          child: primary,
        ),
        const VerticalDivider(width: 1),
        Expanded(child: secondary),
      ],
    );
  }
}
