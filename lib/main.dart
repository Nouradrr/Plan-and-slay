// Plan & Slay — Sprint 3 latest targeted corrections (single main.dart for DartPad)
// ignore_for_file: prefer_const_constructors

import 'dart:math' as math;

import 'package:flutter/material.dart';

// ======================================================================
// main.dart
// ======================================================================
void main() => runApp(const PlanAndSlayApp());

class PlanAndSlayApp extends StatelessWidget {
  const PlanAndSlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan & Slay',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const AppShell(),
    );
  }
}

/// Adaptive shell: desktop sidebar, and phone/tablet app bar, drawer and bottom navigation.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _sidebarCollapsed = false;

  // Screens are created without `const` on purpose so they rebuild
  // every time the app state changes.
  Widget _screenFor(AppScreen s) => switch (s) {
    AppScreen.home => HomeScreen(),
    AppScreen.createPlan => CreatePlanScreen(),
    AppScreen.groupPlanning => GroupPlanningScreen(),
    AppScreen.finalizedPlan => FinalizedPlanScreen(),
    AppScreen.moodboard => MoodboardScreen(),
    AppScreen.styleVoting => StyleVotingScreen(),
    AppScreen.outfitPlanner => OutfitPlannerScreen(),
    AppScreen.packingList => PackingListScreen(),
    AppScreen.myPlans => MyPlansScreen(),
  };

  static int _bottomIndex(AppScreen s) => switch (s) {
    AppScreen.home => 0,
    AppScreen.createPlan => 1,
    AppScreen.groupPlanning || AppScreen.finalizedPlan => 2,
    AppScreen.moodboard ||
    AppScreen.styleVoting ||
    AppScreen.outfitPlanner ||
    AppScreen.packingList => 3,
    AppScreen.myPlans => 4,
  };

  void _onBottomTap(int i) {
    switch (i) {
      case 0:
        appState.goTo(AppScreen.home);
      case 1:
        appState.goTo(AppScreen.createPlan);
      case 2:
        final plan = appState.selectedPlan;
        if (plan == null) {
          appState.goTo(AppScreen.groupPlanning);
        } else {
          appState.openPlan(plan);
        }
      case 3:
        appState.goTo(AppScreen.moodboard);
      case 4:
        appState.goTo(AppScreen.myPlans);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final wide = MediaQuery.sizeOf(context).width >= 960; // Desktop layout
        final body = AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          layoutBuilder: (current, previous) => Stack(
            fit: StackFit.expand,
            children: [...previous, if (current != null) current],
          ),
          child: KeyedSubtree(
            key: ValueKey(appState.screen),
            child: _screenFor(appState.screen),
          ),
        );

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: _sidebarCollapsed ? 76 : 264,
                  child: SideNav(
                    collapsed: _sidebarCollapsed,
                    onToggle: () =>
                        setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                  ),
                ),
                Container(width: 1, color: AppColors.line),
                Expanded(child: SafeArea(child: body)),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.porcelain,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            title: const Logo(size: 24),
          ),
          drawer: const Drawer(
            backgroundColor: AppColors.porcelain,
            child: SafeArea(child: NavList(inDrawer: true)),
          ),
          body: body,
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: AppColors.blush,
            selectedIndex: _bottomIndex(appState.screen),
            onDestinationSelected: _onBottomTap,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                label: 'Create',
              ),
              NavigationDestination(
                icon: Icon(Icons.how_to_vote_outlined),
                label: 'Plan',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                label: 'Style',
              ),
              NavigationDestination(
                icon: Icon(Icons.collections_bookmark_outlined),
                label: 'My Plans',
              ),
            ],
          ),
        );
      },
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Plan ', style: AppText.display(size)),
          TextSpan(
            text: '&',
            style: AppText.display(size, color: AppColors.mauve),
          ),
          TextSpan(text: ' Slay', style: AppText.display(size)),
        ],
      ),
    );
  }
}

class SideNav extends StatelessWidget {
  const SideNav({super.key, required this.collapsed, required this.onToggle});
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(collapsed ? 8 : 18, 18, 8, 2),
              child: Row(
                children: [
                  if (!collapsed)
                    const Expanded(child: Logo(size: 25))
                  else
                    const Expanded(
                      child: Icon(Icons.auto_awesome, color: AppColors.mauve),
                    ),
                  IconButton(
                    tooltip: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
                    onPressed: onToggle,
                    icon: Icon(
                      collapsed ? Icons.chevron_right : Icons.chevron_left,
                    ),
                  ),
                ],
              ),
            ),
            if (!collapsed)
              const Padding(
                padding: EdgeInsets.fromLTRB(22, 0, 20, 12),
                child: Text(
                  'Plan together, dress the part.',
                  style: AppText.small,
                ),
              ),
            Expanded(child: NavList(collapsed: collapsed)),
            if (!collapsed)
              ListenableBuilder(
                listenable: appState,
                builder: (context, _) {
                  final plan = appState.selectedPlan;
                  if (plan == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Material(
                      color: plan.type.tint,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => appState.openPlan(plan),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Current plan', style: AppText.small),
                              const SizedBox(height: 4),
                              Text(
                                '${plan.type.emoji}  ${plan.name}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.strong.copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                plan.isFinalized ? 'Confirmed' : 'Voting open',
                                style: AppText.small,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// All nine screens, grouped so planning and style read as one journey.
class NavList extends StatelessWidget {
  const NavList({super.key, this.inDrawer = false, this.collapsed = false});
  final bool inDrawer;
  final bool collapsed;

  static const _groups = <(String, List<AppScreen>)>[
    (
      'Plan',
      [AppScreen.home, AppScreen.groupPlanning, AppScreen.finalizedPlan],
    ),
    (
      'Slay',
      [
        AppScreen.moodboard,
        AppScreen.styleVoting,
        AppScreen.outfitPlanner,
        AppScreen.packingList,
      ],
    ),
    ('Yours', [AppScreen.myPlans]),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          if (inDrawer)
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Logo(size: 26),
            ),
          for (final group in _groups) ...[
            if (!collapsed)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
                child: Text(
                  group.$1,
                  style: AppText.small.copyWith(fontWeight: FontWeight.w700),
                ),
              )
            else
              const SizedBox(height: 16),
            for (final s in group.$2) _item(context, s),
          ],
        ],
      ),
    );
  }

  Widget _item(BuildContext context, AppScreen s) {
    final selected = appState.screen == s;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? AppColors.blush : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            appState.goTo(s);
            if (inDrawer) Navigator.of(context).pop();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 12 : 14,
              vertical: 11,
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  s.icon,
                  size: 20,
                  color: selected ? AppColors.ink : AppColors.inkSoft,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      s.label,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: selected ? AppColors.ink : AppColors.inkSoft,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// theme.dart
// ======================================================================
/// Soft pastel palette on a cool porcelain base.
class AppColors {
  AppColors._();
  static const porcelain = Color(0xFFF7F5F8); // page background
  static const mist = Color(0xFFEEEAF1); // quiet surfaces
  static const line = Color(0xFFE4DFE8); // borders
  static const ink = Color(0xFF2A2433); // main text, primary buttons
  static const inkSoft = Color(0xFF564E61);
  static const muted = Color(0xFF8C8496);
  static const mauve = Color(0xFFB05F82); // accent: votes, selection
  static const blush = Color(0xFFF6D6DC);
  static const lavender = Color(0xFFDCD5F0);
  static const sky = Color(0xFFCFE1F2);
  static const mint = Color(0xFFCFE8DC);
  static const butter = Color(0xFFF7EAC0);
}

class AppText {
  AppText._();

  /// Fashion-magazine display face for titles.
  static TextStyle display(double size, {Color color = AppColors.ink}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.12,
      );

  static const muted = TextStyle(
    color: AppColors.muted,
    fontSize: 14,
    height: 1.45,
  );
  static const small = TextStyle(
    color: AppColors.muted,
    fontSize: 12.5,
    height: 1.4,
  );
  static const strong = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: AppColors.ink,
  );
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.mauve,
      surface: AppColors.porcelain,
      primary: AppColors.ink,
      secondary: AppColors.mauve,
    ),
    scaffoldBackgroundColor: AppColors.porcelain,
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.line),
  );
  const buttonText = TextStyle(fontWeight: FontWeight.w700, fontSize: 15);
  const buttonPadding = EdgeInsets.symmetric(horizontal: 22, vertical: 16);

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.mauve, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        padding: buttonPadding,
        shape: const StadiumBorder(),
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.ink),
        padding: buttonPadding,
        shape: const StadiumBorder(),
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.mauve,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );
}

// ======================================================================
// models.dart
// ======================================================================
/// Kinds of activities a group can plan.
enum ActivityType {
  holiday('Holiday', '🏖️', Color(0xFFCFE1F2)),
  dinner('Dinner', '🍽️', Color(0xFFF6D6DC)),
  concert('Concert', '🎤', Color(0xFFDCD5F0)),
  cafe('Café outing', '☕', Color(0xFFF7EAC0)),
  party('Party', '🎉', Color(0xFFF8DCCB)),
  dayTrip('Day trip', '🌿', Color(0xFFCFE8DC)),
  custom('Custom activity', '✨', Color(0xFFEEEAF1));

  const ActivityType(this.label, this.emoji, this.tint);
  final String label;
  final String emoji;
  final Color tint;
}

/// Currency is a display and proposal setting, not an exchange-rate service.
/// Amounts in existing suggestions are never automatically converted.
enum BudgetCurrency {
  krw('KRW', '₩'),
  eur('EUR', '€'),
  usd('USD', r'$'),
  jpy('JPY', '¥'),
  gbp('GBP', '£');

  const BudgetCurrency(this.code, this.symbol);
  final String code;
  final String symbol;
}

/// The four things a group votes on.
enum OptionCategory {
  destination('Where', Icons.place_outlined, 'e.g. Haeundae Beach, Busan'),
  dates('When', Icons.calendar_today_outlined, 'e.g. Fri 6 Nov, 7 pm'),
  activity(
    'What we’ll do',
    Icons.auto_awesome_outlined,
    'e.g. Sunset walk at Gwangalli',
  ),
  budget(
    'Budget',
    Icons.account_balance_wallet_outlined,
    'e.g. ₩60,000 per person',
  );

  const OptionCategory(this.label, this.icon, this.hint);
  final String label;
  final IconData icon;
  final String hint;
}

enum PlanStatus { planning, finalized }

class Friend {
  const Friend(this.id, this.name, this.color);
  final String id;
  final String name;
  final Color color;

  String get initial =>
      name.isEmpty ? '?' : name.characters.first.toUpperCase();
}

/// One suggestion in the group vote (a place, a date, an activity, a budget).
class PlanOption {
  PlanOption({
    required this.id,
    required this.category,
    required this.title,
    required this.suggestedBy,
    this.note,
    Set<String>? voterIds,
  }) : voterIds = voterIds ?? <String>{};

  final String id;
  final OptionCategory category;
  final String title;
  final String? note;
  final String suggestedBy;
  final Set<String> voterIds;
}

class ChecklistItem {
  ChecklistItem(this.title, {this.assigneeId, this.done = false});
  final String title;
  String? assigneeId;
  bool done;
}

class PackingItem {
  PackingItem(this.title, this.category, {this.packed = false});
  String title;
  final String category;
  bool packed;
}

class MoodTileData {
  const MoodTileData(this.label, this.icon, {this.height = 1.0, this.imageUrl});
  final String label;
  final IconData icon;

  /// Relative tile height for the Pinterest-style collage.
  final double height;

  /// Optional photo (Stage 2+). Tiles fall back to a palette gradient.
  final String? imageUrl;
}

class Outfit {
  const Outfit(
    this.id,
    this.name,
    this.occasion,
    this.pieces,
    this.accessories,
  );
  final String id;
  final String name;
  final String occasion;
  final List<String> pieces;
  final List<String> accessories;
}

class Moodboard {
  const Moodboard({
    required this.id,
    required this.name,
    required this.tagline,
    required this.palette,
    required this.keywords,
    required this.tiles,
    required this.outfits,
  });

  final String id;
  final String name;
  final String tagline;
  final List<Color> palette;
  final List<String> keywords;
  final List<MoodTileData> tiles;
  final List<Outfit> outfits;
}

/// A reusable user-defined style name and colour palette for this plan.
/// All custom data remains in memory in this DartPad-only prototype.
class CustomStylePalette {
  const CustomStylePalette({
    required this.id,
    required this.name,
    required this.colors,
  });
  final String id;
  final String name;
  final List<Color> colors;
}

class Plan {
  Plan({
    required this.id,
    required this.name,
    required this.type,
    required this.memberIds,
    this.status = PlanStatus.planning,
    this.currency = BudgetCurrency.krw,
    this.customActivityName,
    this.selectedMoodboardId,
    List<Moodboard>? customMoodboards,
    List<CustomStylePalette>? customStylePalettes,
    this.season,
    this.weather,
    this.tripDays,
    List<PlanOption>? options,
    Map<OptionCategory, PlanOption>? confirmed,
    List<ChecklistItem>? checklist,
    Map<String, String>? styleVotes,
    List<PackingItem>? packing,
  }) : options = options ?? [],
       confirmed = confirmed ?? {},
       checklist = checklist ?? [],
       styleVotes = styleVotes ?? {},
       packing = packing ?? [],
       customMoodboards = customMoodboards ?? [],
       customStylePalettes = customStylePalettes ?? [];

  final String id;
  String name;
  ActivityType type;
  final List<String> memberIds; // first member is the host
  PlanStatus status;
  BudgetCurrency currency;
  String? customActivityName;
  final List<Moodboard> customMoodboards;
  final List<CustomStylePalette> customStylePalettes;

  String get activityLabel =>
      type == ActivityType.custom && customActivityName != null
      ? customActivityName!
      : type.label;

  final List<PlanOption> options;
  final Map<OptionCategory, PlanOption> confirmed;
  final List<ChecklistItem> checklist;

  /// memberId -> moodboardId
  final Map<String, String> styleVotes;
  String? selectedMoodboardId;
  final List<PackingItem> packing;

  // Sample context used by the moodboard and packing list (Stage 1).
  String? season;
  String? weather;
  int? tripDays;

  bool get isFinalized => status == PlanStatus.finalized;

  List<PlanOption> optionsFor(OptionCategory c) =>
      options.where((o) => o.category == c).toList();

  String get whereLabel =>
      confirmed[OptionCategory.destination]?.title ?? 'Place to be decided';
  String get whenLabel =>
      confirmed[OptionCategory.dates]?.title ?? 'Date to be decided';
}

// ======================================================================
// sample_data.dart
// ======================================================================
/// The person using the app.
const String meId = 'me';

const avatarColors = <Color>[
  Color(0xFFB05F82),
  Color(0xFF6F8FB0),
  Color(0xFF8E7BB8),
  Color(0xFF7FA38A),
  Color(0xFFC79A55),
  Color(0xFF5F8C8A),
  Color(0xFFC57E66),
  Color(0xFF857468),
];

List<Friend> sampleContacts() => [Friend(meId, 'You', avatarColors[0])];

// ---------------------------------------------------------------------------
// Moodboards (predefined sample-style recommendations for the prototype)
// ---------------------------------------------------------------------------

const coastalChic = Moodboard(
  id: 'coastal-chic',
  name: 'Coastal Chic',
  tagline: 'Breezy linen, sea blues and a little gold for golden hour.',
  palette: [
    Color(0xFFEDE3D3),
    Color(0xFF9DB9C9),
    Color(0xFFD9C3A5),
    Color(0xFF2F4858),
  ],
  keywords: ['Linen', 'Stripes', 'Gold accents'],
  tiles: [
    MoodTileData('Linen shirt dress', Icons.dry_cleaning_outlined, height: 1.5),
    MoodTileData('Straw tote', Icons.shopping_bag_outlined),
    MoodTileData('Gold hoops', Icons.diamond_outlined, height: 0.8),
    MoodTileData('Striped knit', Icons.checkroom_outlined, height: 1.2),
    MoodTileData('Leather sandals', Icons.directions_walk, height: 0.9),
  ],
  outfits: [
    Outfit(
      'coastal-1',
      'Seaside lunch',
      'Daytime at Haeundae',
      ['White linen shirt', 'Navy wide-leg trousers'],
      ['Straw tote', 'Gold hoops', 'Leather sandals'],
    ),
    Outfit(
      'coastal-2',
      'Golden hour',
      'Evening at Gwangalli',
      ['Blue striped knit top', 'Cream midi skirt'],
      ['Silk scarf', 'Woven flats'],
    ),
    Outfit(
      'coastal-3',
      'Village explorer',
      'Gamcheon Culture Village',
      ['Linen shirt dress', 'Light cardigan'],
      ['Bucket bag', 'White sneakers', 'Sunglasses'],
    ),
  ],
);

const beachCasual = Moodboard(
  id: 'beach-casual',
  name: 'Beach Casual',
  tagline:
      'Sun-ready basics you can wear straight from the sand to the market.',
  palette: [
    Color(0xFFF28C7A),
    Color(0xFF7FC8C3),
    Color(0xFFEED9B7),
    Color(0xFFF6C667),
  ],
  keywords: ['Easy', 'Denim', 'Sun-proof'],
  tiles: [
    MoodTileData('Bikini & cover-up', Icons.beach_access_outlined, height: 1.3),
    MoodTileData('Denim cut-offs', Icons.checkroom_outlined),
    MoodTileData('Bucket hat', Icons.wb_sunny_outlined, height: 0.9),
    MoodTileData('Oversized tee', Icons.dry_cleaning_outlined, height: 1.3),
    MoodTileData('Slides', Icons.directions_walk, height: 0.8),
  ],
  outfits: [
    Outfit(
      'beach-1',
      'Beach day',
      'Haeundae Beach',
      ['Ribbed bikini', 'Oversized white tee', 'Denim cut-offs'],
      ['Bucket hat', 'Slides', 'Sunglasses'],
    ),
    Outfit(
      'beach-2',
      'Market stroll',
      'Jagalchi Market',
      ['Cotton tank top', 'Cargo shorts'],
      ['Crossbody bag', 'Canvas sneakers'],
    ),
    Outfit(
      'beach-3',
      'Bonfire night',
      'Beach at night',
      ['Hoodie', 'Linen drawstring shorts'],
      ['Shell necklace', 'Flip-flops'],
    ),
  ],
);

const minimalistSummer = Moodboard(
  id: 'minimal-summer',
  name: 'Minimalist Summer',
  tagline: 'Clean lines, neutral tones and pieces that all mix together.',
  palette: [
    Color(0xFFE9E4DC),
    Color(0xFFCBBBA4),
    Color(0xFF9A958F),
    Color(0xFF2B2B2B),
  ],
  keywords: ['Neutral', 'Capsule', 'Effortless'],
  tiles: [
    MoodTileData('White tank top', Icons.dry_cleaning_outlined, height: 1.2),
    MoodTileData('Wide trousers', Icons.checkroom_outlined, height: 1.4),
    MoodTileData('Minimal watch', Icons.watch_outlined, height: 0.8),
    MoodTileData('Canvas tote', Icons.shopping_bag_outlined),
    MoodTileData('Black slides', Icons.directions_walk, height: 0.9),
  ],
  outfits: [
    Outfit(
      'minimal-1',
      'Clean lines',
      'Daytime sightseeing',
      ['White tank top', 'Oat wide-leg trousers'],
      ['Canvas tote', 'Minimal watch', 'White sneakers'],
    ),
    Outfit(
      'minimal-2',
      'Seafood dinner',
      'Evening out',
      ['Black slip dress', 'Cropped linen blazer'],
      ['Thin gold chain', 'Black sandals'],
    ),
    Outfit(
      'minimal-3',
      'Travel day',
      'On the KTX',
      ['Grey knit polo', 'Straight-leg jeans'],
      ['Leather backpack', 'Loafers'],
    ),
  ],
);

const elegantChic = Moodboard(
  id: 'elegant-chic',
  name: 'Elegant Chic',
  tagline: 'Satin, pearls and tailoring for a dinner worth dressing up for.',
  palette: [
    Color(0xFFEADBC8),
    Color(0xFFA08C7D),
    Color(0xFFC9A45C),
    Color(0xFF4A3F38),
  ],
  keywords: ['Satin', 'Pearls', 'Tailored'],
  tiles: [
    MoodTileData('Satin blouse', Icons.dry_cleaning_outlined, height: 1.4),
    MoodTileData('Pearl earrings', Icons.diamond_outlined, height: 0.8),
    MoodTileData('Tailored trousers', Icons.checkroom_outlined, height: 1.3),
    MoodTileData('Mini clutch', Icons.shopping_bag_outlined),
    MoodTileData('Heeled mules', Icons.directions_walk, height: 0.9),
  ],
  outfits: [
    Outfit(
      'elegant-1',
      'Birthday toast',
      'Dinner',
      ['Champagne satin blouse', 'Tailored black trousers'],
      ['Pearl earrings', 'Heeled mules', 'Mini clutch'],
    ),
    Outfit(
      'elegant-2',
      'Polished knit',
      'Dinner',
      ['Fine-knit cardigan set', 'Pleated midi skirt'],
      ['Gold watch', 'Slingback heels'],
    ),
    Outfit(
      'elegant-3',
      'Smart tailoring',
      'Dinner and drinks',
      ['Ivory blazer', 'Silk camisole', 'Straight trousers'],
      ['Gold chain', 'Pointed flats'],
    ),
  ],
);

const allBlack = Moodboard(
  id: 'all-black',
  name: 'All Black',
  tagline: 'One colour, many textures. Easy to coordinate as a group.',
  palette: [
    Color(0xFF1F1D1C),
    Color(0xFF3A3735),
    Color(0xFF8F9196),
    Color(0xFF5B5754),
  ],
  keywords: ['Monochrome', 'Leather', 'Silver'],
  tiles: [
    MoodTileData('Black slip dress', Icons.dry_cleaning_outlined, height: 1.5),
    MoodTileData('Leather jacket', Icons.checkroom_outlined, height: 1.1),
    MoodTileData('Silver jewellery', Icons.diamond_outlined, height: 0.8),
    MoodTileData('Ankle boots', Icons.directions_walk),
    MoodTileData('Sleek bag', Icons.shopping_bag_outlined, height: 0.9),
  ],
  outfits: [
    Outfit(
      'black-1',
      'Monochrome night',
      'Dinner',
      ['Black slip dress', 'Leather jacket'],
      ['Silver hoops', 'Ankle boots'],
    ),
    Outfit(
      'black-2',
      'Sharp suit',
      'Dinner',
      ['Black blazer', 'Black turtleneck', 'Straight-leg trousers'],
      ['Silver chain', 'Loafers'],
    ),
    Outfit(
      'black-3',
      'Soft black',
      'Dinner and dessert',
      ['Black knit dress', 'Long wool coat'],
      ['Sleek shoulder bag', 'Kitten heels'],
    ),
  ],
);

const romanticDinner = Moodboard(
  id: 'romantic-dinner',
  name: 'Romantic Dinner',
  tagline: 'Florals, ribbons and soft pinks with a touch of burgundy.',
  palette: [
    Color(0xFFF2C9CC),
    Color(0xFFD98E9A),
    Color(0xFFF1E3D3),
    Color(0xFF7E2E3B),
  ],
  keywords: ['Florals', 'Ribbons', 'Soft pink'],
  tiles: [
    MoodTileData(
      'Floral midi dress',
      Icons.local_florist_outlined,
      height: 1.5,
    ),
    MoodTileData('Ribbon hair clip', Icons.auto_awesome_outlined, height: 0.8),
    MoodTileData('Soft cardigan', Icons.checkroom_outlined, height: 1.1),
    MoodTileData('Pearl necklace', Icons.diamond_outlined),
    MoodTileData('Mary Janes', Icons.directions_walk, height: 0.9),
  ],
  outfits: [
    Outfit(
      'romantic-1',
      'Rosé evening',
      'Dinner',
      ['Floral midi dress', 'Cropped cardigan'],
      ['Pearl necklace', 'Mary Janes'],
    ),
    Outfit(
      'romantic-2',
      'Ribbon details',
      'Dinner',
      ['Blush blouse with bow', 'Cream satin skirt'],
      ['Ribbon hair clip', 'Ballet flats'],
    ),
    Outfit(
      'romantic-3',
      'Burgundy mood',
      'Dinner and cake',
      ['Burgundy knit top', 'Lace-trim skirt'],
      ['Heart pendant', 'Strappy heels'],
    ),
  ],
);

const koreanStreetwear = Moodboard(
  id: 'streetwear',
  name: 'Korean Streetwear',
  tagline: 'Relaxed layers and chunky sneakers made for walking Seongsu.',
  palette: [
    Color(0xFF6B6E4E),
    Color(0xFFC7B68E),
    Color(0xFFA9A9A4),
    Color(0xFF2B2B2B),
  ],
  keywords: ['Oversized', 'Layers', 'Sneakers'],
  tiles: [
    MoodTileData('Oversized hoodie', Icons.dry_cleaning_outlined, height: 1.3),
    MoodTileData('Cargo pants', Icons.checkroom_outlined, height: 1.4),
    MoodTileData('Ball cap', Icons.sports_baseball_outlined, height: 0.8),
    MoodTileData('Chunky sneakers', Icons.directions_walk),
    MoodTileData('Mini crossbody', Icons.shopping_bag_outlined, height: 0.9),
  ],
  outfits: [
    Outfit(
      'street-1',
      'Seongsu explorer',
      'Café hopping',
      ['Oversized hoodie', 'Cargo pants'],
      ['Ball cap', 'Chunky sneakers', 'Mini crossbody'],
    ),
    Outfit(
      'street-2',
      'Layered fit',
      'Pop-up stores',
      ['Graphic tee', 'Nylon track jacket', 'Wide jeans'],
      ['Beanie', 'Silver rings'],
    ),
    Outfit(
      'street-3',
      'Clean street',
      'Afternoon out',
      ['Varsity jacket', 'White tee', 'Black trousers'],
      ['Tote bag', 'Retro sneakers'],
    ),
  ],
);

const scandiMinimalist = Moodboard(
  id: 'scandi',
  name: 'Scandinavian Minimalist',
  tagline: 'Oat, stone and sage. Calm, cosy and quietly put together.',
  palette: [
    Color(0xFFE5DACB),
    Color(0xFFA7B5A0),
    Color(0xFFD0C6B8),
    Color(0xFF5E5A55),
  ],
  keywords: ['Knits', 'Neutrals', 'Cosy'],
  tiles: [
    MoodTileData('Oversized knit', Icons.checkroom_outlined, height: 1.4),
    MoodTileData('Straight jeans', Icons.dry_cleaning_outlined, height: 1.2),
    MoodTileData('Wool scarf', Icons.waves, height: 0.8),
    MoodTileData('Structured tote', Icons.shopping_bag_outlined),
    MoodTileData('Leather loafers', Icons.directions_walk, height: 0.9),
  ],
  outfits: [
    Outfit(
      'scandi-1',
      'Oat and stone',
      'Café hopping',
      ['Oversized knit', 'Straight jeans'],
      ['Leather loafers', 'Structured tote'],
    ),
    Outfit(
      'scandi-2',
      'Soft tailoring',
      'Gallery visit',
      ['Grey wool blazer', 'Cream turtleneck', 'Wide trousers'],
      ['Wool scarf', 'Minimal watch'],
    ),
    Outfit(
      'scandi-3',
      'Weekend calm',
      'Afternoon out',
      ['Striped long-sleeve tee', 'Barrel jeans'],
      ['Canvas tote', 'White sneakers'],
    ),
  ],
);

const softGirl = Moodboard(
  id: 'soft-girl',
  name: 'Soft Girl',
  tagline: 'Pastel knits, bows and pleats — very photogenic in a café window.',
  palette: [
    Color(0xFFF6C9D7),
    Color(0xFFD9C8EE),
    Color(0xFFF3E8DA),
    Color(0xFFC3DDF2),
  ],
  keywords: ['Pastel', 'Bows', 'Pleats'],
  tiles: [
    MoodTileData('Cropped cardigan', Icons.checkroom_outlined, height: 1.3),
    MoodTileData('Hair bows', Icons.auto_awesome_outlined, height: 0.8),
    MoodTileData('Pleated skirt', Icons.dry_cleaning_outlined, height: 1.4),
    MoodTileData('Shoulder bag', Icons.shopping_bag_outlined),
    MoodTileData('Platform sneakers', Icons.directions_walk, height: 0.9),
  ],
  outfits: [
    Outfit(
      'soft-1',
      'Pastel café date',
      'Café hopping',
      ['Cropped pink cardigan', 'Pleated mini skirt'],
      ['Hair bows', 'Platform sneakers'],
    ),
    Outfit(
      'soft-2',
      'Cloud day',
      'Photo walk',
      ['Lilac babydoll top', 'White wide jeans'],
      ['Pearl clips', 'Shoulder bag'],
    ),
    Outfit(
      'soft-3',
      'Sweet knit',
      'Dessert stop',
      ['Baby-blue knit vest', 'Frilled blouse', 'Cream skirt'],
      ['Heart earrings', 'Mary Janes'],
    ),
  ],
);

// These built-in seasonal templates use the same tiles and outfits as existing
// moodboards, so Style Voting and Outfit Planner need no new UI or workflow.
const winterLayers = Moodboard(
  id: 'winter-layers',
  name: 'Winter Layers',
  tagline: 'Warm coats, soft sweaters, scarves and sturdy boots for cold days.',
  palette: [
    Color(0xFFE6E2DD),
    Color(0xFFB9C8D2),
    Color(0xFF887D77),
    Color(0xFF374452),
  ],
  keywords: ['Wool coats', 'Chunky knits', 'Scarves'],
  tiles: [
    MoodTileData('Long wool coat', Icons.checkroom_outlined, height: 1.4),
    MoodTileData('Chunky sweater', Icons.dry_cleaning_outlined, height: 1.2),
    MoodTileData('Warm scarf', Icons.waves, height: 0.9),
    MoodTileData('Insulated boots', Icons.directions_walk, height: 1.1),
    MoodTileData('Knit gloves', Icons.back_hand_outlined, height: 0.8),
  ],
  outfits: [
    Outfit(
      'winter-layers-1',
      'Winter explorer',
      'Cold-weather sightseeing',
      ['Long wool coat', 'Cable-knit sweater', 'Thermal top', 'Warm trousers'],
      ['Wool scarf', 'Insulated ankle boots', 'Knit gloves'],
    ),
    Outfit(
      'winter-layers-2',
      'Cozy café stop',
      'Winter cafés and city strolls',
      ['Puffer jacket', 'Turtleneck sweater', 'Straight-leg jeans'],
      ['Beanie', 'Winter boots', 'Crossbody bag'],
    ),
    Outfit(
      'winter-layers-3',
      'Cold evening',
      'Dinner on a winter trip',
      [
        'Tailored wool coat',
        'Fine-knit sweater',
        'Thick midi skirt',
        'Warm tights',
      ],
      ['Soft scarf', 'Leather winter boots', 'Gloves'],
    ),
  ],
);

const winterCity = Moodboard(
  id: 'winter-city',
  name: 'Winter City Chic',
  tagline: 'Structured coats, cozy layers and boots in cool city neutrals.',
  palette: [
    Color(0xFFDBD9D2),
    Color(0xFF9CA8B4),
    Color(0xFF5A6472),
    Color(0xFF292E38),
  ],
  keywords: ['Tailored coat', 'Turtlenecks', 'Winter boots'],
  tiles: [
    MoodTileData('Tailored winter coat', Icons.checkroom_outlined, height: 1.4),
    MoodTileData('Fine-knit turtleneck', Icons.dry_cleaning_outlined),
    MoodTileData('Wide wool trousers', Icons.checkroom_outlined, height: 1.2),
    MoodTileData('Leather boots', Icons.directions_walk),
    MoodTileData('Cashmere scarf', Icons.waves, height: 0.8),
  ],
  outfits: [
    Outfit(
      'winter-city-1',
      'City layers',
      'Winter museum and shopping day',
      ['Long tailored coat', 'Turtleneck sweater', 'Wool trousers'],
      ['Leather winter boots', 'Cashmere scarf', 'Structured tote'],
    ),
    Outfit(
      'winter-city-2',
      'Snowy streets',
      'Cold day walking tour',
      ['Warm down jacket', 'Thermal long-sleeve top', 'Fleece-lined trousers'],
      ['Waterproof boots', 'Warm beanie', 'Gloves'],
    ),
    Outfit(
      'winter-city-3',
      'Evening elegance',
      'Dinner in winter',
      ['Wool wrap coat', 'Ribbed knit dress', 'Thermal tights'],
      ['Knee-high boots', 'Soft scarf', 'Crossbody bag'],
    ),
  ],
);

const alpineSki = Moodboard(
  id: 'alpine-ski',
  name: 'Alpine Ski',
  tagline:
      'Insulated ski jackets, technical thermals and snow-ready accessories.',
  palette: [
    Color(0xFFF0F4F5),
    Color(0xFFB8C9DA),
    Color(0xFF6A8199),
    Color(0xFF293B50),
  ],
  keywords: ['Ski jacket', 'Thermal layers', 'Snow boots'],
  tiles: [
    MoodTileData('Insulated ski jacket', Icons.ac_unit, height: 1.5),
    MoodTileData('Thermal base layers', Icons.checkroom_outlined, height: 1.1),
    MoodTileData('Ski trousers', Icons.dry_cleaning_outlined, height: 1.3),
    MoodTileData('Snow goggles', Icons.visibility_outlined, height: 0.8),
    MoodTileData('Snow boots', Icons.directions_walk),
  ],
  outfits: [
    Outfit(
      'alpine-ski-1',
      'On the slopes',
      'Skiing and snowboarding',
      ['Waterproof ski jacket', 'Insulated ski trousers', 'Thermal base layer'],
      ['Ski goggles', 'Ski gloves', 'Helmet', 'Warm ski socks'],
    ),
    Outfit(
      'alpine-ski-2',
      'Lift to lodge',
      'Cold mountain travel',
      ['Down jacket', 'Fleece mid-layer', 'Thermal leggings'],
      ['Snow boots', 'Knit hat', 'Neck warmer'],
    ),
    Outfit(
      'alpine-ski-3',
      'Snow walk',
      'Snowy resort afternoon',
      ['Insulated parka', 'Wool sweater', 'Fleece-lined trousers'],
      ['Waterproof snow boots', 'Thick scarf', 'Gloves'],
    ),
  ],
);

const apresSki = Moodboard(
  id: 'apres-ski',
  name: 'Après-Ski Cozy',
  tagline: 'Mountain lodge knits, padded coats and snug snow boots.',
  palette: [
    Color(0xFFF0E4D4),
    Color(0xFFC7AFA0),
    Color(0xFF947A72),
    Color(0xFF423E45),
  ],
  keywords: ['Cable knits', 'Puffer coats', 'Warm layers'],
  tiles: [
    MoodTileData(
      'Cable-knit sweater',
      Icons.dry_cleaning_outlined,
      height: 1.4,
    ),
    MoodTileData('Oversized puffer', Icons.checkroom_outlined, height: 1.2),
    MoodTileData('Fleece-lined leggings', Icons.checkroom_outlined),
    MoodTileData('Faux-fur lined boots', Icons.directions_walk),
    MoodTileData('Wool beanie', Icons.ac_unit, height: 0.8),
  ],
  outfits: [
    Outfit(
      'apres-1',
      'Lodge lounge',
      'Après-ski hot chocolate',
      ['Cable-knit sweater', 'Thermal leggings', 'Long puffer jacket'],
      ['Insulated snow boots', 'Wool beanie', 'Warm socks'],
    ),
    Outfit(
      'apres-2',
      'Mountain dinner',
      'Dinner after skiing',
      ['Turtleneck knit', 'Corduroy trousers', 'Warm wool coat'],
      ['Ankle snow boots', 'Thick scarf', 'Leather gloves'],
    ),
    Outfit(
      'apres-3',
      'Cozy travel',
      'Winter train or lodge day',
      ['Fleece cardigan', 'Thermal top', 'Relaxed warm joggers'],
      ['Fleece-lined boots', 'Knit scarf', 'Soft tote'],
    ),
  ],
);

const autumnCity = Moodboard(
  id: 'autumn-city',
  name: 'Autumn City Layers',
  tagline:
      'Trench coats, soft knits and comfortable shoes for crisp city trips.',
  palette: [
    Color(0xFFE9D8C5),
    Color(0xFFC69A6A),
    Color(0xFF8F6E57),
    Color(0xFF4E5543),
  ],
  keywords: ['Trench coats', 'Layering', 'Autumn tones'],
  tiles: [
    MoodTileData('Classic trench coat', Icons.checkroom_outlined, height: 1.4),
    MoodTileData('Soft knit sweater', Icons.dry_cleaning_outlined),
    MoodTileData('Straight-leg jeans', Icons.checkroom_outlined, height: 1.2),
    MoodTileData('Leather ankle boots', Icons.directions_walk),
    MoodTileData('Light scarf', Icons.waves, height: 0.8),
  ],
  outfits: [
    Outfit(
      'autumn-city-1',
      'Fall explorer',
      'Autumn city sightseeing',
      ['Trench coat', 'Lightweight knit sweater', 'Straight-leg jeans'],
      ['Ankle boots', 'Crossbody bag', 'Light scarf'],
    ),
    Outfit(
      'autumn-city-2',
      'Coffee and galleries',
      'Autumn café afternoon',
      ['Wool blazer', 'Long-sleeve tee', 'Wide-leg trousers'],
      ['Leather loafers', 'Tote bag', 'Small scarf'],
    ),
    Outfit(
      'autumn-city-3',
      'Layered evening',
      'Dinner on an autumn trip',
      ['Camel jacket', 'Ribbed knit top', 'Midi skirt', 'Warm tights'],
      ['Knee-high boots', 'Shoulder bag', 'Light scarf'],
    ),
  ],
);

const springCity = Moodboard(
  id: 'spring-city',
  name: 'Spring City',
  tagline: 'Light jackets, fresh pastels and comfortable layers for mild days.',
  palette: [
    Color(0xFFF6E0E2),
    Color(0xFFD7E8D2),
    Color(0xFFC7D9EF),
    Color(0xFF7B837A),
  ],
  keywords: ['Light jackets', 'Cardigans', 'Spring layers'],
  tiles: [
    MoodTileData('Light trench', Icons.checkroom_outlined, height: 1.4),
    MoodTileData('Cotton cardigan', Icons.dry_cleaning_outlined),
    MoodTileData('Straight jeans', Icons.checkroom_outlined),
    MoodTileData('Comfortable sneakers', Icons.directions_walk),
    MoodTileData('Canvas tote', Icons.shopping_bag_outlined),
  ],
  outfits: [
    Outfit(
      'spring-city-1',
      'Spring explorer',
      'City walk in spring',
      ['Light trench coat', 'Cotton cardigan', 'Straight-leg jeans'],
      ['Comfortable sneakers', 'Canvas tote', 'Light scarf'],
    ),
    Outfit(
      'spring-city-2',
      'Garden café',
      'Spring café stop',
      ['Relaxed blouse', 'Wide trousers', 'Light denim jacket'],
      ['Ballet flats', 'Crossbody bag'],
    ),
    Outfit(
      'spring-city-3',
      'Breezy afternoon',
      'Spring day trip',
      ['Soft knit top', 'Midi skirt', 'Light jacket'],
      ['White sneakers', 'Small umbrella'],
    ),
  ],
);

const summerCity = Moodboard(
  id: 'summer-city',
  name: 'Summer City',
  tagline: 'Breezy but city-ready pieces, with no beach assumed.',
  palette: [
    Color(0xFFF4EBD9),
    Color(0xFFE9CDAE),
    Color(0xFF9ABDB6),
    Color(0xFF687B85),
  ],
  keywords: ['Breathable', 'Linen', 'City walks'],
  tiles: [
    MoodTileData('Light linen shirt', Icons.dry_cleaning_outlined, height: 1.3),
    MoodTileData('Loose trousers', Icons.checkroom_outlined, height: 1.2),
    MoodTileData('Comfortable trainers', Icons.directions_walk),
    MoodTileData('Canvas bag', Icons.shopping_bag_outlined),
    MoodTileData('Sun hat', Icons.wb_sunny_outlined, height: 0.8),
  ],
  outfits: [
    Outfit(
      'summer-city-1',
      'Warm city walk',
      'Summer sightseeing',
      ['Breathable linen shirt', 'Lightweight wide-leg trousers'],
      ['Comfortable trainers', 'Canvas tote', 'Sun hat'],
    ),
    Outfit(
      'summer-city-2',
      'Summer cafés',
      'Coffee and shopping',
      ['Cotton short-sleeve top', 'Relaxed cotton trousers'],
      ['Canvas sneakers', 'Crossbody bag', 'Sunglasses'],
    ),
    Outfit(
      'summer-city-3',
      'Warm evening',
      'Summer city dinner',
      ['Light summer blouse', 'Flowy midi skirt'],
      ['Comfortable sandals', 'Small bag'],
    ),
  ],
);

const neutralTravel = Moodboard(
  id: 'neutral-travel',
  name: 'Everyday Travel Layers',
  tagline: 'Versatile pieces for a trip when the season is not yet known.',
  palette: [
    Color(0xFFE6E0D5),
    Color(0xFFC6C3BA),
    Color(0xFF909C97),
    Color(0xFF48565A),
  ],
  keywords: ['Versatile', 'Comfortable', 'Layerable'],
  tiles: [
    MoodTileData('Versatile jacket', Icons.checkroom_outlined, height: 1.3),
    MoodTileData('Layering top', Icons.dry_cleaning_outlined),
    MoodTileData('Comfortable trousers', Icons.checkroom_outlined, height: 1.2),
    MoodTileData('Walking shoes', Icons.directions_walk),
    MoodTileData('Everyday backpack', Icons.shopping_bag_outlined),
  ],
  outfits: [
    Outfit(
      'travel-neutral-1',
      'Travel essentials',
      'Travel day',
      ['Comfortable layering top', 'Versatile jacket', 'Relaxed trousers'],
      ['Walking shoes', 'Everyday backpack'],
    ),
    Outfit(
      'travel-neutral-2',
      'City explorer',
      'Flexible sightseeing day',
      ['Cotton shirt', 'Light overshirt', 'Straight-leg jeans'],
      ['Comfortable sneakers', 'Crossbody bag'],
    ),
    Outfit(
      'travel-neutral-3',
      'Casual evening',
      'Relaxed dinner',
      ['Soft knit or cotton top', 'Smart-casual trousers', 'Light outer layer'],
      ['Closed-toe shoes', 'Small bag'],
    ),
  ],
);

const allMoodboards = <Moodboard>[
  coastalChic,
  beachCasual,
  minimalistSummer,
  elegantChic,
  allBlack,
  romanticDinner,
  koreanStreetwear,
  scandiMinimalist,
  softGirl,
  winterLayers,
  winterCity,
  alpineSki,
  apresSki,
  autumnCity,
  springCity,
  summerCity,
  neutralTravel,
];

/// Fallback: three predefined moodboards per broad type of activity.
List<Moodboard> moodboardsFor(ActivityType type) => switch (type) {
  ActivityType.holiday => [neutralTravel, koreanStreetwear, scandiMinimalist],
  ActivityType.dinner ||
  ActivityType.party => [elegantChic, allBlack, romanticDinner],
  ActivityType.cafe ||
  ActivityType.concert ||
  ActivityType.dayTrip ||
  ActivityType.custom => [koreanStreetwear, scandiMinimalist, softGirl],
};

// Rule-based seasonal context: the plan title has first priority, then
// destination/activity, then chosen dates. An unspecified Holiday is neutral.
enum _TravelStyle { ski, winter, beach, summer, autumn, spring, neutral }

bool _containsContextWord(String value, List<String> keywords) {
  final words = value.toLowerCase();
  for (final keyword in keywords) {
    final escaped = RegExp.escape(keyword.toLowerCase());
    if (RegExp('(^|[^a-z])$escaped([^a-z]|\$)').hasMatch(words)) return true;
  }
  return false;
}

_TravelStyle? _explicitStyle(String source) {
  if (_containsContextWord(source, [
    'ski',
    'skiing',
    'skis',
    'snowboard',
    'snowboarding',
    'ski resort',
    'ski trip',
    'piste',
  ]))
    return _TravelStyle.ski;
  if (_containsContextWord(source, [
    'winter',
    'snow',
    'snowy',
    'christmas',
    'frost',
    'freezing',
    'cold-weather',
  ]))
    return _TravelStyle.winter;
  if (_containsContextWord(source, [
    'beach',
    'beaches',
    'coast',
    'coastal',
    'seaside',
    'surf',
    'surfing',
    'swimming',
    'ocean',
    'haeundae',
    'gwangalli',
  ]))
    return _TravelStyle.beach;
  if (_containsContextWord(source, ['autumn', 'fall']))
    return _TravelStyle.autumn;
  if (_containsContextWord(source, ['spring'])) return _TravelStyle.spring;
  if (_containsContextWord(source, ['summer', 'hot-weather']))
    return _TravelStyle.summer;
  return null;
}

_TravelStyle? _styleFromDate(String value) {
  // Date labels generated by the existing date pickers use month names.
  // Use northern-hemisphere calendar seasons as a prototype approximation.
  final match = RegExp(
    r'\b(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|'
    r'jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|'
    r'oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\b',
    caseSensitive: false,
  ).firstMatch(value);
  if (match == null) return null;
  final month = match.group(0)!.toLowerCase().substring(0, 3);
  if (['dec', 'jan', 'feb'].contains(month)) return _TravelStyle.winter;
  if (['mar', 'apr', 'may'].contains(month)) return _TravelStyle.spring;
  if (['jun', 'jul', 'aug'].contains(month)) return _TravelStyle.summer;
  return _TravelStyle.autumn;
}

_TravelStyle _styleForDetails({
  required String title,
  String destination = '',
  String activity = '',
  String dates = '',
}) {
  // The title controls the season, while an explicitly named ski/beach
  // activity can refine a compatible season (winter ski, summer beach).
  // A broad Holiday category never selects summer or a beach by itself.
  final titleStyle = _explicitStyle(title);
  final detailsStyle = _explicitStyle('$activity $destination');
  if (titleStyle == _TravelStyle.winter && detailsStyle == _TravelStyle.ski)
    return _TravelStyle.ski;
  if (titleStyle == _TravelStyle.summer && detailsStyle == _TravelStyle.beach)
    return _TravelStyle.beach;
  if (titleStyle != null) return titleStyle;
  if (detailsStyle != null) return detailsStyle;
  return _styleFromDate(dates) ?? _TravelStyle.neutral;
}

String _planChoice(Plan plan, OptionCategory category) {
  final confirmed = plan.confirmed[category];
  if (confirmed != null) return confirmed.title;
  final options = plan.optionsFor(category);
  return options.isEmpty ? '' : options.first.title;
}

_TravelStyle _styleForPlan(Plan plan) => _styleForDetails(
  title: plan.name,
  destination: _planChoice(plan, OptionCategory.destination),
  activity:
      '${plan.activityLabel} ${_planChoice(plan, OptionCategory.activity)}',
  dates: _planChoice(plan, OptionCategory.dates),
);

/// The same selected moodboards provide the outfit ideas in Outfit Planner.
/// Custom moodboards and the existing group style vote are preserved.
List<Moodboard> moodboardsForPlan(Plan plan) {
  switch (_styleForPlan(plan)) {
    case _TravelStyle.ski:
      return [alpineSki, apresSki, winterLayers];
    case _TravelStyle.winter:
      return [winterLayers, winterCity, apresSki];
    case _TravelStyle.beach:
      return [coastalChic, beachCasual, minimalistSummer];
    case _TravelStyle.summer:
      return [summerCity, minimalistSummer, koreanStreetwear];
    case _TravelStyle.autumn:
      return [autumnCity, koreanStreetwear, scandiMinimalist];
    case _TravelStyle.spring:
      return [springCity, scandiMinimalist, softGirl];
    case _TravelStyle.neutral:
      break;
  }

  final activity = _planChoice(plan, OptionCategory.activity).toLowerCase();
  final destination = _planChoice(
    plan,
    OptionCategory.destination,
  ).toLowerCase();
  final context =
      '$activity $destination ${plan.name.toLowerCase()} '
      '${plan.activityLabel.toLowerCase()}';
  bool containsAny(List<String> words) =>
      words.any((word) => context.contains(word));

  if (containsAny([
    'hike',
    'hiking',
    'mountain',
    'trail',
    'camp',
    'trek',
    'forest',
    'park',
    'outdoor',
    'nature',
  ])) {
    return [neutralTravel, koreanStreetwear, scandiMinimalist];
  }
  if (containsAny([
    'dinner',
    'restaurant',
    'birthday',
    'gala',
    'formal',
    'fine dining',
    'wedding',
    'date night',
  ])) {
    return [elegantChic, allBlack, romanticDinner];
  }
  if (containsAny(['party', 'club', 'nightlife', 'cocktail', 'bar'])) {
    return [allBlack, elegantChic, romanticDinner];
  }
  if (containsAny([
    'café',
    'cafe',
    'coffee',
    'brunch',
    'bakery',
    'seongsu',
    'gallery',
    'museum',
    'shopping',
  ])) {
    return [koreanStreetwear, scandiMinimalist, softGirl];
  }
  if (containsAny(['concert', 'festival', 'music', 'show', 'performance'])) {
    return [koreanStreetwear, allBlack, softGirl];
  }
  if (containsAny([
    'city',
    'sightseeing',
    'tour',
    'explore',
    'walking',
    'seoul',
    'hongdae',
    'myeongdong',
  ])) {
    return [koreanStreetwear, scandiMinimalist, neutralTravel];
  }
  return moodboardsFor(plan.type);
}

/// Custom boards exist only in memory until a separate persistence stage.
final Map<String, Moodboard> customBoardRegistry = {};

List<Moodboard> availableMoodboardsForPlan(Plan plan) => [
  ...moodboardsForPlan(plan),
  ...plan.customMoodboards,
];

Moodboard? moodboardById(String? id) {
  for (final b in allMoodboards) {
    if (b.id == id) return b;
  }
  return customBoardRegistry[id];
}

/// Finds an outfit and the moodboard it belongs to.
(Outfit, Moodboard)? outfitById(String id) {
  for (final b in [...allMoodboards, ...customBoardRegistry.values]) {
    for (final o in b.outfits) {
      if (o.id == id) return (o, b);
    }
  }
  return null;
}

/// Sample context, never a live forecast. Holiday alone does not mean summer.
({String season, String weather, int? days}) sampleContextFor(
  ActivityType type, {
  String title = '',
  String destination = '',
  String activity = '',
  String dates = '',
}) {
  final style = _styleForDetails(
    title: title,
    destination: destination,
    activity: activity,
    dates: dates,
  );
  final days = type == ActivityType.holiday ? 3 : null;
  // A beach trip can be in any season; respect explicit summer wording.
  final isBeachInSummer =
      _containsContextWord(title, ['summer']) ||
      _styleFromDate(dates) == _TravelStyle.summer;
  return switch (style) {
    _TravelStyle.beach => (
      season: isBeachInSummer ? 'Summer' : 'Beach trip (season varies)',
      weather: isBeachInSummer
          ? 'Warm and sunny, around 24–30°C (sample)'
          : 'Local weather not available (sample only)',
      days: days,
    ),
    _TravelStyle.ski => (
      season: 'Winter',
      weather: 'Snowy and cold, around -8 to 0°C (sample)',
      days: days,
    ),
    _TravelStyle.winter => (
      season: 'Winter',
      weather: 'Cold, around -5 to 3°C (sample)',
      days: days,
    ),
    _TravelStyle.summer => (
      season: 'Summer',
      weather: 'Warm, around 24–30°C (sample)',
      days: days,
    ),
    _TravelStyle.autumn => (
      season: 'Autumn',
      weather: 'Cool, around 8–16°C (sample)',
      days: days,
    ),
    _TravelStyle.spring => (
      season: 'Spring',
      weather: 'Mild, around 12–20°C (sample)',
      days: days,
    ),
    _TravelStyle.neutral => (
      season: 'Season not determined',
      weather: 'Weather not available (sample only)',
      days: days,
    ),
  };
}

// ---------------------------------------------------------------------------
// Checklists and packing lists
// ---------------------------------------------------------------------------

List<ChecklistItem> defaultChecklist(ActivityType type, List<String> members) {
  final tasks = switch (type) {
    ActivityType.holiday => [
      'Book transport tickets',
      'Reserve the accommodation',
      'Set up a shared budget',
      'Check the weather forecast',
      'Pick a group outfit theme',
    ],
    ActivityType.dinner || ActivityType.party => [
      'Make the reservation',
      'Collect money for the cake and gift',
      'Confirm the headcount',
      'Pick a group outfit theme',
    ],
    ActivityType.concert => [
      'Buy the tickets',
      'Plan how to get there and back',
      'Check the venue bag policy',
      'Pick a group outfit theme',
    ],
    ActivityType.cafe || ActivityType.dayTrip || ActivityType.custom => [
      'Save the spots to a shared map',
      'Check opening hours',
      'Agree on a meeting point',
      'Pick a group outfit theme',
    ],
  };
  return [
    for (var i = 0; i < tasks.length; i++)
      ChecklistItem(tasks[i], assigneeId: members[i % members.length]),
  ];
}

/// Builds a packing list from trip length, activity and the chosen outfits.
List<PackingItem> generatePackingList(Plan plan) {
  final days = plan.tripDays ?? 3;
  final board = moodboardById(plan.selectedMoodboardId);
  final items = <PackingItem>[];
  final seen = <String>{};
  void add(String title, String category) {
    if (seen.add(title.toLowerCase())) items.add(PackingItem(title, category));
  }

  add('ID card', 'Essentials');
  add('Transport tickets (on your phone)', 'Essentials');
  add('Wallet and transit card', 'Essentials');
  if (board != null) {
    for (final o in board.outfits) {
      for (final p in o.pieces) {
        add(p, 'Outfits · ${board.name}');
      }
    }
    for (final o in board.outfits) {
      for (final a in o.accessories) {
        add(a, 'Accessories');
      }
    }
  } else {
    add('Outfits for $days days', 'Outfits');
  }
  add('Underwear and socks × $days', 'Basics');
  add('Pyjamas', 'Basics');
  if (plan.type == ActivityType.holiday) {
    // Don't give a winter traveller an automatic beach packing list.
    switch (_styleForPlan(plan)) {
      case _TravelStyle.ski:
        add('Thermal base layers', 'Basics');
        add('Ski jacket and waterproof trousers', 'Outfits');
        add('Warm ski socks', 'Basics');
        add('Ski gloves and goggles', 'Accessories');
        add('Snow boots', 'Outfits');
      case _TravelStyle.winter:
        add('Warm winter coat', 'Outfits');
        add('Sweaters and thermal layers', 'Basics');
        add('Scarf and gloves', 'Accessories');
        add('Winter boots', 'Outfits');
      case _TravelStyle.beach:
        add('Swimwear', 'Basics');
        add('Sunglasses', 'Accessories');
        add('Sunscreen SPF 50+', 'Toiletries');
        add('Beach towel', 'Extras');
      case _TravelStyle.summer:
        add('Sunglasses', 'Accessories');
        add('Sunscreen SPF 50+', 'Toiletries');
        add('Breathable clothes', 'Basics');
      case _TravelStyle.autumn:
        add('Light jacket and knit layers', 'Outfits');
        add('Comfortable closed-toe shoes', 'Outfits');
        add('Small umbrella', 'Extras');
      case _TravelStyle.spring:
        add('Light jacket', 'Outfits');
        add('Layering cardigan', 'Outfits');
        add('Small umbrella', 'Extras');
      case _TravelStyle.neutral:
        add('Versatile extra layer', 'Outfits');
        add('Comfortable walking shoes', 'Outfits');
        add('Small umbrella', 'Extras');
    }
  }
  add('Toothbrush and toothpaste', 'Toiletries');
  add('Skincare minis', 'Toiletries');
  add('Phone charger', 'Tech');
  add('Power bank', 'Tech');
  return items;
}

// ---------------------------------------------------------------------------
// Sample plans are deliberately not created at startup.
// Plans and votes are added only through user interactions.

// ======================================================================
// app_state.dart
// ======================================================================
/// The nine screens of the app.
enum AppScreen {
  home('Home', Icons.home_outlined),
  createPlan('Create a Plan', Icons.add_circle_outline),
  groupPlanning('Group Planning', Icons.how_to_vote_outlined),
  finalizedPlan('Finalized Plan', Icons.task_alt),
  moodboard('Style Moodboard', Icons.auto_awesome_mosaic_outlined),
  styleVoting('Style Voting', Icons.favorite_border),
  outfitPlanner('Outfit Planner', Icons.checkroom_outlined),
  packingList('Packing List', Icons.luggage_outlined),
  myPlans('My Plans', Icons.collections_bookmark_outlined);

  const AppScreen(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Single source of truth for the prototype. Screens read from [appState]
/// and call its methods; the shell rebuilds on every change.
class AppState extends ChangeNotifier {
  AppScreen screen = AppScreen.home;
  final List<Friend> contacts = sampleContacts();
  final List<Plan> plans = [];
  final Set<String> savedOutfitIds = {};

  String _selectedPlanId = '';
  final List<String> customActivities = [];
  String _votingAs = meId;
  final Map<String, String> prototypeProfiles = {};
  String? activeProfileId;
  int _counter = 0;

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_counter++}';

  // ---------------- People ----------------

  Friend friend(String id) => contacts.firstWhere(
    (f) => f.id == id,
    orElse: () => Friend(id, 'Guest', AppColors.muted),
  );

  String displayName(String id) => id == meId ? 'You' : friend(id).name;

  Friend addContact(String name) {
    final clean = name.trim();
    for (final f in contacts) {
      if (f.name.toLowerCase() == clean.toLowerCase()) return f;
    }
    final f = Friend(
      _newId('friend'),
      clean,
      avatarColors[contacts.length % avatarColors.length],
    );
    contacts.add(f);
    notifyListeners();
    return f;
  }

  /// A saved custom activity can be reused in future plans. The plan keeps
  /// its own text label, so deleting a catalogue entry does not change it.
  void addCustomActivity(String activity) {
    final clean = activity.trim();
    if (clean.isEmpty) return;
    if (customActivities.any((n) => n.toLowerCase() == clean.toLowerCase())) {
      return;
    }
    customActivities.add(clean);
    notifyListeners();
  }

  void deleteCustomActivity(String activity) {
    customActivities.removeWhere(
      (n) => n.toLowerCase() == activity.toLowerCase(),
    );
    notifyListeners();
  }

  // ---------------- Navigation ----------------

  Plan? get selectedPlan {
    for (final p in plans) {
      if (p.id == _selectedPlanId) return p;
    }
    return plans.isEmpty ? null : plans.first;
  }

  void goTo(AppScreen target, {String? planId}) {
    if (planId != null) _selectedPlanId = planId;
    screen = target;
    notifyListeners();
  }

  void selectPlan(String id) {
    _selectedPlanId = id;
    notifyListeners();
  }

  void openPlan(Plan plan) => goTo(
    plan.isFinalized ? AppScreen.finalizedPlan : AppScreen.groupPlanning,
    planId: plan.id,
  );

  /// Delete only this plan and data owned by it. Shared built-in outfits
  /// and other plans are left untouched. No browser persistence is enabled.
  void deletePlan(Plan plan) {
    if (!plans.any((p) => p.id == plan.id)) return;
    if (_stylePreviewPlanId == plan.id) {
      _stylePreviewPlanId = null;
      _stylePreviewId = null;
    }
    for (final board in plan.customMoodboards) {
      customBoardRegistry.remove(board.id);
      for (final outfit in board.outfits) {
        savedOutfitIds.remove(outfit.id);
      }
    }
    plans.removeWhere((p) => p.id == plan.id);
    if (_selectedPlanId == plan.id) {
      _selectedPlanId = plans.isEmpty ? '' : plans.first.id;
      _votingAs = meId;
    }
    notifyListeners();
  }

  // ---------------- Create a plan ----------------

  Plan createPlan({
    required String name,
    required ActivityType type,
    required List<String> invitedIds,
    BudgetCurrency currency = BudgetCurrency.krw,
    String? customActivityName,
    String? initialDestination,
    String? initialDate,
    String? initialActivity,
    String? initialBudget,
  }) {
    final ctx = sampleContextFor(
      type,
      title: name,
      destination: initialDestination ?? '',
      activity: initialActivity ?? '',
      dates: initialDate ?? '',
    );
    final initialOptions = <PlanOption>[];
    void seed(OptionCategory category, String? value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return;
      initialOptions.add(
        PlanOption(
          id: _newId('opt'),
          category: category,
          title: text,
          suggestedBy: meId,
        ),
      );
    }

    seed(OptionCategory.destination, initialDestination);
    seed(OptionCategory.dates, initialDate);
    seed(OptionCategory.activity, initialActivity);
    seed(OptionCategory.budget, initialBudget);
    final plan = Plan(
      id: _newId('plan'),
      name: name,
      type: type,
      memberIds: [meId, ...invitedIds],
      currency: currency,
      customActivityName: customActivityName,
      options: initialOptions,
      season: ctx.season,
      weather: ctx.weather,
      tripDays: ctx.days,
    );
    plans.insert(0, plan);
    _selectedPlanId = plan.id;
    _votingAs = meId;
    screen = AppScreen.groupPlanning;
    notifyListeners();
    return plan;
  }

  void setCurrency(Plan plan, BudgetCurrency currency) {
    plan.currency = currency;
    notifyListeners();
  }

  // ---------------- Group voting ----------------

  /// Prototype helper: whose turn it is to vote (the user can switch).
  String voterFor(Plan plan) {
    final id = activeProfileId ?? _votingAs;
    return plan.memberIds.contains(id) ? id : plan.memberIds.first;
  }

  void setVoter(String memberId) {
    activeProfileId = null;
    _votingAs = memberId;
    notifyListeners();
  }

  void activateProfile(Plan plan, String memberId, {String? newName}) {
    if (!plan.memberIds.contains(memberId)) return;
    if (newName != null) {
      final clean = newName.trim();
      if (clean.isEmpty || prototypeProfiles.containsKey(memberId)) return;
      prototypeProfiles[memberId] = clean;
    }
    if (!prototypeProfiles.containsKey(memberId)) return;
    activeProfileId = memberId;
    notifyListeners();
  }

  /// Returns an error message, or null when the suggestion was added.
  String? addOption(
    Plan plan,
    OptionCategory category,
    String title,
    String note,
  ) {
    final clean = title.trim();
    if (clean.isEmpty) return 'Write your idea first';
    final duplicate = plan
        .optionsFor(category)
        .any((o) => o.title.toLowerCase() == clean.toLowerCase());
    if (duplicate) return 'This has already been suggested';
    plan.options.add(
      PlanOption(
        id: _newId('opt'),
        category: category,
        title: clean,
        note: note.trim().isEmpty ? null : note.trim(),
        suggestedBy: voterFor(plan),
      ),
    );
    notifyListeners();
    return null;
  }

  void removeOption(Plan plan, PlanOption option) {
    plan.options.remove(option);
    notifyListeners();
  }

  /// One vote per person per category: voting for a new option moves the vote.
  void toggleVote(Plan plan, PlanOption option) {
    if (plan.isFinalized) return;
    final voter = voterFor(plan);
    if (option.voterIds.contains(voter)) {
      option.voterIds.remove(voter);
    } else {
      for (final o in plan.optionsFor(option.category)) {
        o.voterIds.remove(voter);
      }
      option.voterIds.add(voter);
    }
    notifyListeners();
  }

  bool hasVotedAll(Plan plan, String memberId) => OptionCategory.values.every(
    (c) => plan.optionsFor(c).any((o) => o.voterIds.contains(memberId)),
  );

  int membersFullyVoted(Plan plan) =>
      plan.memberIds.where((id) => hasVotedAll(plan, id)).length;

  List<PlanOption> leaders(Plan plan, OptionCategory c) {
    final opts = plan.optionsFor(c);
    if (opts.isEmpty) return [];
    final top = opts.map((o) => o.voterIds.length).reduce(math.max);
    if (top == 0) return [];
    return opts.where((o) => o.voterIds.length == top).toList();
  }

  bool isTie(Plan plan, OptionCategory c) => leaders(plan, c).length > 1;

  /// Most votes wins; a tie goes to the earliest suggestion.
  PlanOption? winner(Plan plan, OptionCategory c) {
    final opts = plan.optionsFor(c);
    if (opts.isEmpty) return null;
    var best = opts.first;
    for (final o in opts) {
      if (o.voterIds.length > best.voterIds.length) best = o;
    }
    return best;
  }

  bool canConfirm(Plan plan) =>
      !plan.isFinalized &&
      OptionCategory.values.every((c) => plan.optionsFor(c).isNotEmpty);

  void confirmPlan(Plan plan) {
    if (!canConfirm(plan)) return;
    for (final c in OptionCategory.values) {
      plan.confirmed[c] = winner(plan, c)!;
    }
    plan.status = PlanStatus.finalized;
    // Reflect the winning location/activity/date in the sample context.
    final context = sampleContextFor(
      plan.type,
      title: plan.name,
      destination: plan.whereLabel,
      activity:
          '${plan.activityLabel} ${_planChoice(plan, OptionCategory.activity)}',
      dates: plan.whenLabel,
    );
    plan.season = context.season;
    plan.weather = context.weather;
    if (plan.checklist.isEmpty) {
      plan.checklist.addAll(defaultChecklist(plan.type, plan.memberIds));
    }
    if (plan.type == ActivityType.holiday) {
      plan.packing
        ..clear()
        ..addAll(generatePackingList(plan));
    }
    screen = AppScreen.finalizedPlan;
    notifyListeners();
  }

  void addChecklistTask(Plan plan, String title, String memberId) {
    final clean = title.trim();
    if (!plans.contains(plan) ||
        !plan.isFinalized ||
        clean.isEmpty ||
        !plan.memberIds.contains(memberId)) {
      return;
    }
    plan.checklist.add(ChecklistItem(clean, assigneeId: memberId));
    notifyListeners();
  }

  void assignChecklistTask(Plan plan, ChecklistItem item, String memberId) {
    if (!plans.contains(plan) ||
        !plan.isFinalized ||
        !plan.checklist.contains(item) ||
        !plan.memberIds.contains(memberId)) {
      return;
    }
    item.assigneeId = memberId;
    notifyListeners();
  }

  void toggleChecklist(ChecklistItem item) {
    item.done = !item.done;
    notifyListeners();
  }

  // ---------------- Style ----------------

  /// Customize an existing sample template. No AI model is involved.
  Moodboard saveCustomMoodboard(
    Plan plan, {
    required Moodboard template,
    String? editingId,
    required String name,
    required String tagline,
    required List<String> keywords,
    required List<String> tileLabels,
    required List<Color> palette,
  }) {
    final old = editingId == null ? null : moodboardById(editingId);
    final id = editingId ?? _newId('moodboard');
    final tiles = <MoodTileData>[
      for (var i = 0; i < tileLabels.length; i++)
        MoodTileData(
          tileLabels[i],
          template.tiles[i % template.tiles.length].icon,
          height: template.tiles[i % template.tiles.length].height,
        ),
    ];
    final board = Moodboard(
      id: id,
      name: name.trim(),
      tagline: tagline.trim(),
      palette: List<Color>.of(palette),
      keywords: List<String>.of(keywords),
      tiles: tiles,
      outfits:
          old?.outfits ??
          [
            for (final o in template.outfits)
              Outfit(
                '$id-${o.id}',
                o.name,
                o.occasion,
                List<String>.of(o.pieces),
                List<String>.of(o.accessories),
              ),
          ],
    );
    final existingIndex = plan.customMoodboards.indexWhere((b) => b.id == id);
    if (existingIndex >= 0) {
      plan.customMoodboards[existingIndex] = board;
    } else {
      plan.customMoodboards.add(board);
    }
    customBoardRegistry[id] = board;
    notifyListeners();
    return board;
  }

  CustomStylePalette addCustomStylePalette(
    Plan plan,
    String name,
    List<Color> colors,
  ) {
    final palette = CustomStylePalette(
      id: _newId('style'),
      name: name.trim(),
      colors: List<Color>.of(colors),
    );
    plan.customStylePalettes.add(palette);
    notifyListeners();
    return palette;
  }

  /// Remove only user-created moodboards. Clear associated style votes,
  /// locked selection, and saved outfits to avoid stale references.
  void deleteCustomMoodboard(Plan plan, Moodboard board) {
    if (!plan.customMoodboards.any((b) => b.id == board.id)) return;
    plan.customMoodboards.removeWhere((b) => b.id == board.id);
    customBoardRegistry.remove(board.id);
    if (_stylePreviewId == board.id) _stylePreviewId = null;
    plan.styleVotes.removeWhere((_, id) => id == board.id);
    if (plan.selectedMoodboardId == board.id) {
      plan.selectedMoodboardId = null;
    }
    for (final outfit in board.outfits) {
      savedOutfitIds.remove(outfit.id);
    }
    notifyListeners();
  }

  String? _stylePreviewPlanId;
  String? _stylePreviewId;

  String? stylePreviewFor(Plan plan) =>
      plan.id == _stylePreviewPlanId ? _stylePreviewId : null;

  void openStyleVoting(Plan plan, String boardId) {
    if (!plans.contains(plan) ||
        !plan.isFinalized ||
        !availableMoodboardsForPlan(plan).any((board) => board.id == boardId)) {
      return;
    }
    _stylePreviewPlanId = plan.id;
    _stylePreviewId = boardId;
    goTo(AppScreen.styleVoting, planId: plan.id);
  }

  void voteStyle(Plan plan, String boardId) {
    if (!plan.isFinalized ||
        !availableMoodboardsForPlan(plan).any((board) => board.id == boardId)) {
      return;
    }
    final voter = voterFor(plan);
    if (plan.styleVotes[voter] == boardId) {
      plan.styleVotes.remove(voter);
    } else {
      plan.styleVotes[voter] = boardId;
    }
    notifyListeners();
  }

  List<String> styleVotersFor(Plan plan, String boardId) => plan
      .styleVotes
      .entries
      .where((e) => e.value == boardId)
      .map((e) => e.key)
      .toList();

  String? styleLeader(Plan plan) {
    String? best;
    var bestVotes = 0;
    for (final b in availableMoodboardsForPlan(plan)) {
      final n = styleVotersFor(plan, b.id).length;
      if (n > bestVotes) {
        best = b.id;
        bestVotes = n;
      }
    }
    return best;
  }

  void lockStyle(Plan plan) {
    final id = styleLeader(plan);
    if (id == null) return;
    plan.selectedMoodboardId = id;
    if (plan.type == ActivityType.holiday) {
      plan.packing
        ..clear()
        ..addAll(generatePackingList(plan));
    }
    screen = AppScreen.outfitPlanner;
    notifyListeners();
  }

  void toggleSavedOutfit(String id) {
    if (!savedOutfitIds.remove(id)) savedOutfitIds.add(id);
    notifyListeners();
  }

  // ---------------- Packing ----------------

  void generatePacking(Plan plan) {
    plan.packing
      ..clear()
      ..addAll(generatePackingList(plan));
    notifyListeners();
  }

  void togglePacked(PackingItem item) {
    item.packed = !item.packed;
    notifyListeners();
  }

  /// Packing items are held on their own plan, never shared across trips.
  void addPackingItem(Plan plan, String title, String category) {
    final clean = title.trim();
    if (clean.isEmpty) return;
    plan.packing.add(PackingItem(clean, category));
    notifyListeners();
  }

  void editPackingItem(Plan plan, PackingItem item, String title) {
    if (!plan.packing.contains(item) || title.trim().isEmpty) return;
    item.title = title.trim();
    notifyListeners();
  }

  void deletePackingItem(Plan plan, PackingItem item) {
    if (!plan.packing.remove(item)) return;
    notifyListeners();
  }
}

final appState = AppState();

// ======================================================================
// widgets/common.dart
// ======================================================================
// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

/// Scrollable, centred page with a comfortable max width.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.maxWidth = 1120});
  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 32,
        compact ? 12 : 28,
        compact ? 16 : 32,
        48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Wraps children into as many columns as fit [minItemWidth].
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 280,
    this.spacing = 16,
  });
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = math.max(
          1,
          math.min(
            4,
            ((constraints.maxWidth + spacing) / (minItemWidth + spacing))
                .floor(),
          ),
        );
        final width = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final c in children) SizedBox(width: width, child: c),
          ],
        );
      },
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.kicker,
    this.subtitle,
    this.trailing,
  });
  final String title;
  final String? kicker;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kicker != null) ...[
          Text(
            kicker!,
            style: const TextStyle(
              color: AppColors.mauve,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Text(title, style: AppText.display(compact ? 30 : 40)),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(subtitle!, style: AppText.muted.copyWith(fontSize: 15)),
          ),
        ],
      ],
    );
    if (trailing == null) return text;
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [text, const SizedBox(height: 14), trailing!],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: text),
        const SizedBox(width: 20),
        trailing!,
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.display(24)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: AppText.muted),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = Colors.white,
    this.borderColor = AppColors.line,
    this.radius = 22,
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip(
    this.label, {
    super.key,
    this.icon,
    this.color = AppColors.mist,
    this.textColor = AppColors.ink,
  });
  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            if (icon != null)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Icon(icon, size: 14, color: textColor),
                ),
              ),
            TextSpan(text: label),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class InfoLine extends StatelessWidget {
  const InfoLine(this.icon, this.text, {super.key});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.friend,
    this.size = 32,
    this.selected = false,
  });
  final Friend friend;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: friend.name,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: friend.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.ink : Colors.white,
            width: selected ? 2.5 : 2,
          ),
        ),
        child: Text(
          friend.initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }
}

class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.ids,
    this.size = 28,
    this.max = 5,
  });
  final List<String> ids;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = ids.take(max).toList();
    final extra = ids.length - shown.length;
    final count = shown.length + (extra > 0 ? 1 : 0);
    if (count == 0) return SizedBox(height: size);
    final step = size * 0.68;
    return SizedBox(
      width: size + (count - 1) * step,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * step,
              child: Avatar(friend: appState.friend(shown[i]), size: size),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * step,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A moodboard tile: a photo when one is provided, otherwise a palette gradient.
class MoodTile extends StatelessWidget {
  const MoodTile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.height = 120,
    this.imageUrl,
    this.showLabel = true,
  });
  final String label;
  final IconData icon;
  final Color color;
  final double height;
  final String? imageUrl;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final fg = color.computeLuminance() > 0.45 ? AppColors.ink : Colors.white;
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(color, Colors.white, 0.35)!, color],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              icon,
              size: (height * 0.3).clamp(18.0, 44.0).toDouble(),
              color: fg.withValues(alpha: 0.7),
            ),
          ),
          if (showLabel)
            Positioned(
              left: 10,
              right: 10,
              bottom: 9,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: imageUrl == null
            ? placeholder
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

/// Pinterest-style two-column collage of a moodboard's tiles.
class MoodCollage extends StatelessWidget {
  const MoodCollage({
    super.key,
    required this.board,
    this.baseHeight = 84,
    this.gap = 8,
    this.showLabels = true,
  });
  final Moodboard board;
  final double baseHeight;
  final double gap;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final left = <Widget>[];
    final right = <Widget>[];
    var lh = 0.0, rh = 0.0;
    for (var i = 0; i < board.tiles.length; i++) {
      final t = board.tiles[i];
      final h = baseHeight * t.height;
      final tile = Padding(
        padding: EdgeInsets.only(bottom: gap),
        child: MoodTile(
          label: t.label,
          icon: t.icon,
          color: board.palette[i % board.palette.length],
          height: h,
          imageUrl: t.imageUrl,
          showLabel: showLabels,
        ),
      );
      if (lh <= rh) {
        left.add(tile);
        lh += h + gap;
      } else {
        right.add(tile);
        rh += h + gap;
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(children: left)),
        SizedBox(width: gap),
        Expanded(child: Column(children: right)),
      ],
    );
  }
}

class PaletteRow extends StatelessWidget {
  const PaletteRow(this.colors, {super.key, this.size = 22});
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in colors)
          Container(
            width: size,
            height: size,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
          ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.blush,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.mauve),
          ),
          const SizedBox(height: 18),
          Text(title, textAlign: TextAlign.center, style: AppText.display(26)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.muted.copyWith(fontSize: 15),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plan-aware widgets (these connect planning and fashion)
// ---------------------------------------------------------------------------

/// Dropdown to switch which plan a screen is showing.
class PlanSwitcher extends StatelessWidget {
  const PlanSwitcher({super.key, required this.current});
  final Plan current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Plan', style: AppText.muted),
        const SizedBox(width: 10),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.line),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: current.id,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(14),
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                  items: [
                    for (final p in appState.plans)
                      DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          '${p.type.emoji}  ${p.name}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (id) {
                    if (id != null) appState.selectPlan(id);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The plan's journey from voting to packing. Each step is tappable.
class JourneyBar extends StatelessWidget {
  const JourneyBar({super.key, required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final steps = <(AppScreen, String, bool)>[
      (AppScreen.groupPlanning, 'Vote', plan.options.isNotEmpty),
      (AppScreen.finalizedPlan, 'Confirm', plan.isFinalized),
      (AppScreen.moodboard, 'Moodboards', plan.isFinalized),
      (AppScreen.styleVoting, 'Style vote', plan.selectedMoodboardId != null),
      (AppScreen.outfitPlanner, 'Outfits', plan.selectedMoodboardId != null),
      if (plan.type == ActivityType.holiday)
        (
          AppScreen.packingList,
          'Pack',
          plan.packing.isNotEmpty && plan.packing.every((i) => i.packed),
        ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.muted,
                ),
              ),
            _JourneyStep(
              screen: steps[i].$1,
              label: steps[i].$2,
              done: steps[i].$3,
              current: appState.screen == steps[i].$1,
            ),
          ],
        ],
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.screen,
    required this.label,
    required this.done,
    required this.current,
  });
  final AppScreen screen;
  final String label;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final fg = current
        ? Colors.white
        : done
        ? AppColors.ink
        : AppColors.muted;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => appState.goTo(screen),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: current
              ? AppColors.ink
              : done
              ? AppColors.mint
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: current ? AppColors.ink : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              done && !current ? Icons.check : screen.icon,
              size: 14,
              color: fg,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Prototype control: tap a friend to vote on their behalf.
class VoterBar extends StatelessWidget {
  const VoterBar({super.key, required this.plan});
  final Plan plan;

  Future<void> _createProfile(BuildContext context, String id) async {
    final form = GlobalKey<FormState>();
    var name = '';
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Create profile for ${appState.displayName(id)}'),
        scrollable: true,
        content: Form(
          key: form,
          child: TextFormField(
            autofocus: true,
            maxLength: 32,
            decoration: const InputDecoration(
              labelText: 'Prototype display name',
            ),
            onChanged: (value) => name = value,
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Enter a display name' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate())
                Navigator.pop(dialogContext, true);
            },
            child: const Text('Create profile'),
          ),
        ],
      ),
    );
    if (saved == true) appState.activateProfile(plan, id, newName: name);
  }

  @override
  Widget build(BuildContext context) {
    final current = appState.voterFor(plan);
    final activeId = appState.activeProfileId;
    final profile = appState.prototypeProfiles[activeId];
    return SoftCard(
      color: AppColors.lavender.withValues(alpha: 0.45),
      borderColor: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Voting as ${appState.displayName(current)}',
                style: AppText.strong,
              ),
              PopupMenuButton<String>(
                tooltip: 'Manage demo profiles',
                onSelected: (id) {
                  if (id.isEmpty) {
                    appState.setVoter(meId);
                  } else if (appState.prototypeProfiles.containsKey(id)) {
                    appState.activateProfile(plan, id);
                  } else {
                    _createProfile(context, id);
                  }
                },
                itemBuilder: (_) => [
                  for (final id in plan.memberIds)
                    PopupMenuItem(
                      value: id,
                      child: Text(
                        appState.prototypeProfiles.containsKey(id)
                            ? 'Use ${appState.prototypeProfiles[id]} · ${appState.displayName(id)}'
                            : 'Create profile · ${appState.displayName(id)}',
                      ),
                    ),
                  if (activeId != null)
                    const PopupMenuItem(value: '', child: Text('Sign out')),
                ],
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Text('Demo profiles ▾', style: AppText.strong),
                ),
              ),
            ],
          ),
          if (profile != null)
            Text(
              activeId == current
                  ? 'Active profile · $profile'
                  : 'Active profile · $profile · outside this plan',
              style: AppText.small,
            ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final id in plan.memberIds)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => appState.setVoter(id),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Column(
                          children: [
                            Avatar(
                              friend: appState.friend(id),
                              size: 38,
                              selected: id == current,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appState.displayName(id),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: id == current
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Demo profiles last for this session. Tap a member to switch to simulated voting.',
            style: AppText.small,
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return plan.isFinalized
        ? const TagChip(
            'Confirmed',
            icon: Icons.check_circle,
            color: Colors.white,
          )
        : const TagChip(
            'Voting open',
            icon: Icons.how_to_vote,
            color: Colors.white,
          );
  }
}

/// Plan card used on Home and My Plans.
class PlanPreviewCard extends StatelessWidget {
  const PlanPreviewCard({super.key, required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final board = moodboardById(plan.selectedMoodboardId);
    final cover = board != null
        ? [board.palette[0], board.palette[1 % board.palette.length]]
        : [plan.type.tint, Color.lerp(plan.type.tint, Colors.white, 0.55)!];
    final voted = appState.membersFullyVoted(plan);
    return SoftCard(
      padding: EdgeInsets.zero,
      onTap: () => appState.openPlan(plan),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 108,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: cover,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: StatusChip(plan: plan),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    plan.type.emoji,
                    style: const TextStyle(fontSize: 42),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(20),
                ),
                const SizedBox(height: 6),
                InfoLine(
                  Icons.place_outlined,
                  plan.isFinalized
                      ? plan.whereLabel
                      : '${plan.options.length} suggestions so far',
                ),
                InfoLine(
                  Icons.calendar_today_outlined,
                  plan.isFinalized
                      ? plan.whenLabel
                      : '$voted of ${plan.memberIds.length} friends finished voting',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    AvatarStack(ids: plan.memberIds, size: 26),
                    const SizedBox(width: 10),
                    const Spacer(),
                    if (board != null)
                      Flexible(
                        child: TagChip(
                          board.name,
                          icon: Icons.auto_awesome,
                          color: AppColors.mist,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Smaller summary for confirmed plans, so several plans fit on one screen.
class CompactConfirmedPlanCard extends StatelessWidget {
  const CompactConfirmedPlanCard({super.key, required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final board = moodboardById(plan.selectedMoodboardId);
    return SoftCard(
      padding: const EdgeInsets.all(15),
      onTap: () => appState.openPlan(plan),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: plan.type.tint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  plan.type.emoji,
                  style: const TextStyle(fontSize: 23),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  plan.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.strong,
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 8),
          InfoLine(Icons.place_outlined, plan.whereLabel),
          InfoLine(Icons.calendar_today_outlined, plan.whenLabel),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              const TagChip('Confirmed', color: AppColors.mint),
              TagChip(plan.activityLabel),
              if (board != null) TagChip(board.name, icon: Icons.auto_awesome),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shown when a style screen is opened for a plan that isn't ready yet.
class NotReadyState extends StatelessWidget {
  const NotReadyState({
    super.key,
    required this.plan,
    required this.title,
    required this.message,
    this.actionLabel,
    this.target,
  });
  final Plan? plan;
  final String title;
  final String message;
  final String? actionLabel;
  final AppScreen? target;

  @override
  Widget build(BuildContext context) {
    final p = plan;
    final t = target;
    return PageBody(
      children: [
        if (p != null) ...[
          PlanSwitcher(current: p),
          const SizedBox(height: 12),
          JourneyBar(plan: p),
        ],
        EmptyState(
          icon: Icons.hourglass_empty_rounded,
          title: title,
          message: message,
          actionLabel: actionLabel,
          onAction: t == null ? null : () => appState.goTo(t),
        ),
      ],
    );
  }
}

// ======================================================================
// screens/home_screen.dart
// ======================================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return PageBody(
      children: [
        _Hero(showCollage: width >= 760),
        const SizedBox(height: 36),
        const SectionTitle(title: 'How it works'),
        const SizedBox(height: 14),
        const ResponsiveGrid(
          minItemWidth: 220,
          children: [
            _StepCard(
              step: 1,
              title: 'Create a plan',
              text: 'Name it, pick the kind of outing and invite your friends.',
              color: AppColors.blush,
            ),
            _StepCard(
              step: 2,
              title: 'Vote together',
              text: 'Everyone suggests places, dates and budgets, then votes.',
              color: AppColors.lavender,
            ),
            _StepCard(
              step: 3,
              title: 'Get styled',
              text:
                  'Moodboards and outfits that match the place, weather and vibe.',
              color: AppColors.sky,
            ),
            _StepCard(
              step: 4,
              title: 'Pack and go',
              text:
                  'A shared checklist and packing list so nothing is forgotten.',
              color: AppColors.mint,
            ),
          ],
        ),
        const SizedBox(height: 40),
        SectionTitle(
          title: 'Upcoming activities',
          subtitle: 'Tap a plan to pick up where your group left off.',
          trailing: TextButton(
            onPressed: () => appState.goTo(AppScreen.myPlans),
            child: const Text('See all'),
          ),
        ),
        const SizedBox(height: 14),
        if (appState.plans.isEmpty)
          EmptyState(
            icon: Icons.event_note_outlined,
            title: 'No plans yet',
            message:
                'Create your first plan to start planning and voting with friends.',
            actionLabel: 'Create your first plan',
            onAction: () => appState.goTo(AppScreen.createPlan),
          )
        else
          ResponsiveGrid(
            minItemWidth: 290,
            children: [
              for (final p in appState.plans) PlanPreviewCard(plan: p),
            ],
          ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.showCollage});
  final bool showCollage;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi there 👋',
          style: AppText.strong.copyWith(color: AppColors.inkSoft),
        ),
        const SizedBox(height: 14),
        Text(
          'Plan it together.\nShow up looking good.',
          style: AppText.display(compact ? 34 : 50),
        ),
        const SizedBox(height: 16),
        const Text(
          'Organise outings with your friends, vote on the details, '
          'then get outfit moodboards that match where you’re going.',
          style: TextStyle(
            fontSize: 16,
            height: 1.55,
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => appState.goTo(AppScreen.createPlan),
              icon: const Icon(Icons.add),
              style: FilledButton.styleFrom(
                minimumSize: Size(compact ? 176 : 210, compact ? 56 : 64),
                padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 26),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              label: const Text('Create a Plan'),
            ),
            OutlinedButton(
              onPressed: () => appState.goTo(AppScreen.myPlans),
              child: const Text('View my plans'),
            ),
          ],
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(compact ? 22 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.line),
      ),
      child: showCollage
          ? Row(
              children: [
                Expanded(flex: 6, child: text),
                const SizedBox(width: 36),
                const Expanded(flex: 4, child: _HeroCollage()),
              ],
            )
          : text,
    );
  }
}

class _HeroCollage extends StatelessWidget {
  const _HeroCollage();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              MoodTile(
                label: 'Linen & gold',
                icon: Icons.dry_cleaning_outlined,
                color: Color(0xFFEDE3D3),
                height: 160,
              ),
              SizedBox(height: 10),
              MoodTile(
                label: 'Sea blues',
                icon: Icons.waves,
                color: Color(0xFF9DB9C9),
                height: 104,
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              SizedBox(height: 28),
              MoodTile(
                label: 'Pastel knits',
                icon: Icons.checkroom_outlined,
                color: Color(0xFFF6C9D7),
                height: 110,
              ),
              SizedBox(height: 10),
              MoodTile(
                label: 'All black',
                icon: Icons.nightlife,
                color: Color(0xFF2A2433),
                height: 126,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.text,
    required this.color,
  });
  final int step;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$step', style: AppText.display(30, color: AppColors.inkSoft)),
          const SizedBox(height: 10),
          Text(title, style: AppText.strong),
          const SizedBox(height: 4),
          Text(text, style: AppText.muted.copyWith(color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

// ======================================================================
// screens/create_plan_screen.dart
// ======================================================================
class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _name = TextEditingController();
  final _newFriend = TextEditingController();
  final _customActivity = TextEditingController();
  final _where = TextEditingController();
  final _what = TextEditingController();
  final _budgetAmount = TextEditingController();
  ActivityType? _type;
  BudgetCurrency _currency = BudgetCurrency.krw;
  final Set<String> _invited = {};
  int _step = 0;
  bool _triedStep = false;
  DateTime? _selectedDate;
  DateTimeRange? _selectedRange;
  TimeOfDay? _selectedTime;
  String _dateLabel = '';

  static const _stepCount = 5;

  @override
  void dispose() {
    _name.dispose();
    _newFriend.dispose();
    _customActivity.dispose();
    _where.dispose();
    _what.dispose();
    _budgetAmount.dispose();
    super.dispose();
  }

  String? get _nameError =>
      _name.text.trim().isEmpty ? 'Give your plan a name' : null;
  String? get _typeError {
    if (_type == null) return 'Choose the kind of activity';
    if (_type == ActivityType.custom && _customActivity.text.trim().isEmpty) {
      return 'Choose or type a custom activity';
    }
    return null;
  }

  String? get _whereError =>
      _where.text.trim().isEmpty ? 'Enter a destination or location' : null;
  String? get _whenError =>
      _dateLabel.isEmpty ? 'Select a date before continuing' : null;
  String? get _whatError =>
      _what.text.trim().isEmpty ? 'Tell us what you want to do' : null;
  String? get _friendsError =>
      _invited.isEmpty ? 'Invite at least one friend' : null;
  String? get _budgetError {
    final amount = double.tryParse(
      _budgetAmount.text.trim().replaceAll(',', '.'),
    );
    if (amount == null || !amount.isFinite || amount <= 0) {
      return 'Enter a positive budget per person';
    }
    return null;
  }

  String? _errorForStep(int step) => switch (step) {
    0 => _nameError ?? _typeError ?? _friendsError,
    1 => _whereError,
    2 => _whenError,
    3 => _whatError,
    4 => _budgetError,
    _ => null,
  };

  void _toggleFriend(String id) => setState(() {
    if (!_invited.remove(id)) _invited.add(id);
  });

  void _addFriend() {
    final name = _newFriend.text.trim();
    if (name.isEmpty) return;
    final friend = appState.addContact(name);
    setState(() {
      _invited.add(friend.id);
      _newFriend.clear();
    });
  }

  void _selectActivityType(ActivityType type) {
    final changedTripMode =
        (_type == ActivityType.holiday) != (type == ActivityType.holiday);
    setState(() {
      _type = type;
      if (changedTripMode) {
        _selectedDate = null;
        _selectedRange = null;
        _selectedTime = null;
        _dateLabel = '';
      }
      _triedStep = false;
    });
  }

  void _saveCustomActivity() {
    final name = _customActivity.text.trim();
    if (name.isEmpty) {
      setState(() => _triedStep = true);
      return;
    }
    appState.addCustomActivity(name);
    setState(() {
      _type = ActivityType.custom;
      _triedStep = false;
    });
  }

  Future<void> _deleteActivity(String activity) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete custom activity?'),
        content: Text(
          'Remove "$activity" from your saved activities? '
          'Existing plans using it will keep their activity name.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete activity'),
          ),
        ],
      ),
    );
    if (!mounted || ok != true) return;
    appState.deleteCustomActivity(activity);
    if (_customActivity.text.trim().toLowerCase() == activity.toLowerCase()) {
      setState(() => _customActivity.clear());
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_type == ActivityType.holiday) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: today,
        lastDate: DateTime(now.year + 5, 12, 31),
        initialDateRange: _selectedRange,
        helpText: 'When is your trip?',
      );
      if (range == null || !mounted) return;
      final l = MaterialLocalizations.of(context);
      setState(() {
        _selectedRange = range;
        _dateLabel =
            '${l.formatMediumDate(range.start)} – '
            '${l.formatMediumDate(range.end)}';
        _triedStep = false;
      });
    } else {
      final picked = await showDatePicker(
        context: context,
        firstDate: today,
        lastDate: DateTime(now.year + 5, 12, 31),
        initialDate: _selectedDate != null && !_selectedDate!.isBefore(today)
            ? _selectedDate!
            : today,
        helpText: 'When is your activity?',
      );
      if (picked == null || !mounted) return;
      setState(() {
        _selectedDate = picked;
        _updateDateLabel();
        _triedStep = false;
      });
    }
  }

  void _updateDateLabel() {
    if (_selectedDate == null) return;
    final l = MaterialLocalizations.of(context);
    final time = _selectedTime == null
        ? ''
        : ', ${l.formatTimeOfDay(_selectedTime!)}';
    _dateLabel = '${l.formatMediumDate(_selectedDate!)}$time';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 13, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedTime = picked;
      _updateDateLabel();
    });
  }

  void _nextStep() {
    setState(() => _triedStep = true);
    if (_errorForStep(_step) != null) return;
    if (_step < _stepCount - 1) {
      setState(() {
        _step++;
        _triedStep = false;
      });
    }
  }

  void _submit() {
    setState(() => _triedStep = true);
    for (var i = 0; i < _stepCount; i++) {
      if (_errorForStep(i) != null) {
        setState(() => _step = i);
        return;
      }
    }
    final amount = double.parse(_budgetAmount.text.trim().replaceAll(',', '.'));
    final amountText = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    if (_type == ActivityType.custom) {
      appState.addCustomActivity(_customActivity.text);
    }
    final plan = appState.createPlan(
      name: _name.text.trim(),
      type: _type!,
      invitedIds: _invited.toList(),
      currency: _currency,
      customActivityName: _type == ActivityType.custom
          ? _customActivity.text.trim()
          : null,
      initialDestination: _where.text.trim(),
      initialDate: _dateLabel,
      initialActivity: _what.text.trim(),
      initialBudget:
          '${_currency.symbol}$amountText '
          '${_currency.code} per person',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '“${plan.name}” created. Your destination, date, activity and '
          'budget are suggestions; friends can now vote.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final friends = appState.contacts.where((f) => f.id != meId).toList();
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_step == 0)
          _FormSection(
            step: 1,
            title: 'What',
            subtitle:
                'Name your plan, choose the type of outing and invite friends.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Plan name', style: AppText.strong),
                const SizedBox(height: 8),
                TextField(
                  controller: _name,
                  maxLength: 40,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'e.g. Café hopping in Seongsu',
                    errorText: _triedStep ? _nameError : null,
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Type of outing', style: AppText.strong),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final t in ActivityType.values)
                      _TypeCard(
                        type: t,
                        selected: _type == t,
                        onTap: () => _selectActivityType(t),
                      ),
                  ],
                ),
                if (_type == ActivityType.custom) ...[
                  const SizedBox(height: 14),
                  if (appState.customActivities.isNotEmpty) ...[
                    const Text('Your saved activities', style: AppText.strong),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final activity in appState.customActivities)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ChoiceChip(
                                label: Text(activity),
                                selected: _customActivity.text == activity,
                                onSelected: (_) => setState(() {
                                  _customActivity.text = activity;
                                }),
                              ),
                              IconButton(
                                tooltip: 'Delete activity: $activity',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 19,
                                ),
                                onPressed: () => _deleteActivity(activity),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextField(
                    controller: _customActivity,
                    onChanged: (_) => setState(() {}),
                    maxLength: 60,
                    decoration: const InputDecoration(
                      labelText: 'Custom activity',
                      hintText: 'e.g. Café hopping and vintage shopping',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _saveCustomActivity,
                    icon: const Icon(Icons.add),
                    label: const Text('Save to my activities'),
                  ),
                  const Text(
                    'Deleting a saved activity will not change existing plans.',
                    style: AppText.small,
                  ),
                ],
                if (_triedStep && _typeError != null) _ErrorText(_typeError!),
                const SizedBox(height: 20),
                const Divider(color: AppColors.line),
                const SizedBox(height: 12),
                const Text('Invite friends', style: AppText.strong),
                const SizedBox(height: 6),
                const Text(
                  'You are the host. Choose or add at least one friend.',
                  style: AppText.small,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final f in friends)
                      _FriendChip(
                        friend: f,
                        selected: _invited.contains(f.id),
                        onTap: () => _toggleFriend(f.id),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newFriend,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _addFriend(),
                        decoration: const InputDecoration(
                          hintText: 'Add a friend by name',
                          prefixIcon: Icon(Icons.person_add_alt_1_outlined),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: _addFriend,
                      tooltip: 'Add friend',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.ink,
                      ),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                if (_triedStep && _friendsError != null)
                  _ErrorText(_friendsError!),
              ],
            ),
          ),
        if (_step == 1)
          _FormSection(
            step: 2,
            title: 'Where',
            subtitle: 'Suggest a destination or location for the group vote.',
            child: TextField(
              controller: _where,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 180,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Destination / location',
                hintText: 'e.g. Seongsu-dong, Seoul',
                errorText: _triedStep ? _whereError : null,
              ),
            ),
          ),
        if (_step == 2)
          _FormSection(
            step: 3,
            title: 'When',
            subtitle:
                'Suggest a date${_type == ActivityType.holiday ? ' range' : ' and optional time'} for the group vote.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    _dateLabel.isEmpty ? 'Choose a date' : _dateLabel,
                  ),
                ),
                if (_type != ActivityType.holiday && _selectedDate != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _selectedTime == null
                          ? 'Add time (optional)'
                          : 'Change time',
                    ),
                  ),
                ],
                if (_triedStep && _whenError != null) _ErrorText(_whenError!),
              ],
            ),
          ),
        if (_step == 3)
          _FormSection(
            step: 4,
            title: 'What We’ll Do',
            subtitle:
                'Suggest an activity. Friends can add alternatives and vote later.',
            child: TextField(
              controller: _what,
              maxLines: 3,
              maxLength: 180,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Activity suggestion',
                hintText: 'e.g. Visit three cafés and browse pop-up stores',
                errorText: _triedStep ? _whatError : null,
              ),
            ),
          ),
        if (_step == 4)
          _FormSection(
            step: 5,
            title: 'Budget',
            subtitle: 'Choose a currency and suggest a budget per person.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<BudgetCurrency>(
                  value: _currency,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: [
                    for (final c in BudgetCurrency.values)
                      DropdownMenuItem(
                        value: c,
                        child: Text('${c.code} (${c.symbol})'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _currency = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _budgetAmount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Amount per person',
                    hintText: 'e.g. 40000',
                    errorText: _triedStep ? _budgetError : null,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Amounts are not converted automatically. The group can suggest other budgets.',
                  style: AppText.small,
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (_step > 0)
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _step--;
                  _triedStep = false;
                }),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous step'),
              ),
            if (_step < _stepCount - 1)
              FilledButton.icon(
                onPressed: _nextStep,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continue'),
              ),
          ],
        ),
      ],
    );

    final preview = _PlanPreview(
      name: _name.text.trim(),
      type: _type,
      memberIds: [meId, ..._invited],
      customActivityName: _customActivity.text.trim(),
      onSubmit: _submit,
    );

    return PageBody(
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            foregroundColor: AppColors.inkSoft,
          ),
          onPressed: () => appState.goTo(AppScreen.home),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Back to home'),
        ),
        const SizedBox(height: 8),
        const ScreenHeader(
          title: 'Create a plan',
          subtitle:
              'What → Where → When → What We’ll Do → Budget. '
              'Your group can then vote on each suggestion.',
        ),
        const SizedBox(height: 20),
        Text('Step ${_step + 1} of $_stepCount', style: AppText.strong),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: (_step + 1) / _stepCount,
            minHeight: 8,
            color: AppColors.mauve,
            backgroundColor: AppColors.mist,
          ),
        ),
        const SizedBox(height: 24),
        if (wide && _step == _stepCount - 1)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: form),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: preview),
            ],
          )
        else ...[
          form,
          if (_step == _stepCount - 1) ...[const SizedBox(height: 16), preview],
        ],
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.step,
    required this.title,
    required this.child,
    this.subtitle,
  });
  final int step;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.blush,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$step',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppText.strong.copyWith(fontSize: 17),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: AppText.muted),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });
  final ActivityType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : type.tint.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? AppColors.ink : Colors.transparent),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 124,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 8),
                Text(
                  type.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendChip extends StatelessWidget {
  const _FriendChip({
    required this.friend,
    required this.selected,
    required this.onTap,
  });
  final Friend friend;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.blush : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? AppColors.mauve : AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Avatar(friend: friend, size: 30),
              const SizedBox(width: 8),
              Text(
                friend.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check, size: 16, color: AppColors.mauve),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Live preview of the plan being created, with the submit button.
class _PlanPreview extends StatelessWidget {
  const _PlanPreview({
    required this.name,
    required this.type,
    required this.memberIds,
    required this.onSubmit,
    this.customActivityName = '',
  });
  final String name;
  final ActivityType? type;
  final List<String> memberIds;
  final String customActivityName;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final t = type;
    final tint = t?.tint ?? AppColors.mist;
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [tint, Color.lerp(tint, Colors.white, 0.6)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: TagChip(
                    'Preview',
                    icon: Icons.visibility_outlined,
                    color: Colors.white,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    t?.emoji ?? '✨',
                    style: const TextStyle(fontSize: 46),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Untitled plan' : name,
                  style: AppText.display(
                    24,
                    color: name.isEmpty ? AppColors.muted : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t == ActivityType.custom && customActivityName.isNotEmpty
                      ? customActivityName
                      : (t?.label ?? 'Activity not chosen yet'),
                  style: AppText.muted,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    AvatarStack(ids: memberIds, size: 30, max: 6),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        memberIds.length == 1
                            ? 'Just you so far'
                            : 'You + ${memberIds.length - 1} '
                                  '${memberIds.length == 2 ? 'friend' : 'friends'}',
                        style: AppText.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(color: AppColors.line, height: 1),
                const SizedBox(height: 16),
                const Text('Your group will vote on', style: AppText.small),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in OptionCategory.values)
                      TagChip(c.label, icon: c.icon),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Create plan and start voting'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// screens/group_planning_screen.dart
// ======================================================================
class GroupPlanningScreen extends StatelessWidget {
  const GroupPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = appState.selectedPlan;
    if (plan == null) {
      return PageBody(
        children: [
          EmptyState(
            icon: Icons.how_to_vote_outlined,
            title: 'No plans yet',
            message: 'Create a plan and invite your friends to start voting.',
            actionLabel: 'Create a Plan',
            onAction: () => appState.goTo(AppScreen.createPlan),
          ),
        ],
      );
    }
    final finalized = plan.isFinalized;

    return PageBody(
      children: [
        PlanSwitcher(current: plan),
        const SizedBox(height: 12),
        JourneyBar(plan: plan),
        const SizedBox(height: 26),
        ScreenHeader(
          kicker:
              '${plan.type.emoji}  ${plan.activityLabel} with ${plan.memberIds.length} people',
          title: plan.name,
          subtitle: finalized
              ? 'Voting is closed. Here’s how everyone voted.'
              : 'Suggest options, vote for your favourite in each category, '
                    'then confirm the winners together.',
          trailing: AvatarStack(ids: plan.memberIds, size: 36, max: 6),
        ),
        const SizedBox(height: 22),
        if (finalized)
          _ConfirmedBanner(plan: plan)
        else
          ResponsiveGrid(
            minItemWidth: 380,
            children: [
              VoterBar(plan: plan),
              _ProgressCard(plan: plan),
            ],
          ),
        const SizedBox(height: 16),
        ResponsiveGrid(
          minItemWidth: 400,
          children: [
            for (final c in OptionCategory.values)
              _CategoryBoard(plan: plan, category: c),
          ],
        ),
        if (!finalized) ...[
          const SizedBox(height: 20),
          _ConfirmBar(plan: plan),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final total = plan.memberIds.length;
    final voted = appState.membersFullyVoted(plan);
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$voted of $total have voted in every category',
            style: AppText.strong,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : voted / total,
              minHeight: 8,
              backgroundColor: AppColors.mist,
              color: AppColors.mauve,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              for (final id in plan.memberIds)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Avatar(friend: appState.friend(id), size: 24),
                    const SizedBox(width: 6),
                    Text(
                      appState.displayName(id),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      appState.hasVotedAll(plan, id)
                          ? Icons.check_circle
                          : Icons.schedule,
                      size: 15,
                      color: appState.hasVotedAll(plan, id)
                          ? AppColors.mauve
                          : AppColors.muted,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryBoard extends StatelessWidget {
  const _CategoryBoard({required this.plan, required this.category});
  final Plan plan;
  final OptionCategory category;

  @override
  Widget build(BuildContext context) {
    final options = plan.optionsFor(category);
    final voter = appState.voterFor(plan);
    final leaders = appState.leaders(plan, category);
    final tie = leaders.length > 1;
    final categoryIcon = switch (category) {
      OptionCategory.destination => Icons.location_on,
      OptionCategory.dates => Icons.event,
      OptionCategory.activity => Icons.local_activity_outlined,
      OptionCategory.budget => Icons.payments_outlined,
    };

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.mist,
                  shape: BoxShape.circle,
                ),
                child: Icon(categoryIcon, size: 21, color: AppColors.inkSoft),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: AppText.strong.copyWith(fontSize: 17),
                    ),
                    Text(
                      options.isEmpty
                          ? 'No suggestions yet'
                          : '${options.length} ${options.length == 1 ? 'suggestion' : 'suggestions'}',
                      style: AppText.small,
                    ),
                  ],
                ),
              ),
              if (!plan.isFinalized)
                TextButton.icon(
                  onPressed: () => showSuggestSheet(context, plan, category),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Suggest'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (options.isEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: plan.isFinalized
                  ? null
                  : () => showSuggestSheet(context, plan, category),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.porcelain,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Be the first to suggest something.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.hint,
                      textAlign: TextAlign.center,
                      style: AppText.small,
                    ),
                  ],
                ),
              ),
            )
          else
            for (final o in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OptionTile(
                  plan: plan,
                  option: o,
                  isMine: o.voterIds.contains(voter),
                  isLeader: leaders.contains(o),
                  isTie: tie,
                  isWinner: plan.confirmed[category] == o,
                  canDelete: !plan.isFinalized && o.suggestedBy == voter,
                ),
              ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.plan,
    required this.option,
    required this.isMine,
    required this.isLeader,
    required this.isTie,
    required this.isWinner,
    required this.canDelete,
  });
  final Plan plan;
  final PlanOption option;
  final bool isMine;
  final bool isLeader;
  final bool isTie;
  final bool isWinner;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final finalized = plan.isFinalized;
    final votes = option.voterIds.length;
    final total = plan.memberIds.length;
    final highlighted = finalized ? isWinner : isMine;

    final String? badge = finalized
        ? (isWinner ? 'Winner' : null)
        : (isLeader ? (isTie ? 'Tied' : 'Leading') : null);

    final IconData leadingIcon = finalized
        ? (isWinner ? Icons.emoji_events_outlined : Icons.circle_outlined)
        : (isMine ? Icons.check_circle : Icons.radio_button_unchecked);

    return Material(
      color: highlighted
          ? AppColors.blush.withValues(alpha: 0.6)
          : AppColors.porcelain,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlighted ? AppColors.mauve : AppColors.line,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: finalized ? null : () => appState.toggleVote(plan, option),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      leadingIcon,
                      size: 22,
                      color: highlighted ? AppColors.mauve : AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              option.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            if (badge != null)
                              TagChip(
                                badge,
                                icon: badge == 'Tied'
                                    ? Icons.balance
                                    : Icons.emoji_events,
                                color: AppColors.butter,
                              ),
                          ],
                        ),
                        if (option.note != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            option.note!,
                            style: AppText.muted.copyWith(fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          'Suggested by ${appState.displayName(option.suggestedBy)}',
                          style: AppText.small,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$votes', style: AppText.display(24)),
                      Text(votes == 1 ? 'vote' : 'votes', style: AppText.small),
                    ],
                  ),
                  if (canDelete)
                    IconButton(
                      tooltip: 'Remove my suggestion',
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        if (option.category != OptionCategory.activity) {
                          appState.removeOption(plan, option);
                          return;
                        }
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete activity suggestion?'),
                            content: Text(
                              'Delete "${option.title}" from this plan?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete activity'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) appState.removeOption(plan, option);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.muted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : votes / total,
                        minHeight: 6,
                        backgroundColor: Colors.white,
                        color: AppColors.mauve,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AvatarStack(ids: option.voterIds.toList(), size: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final ready = appState.canConfirm(plan);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 16,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to lock it in?',
                  style: AppText.display(24, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  ready
                      ? 'The option with the most votes wins each category. '
                            'A tie goes to whichever was suggested first.'
                      : 'Each category needs at least one suggestion before you can confirm.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blush,
              foregroundColor: AppColors.ink,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.15),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
            ),
            onPressed: ready ? () => _confirm(context, plan) : null,
            icon: const Icon(Icons.check),
            label: const Text('Confirm plan'),
          ),
        ],
      ),
    );
  }
}

class _ConfirmedBanner extends StatelessWidget {
  const _ConfirmedBanner({required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.mint.withValues(alpha: 0.6),
      borderColor: Colors.transparent,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.ink),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Confirmed: ${plan.whereLabel}, ${plan.whenLabel}',
                  style: AppText.strong,
                ),
              ),
            ],
          ),
          FilledButton(
            onPressed: () => appState.goTo(AppScreen.finalizedPlan),
            child: const Text('View finalized plan'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheets and dialogs
// ---------------------------------------------------------------------------

Future<void> showSuggestSheet(
  BuildContext context,
  Plan plan,
  OptionCategory category,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.porcelain,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _SuggestSheet(plan: plan, category: category),
  );
}

class _SuggestSheet extends StatefulWidget {
  const _SuggestSheet({required this.plan, required this.category});
  final Plan plan;
  final OptionCategory category;

  @override
  State<_SuggestSheet> createState() => _SuggestSheetState();
}

class _SuggestSheetState extends State<_SuggestSheet> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String? _error;
  late BudgetCurrency _budgetCurrency;

  @override
  void initState() {
    super.initState();
    _budgetCurrency = widget.plan.currency;
  }

  DateTime? _selectedDate;
  DateTimeRange? _selectedRange;
  TimeOfDay? _selectedTime;

  bool get _isDate => widget.category == OptionCategory.dates;
  bool get _isTrip => widget.plan.type == ActivityType.holiday;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    if (_isTrip) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: start,
        lastDate: DateTime(now.year + 5, 12, 31),
        initialDateRange: _selectedRange,
        helpText: 'Choose your trip dates',
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _selectedRange = picked;
        final localizations = MaterialLocalizations.of(context);
        _title.text =
            '${localizations.formatMediumDate(picked.start)} – '
            '${localizations.formatMediumDate(picked.end)}';
        _error = null;
      });
    } else {
      final picked = await showDatePicker(
        context: context,
        firstDate: start,
        lastDate: DateTime(now.year + 5, 12, 31),
        initialDate: _selectedDate != null && !_selectedDate!.isBefore(start)
            ? _selectedDate!
            : start,
        helpText: 'Choose a date',
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _selectedDate = picked;
        _updateDateLabel();
        _error = null;
      });
    }
  }

  void _updateDateLabel() {
    if (_selectedDate == null) return;
    final loc = MaterialLocalizations.of(context);
    final date = loc.formatMediumDate(_selectedDate!);
    final time = _selectedTime == null
        ? ''
        : ', ${loc.formatTimeOfDay(_selectedTime!)}';
    _title.text = '$date$time';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 19, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedTime = picked;
      _updateDateLabel();
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    var suggestion = _title.text;
    if (widget.category == OptionCategory.budget) {
      final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
      if (amount == null || !amount.isFinite || amount <= 0) {
        setState(() => _error = 'Enter a positive budget amount');
        return;
      }
      final display = amount == amount.roundToDouble()
          ? amount.toInt().toString()
          : amount.toStringAsFixed(2);
      suggestion =
          '${_budgetCurrency.symbol}$display ${_budgetCurrency.code} per person';
    }
    final error = appState.addOption(
      widget.plan,
      widget.category,
      suggestion,
      _note.text,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (widget.category == OptionCategory.budget) {
      appState.setCurrency(widget.plan, _budgetCurrency);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final voter = appState.displayName(appState.voterFor(widget.plan));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.line,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Suggest: ${widget.category.label}',
                      style: AppText.display(26),
                    ),
                    const SizedBox(height: 4),
                    Text('Adding as $voter', style: AppText.muted),
                    const SizedBox(height: 18),
                    if (_isDate) ...[
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(
                          _title.text.isEmpty
                              ? (_isTrip
                                    ? 'Choose dates on calendar'
                                    : 'Choose a date on calendar')
                              : _title.text,
                        ),
                      ),
                      if (!_isTrip && _selectedDate != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            _selectedTime == null
                                ? 'Add time (optional)'
                                : 'Change time',
                          ),
                        ),
                      ],
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ] else if (widget.category == OptionCategory.budget) ...[
                      DropdownButtonFormField<BudgetCurrency>(
                        value: _budgetCurrency,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                        ),
                        items: [
                          for (final c in BudgetCurrency.values)
                            DropdownMenuItem(
                              value: c,
                              child: Text('${c.code} (${c.symbol})'),
                            ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _budgetCurrency = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amount,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Amount per person',
                          hintText: 'e.g. 40000',
                          errorText: _error,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Changing currencies does not convert existing budget suggestions.',
                        style: AppText.small,
                      ),
                    ] else
                      TextField(
                        controller: _title,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Your idea',
                          hintText: widget.category.hint,
                          errorText: _error,
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _note,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Why this one? (optional)',
                        hintText: 'e.g. Cheap KTX tickets that weekend',
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _submit,
                      child: const Text('Add suggestion'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _confirm(BuildContext context, Plan plan) async {
  final waiting = plan.memberIds
      .where((id) => !appState.hasVotedAll(plan, id))
      .toList();
  final waitingNames = waiting.map(appState.displayName).join(', ');

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.porcelain,
      title: Text('Confirm the winning plan?', style: AppText.display(26)),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in OptionCategory.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(c.icon, size: 18, color: AppColors.mauve),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.label, style: AppText.small),
                            Text(
                              appState.winner(plan, c)!.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${appState.winner(plan, c)!.voterIds.length} of '
                              '${plan.memberIds.length} votes'
                              '${appState.isTie(plan, c) ? ', tie decided by earliest suggestion' : ''}',
                              style: AppText.small,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (waiting.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.butter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    waiting.length == 1
                        ? '$waitingNames hasn’t voted in every category yet.'
                        : '$waitingNames haven’t voted in every category yet.',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Keep voting'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Confirm plan'),
        ),
      ],
    ),
  );

  if (ok == true) {
    appState.confirmPlan(plan);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan confirmed 🎉 Your shared checklist is ready.'),
        ),
      );
    }
  }
}

// ======================================================================
// screens/finalized_plan_screen.dart
// ======================================================================
class FinalizedPlanScreen extends StatelessWidget {
  const FinalizedPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = appState.selectedPlan;
    if (plan == null || !plan.isFinalized) {
      return NotReadyState(
        plan: plan,
        title: 'Not confirmed yet',
        message:
            'Finish the group vote first. The confirmed details and the '
            'shared checklist will appear here.',
        actionLabel: 'Go to group planning',
        target: AppScreen.groupPlanning,
      );
    }
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final checklist = _ChecklistCard(plan: plan);
    final next = _NextStepCard(plan: plan);

    return PageBody(
      children: [
        PlanSwitcher(current: plan),
        const SizedBox(height: 12),
        JourneyBar(plan: plan),
        const SizedBox(height: 24),
        _ConfirmedHero(plan: plan),
        const SizedBox(height: 18),
        ResponsiveGrid(
          minItemWidth: 230,
          spacing: 14,
          children: [
            for (final c in OptionCategory.values)
              _DetailTile(
                category: c,
                option: plan.confirmed[c],
                total: plan.memberIds.length,
              ),
          ],
        ),
        const SizedBox(height: 18),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: checklist),
              const SizedBox(width: 18),
              Expanded(flex: 2, child: next),
            ],
          )
        else ...[
          checklist,
          const SizedBox(height: 16),
          next,
        ],
      ],
    );
  }
}

class _ConfirmedHero extends StatelessWidget {
  const _ConfirmedHero({required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      padding: EdgeInsets.all(compact ? 22 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            plan.type.tint,
            Color.lerp(plan.type.tint, Colors.white, 0.65)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const TagChip(
                'Confirmed',
                icon: Icons.check_circle,
                color: Colors.white,
              ),
              TagChip(
                '${plan.type.emoji}  ${plan.activityLabel}',
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(plan.name, style: AppText.display(compact ? 30 : 42)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AvatarStack(ids: plan.memberIds, size: 32, max: 6),
              Text(
                '${plan.memberIds.length} going',
                style: AppText.strong.copyWith(fontSize: 14),
              ),
              TextButton(
                onPressed: () => appState.goTo(AppScreen.groupPlanning),
                child: const Text('See how everyone voted'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.category,
    required this.option,
    required this.total,
  });
  final OptionCategory category;
  final PlanOption? option;
  final int total;

  @override
  Widget build(BuildContext context) {
    final o = option;
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 18, color: AppColors.mauve),
              const SizedBox(width: 8),
              Text(category.label, style: AppText.small),
            ],
          ),
          const SizedBox(height: 10),
          Text(o?.title ?? 'Not decided', style: AppText.strong),
          const SizedBox(height: 4),
          Text(
            o == null ? '' : '${o.voterIds.length} of $total votes',
            style: AppText.small,
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.plan});
  final Plan plan;

  Future<void> _editTask(BuildContext context, [ChecklistItem? item]) async {
    final form = GlobalKey<FormState>();
    var title = '';
    final currentId = item?.assigneeId;
    var memberId = currentId != null && plan.memberIds.contains(currentId)
        ? currentId
        : plan.memberIds.first;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item == null ? 'Add a task' : 'Edit assignment'),
        scrollable: true,
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (item == null)
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Task name'),
                  onChanged: (value) => title = value,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Enter a task name' : null,
                )
              else
                Text(item.title),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: memberId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Assigned member'),
                items: [
                  for (final id in plan.memberIds)
                    DropdownMenuItem(
                      value: id,
                      child: Text(
                        appState.displayName(id),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) memberId = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate())
                Navigator.pop(dialogContext, true);
            },
            child: Text(item == null ? 'Add task' : 'Save assignment'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    if (item == null) {
      appState.addChecklistTask(plan, title, memberId);
    } else {
      appState.assignChecklistTask(plan, item, memberId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = plan.checklist.where((i) => i.done).length;
    final total = plan.checklist.length;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Shared checklist', style: AppText.display(24)),
              ),
              Text('$done of $total done', style: AppText.muted),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Split the prep so nothing is left to the last minute.',
            style: AppText.muted,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 8,
              backgroundColor: AppColors.mist,
              color: AppColors.mauve,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in plan.checklist)
            CheckboxListTile(
              value: item.done,
              onChanged: (_) => appState.toggleChecklist(item),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.mauve,
              title: Text(
                item.title,
                style: TextStyle(
                  decoration: item.done ? TextDecoration.lineThrough : null,
                  color: item.done ? AppColors.muted : AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                item.assigneeId == null
                    ? 'Unassigned'
                    : appState.displayName(item.assigneeId!),
              ),
              secondary: IconButton(
                tooltip: 'Edit assignment',
                onPressed: () => _editTask(context, item),
                icon: item.assigneeId == null
                    ? const Icon(Icons.person_add_alt_1_outlined)
                    : Avatar(
                        friend: appState.friend(item.assigneeId!),
                        size: 28,
                      ),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _editTask(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add a task'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final hasTheme = plan.selectedMoodboardId != null;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [AppColors.lavender, AppColors.blush],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.ink),
          const SizedBox(height: 12),
          Text('Now, what to wear', style: AppText.display(24)),
          const SizedBox(height: 8),
          Text(
            'Outfit moodboards suggested for ${plan.whereLabel}, '
            '${(plan.season ?? 'this season').toLowerCase()} and the vibe of your plan.',
            style: const TextStyle(color: AppColors.inkSoft, height: 1.5),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: () => appState.goTo(
                  hasTheme ? AppScreen.outfitPlanner : AppScreen.moodboard,
                ),
                child: Text(
                  hasTheme ? 'Open outfit planner' : 'See moodboards',
                ),
              ),
              if (plan.type == ActivityType.holiday)
                OutlinedButton(
                  onPressed: () => appState.goTo(AppScreen.packingList),
                  child: const Text('Packing list'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// screens/moodboard_screen.dart
// ======================================================================
class MoodboardScreen extends StatelessWidget {
  const MoodboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = appState.selectedPlan;
    if (plan == null || !plan.isFinalized) {
      return NotReadyState(
        plan: plan,
        title: 'Confirm the plan first',
        message:
            'Moodboards are matched to the confirmed place, season and '
            'activity. Finish the group vote to see them.',
        actionLabel: 'Go to group planning',
        target: AppScreen.groupPlanning,
      );
    }
    final boards = availableMoodboardsForPlan(plan);
    final activity =
        plan.confirmed[OptionCategory.activity]?.title ?? plan.type.label;

    return PageBody(
      children: [
        PlanSwitcher(current: plan),
        const SizedBox(height: 12),
        JourneyBar(plan: plan),
        const SizedBox(height: 26),
        ScreenHeader(
          kicker: 'Style moodboards',
          title: 'Looks for ${plan.name}',
          subtitle:
              'Suggested from your confirmed activity and destination using sample '
              'templates. Customize a template or make your own moodboard.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TagChip(
              plan.whereLabel,
              icon: Icons.place_outlined,
              color: Colors.white,
            ),
            TagChip(
              plan.season ?? 'Season to be confirmed',
              icon: Icons.eco_outlined,
              color: Colors.white,
            ),
            TagChip(
              'Sample weather: ${plan.weather ?? 'not available'}',
              icon: Icons.wb_sunny_outlined,
              color: Colors.white,
            ),
            TagChip(
              activity,
              icon: Icons.auto_awesome_outlined,
              color: Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 22),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () => showMoodboardEditor(context, plan),
            icon: const Icon(Icons.add),
            label: const Text('Create my moodboard'),
          ),
        ),
        const SizedBox(height: 20),
        ResponsiveGrid(
          minItemWidth: 300,
          spacing: 18,
          children: [
            for (final b in boards)
              _MoodboardCard(
                plan: plan,
                board: b,
                isGroupPick: plan.selectedMoodboardId == b.id,
              ),
          ],
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () => appState.goTo(AppScreen.styleVoting),
              icon: const Icon(Icons.how_to_vote_outlined),
              label: const Text('Let the group vote'),
            ),
            const Text(
              'Everyone picks a favourite. The winner becomes your dress code.',
              style: AppText.muted,
            ),
          ],
        ),
      ],
    );
  }
}

class _MoodboardCard extends StatelessWidget {
  const _MoodboardCard({
    required this.plan,
    required this.board,
    required this.isGroupPick,
  });
  final Plan plan;
  final Moodboard board;
  final bool isGroupPick;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      borderColor: isGroupPick ? AppColors.mauve : AppColors.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoodCollage(board: board),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(board.name, style: AppText.display(22))),
              if (isGroupPick)
                const TagChip(
                  'Group pick',
                  icon: Icons.star,
                  color: AppColors.butter,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(board.tagline, style: AppText.muted),
          const SizedBox(height: 14),
          PaletteRow(board.palette),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final k in board.keywords) TagChip(k)],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => appState.openStyleVoting(plan, board.id),
            icon: const Icon(Icons.how_to_vote_outlined),
            label: const Text('Select for style voting'),
          ),
          TextButton.icon(
            onPressed: () => showMoodboardEditor(context, plan, initial: board),
            icon: const Icon(Icons.edit_outlined),
            label: Text(
              plan.customMoodboards.any((b) => b.id == board.id)
                  ? 'Edit my moodboard'
                  : 'Customize this moodboard',
            ),
          ),
          if (plan.customMoodboards.any((b) => b.id == board.id))
            OutlinedButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete moodboard?'),
                    content: Text(
                      'Delete "${board.name}"? Its style votes and any locked '
                      'selection will also be cleared.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete moodboard'),
                      ),
                    ],
                  ),
                );
                if (ok == true) appState.deleteCustomMoodboard(plan, board);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Moodboard'),
            ),
        ],
      ),
    );
  }
}

/// Create or customize a moodboard using the existing pastel palette system.
/// This is a form-based prototype, not an AI image-generation feature.
Future<void> showMoodboardEditor(
  BuildContext context,
  Plan plan, {
  Moodboard? initial,
}) async {
  final board = await showModalBottomSheet<Moodboard>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.porcelain,
    builder: (_) => _MoodboardEditor(plan: plan, initial: initial),
  );
  if (board != null) appState.openStyleVoting(plan, board.id);
}

class _MoodboardEditor extends StatefulWidget {
  const _MoodboardEditor({required this.plan, this.initial});
  final Plan plan;
  final Moodboard? initial;

  @override
  State<_MoodboardEditor> createState() => _MoodboardEditorState();
}

class _MoodboardEditorState extends State<_MoodboardEditor> {
  final _name = TextEditingController();
  final _tagline = TextEditingController();
  final _keywords = TextEditingController();
  final _tiles = TextEditingController();
  final _newStyleName = TextEditingController();
  final _newColors = TextEditingController();
  late Moodboard _template;
  late bool _editingCustom;
  late String _paletteChoice;
  late List<Color> _chosenColors;
  String? _error;

  @override
  void initState() {
    super.initState();
    final recommended = moodboardsForPlan(widget.plan);
    final initial = widget.initial;
    _template = initial ?? recommended.first;
    _editingCustom = widget.plan.customMoodboards.any(
      (b) => b.id == initial?.id,
    );
    _paletteChoice = _editingCustom
        ? 'current:${_template.id}'
        : 'template:${_template.id}';
    _chosenColors = List<Color>.of(_template.palette);
    _name.text = initial == null
        ? '${_template.name} Remix'
        : (_editingCustom ? initial.name : '${initial.name} Remix');
    _tagline.text = initial?.tagline ?? _template.tagline;
    _keywords.text = (initial?.keywords ?? _template.keywords).join(', ');
    _tiles.text = (initial?.tiles ?? _template.tiles)
        .map((t) => t.label)
        .join(', ');
  }

  @override
  void dispose() {
    _name.dispose();
    _tagline.dispose();
    _keywords.dispose();
    _tiles.dispose();
    _newStyleName.dispose();
    _newColors.dispose();
    super.dispose();
  }

  List<String> _words(String source) => source
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  /// #RRGGBB (and RRGGBB) hex codes; blank means copy selected palette.
  List<Color>? _parseColors(String text) {
    final values = _words(text);
    if (values.isEmpty) return List<Color>.of(_chosenColors);
    final colors = <Color>[];
    for (final raw in values) {
      final hex = raw.startsWith('#') ? raw.substring(1) : raw;
      if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
      colors.add(Color(0xFF000000 | int.parse(hex, radix: 16)));
    }
    return colors;
  }

  void _addStylePalette() {
    final label = _newStyleName.text.trim();
    if (label.isEmpty) {
      setState(() => _error = 'Type a name for your custom style');
      return;
    }
    final colors = _parseColors(_newColors.text);
    if (colors == null || colors.isEmpty) {
      setState(() => _error = 'Use comma-separated #RRGGBB colours');
      return;
    }
    final style = appState.addCustomStylePalette(widget.plan, label, colors);
    setState(() {
      _paletteChoice = 'custom:${style.id}';
      _chosenColors = List<Color>.of(style.colors);
      _newStyleName.clear();
      _newColors.clear();
      _error = null;
    });
  }

  void _choosePalette(String key, List<Moodboard> recommended) {
    setState(() {
      _paletteChoice = key;
      if (key.startsWith('template:')) {
        final board = recommended.firstWhere(
          (b) => b.id == key.substring('template:'.length),
        );
        _template = board;
        _chosenColors = List<Color>.of(board.palette);
      } else if (key.startsWith('custom:')) {
        final style = widget.plan.customStylePalettes.firstWhere(
          (p) => p.id == key.substring('custom:'.length),
        );
        _chosenColors = List<Color>.of(style.colors);
      } else if (key.startsWith('current:') && widget.initial != null) {
        _template = widget.initial!;
        _chosenColors = List<Color>.of(_template.palette);
      }
      _error = null;
    });
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Give your moodboard a name');
      return;
    }
    final tileLabels = _words(_tiles.text);
    if (tileLabels.isEmpty) {
      setState(() => _error = 'Add at least one visual tile');
      return;
    }
    final board = appState.saveCustomMoodboard(
      widget.plan,
      template: _template,
      editingId: _editingCustom ? widget.initial!.id : null,
      name: _name.text.trim(),
      tagline: _tagline.text.trim(),
      keywords: _words(_keywords.text),
      tileLabels: tileLabels,
      palette: _chosenColors,
    );
    Navigator.of(context).pop(board);
  }

  @override
  Widget build(BuildContext context) {
    final templates = moodboardsForPlan(widget.plan);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 570),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _editingCustom
                          ? 'Edit your moodboard'
                          : 'Customize a moodboard',
                      style: AppText.display(26),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose a suggested palette, or add your own custom style and colours.',
                      style: AppText.muted,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _paletteChoice,
                      decoration: const InputDecoration(
                        labelText: 'Base style / palette',
                      ),
                      items: [
                        for (final board in templates)
                          DropdownMenuItem(
                            value: 'template:${board.id}',
                            child: Text(board.name),
                          ),
                        if (_editingCustom)
                          DropdownMenuItem(
                            value: 'current:${widget.initial!.id}',
                            child: const Text('Current moodboard palette'),
                          ),
                        for (final style in widget.plan.customStylePalettes)
                          DropdownMenuItem(
                            value: 'custom:${style.id}',
                            child: Text(style.name),
                          ),
                      ],
                      onChanged: (key) {
                        if (key != null) _choosePalette(key, templates);
                      },
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: PaletteRow(_chosenColors),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Add your own style / palette',
                      style: AppText.strong,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newStyleName,
                      decoration: const InputDecoration(
                        labelText: 'Custom style name',
                        hintText: 'e.g. Vintage Autumn, Cyber Chic, Café Core',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _newColors,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Palette colours (optional)',
                        hintText: '#B05F82, #EEEAF1, #DCD5F0',
                        helperText:
                            'Comma-separated hex colours; blank = use selected palette',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _addStylePalette,
                      icon: const Icon(Icons.add),
                      label: const Text('Add and select custom style'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _name,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        labelText: 'Moodboard name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _tagline,
                      maxLength: 140,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _keywords,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Style keywords (comma separated)',
                        hintText: 'Knitwear, Sneakers, Neutral',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _tiles,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Moodboard tile labels (comma separated)',
                        hintText: 'Oversized knit, Tote bag, Loafers',
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: const Text('Save moodboard'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Outfit suggestions still use the selected sample template. '
                      'Custom styles and moodboards are in memory until reload.',
                      style: AppText.small,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// screens/style_voting_screen.dart
// ======================================================================
class StyleVotingScreen extends StatelessWidget {
  const StyleVotingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = appState.selectedPlan;
    if (plan == null || !plan.isFinalized) {
      return NotReadyState(
        plan: plan,
        title: 'Confirm the plan first',
        message: 'Style voting opens once your group has confirmed the plan.',
        actionLabel: 'Go to group planning',
        target: AppScreen.groupPlanning,
      );
    }
    final boards = [...availableMoodboardsForPlan(plan)];
    final previewId = appState.stylePreviewFor(plan);
    final preview = boards.indexWhere((board) => board.id == previewId);
    if (preview > 0) {
      final board = boards.removeAt(preview);
      boards.insert(0, board);
    }
    final voter = appState.voterFor(plan);
    final leader = appState.styleLeader(plan);
    final chosen = moodboardById(plan.selectedMoodboardId);

    return PageBody(
      children: [
        PlanSwitcher(current: plan),
        const SizedBox(height: 12),
        JourneyBar(plan: plan),
        const SizedBox(height: 26),
        const ScreenHeader(
          kicker: 'Group style vote',
          title: 'Pick the group’s look',
          subtitle:
              'Everyone votes for one moodboard. The winner becomes the '
              'dress code for the whole group. Voting is simulated in this prototype.',
        ),
        const SizedBox(height: 18),
        if (chosen != null) ...[
          SoftCard(
            color: AppColors.butter.withValues(alpha: 0.7),
            borderColor: Colors.transparent,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Text(
                  'Your group’s look: ${chosen.name}',
                  style: AppText.strong,
                ),
                FilledButton(
                  onPressed: () => appState.goTo(AppScreen.outfitPlanner),
                  child: const Text('Open outfit planner'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () =>
                appState.goTo(AppScreen.moodboard, planId: plan.id),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Browse moodboards'),
          ),
        ),
        VoterBar(plan: plan),
        const SizedBox(height: 16),
        ResponsiveGrid(
          minItemWidth: 300,
          spacing: 18,
          children: [
            for (final b in boards)
              _StyleVoteCard(
                plan: plan,
                board: b,
                myVote: plan.styleVotes[voter] == b.id,
                leading: leader == b.id,
              ),
          ],
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: leader == null
                ? null
                : () {
                    appState.lockStyle(plan);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${moodboardById(leader)!.name} is your group’s look ✨',
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.lock_outline),
            label: Text(
              chosen == null
                  ? 'Lock in the winning look'
                  : 'Update the group’s look',
            ),
          ),
        ),
      ],
    );
  }
}

class _StyleVoteCard extends StatelessWidget {
  const _StyleVoteCard({
    required this.plan,
    required this.board,
    required this.myVote,
    required this.leading,
  });
  final Plan plan;
  final Moodboard board;
  final bool myVote;
  final bool leading;

  @override
  Widget build(BuildContext context) {
    final voters = appState.styleVotersFor(plan, board.id);
    return SoftCard(
      padding: const EdgeInsets.all(14),
      borderColor: myVote ? AppColors.mauve : AppColors.line,
      onTap: () => appState.voteStyle(plan, board.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 130,
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: MoodTile(
                      label: board.tiles[i % board.tiles.length].label,
                      icon: board.tiles[i % board.tiles.length].icon,
                      color: board.palette[i % board.palette.length],
                      height: 130,
                      showLabel: false,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(board.name, style: AppText.display(21))),
              if (leading)
                const TagChip(
                  'Leading',
                  icon: Icons.emoji_events,
                  color: AppColors.butter,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(board.tagline, style: AppText.muted),
          const SizedBox(height: 14),
          Row(
            children: [
              AvatarStack(ids: voters, size: 26),
              if (voters.isNotEmpty) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${voters.length} ${voters.length == 1 ? 'vote' : 'votes'}',
                  style: AppText.muted,
                ),
              ),
              myVote
                  ? FilledButton.icon(
                      onPressed: () => appState.voteStyle(plan, board.id),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Voted'),
                    )
                  : OutlinedButton(
                      onPressed: () => appState.voteStyle(plan, board.id),
                      child: const Text('Vote'),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// screens/outfit_planner_screen.dart
// ======================================================================
class OutfitPlannerScreen extends StatefulWidget {
  const OutfitPlannerScreen({super.key});

  @override
  State<OutfitPlannerScreen> createState() => _OutfitPlannerScreenState();
}

class _OutfitPlannerScreenState extends State<OutfitPlannerScreen> {
  bool _savedOnly = false;

  @override
  Widget build(BuildContext context) {
    final plan = appState.selectedPlan;
    if (plan == null || !plan.isFinalized) {
      return NotReadyState(
        plan: plan,
        title: 'Confirm the plan first',
        message:
            'Outfits are planned around the confirmed activity and the group’s look.',
        actionLabel: 'Go to group planning',
        target: AppScreen.groupPlanning,
      );
    }
    final board = moodboardById(plan.selectedMoodboardId);
    if (board == null) {
      return NotReadyState(
        plan: plan,
        title: 'No group look yet',
        message:
            'Vote on a moodboard with your friends. The winner sets the outfits shown here.',
        actionLabel: 'Go to style voting',
        target: AppScreen.styleVoting,
      );
    }

    final shownOutfits = board.outfits
        .where((o) => !_savedOnly || appState.savedOutfitIds.contains(o.id))
        .toList();

    return PageBody(
      children: [
        PlanSwitcher(current: plan),
        const SizedBox(height: 12),
        JourneyBar(plan: plan),
        const SizedBox(height: 26),
        ScreenHeader(
          kicker: 'Outfit planner',
          title: '${board.name} for ${plan.name}',
          subtitle: board.tagline,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Group palette',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            PaletteRow(board.palette, size: 26),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TagChip(plan.whereLabel, icon: Icons.place_outlined),
            TagChip(
              plan.confirmed[OptionCategory.activity]?.title ??
                  plan.activityLabel,
              icon: Icons.auto_awesome_outlined,
            ),
            TagChip(
              'Sample weather: ${plan.weather ?? 'not available'}',
              icon: Icons.wb_sunny_outlined,
            ),
          ],
        ),
        const SizedBox(height: 22),
        SectionTitle(
          title: 'Your outfit ideas',
          subtitle: 'Save favourites with the heart button.',
          trailing: FilterChip(
            label: const Text('Saved only'),
            selected: _savedOnly,
            onSelected: (value) => setState(() => _savedOnly = value),
          ),
        ),
        const SizedBox(height: 14),
        if (shownOutfits.isEmpty)
          const EmptyState(
            icon: Icons.favorite_border,
            title: 'No saved outfits here yet',
            message: 'Turn off Saved only, then save an outfit with the heart.',
          )
        else
          ResponsiveGrid(
            minItemWidth: 300,
            spacing: 18,
            children: [
              for (final o in shownOutfits)
                _OutfitCard(
                  outfit: o,
                  board: board,
                  saved: appState.savedOutfitIds.contains(o.id),
                ),
            ],
          ),
        if (plan.type == ActivityType.holiday) ...[
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => appState.goTo(AppScreen.packingList),
              icon: const Icon(Icons.luggage_outlined),
              label: const Text('See the packing list'),
            ),
          ),
        ],
      ],
    );
  }
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({
    required this.outfit,
    required this.board,
    required this.saved,
  });
  final Outfit outfit;
  final Moodboard board;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final p = board.palette;
    final second = outfit.pieces.length > 1
        ? outfit.pieces[1]
        : outfit.accessories.first;
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 176,
            child: Row(
              children: [
                Expanded(
                  child: MoodTile(
                    label: outfit.pieces.first,
                    icon: Icons.checkroom_outlined,
                    color: p[0],
                    height: 176,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      MoodTile(
                        label: second,
                        icon: Icons.dry_cleaning_outlined,
                        color: p[1 % p.length],
                        height: 84,
                      ),
                      const SizedBox(height: 8),
                      MoodTile(
                        label: outfit.accessories.first,
                        icon: Icons.diamond_outlined,
                        color: p[2 % p.length],
                        height: 84,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(outfit.name, style: AppText.display(21))),
              IconButton(
                tooltip: saved ? 'Remove from saved' : 'Save outfit',
                onPressed: () => appState.toggleSavedOutfit(outfit.id),
                icon: Icon(
                  saved ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.mauve,
                ),
              ),
            ],
          ),
          TagChip(outfit.occasion, icon: Icons.event_outlined),
          const SizedBox(height: 14),
          const Text('Clothes', style: AppText.small),
          const SizedBox(height: 4),
          for (final piece in outfit.pieces)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '• $piece',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(height: 12),
          const Text('Accessories', style: AppText.small),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final a in outfit.accessories)
                TagChip(a, color: AppColors.blush),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// screens/packing_list_screen.dart
// ======================================================================
class PackingListScreen extends StatelessWidget {
  const PackingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = appState.selectedPlan;
    if (plan == null || !plan.isFinalized) {
      return NotReadyState(
        plan: plan,
        title: 'Confirm the plan first',
        message:
            'The packing list uses the confirmed destination, dates and outfits.',
        actionLabel: 'Go to group planning',
        target: AppScreen.groupPlanning,
      );
    }
    if (plan.type != ActivityType.holiday) {
      return NotReadyState(
        plan: plan,
        title: 'Packing lists are for trips',
        message: 'Switch to a holiday plan to see a packing list.',
      );
    }
    if (plan.packing.isEmpty) {
      return PageBody(
        children: [
          PlanSwitcher(current: plan),
          EmptyState(
            icon: Icons.luggage_outlined,
            title: 'No packing list yet',
            message: 'Build one from your trip length, activities and outfits.',
            actionLabel: 'Build packing list',
            onAction: () => appState.generatePacking(plan),
          ),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => showPackingItemEditor(context, plan),
              icon: const Icon(Icons.add),
              label: const Text('Add packing item'),
            ),
          ),
        ],
      );
    }

    final board = moodboardById(plan.selectedMoodboardId);
    final grouped = <String, List<PackingItem>>{};
    for (final item in plan.packing) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    final packed = plan.packing.where((i) => i.packed).length;
    final total = plan.packing.length;

    return PageBody(
      children: [
        PlanSwitcher(current: plan),
        const SizedBox(height: 12),
        JourneyBar(plan: plan),
        const SizedBox(height: 26),
        ScreenHeader(
          kicker: 'Smart packing list',
          title: 'Packing for ${plan.whereLabel}',
          subtitle:
              'Based on ${plan.tripDays ?? 3} days, sample weather: ${plan.weather ?? 'not available'}'
              '${board == null ? '' : ' and your ${board.name} outfits'}.',
          trailing: OutlinedButton.icon(
            onPressed: () => showPackingItemEditor(context, plan),
            icon: const Icon(Icons.add),
            label: const Text('Add packing item'),
          ),
        ),
        const SizedBox(height: 18),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$packed of $total packed',
                      style: AppText.display(24),
                    ),
                  ),
                  if (packed == total)
                    const TagChip('Ready to go 🧳', color: AppColors.mint),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : packed / total,
                  minHeight: 10,
                  backgroundColor: AppColors.mist,
                  color: AppColors.mauve,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ResponsiveGrid(
          minItemWidth: 300,
          children: [
            for (final entry in grouped.entries)
              _PackingGroup(plan: plan, title: entry.key, items: entry.value),
          ],
        ),
      ],
    );
  }
}

class _PackingGroup extends StatelessWidget {
  const _PackingGroup({
    required this.plan,
    required this.title,
    required this.items,
  });
  final Plan plan;
  final String title;
  final List<PackingItem> items;

  @override
  Widget build(BuildContext context) {
    final done = items.where((i) => i.packed).length;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppText.strong)),
              Text('$done/${items.length}', style: AppText.muted),
            ],
          ),
          const SizedBox(height: 4),
          for (final item in items)
            CheckboxListTile(
              value: item.packed,
              onChanged: (_) => appState.togglePacked(item),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: AppColors.mauve,
              title: Text(
                item.title,
                style: TextStyle(
                  fontSize: 14,
                  decoration: item.packed ? TextDecoration.lineThrough : null,
                  color: item.packed ? AppColors.muted : AppColors.ink,
                ),
              ),
              secondary: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit ${item.title}',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.edit_outlined, size: 19),
                    onPressed: () =>
                        showPackingItemEditor(context, plan, item: item),
                  ),
                  IconButton(
                    tooltip: 'Delete ${item.title}',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline, size: 19),
                    onPressed: () =>
                        confirmDeletePackingItem(context, plan, item),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Add or rename an item without resetting its checkbox or other trip items.
Future<void> showPackingItemEditor(
  BuildContext context,
  Plan plan, {
  PackingItem? item,
}) async {
  final controller = TextEditingController(text: item?.title ?? '');
  final categories = <String>{
    'Essentials',
    'Basics',
    'Outfits',
    'Accessories',
    'Toiletries',
    'Tech',
    'Extras',
    ...plan.packing.map((i) => i.category),
  }.toList();
  String category = item?.category ?? 'Extras';
  try {
    final updated = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, updateDialog) => AlertDialog(
          title: Text(item == null ? 'Add packing item' : 'Edit packing item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Item name'),
                onChanged: (_) => updateDialog(() {}),
                onSubmitted: (_) {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.of(dialogContext).pop(controller.text.trim());
                  }
                },
              ),
              if (item == null) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: category,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (v) {
                    if (v != null) updateDialog(() => category = v);
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: controller.text.trim().isEmpty
                  ? null
                  : () =>
                        Navigator.of(dialogContext).pop(controller.text.trim()),
              child: Text(item == null ? 'Add item' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
    if (updated == null || updated.trim().isEmpty) return;
    if (item == null) {
      appState.addPackingItem(plan, updated, category);
    } else {
      appState.editPackingItem(plan, item, updated);
    }
  } finally {
    // Dispose once the dialog is finished (not while its field is still shown).
    controller.dispose();
  }
}

Future<void> confirmDeletePackingItem(
  BuildContext context,
  Plan plan,
  PackingItem item,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete packing item?'),
      content: Text('Remove "${item.title}" from this trip?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Delete item'),
        ),
      ],
    ),
  );
  if (confirmed == true) appState.deletePackingItem(plan, item);
}

// ======================================================================
// screens/my_plans_screen.dart
// ======================================================================
class MyPlansScreen extends StatefulWidget {
  const MyPlansScreen({super.key});

  @override
  State<MyPlansScreen> createState() => _MyPlansScreenState();
}

class _MyPlansScreenState extends State<MyPlansScreen> {
  String? _activityFilter;
  List<String> _randomFilterOrder = [];

  /// The list is shuffled only if the set of categories actually changes.
  /// Choosing a filter never reshuffles the dropdown while it is open.
  void _updateActivityOptions() {
    final present = appState.plans.map((p) => p.activityLabel).toSet();
    if (_randomFilterOrder.toSet().length != present.length ||
        !_randomFilterOrder.toSet().containsAll(present)) {
      _randomFilterOrder = present.toList()..shuffle(math.Random());
    }
    if (_activityFilter != null && !present.contains(_activityFilter)) {
      _activityFilter = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateActivityOptions();
    final filtered = appState.plans
        .where(
          (p) => _activityFilter == null || p.activityLabel == _activityFilter,
        )
        .toList();
    final voting = filtered.where((p) => !p.isFinalized).toList();
    final confirmed = filtered.where((p) => p.isFinalized).toList();

    return PageBody(
      children: [
        ScreenHeader(
          title: 'My Plans',
          subtitle: 'Your plans, organized by voting status.',
          trailing: FilledButton.icon(
            onPressed: () => appState.goTo(AppScreen.createPlan),
            icon: const Icon(Icons.add),
            label: const Text('New plan'),
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: DropdownButtonFormField<String>(
            // Recreate the FormField when the chosen activity disappears.
            // Otherwise it can retain a deleted value and assert at runtime.
            key: ValueKey<String>(_activityFilter ?? ''),
            value: _activityFilter ?? '',
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Filter by Activity'),
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Text('All Activities'),
              ),
              for (final activity in _randomFilterOrder)
                DropdownMenuItem<String>(
                  value: activity,
                  child: Text(activity, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (activity) => setState(() {
              _activityFilter = activity == null || activity.isEmpty
                  ? null
                  : activity;
            }),
          ),
        ),
        const SizedBox(height: 30),
        SectionTitle(
          title: 'Still Voting',
          subtitle: _count(voting.length, 'plan'),
        ),
        const SizedBox(height: 14),
        if (voting.isEmpty)
          Text(
            appState.plans.isEmpty
                ? 'No plans yet. Create your first plan.'
                : 'No plans awaiting votes for this activity.',
            style: AppText.muted,
          )
        else
          ResponsiveGrid(
            minItemWidth: 290,
            children: [
              for (final p in voting)
                _PlanCardWithDelete(plan: p, compact: false),
            ],
          ),
        const SizedBox(height: 34),
        SectionTitle(
          title: 'Confirmed',
          subtitle: _count(confirmed.length, 'plan'),
        ),
        const SizedBox(height: 14),
        if (confirmed.isEmpty)
          Text(
            appState.plans.isEmpty
                ? 'No confirmed plans yet.'
                : 'No confirmed plans for this activity.',
            style: AppText.muted,
          )
        else
          ResponsiveGrid(
            minItemWidth: 290,
            children: [
              for (final p in confirmed)
                _PlanCardWithDelete(plan: p, compact: true),
            ],
          ),
      ],
    );
  }

  static String _count(int n, String noun) =>
      '$n ${n == 1 ? noun : '${noun}s'}';
}

/// Plan overview cards retain their original design and navigation.
/// Deletion is a separate control, so a click never opens the plan by mistake.
class _PlanCardWithDelete extends StatelessWidget {
  const _PlanCardWithDelete({required this.plan, required this.compact});
  final Plan plan;
  final bool compact;

  Future<void> _confirmDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: Text(
          'Permanently delete "${plan.name}" and its votes, custom '
          'moodboards and other plan-specific data? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete Plan'),
          ),
        ],
      ),
    );
    if (confirmed == true) appState.deletePlan(plan);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (compact)
          CompactConfirmedPlanCard(plan: plan)
        else
          PlanPreviewCard(plan: plan),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _confirmDeletion(context),
            icon: const Icon(Icons.delete_outline, size: 19),
            label: const Text('Delete Plan'),
          ),
        ),
      ],
    );
  }
}
