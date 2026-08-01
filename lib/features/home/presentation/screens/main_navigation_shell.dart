import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nukkad/features/all/presentation/screens/all_feed_screen.dart';
import 'package:nukkad/features/buy/presentation/screens/buy_screen.dart';
import 'package:nukkad/features/game_zone/presentation/screens/game_zone_screen.dart';
import 'package:nukkad/features/help/presentation/screens/help_screen.dart';
import 'package:nukkad/features/lend/presentation/screens/lend_screen.dart';
import 'package:nukkad/features/sell/presentation/screens/sell_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final StatefulNavigationShell? navigationShell;

  const MainNavigationShell({
    super.key,
    this.navigationShell,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AllFeedScreen(),
    BuyScreen(),
    SellScreen(),
    LendScreen(),
    HelpScreen(),
    GameZoneScreen(),
  ];

  static const List<_NavItemData> _navItems = [
    _NavItemData(
      label: 'All',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      color: Color(0xFF059669),
    ),
    _NavItemData(
      label: 'Buy',
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      color: Color(0xFF1E88E5),
    ),
    _NavItemData(
      label: 'Sell',
      icon: Icons.sell_outlined,
      activeIcon: Icons.sell_rounded,
      color: Color(0xFF43A047),
    ),
    _NavItemData(
      label: 'Lend',
      icon: Icons.handshake_outlined,
      activeIcon: Icons.handshake_rounded,
      color: Color(0xFFFB8C00),
    ),
    _NavItemData(
      label: 'Help',
      icon: Icons.volunteer_activism_outlined,
      activeIcon: Icons.volunteer_activism_rounded,
      color: Color(0xFF8E24AA),
    ),
    _NavItemData(
      label: 'Games',
      icon: Icons.sports_esports_outlined,
      activeIcon: Icons.sports_esports_rounded,
      color: Color(0xFF8B5CF6),
    ),
  ];

  void _onTabSelected(int index) {
    if (widget.navigationShell != null) {
      widget.navigationShell!.goBranch(
        index,
        initialLocation: index == widget.navigationShell!.currentIndex,
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeIndex = widget.navigationShell?.currentIndex ?? _currentIndex;

    final navBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final navBorderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final showFab = activeIndex >= 0 && activeIndex <= 4;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: widget.navigationShell ??
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: showFab
          ? Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.push('/create'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_circle_outline_rounded,
                              color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Post Listing',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(
            top: BorderSide(
              color: navBorderColor,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = activeIndex == index;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onTabSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? item.color.withValues(alpha: isDark ? 0.25 : 0.14)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: AnimatedScale(
                              scale: isSelected ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isSelected ? item.activeIcon : item.icon,
                                color: isSelected
                                    ? item.color
                                    : (isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8)),
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? item.color
                                  : (isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8)),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Color color;

  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.color,
  });
}
