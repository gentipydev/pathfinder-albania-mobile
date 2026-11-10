import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/agent/features/buddy/bloc/buddy_bloc.dart';
import 'package:travel_buddy/agent/features/buddy/bloc/buddy_event.dart';
import 'package:travel_buddy/agent/features/buddy/bloc/buddy_state.dart';
import 'package:travel_buddy/agent/ui/screens/buddy/buddy_screen.dart';
import 'package:travel_buddy/ui/screens/home/destinations_home_screen.dart';
import 'package:travel_buddy/agent/ui/screens/my_trips/my_trips_screen.dart';
import 'package:travel_buddy/agent/ui/screens/profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = <Widget>[
    HomeScreen(),
    BuddyScreen(),
    const MyTripsScreen(),
    ProfileScreen(),
  ];

  /// One-shot consume: when BuddyBloc emits a non-null `requestedTab` (e.g.,
  /// the trip detail "Refine with Buddy" button dispatches
  /// `BuddyOpenRefineRequested`), switch and dispatch `BuddyTabConsumed` so
  /// revisiting later doesn't re-trigger.
  void _onRequestedTab(BuildContext context, BuddyState s) {
    final v = s.requestedTab;
    if (v == null) return;
    if (v >= 0 && v < _screens.length && v != _currentIndex) {
      setState(() => _currentIndex = v);
    }
    context.read<BuddyBloc>().add(const BuddyTabConsumed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BuddyBloc, BuddyState>(
      listenWhen: (a, b) =>
          b.requestedTab != null && a.requestedTab != b.requestedTab,
      listener: _onRequestedTab,
      child: Scaffold(
        backgroundColor: $styles.colors.black,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                navigationBarTheme: NavigationBarThemeData(
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final isSelected = states.contains(WidgetState.selected);
                    return $styles.text.body.copyWith(
                      fontSize: 12,
                      color: isSelected ? $styles.colors.accent1 : $styles.colors.greyMedium,
                    );
                  }),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) => setState(() => _currentIndex = index),
                backgroundColor: $styles.colors.black,
                indicatorColor: $styles.colors.accent1.withValues(alpha: .15),
                surfaceTintColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.explore_outlined, color: $styles.colors.greyMedium),
                    selectedIcon: Icon(Icons.explore, color: $styles.colors.accent1),
                    label: 'Explore',
                    tooltip: 'Explore destinations',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.chat_bubble_outline, color: $styles.colors.greyMedium),
                    selectedIcon: Icon(Icons.chat_bubble, color: $styles.colors.accent1),
                    label: 'Buddy',
                    tooltip: 'Travel buddy chat',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.luggage_outlined, color: $styles.colors.greyMedium),
                    selectedIcon: Icon(Icons.luggage, color: $styles.colors.accent1),
                    label: 'My Trips',
                    tooltip: 'My trips',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline, color: $styles.colors.greyMedium),
                    selectedIcon: Icon(Icons.person, color: $styles.colors.accent1),
                    label: 'Profile',
                    tooltip: 'Profile settings',
                  ),
                ],
              ),
            ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
