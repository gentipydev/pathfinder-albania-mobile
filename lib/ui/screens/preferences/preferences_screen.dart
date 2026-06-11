import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_buddy/logic/preferences/preferences_service.dart';
import 'package:travel_buddy/ui/common/centered_box.dart';

class TravelerPersona {
  const TravelerPersona({
    required this.id,
    required this.emoji,
    required this.title,
    required this.tagline,
    required this.description,
    required this.lottiePath,
    required this.bgColor,
    required this.accentColor,
    required this.preferences,
  });

  final String id;
  final String emoji;
  final String title;
  final String tagline;
  final String description;
  final String lottiePath;
  final Color bgColor;
  final Color accentColor;
  final Map<String, dynamic> preferences;
}

final List<TravelerPersona> _personas = [
  const TravelerPersona(
    id: 'adventurer',
    emoji: '🧗',
    title: 'The Adventurer',
    tagline: 'Trails over tourist traps',
    description:
        'Budget-flexible · Hiking & wild nature · Rents a car · Guesthouses · Eats where locals eat',
    lottiePath: 'assets/lottie/adventurer.json',
    bgColor: Color(0xFF5C2E1F),
    accentColor: Color(0xFFA85A3C),
    preferences: {
      'budget': null,
      'travel_style': ['adventure', 'hiking', 'nature'],
      'accommodation': 'guesthouse',
      'transport': 'car',
      'pace': 'fast',
      'interests': ['hiking', 'outdoors', 'nature'],
      'food': [],
    },
  ),
  const TravelerPersona(
    id: 'explorer',
    emoji: '🏛',
    title: 'The Explorer',
    tagline: 'Every stone has a story',
    description:
        'Mid-range · History & ruins · Walks everywhere · Boutique hotels · Traditional local dishes',
    lottiePath: 'assets/lottie/explorer.json',
    bgColor: Color(0xFF444B9B),
    accentColor: Color(0xFF4F5FAE),
    preferences: {
      'budget': 'mid-range',
      'travel_style': ['cultural', 'history', 'architecture'],
      'accommodation': 'boutique',
      'transport': 'walking',
      'pace': 'slow',
      'interests': ['history', 'museums', 'architecture'],
      'food': ['local cuisine'],
    },
  ),
  const TravelerPersona(
    id: 'foodie',
    emoji: '🍽',
    title: 'The Foodie',
    tagline: 'Passport stamps taste better',
    description:
        'Mid-range to luxury · Restaurants are the destination · Taxi or public · City hotels',
    lottiePath: 'assets/lottie/foodie.json',
    bgColor: Color(0xFF5A3A14),
    accentColor: Color(0xFFC47A0A),
    preferences: {
      'budget': 'mid-range',
      'travel_style': ['food', 'culinary'],
      'accommodation': 'hotel',
      'transport': 'public',
      'pace': 'moderate',
      'interests': ['restaurants', 'markets', 'street food'],
      'food': [],
    },
  ),
  const TravelerPersona(
    id: 'beach_lover',
    emoji: '🏖',
    title: 'The Beach Lover',
    tagline: 'Salt water fixes everything',
    description:
        'Mid-range · Beaches & sunsets · Car or scooter · Seaside hotels or airbnb · Fresh seafood',
    lottiePath: 'assets/lottie/beach_lover.json',
    bgColor: Color(0xFF1E736D),
    accentColor: Color(0xFF3FA6B5),
    preferences: {
      'budget': 'mid-range',
      'travel_style': ['beach', 'relaxation', 'summer'],
      'accommodation': 'airbnb',
      'transport': 'car',
      'pace': 'slow',
      'interests': ['beaches', 'swimming', 'sunsets'],
      'food': ['seafood'],
    },
  ),
  const TravelerPersona(
    id: 'photographer',
    emoji: '📸',
    title: 'The Photographer',
    tagline: 'Golden hour is non-negotiable',
    description:
        'Mid-range · Scenic spots & hidden views · Car for flexibility · Slow mornings, long evenings',
    lottiePath: 'assets/lottie/photographer.json',
    bgColor: Color(0xFF3D2454),
    accentColor: Color(0xFF8E5BB3),
    preferences: {
      'budget': 'mid-range',
      'travel_style': ['photography', 'scenic', 'slow'],
      'accommodation': 'guesthouse',
      'transport': 'car',
      'pace': 'slow',
      'interests': ['photography', 'scenic spots', 'golden hour'],
      'food': [],
    },
  ),
  const TravelerPersona(
    id: 'anxious_traveler',
    emoji: '😰',
    title: 'The Anxious Traveler',
    tagline: 'First time for everything',
    description:
        'Budget-conscious · Needs clear simple guidance · Organised transport · Safe central hotels',
    lottiePath: 'assets/lottie/anxious_traveler.json',
    bgColor: Color(0xFF2E3F66),
    accentColor: Color(0xFF7E94BD),
    preferences: {
      'budget': 'mid-range',
      'travel_style': ['easy', 'guided', 'safe'],
      'accommodation': 'hotel',
      'transport': 'public',
      'pace': 'slow',
      'interests': ['safety', 'tourist sites', 'easy walks'],
      'food': [],
    },
  ),
];

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late final PageController _pageController;
  int _selectedIndex = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78, initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleStart() async {
    if (_loading) return;
    setState(() => _loading = true);
    final router = GoRouter.of(context);
    final persona = _personas[_selectedIndex];
    final service = GetIt.I<PreferencesService>();
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final body = Map<String, dynamic>.from(persona.preferences);
    body['language'] = settingsBloc.state.currentLocale ?? 'en';

    try {
      await service.savePreferencesMap(body, bearerToken: token);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    // Persona generation is non-blocking — continue regardless.
    try {
      await service.generatePersona(bearerToken: token);
    } catch (_) {/* swallow per spec */}

    if (!mounted) return;
    setState(() => _loading = false);
    router.go(ScreenPaths.home);
  }

  @override
  Widget build(BuildContext context) {
    final persona = _personas[_selectedIndex];
    return Scaffold(
      backgroundColor: $styles.colors.black,
      body: SafeArea(
        // Cap the persona carousel + controls on wide (web/tablet) windows so
        // the PageView's viewportFraction yields card-sized pages, not
        // screen-wide ones.
        child: CenteredBox(
          width: $styles.sizes.maxContentWidth3,
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
                child: Row(
                  children: [
                    Text(
                      $strings.preferencesPersonaSection,
                      style: $styles.text.h4.copyWith(
                        color: $styles.colors.offWhite,
                      ),
                    ),
                    IconButton(
                      onPressed: _showPersonaInfo,
                      padding: EdgeInsets.symmetric(
                        horizontal: $styles.insets.xs,
                      ),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: $styles.colors.offWhite.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, _) {
                    final page = _pageController.hasClients &&
                            _pageController.position.haveDimensions
                        ? (_pageController.page ?? 0.0)
                        : _selectedIndex.toDouble();
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: _personas.length,
                      onPageChanged: (i) => setState(() => _selectedIndex = i),
                      itemBuilder: (context, i) {
                        final delta = (page - i).clamp(-1.0, 1.0);
                        final scale = 1.0 - (delta.abs() * 0.08);
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(delta * 0.22)
                            ..scaleByDouble(scale, scale, 1.0, 1.0),
                          child: _PersonaCard(
                            persona: _personas[i],
                            isSelected: i == _selectedIndex,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: _personas.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: $styles.colors.accent1,
                  dotColor: $styles.colors.greyStrong,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                  spacing: 6,
                ),
              ),
              Gap($styles.insets.sm),
              SizedBox(
                height: 24,
                child: AnimatedSwitcher(
                  duration: $styles.times.pageTransition,
                  child: Text(
                    persona.tagline,
                    key: ValueKey(persona.id),
                    style: $styles.text.body.copyWith(
                      color: $styles.colors.offWhite,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all($styles.insets.md),
                child: _buildStartButton(persona),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPersonaInfo() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => Dialog(
        backgroundColor: $styles.colors.greyStrong,
        elevation: 0,
        insetPadding: EdgeInsets.all($styles.insets.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular($styles.corners.md),
        ),
        child: Padding(
          padding: EdgeInsets.all($styles.insets.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: $styles.colors.accent1,
                size: 28,
              ),
              Gap($styles.insets.sm),
              Text(
                $strings.preferencesPersonaInfoBody,
                style: $styles.text.body.copyWith(
                  color: $styles.colors.offWhite,
                  height: 1.5,
                ),
              ),
              Gap($styles.insets.md),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    $strings.preferencesPersonaInfoDismiss,
                    style: $styles.text.bodyBold.copyWith(
                      color: $styles.colors.accent1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.sm,
        vertical: $styles.insets.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: $styles.colors.offWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Gap($styles.insets.xs),
          Expanded(
            child: Text(
              $strings.preferencesScreenTitle,
              style: $styles.text.h2.copyWith(color: $styles.colors.offWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(TravelerPersona persona) {
    return AnimatedContainer(
      duration: $styles.times.fast,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: $styles.colors.accent1,
        borderRadius: BorderRadius.circular($styles.corners.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular($styles.corners.pill),
          onTap: _loading ? null : _handleStart,
          child: SizedBox(
            height: 56,
            child: Center(
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      $strings.preferencesPersonaUseButton.toUpperCase(),
                      style: $styles.text.btn.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.4,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonaCard extends StatefulWidget {
  const _PersonaCard({required this.persona, required this.isSelected});

  final TravelerPersona persona;
  final bool isSelected;

  @override
  State<_PersonaCard> createState() => _PersonaCardState();
}

class _PersonaCardState extends State<_PersonaCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant _PersonaCard old) {
    super.didUpdateWidget(old);
    _syncLottiePlayback();
  }

  void _syncLottiePlayback() {
    if (widget.isSelected) {
      if (!_lottieController.isAnimating &&
          _lottieController.duration != null) {
        _lottieController.repeat();
      }
    } else {
      if (_lottieController.isAnimating) {
        _lottieController.stop();
      }
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.isSelected ? 1.0 : 0.94,
      duration: $styles.times.fast,
      curve: Curves.easeOutBack,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: $styles.insets.md,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Flexible(
                flex: 5,
                child: Lottie.asset(
                  widget.persona.lottiePath,
                  controller: _lottieController,
                  fit: BoxFit.contain,
                  onLoaded: (composition) {
                    _lottieController.duration = composition.duration;
                    _syncLottiePlayback();
                  },
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      widget.persona.emoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: $styles.insets.md),
                child: Text(
                  widget.persona.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                flex: 3,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: $styles.insets.md),
                  child: Text(
                    widget.persona.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
