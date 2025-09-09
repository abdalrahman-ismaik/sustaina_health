import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_names.dart';
import '../../l10n/app_localizations.dart';

class MainNavigationWrapper extends StatelessWidget {
  final Widget child;

  const MainNavigationWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool compact = screenHeight < 700 || bottomInset > 20;
    
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.transparent,
              Colors.black.withOpacity(0.02),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.only(bottom: compact ? 2 : 4),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 6, 16, compact ? 4 : 8),
            child: Container(
              height: compact ? 56 : 64,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: compact ? 6 : 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFFFFFFF),
                    Color(0xFFF8F9FA),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF2E7D32).withOpacity(0.08),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (int index) {
                  final bool selected = _calculateSelectedIndex(context) == index;
                  final IconData iconData;
                  final IconData selectedIconData;
                  final String label;

                  switch (index) {
                    case 0:
                      iconData = Icons.home_outlined;
                      selectedIconData = Icons.home;
                      label = l10n.home;
                      break;
                    case 1:
                      iconData = Icons.fitness_center_outlined;
                      selectedIconData = Icons.fitness_center;
                      label = l10n.exercise;
                      break;
                    case 2:
                      iconData = Icons.restaurant_outlined;
                      selectedIconData = Icons.restaurant;
                      label = l10n.nutrition;
                      break;
                    case 3:
                      iconData = Icons.bedtime_outlined;
                      selectedIconData = Icons.bedtime;
                      label = l10n.sleep;
                      break;
                    default:
                      iconData = Icons.person_outline;
                      selectedIconData = Icons.person;
                      label = l10n.profile;
                  }

                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _onItemTapped(index, context),
                      child: Container(
                        height: compact ? 44 : 48,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.all(compact ? 4 : 6),
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: <Color>[
                                          Color(0xFF2E7D32),
                                          Color(0xFF43A047),
                                        ],
                                      )
                                    : null,
                                color: selected
                                    ? null
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: selected
                                    ? <BoxShadow>[
                                        BoxShadow(
                                          color: const Color(0xFF2E7D32).withOpacity(0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                selected ? selectedIconData : iconData,
                                size: compact ? 18 : 20,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF757575),
                              ),
                            ),
                            if (!compact) ...<Widget>[
                              SizedBox(height: 1),
                              Flexible(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 250),
                                  opacity: selected ? 1.0 : 0.0,
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFF757575),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    switch (location) {
      case RouteNames.home:
        return 0;
      case RouteNames.exercise:
        return 1;
      case RouteNames.nutrition:
        return 2;
      case RouteNames.sleep:
        return 3;
      case RouteNames.profile:
        return 4;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.exercise);
        break;
      case 2:
        context.go(RouteNames.nutrition);
        break;
      case 3:
        context.go(RouteNames.sleep);
        break;
      case 4:
        context.go(RouteNames.profile);
        break;
    }
  }
} 