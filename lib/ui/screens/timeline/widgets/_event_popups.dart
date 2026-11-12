part of '../timeline_screen.dart';

class _EventPopups extends StatefulWidget {
  const _EventPopups({required this.currentEvent});
  final TimelineEvent? currentEvent;

  @override
  State<_EventPopups> createState() => _EventPopupsState();
}

class _EventPopupsState extends State<_EventPopups> {
  final _debouncer = Debouncer(500.animateMs);
  TimelineEvent? _eventToShow;

  @override
  void dispose() {
    _debouncer.reset();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _EventPopups oldWidget) {
    super.didUpdateWidget(oldWidget);
    _debouncer.call(showCardForCurrentYr);
  }

  void showCardForCurrentYr() {
    setState(() {
      _eventToShow = widget.currentEvent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final evt = _eventToShow;
    return TopCenter(
      child: ClipRect(
        child: IgnorePointerKeepSemantics(
          child: AnimatedSwitcher(
            duration: $styles.times.fast,
            // Top-aligned so cards of different heights don't shift while they cross-fade;
            // the outgoing card is hidden from screen readers so only the new one is announced.
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [
                for (final c in previous) ExcludeSemantics(child: c),
                if (current != null) current,
              ],
            ),
            child: evt == null
                ? SizedBox.shrink()
                : Semantics(
                    // Keyed here, on the switcher's direct child, so one event cross-fades into the next
                    // (with the key on the inner Animate the switcher never saw a new child).
                    key: ValueKey(evt.year),
                    liveRegion: true,
                    child: Animate(
                      effects: const [
                        SlideEffect(begin: Offset(0, -.1)),
                      ],
                      child: IntrinsicHeight(
                        child: SizedBox(
                          width: $styles.sizes.maxContentWidth3,
                          child: Padding(
                            padding: EdgeInsets.all($styles.insets.md),
                            child: TimelineEventCard(
                              text: evt.description,
                              year: evt.year,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
