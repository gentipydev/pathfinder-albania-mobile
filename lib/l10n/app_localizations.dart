import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sq.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('sq')];

  /// No description provided for @localeSwapButton.
  ///
  /// In en, this message translates to:
  /// **'Shqip'**
  String get localeSwapButton;

  /// No description provided for @animatedArrowSemanticSwipe.
  ///
  /// In en, this message translates to:
  /// **'Explore details about {title}.'**
  String animatedArrowSemanticSwipe(Object title);

  /// No description provided for @appBarTitleFactsHistory.
  ///
  /// In en, this message translates to:
  /// **'Facts and History'**
  String get appBarTitleFactsHistory;

  /// No description provided for @appBarTitleConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction'**
  String get appBarTitleConstruction;

  /// No description provided for @appBarTitleLocation.
  ///
  /// In en, this message translates to:
  /// **'Location Info'**
  String get appBarTitleLocation;

  /// No description provided for @bottomScrubberSemanticTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline Scrubber, drag horizontally to navigate the timeline.'**
  String get bottomScrubberSemanticTimeline;

  /// No description provided for @collectionLabelDiscovered.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% discovered'**
  String collectionLabelDiscovered(Object percentage);

  /// No description provided for @collectionLabelCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total}'**
  String collectionLabelCount(Object count, Object total);

  /// No description provided for @collectionButtonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset Collection'**
  String get collectionButtonReset;

  /// No description provided for @eventsListButtonOpenTimeline.
  ///
  /// In en, this message translates to:
  /// **'Open the story timeline'**
  String get eventsListButtonOpenTimeline;

  /// No description provided for @newlyDiscoveredSemanticNew.
  ///
  /// In en, this message translates to:
  /// **'{count} new item{suffix} to explore. Scroll to new item'**
  String newlyDiscoveredSemanticNew(Object count, Object suffix);

  /// No description provided for @newlyDiscoveredLabelNew.
  ///
  /// In en, this message translates to:
  /// **'{count} new item{suffix} to explore'**
  String newlyDiscoveredLabelNew(Object count, Object suffix);

  /// No description provided for @scrollingContentSemanticYoutube.
  ///
  /// In en, this message translates to:
  /// **'Youtube thumbnail'**
  String get scrollingContentSemanticYoutube;

  /// No description provided for @scrollingContentSemanticOpen.
  ///
  /// In en, this message translates to:
  /// **'Open fullscreen maps view'**
  String get scrollingContentSemanticOpen;

  /// No description provided for @timelineSemanticDate.
  ///
  /// In en, this message translates to:
  /// **'{fromDate} to {endDate}'**
  String timelineSemanticDate(Object fromDate, Object endDate);

  /// No description provided for @titleLabelDate.
  ///
  /// In en, this message translates to:
  /// **'{fromDate} to {endDate}'**
  String titleLabelDate(Object fromDate, Object endDate);

  /// No description provided for @appModalsButtonOk.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get appModalsButtonOk;

  /// No description provided for @appModalsButtonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get appModalsButtonCancel;

  /// No description provided for @appPageDefaultTitlePage.
  ///
  /// In en, this message translates to:
  /// **'page'**
  String get appPageDefaultTitlePage;

  /// No description provided for @appPageSemanticSwipe.
  ///
  /// In en, this message translates to:
  /// **'{pageTitle} {current} of {total}.'**
  String appPageSemanticSwipe(Object pageTitle, Object current, Object total);

  /// No description provided for @artifactsTitleArtifacts.
  ///
  /// In en, this message translates to:
  /// **'ARTIFACTS'**
  String get artifactsTitleArtifacts;

  /// No description provided for @semanticsPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous {title}'**
  String semanticsPrevious(Object title);

  /// No description provided for @semanticsNext.
  ///
  /// In en, this message translates to:
  /// **'Next {title}'**
  String semanticsNext(Object title);

  /// No description provided for @artifactsSemanticArtifact.
  ///
  /// In en, this message translates to:
  /// **'Artifact'**
  String get artifactsSemanticArtifact;

  /// No description provided for @artifactDetailsLabelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get artifactDetailsLabelDate;

  /// No description provided for @artifactDetailsLabelPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get artifactDetailsLabelPeriod;

  /// No description provided for @artifactDetailsLabelGeography.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get artifactDetailsLabelGeography;

  /// No description provided for @artifactDetailsLabelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get artifactDetailsLabelMedium;

  /// No description provided for @artifactDetailsLabelDimension.
  ///
  /// In en, this message translates to:
  /// **'Dimension'**
  String get artifactDetailsLabelDimension;

  /// No description provided for @artifactDetailsLabelClassification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get artifactDetailsLabelClassification;

  /// No description provided for @artifactDetailsSemanticThumbnail.
  ///
  /// In en, this message translates to:
  /// **'thumbnail image'**
  String get artifactDetailsSemanticThumbnail;

  /// No description provided for @artifactDetailsErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Unable to find info for artifact {artifactId} '**
  String artifactDetailsErrorNotFound(Object artifactId);

  /// No description provided for @circleButtonsSemanticBack.
  ///
  /// In en, this message translates to:
  /// **'back'**
  String get circleButtonsSemanticBack;

  /// No description provided for @collectibleFoundTitleArtifactDiscovered.
  ///
  /// In en, this message translates to:
  /// **'Artifact Discovered'**
  String get collectibleFoundTitleArtifactDiscovered;

  /// No description provided for @collectibleFoundButtonViewCollection.
  ///
  /// In en, this message translates to:
  /// **'view in my collection'**
  String get collectibleFoundButtonViewCollection;

  /// No description provided for @collectibleItemSemanticCollectible.
  ///
  /// In en, this message translates to:
  /// **'collectible item'**
  String get collectibleItemSemanticCollectible;

  /// No description provided for @collectionTitleCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionTitleCollection;

  /// No description provided for @collectionPopupResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset your collection?'**
  String get collectionPopupResetConfirm;

  /// No description provided for @fullscreenImageViewerSemanticFull.
  ///
  /// In en, this message translates to:
  /// **'full screen image, no description available'**
  String get fullscreenImageViewerSemanticFull;

  /// No description provided for @introTitleJourney.
  ///
  /// In en, this message translates to:
  /// **'Step into the past'**
  String get introTitleJourney;

  /// No description provided for @introDescriptionNavigate.
  ///
  /// In en, this message translates to:
  /// **'Three thousand years of Albanian history, from Illyrian hill forts to Ottoman bazaars.'**
  String get introDescriptionNavigate;

  /// No description provided for @introTitleExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore Albania'**
  String get introTitleExplore;

  /// No description provided for @introDescriptionUncover.
  ///
  /// In en, this message translates to:
  /// **'Ancient cities, castle towns and mountain valleys in eight destinations.'**
  String get introDescriptionUncover;

  /// No description provided for @introTitleDiscover.
  ///
  /// In en, this message translates to:
  /// **'Find hidden artifacts'**
  String get introTitleDiscover;

  /// No description provided for @introDescriptionLearn.
  ///
  /// In en, this message translates to:
  /// **'Discover objects from every era and build your own collection.'**
  String get introDescriptionLearn;

  /// No description provided for @introSemanticNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get introSemanticNavigate;

  /// No description provided for @introSemanticSwipeLeft.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to continue'**
  String get introSemanticSwipeLeft;

  /// No description provided for @introSemanticEnterApp.
  ///
  /// In en, this message translates to:
  /// **'Enter the app'**
  String get introSemanticEnterApp;

  /// No description provided for @introSemanticAppName.
  ///
  /// In en, this message translates to:
  /// **'Travel Buddy'**
  String get introSemanticAppName;

  /// No description provided for @photoGallerySemanticFocus.
  ///
  /// In en, this message translates to:
  /// **'Photo {photoIndex} of {photoTotal}. Tap to focus.'**
  String photoGallerySemanticFocus(Object photoIndex, Object photoTotal);

  /// No description provided for @photoGallerySemanticFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Photo {photoIndex} of {photoTotal}. Tap to open fullscreen view.'**
  String photoGallerySemanticFullscreen(Object photoIndex, Object photoTotal);

  /// No description provided for @eraPrehistory.
  ///
  /// In en, this message translates to:
  /// **'Prehistory'**
  String get eraPrehistory;

  /// No description provided for @eraAntiquity.
  ///
  /// In en, this message translates to:
  /// **'Antiquity'**
  String get eraAntiquity;

  /// No description provided for @eraMiddleAges.
  ///
  /// In en, this message translates to:
  /// **'Middle Ages'**
  String get eraMiddleAges;

  /// No description provided for @eraOttoman.
  ///
  /// In en, this message translates to:
  /// **'Ottoman Era'**
  String get eraOttoman;

  /// No description provided for @eraModern.
  ///
  /// In en, this message translates to:
  /// **'Modern Era'**
  String get eraModern;

  /// No description provided for @yearBCE.
  ///
  /// In en, this message translates to:
  /// **'BCE'**
  String get yearBCE;

  /// No description provided for @yearCE.
  ///
  /// In en, this message translates to:
  /// **'CE'**
  String get yearCE;

  /// No description provided for @yearToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get yearToday;

  /// No description provided for @yearFormat.
  ///
  /// In en, this message translates to:
  /// **'{date} {era}'**
  String yearFormat(Object date, Object era);

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @timelineLabelOrigin.
  ///
  /// In en, this message translates to:
  /// **'{title}: the story begins.'**
  String timelineLabelOrigin(Object title);

  /// No description provided for @timelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Albanian Story Timeline'**
  String get timelineTitle;

  /// No description provided for @destinationDetailsTabLabelInformation.
  ///
  /// In en, this message translates to:
  /// **'information and history'**
  String get destinationDetailsTabLabelInformation;

  /// No description provided for @destinationDetailsTabLabelImages.
  ///
  /// In en, this message translates to:
  /// **'photo gallery'**
  String get destinationDetailsTabLabelImages;

  /// No description provided for @destinationDetailsTabLabelArtifacts.
  ///
  /// In en, this message translates to:
  /// **'artifacts'**
  String get destinationDetailsTabLabelArtifacts;

  /// No description provided for @destinationDetailsTabLabelEvents.
  ///
  /// In en, this message translates to:
  /// **'events'**
  String get destinationDetailsTabLabelEvents;

  /// No description provided for @destinationDetailsTabSemanticBack.
  ///
  /// In en, this message translates to:
  /// **'back to destination selection'**
  String get destinationDetailsTabSemanticBack;

  /// No description provided for @homeSemanticDestination.
  ///
  /// In en, this message translates to:
  /// **'destination'**
  String get homeSemanticDestination;

  /// No description provided for @butrintTitle.
  ///
  /// In en, this message translates to:
  /// **'Butrint'**
  String get butrintTitle;

  /// No description provided for @butrintRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sarandë, Albania'**
  String get butrintRegionTitle;

  /// No description provided for @butrintArtifactCulture.
  ///
  /// In en, this message translates to:
  /// **'Illyrian-Roman'**
  String get butrintArtifactCulture;

  /// No description provided for @butrintPullQuote1Top.
  ///
  /// In en, this message translates to:
  /// **'A Microcosm of'**
  String get butrintPullQuote1Top;

  /// No description provided for @butrintPullQuote1Bottom.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean History'**
  String get butrintPullQuote1Bottom;

  /// No description provided for @butrintPullQuote2.
  ///
  /// In en, this message translates to:
  /// **'Butrint is a testament to the richness and diversity of a cultural landscape shaped by centuries of human settlement.'**
  String get butrintPullQuote2;

  /// No description provided for @butrintPullQuote2Author.
  ///
  /// In en, this message translates to:
  /// **'UNESCO'**
  String get butrintPullQuote2Author;

  /// No description provided for @butrintCallout1.
  ///
  /// In en, this message translates to:
  /// **'Butrint has been inhabited since at least the 8th century BCE and served as a Greek colony, a Roman city, a Byzantine bishopric, and a Venetian outpost.'**
  String get butrintCallout1;

  /// No description provided for @butrintCallout2.
  ///
  /// In en, this message translates to:
  /// **'The ancient theater, built in the 3rd century BCE, could seat approximately 1,500 spectators and is one of the best-preserved in the region.'**
  String get butrintCallout2;

  /// No description provided for @butrintVideoCaption.
  ///
  /// In en, this message translates to:
  /// **'“Butrint Albania | The ruins of Butrinti Albania.” Visit Albania, YouTube.'**
  String get butrintVideoCaption;

  /// No description provided for @butrintMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Map showing location of Butrint National Park in southern Albania.'**
  String get butrintMapCaption;

  /// No description provided for @butrintHistoryInfo1.
  ///
  /// In en, this message translates to:
  /// **'Butrint is an archaeological site in southern Albania, opposite the Greek island of Corfu. First settled by Greek colonists from Corfu in the 8th century BCE, it grew into an important city of the ancient world. According to legend, the city was founded by Trojan refugees led by Aeneas.\nButrint became a Roman protectorate in 228 BCE, and Julius Caesar later designated it a colony for veterans. Under Roman rule, the city flourished with the construction of an aqueduct, public baths, and a forum.'**
  String get butrintHistoryInfo1;

  /// No description provided for @butrintHistoryInfo2.
  ///
  /// In en, this message translates to:
  /// **'Butrint continued to thrive as an important ecclesiastical center in the Byzantine period. A large basilica and baptistery were built in the 6th century CE. The site changed hands many times — from Byzantines to Angevins, from Venetians to Ottomans — each leaving their architectural mark on this remarkable landscape.'**
  String get butrintHistoryInfo2;

  /// No description provided for @butrintConstructionInfo1.
  ///
  /// In en, this message translates to:
  /// **'The ancient theater is carved into the southern slope of the acropolis hill, taking advantage of the natural terrain. Built with local limestone in the Hellenistic period, the theater features a semicircular orchestra, tiered seating (cavea), and a stage building (skene).\nThe nearby Asclepion sanctuary, dedicated to the god of healing, features finely carved stone reliefs and columns in the Corinthian style.'**
  String get butrintConstructionInfo1;

  /// No description provided for @butrintConstructionInfo2.
  ///
  /// In en, this message translates to:
  /// **'The 6th-century baptistery is one of the largest early Christian structures in the Balkans. Its floor is adorned with intricate mosaics depicting animals and geometric patterns, showcasing the artistic sophistication of the era. The structure uses a circular plan with 16 granite columns supporting the interior.'**
  String get butrintConstructionInfo2;

  /// No description provided for @butrintLocationInfo1.
  ///
  /// In en, this message translates to:
  /// **'Butrint is located on a peninsula between the Vivari Channel and Lake Butrint in the Ksamil area of southern Albania, approximately 14 miles (23 km) south of Sarandë. The site sits within a national park encompassing wetlands, forests, and the lake itself.'**
  String get butrintLocationInfo1;

  /// No description provided for @butrintLocationInfo2.
  ///
  /// In en, this message translates to:
  /// **'The strategic position of Butrint, on a narrow strait between the mainland and Corfu, made it an important stop along ancient Mediterranean trade routes. The surrounding landscape of marshes, lagoons, and the Ionian Sea coast has been crucial to the site\'s history as both a defensive position and a thriving port.'**
  String get butrintLocationInfo2;

  /// No description provided for @butrint228bce.
  ///
  /// In en, this message translates to:
  /// **'Butrint becomes a Roman protectorate, together with Corfu.'**
  String get butrint228bce;

  /// No description provided for @butrint44bce.
  ///
  /// In en, this message translates to:
  /// **'Julius Caesar makes Butrint a colony for his veterans; under Augustus the town doubles in size.'**
  String get butrint44bce;

  /// No description provided for @butrint1386ce.
  ///
  /// In en, this message translates to:
  /// **'Venice buys Corfu and Butrint from the Angevins and keeps Butrint as an outpost.'**
  String get butrint1386ce;

  /// No description provided for @butrint1798ce.
  ///
  /// In en, this message translates to:
  /// **'Ali Pasha of Tepelena takes Butrint from the French.'**
  String get butrint1798ce;

  /// No description provided for @butrint1928ce.
  ///
  /// In en, this message translates to:
  /// **'Italian archaeologist Luigi Maria Ugolini begins the first modern excavations.'**
  String get butrint1928ce;

  /// No description provided for @butrint1992ce.
  ///
  /// In en, this message translates to:
  /// **'Butrint is inscribed on the UNESCO World Heritage List.'**
  String get butrint1992ce;

  /// No description provided for @beratTitle.
  ///
  /// In en, this message translates to:
  /// **'Berat'**
  String get beratTitle;

  /// No description provided for @beratRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Berat, Albania'**
  String get beratRegionTitle;

  /// No description provided for @beratArtifactCulture.
  ///
  /// In en, this message translates to:
  /// **'Byzantine-Albanian'**
  String get beratArtifactCulture;

  /// No description provided for @beratPullQuote1Top.
  ///
  /// In en, this message translates to:
  /// **'A Rare Example of'**
  String get beratPullQuote1Top;

  /// No description provided for @beratPullQuote1Bottom.
  ///
  /// In en, this message translates to:
  /// **'Well-Preserved Ottoman Architecture'**
  String get beratPullQuote1Bottom;

  /// No description provided for @beratPullQuote2.
  ///
  /// In en, this message translates to:
  /// **'Berat bears witness to the coexistence of various religious and cultural communities down the centuries.'**
  String get beratPullQuote2;

  /// No description provided for @beratPullQuote2Author.
  ///
  /// In en, this message translates to:
  /// **'UNESCO'**
  String get beratPullQuote2Author;

  /// No description provided for @beratCallout1.
  ///
  /// In en, this message translates to:
  /// **'Berat is known for its distinctive white Ottoman houses climbing up the hillside, their many windows giving the city its famous epithet.'**
  String get beratCallout1;

  /// No description provided for @beratCallout2.
  ///
  /// In en, this message translates to:
  /// **'The castle quarter (Kalaja) has been continuously inhabited for over 2,400 years and still houses a living community within its 13th-century walls.'**
  String get beratCallout2;

  /// No description provided for @beratVideoCaption.
  ///
  /// In en, this message translates to:
  /// **'“Berat, Albania - The pride of Albanian architecture.” Visit Albania, YouTube.'**
  String get beratVideoCaption;

  /// No description provided for @beratMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Map showing location of Berat in central Albania.'**
  String get beratMapCaption;

  /// No description provided for @beratHistoryInfo1.
  ///
  /// In en, this message translates to:
  /// **'Berat is one of the oldest continuously inhabited cities in Albania, located along the banks of the Osum River. The castle hill has been inhabited since at least the 7th century BCE; in antiquity the fortified town here was known as Antipatrea, a name probably honouring the Macedonian regent Antipater.\nUnder Roman rule, the city served as a strategic military outpost along the Via Egnatia trade route.'**
  String get beratHistoryInfo1;

  /// No description provided for @beratHistoryInfo2.
  ///
  /// In en, this message translates to:
  /// **'During the Byzantine period, the city was known as Pulcheriopolis and later Beligrad. The Ottomans captured Berat in 1417 and it became a major center of trade and craftsmanship.\nThe city\'s three historic quarters — Mangalem, Gorica, and Kalaja — preserve an extraordinary blend of Eastern and Western architecture, earning it UNESCO World Heritage status in 2008 as part of the \"Historic Centres of Berat and Gjirokastër.\"'**
  String get beratHistoryInfo2;

  /// No description provided for @beratConstructionInfo1.
  ///
  /// In en, this message translates to:
  /// **'The Berat Castle sits at 614 feet (187 m) above sea level atop a rocky hill. The current walls date primarily to the 13th century under the Despotate of Epirus, though foundations are much older. The fortress encompasses an area of about 24 acres (10 hectares) and originally had 24 towers along its walls.\nWithin the castle walls, several Byzantine churches survive, including the Church of the Holy Trinity and the Church of St. Mary of Blachernae, featuring remarkable 16th-century frescoes by the renowned painter Onufri.'**
  String get beratConstructionInfo1;

  /// No description provided for @beratConstructionInfo2.
  ///
  /// In en, this message translates to:
  /// **'The Mangalem quarter below the castle is famous for its Ottoman-era houses built on the steep hillside. These traditional houses feature stone foundations, timber-framed upper stories, and large windows arranged symmetrically on whitewashed facades — the architectural signature that gives Berat its name \"City of a Thousand Windows.\"'**
  String get beratConstructionInfo2;

  /// No description provided for @beratLocationInfo1.
  ///
  /// In en, this message translates to:
  /// **'Berat is situated in south-central Albania, approximately 75 miles (120 km) south of the capital Tirana. The city is built along both banks of the Osum River, at the foot of Mount Tomorr, one of Albania\'s most sacred mountains reaching 8,042 feet (2,416 m).'**
  String get beratLocationInfo1;

  /// No description provided for @beratLocationInfo2.
  ///
  /// In en, this message translates to:
  /// **'The Osum River canyon, stretching southeast of the city, is one of the most dramatic natural features in Albania, with vertical canyon walls reaching over 260 feet (80 m). The surrounding region has been cultivated since antiquity, producing olives, grapes, and figs in the mild Mediterranean-influenced climate.'**
  String get beratLocationInfo2;

  /// No description provided for @berat200bce.
  ///
  /// In en, this message translates to:
  /// **'The Romans storm and burn Antipatrea, the fortified town on Berat\'s hill.'**
  String get berat200bce;

  /// No description provided for @berat1417ce.
  ///
  /// In en, this message translates to:
  /// **'Berat becomes part of the Ottoman Empire.'**
  String get berat1417ce;

  /// No description provided for @berat1547ce.
  ///
  /// In en, this message translates to:
  /// **'The icon painter Onufri signs a church fresco dated 23 July 1547; Berat\'s castle museum now bears his name.'**
  String get berat1547ce;

  /// No description provided for @berat1922ce.
  ///
  /// In en, this message translates to:
  /// **'The Congress of Berat proclaims the autocephaly of the Albanian Orthodox Church.'**
  String get berat1922ce;

  /// No description provided for @berat1961ce.
  ///
  /// In en, this message translates to:
  /// **'Berat is declared a \"Museum City\", protecting its historic quarters.'**
  String get berat1961ce;

  /// No description provided for @berat2008ce.
  ///
  /// In en, this message translates to:
  /// **'Berat joins Gjirokastër on the UNESCO World Heritage List.'**
  String get berat2008ce;

  /// No description provided for @gjirokasterTitle.
  ///
  /// In en, this message translates to:
  /// **'Gjirokastër'**
  String get gjirokasterTitle;

  /// No description provided for @gjirokasterRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Gjirokastër, Albania'**
  String get gjirokasterRegionTitle;

  /// No description provided for @gjirokasterArtifactCulture.
  ///
  /// In en, this message translates to:
  /// **'Ottoman-Albanian'**
  String get gjirokasterArtifactCulture;

  /// No description provided for @gjirokasterPullQuote1Top.
  ///
  /// In en, this message translates to:
  /// **'A Rare Example of'**
  String get gjirokasterPullQuote1Top;

  /// No description provided for @gjirokasterPullQuote1Bottom.
  ///
  /// In en, this message translates to:
  /// **'a Well-Preserved Ottoman Town'**
  String get gjirokasterPullQuote1Bottom;

  /// No description provided for @gjirokasterPullQuote2.
  ///
  /// In en, this message translates to:
  /// **'Gjirokastër is an outstanding example of a well-preserved Ottoman town, built by farmers of large estates.'**
  String get gjirokasterPullQuote2;

  /// No description provided for @gjirokasterPullQuote2Author.
  ///
  /// In en, this message translates to:
  /// **'UNESCO'**
  String get gjirokasterPullQuote2Author;

  /// No description provided for @gjirokasterCallout1.
  ///
  /// In en, this message translates to:
  /// **'The Gjirokastër Fortress is one of the largest in the Balkans, dominating the city from a hilltop at over 1,100 feet (336 m) above sea level.'**
  String get gjirokasterCallout1;

  /// No description provided for @gjirokasterCallout2.
  ///
  /// In en, this message translates to:
  /// **'The city\'s distinctive tower houses, known as \"kullë,\" feature slate-stone roofs and fortified architecture unique to the region, giving Gjirokastër its name \"The Stone City.\"'**
  String get gjirokasterCallout2;

  /// No description provided for @gjirokasterVideoCaption.
  ///
  /// In en, this message translates to:
  /// **'“Gjirokaster Albania | Gjirokastra Albania.” Visit Albania, YouTube.'**
  String get gjirokasterVideoCaption;

  /// No description provided for @gjirokasterMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Map showing location of Gjirokastër in southern Albania.'**
  String get gjirokasterMapCaption;

  /// No description provided for @gjirokasterHistoryInfo1.
  ///
  /// In en, this message translates to:
  /// **'Gjirokastër is a city in southern Albania, situated in the Drino River valley. The first fortress on the hilltop dates to the 5th–6th centuries CE. The name Gjirokastër likely derives from the medieval Greek \"Argyrokastron\" meaning \"Silver Castle.\"\nThe city rose to prominence in the 13th century as a center of the Despotate of Epirus and later became an important stronghold contested between Byzantine, Serbian, and Ottoman forces.'**
  String get gjirokasterHistoryInfo1;

  /// No description provided for @gjirokasterHistoryInfo2.
  ///
  /// In en, this message translates to:
  /// **'Under Ottoman rule from 1418 onward, Gjirokastër became the center of a large sanjak (administrative district) and thrived as a bazaar city. Wealthy landowners built the distinctive fortified tower houses that define the city\'s character.\nThe city was inscribed as a UNESCO World Heritage Site in 2005 as \"a rare example of a well-preserved Ottoman town, built by farmers of large estates.\" It is the birthplace of both former Albanian dictator Enver Hoxha and Nobel Prize-winning author Ismail Kadare.'**
  String get gjirokasterHistoryInfo2;

  /// No description provided for @gjirokasterConstructionInfo1.
  ///
  /// In en, this message translates to:
  /// **'The Gjirokastër Fortress covers an area of approximately 18 acres (7.3 hectares) on the hilltop. Expanded significantly by Ali Pasha of Ioannina in the early 19th century, the fortress features massive stone walls, a clock tower, an aqueduct, and a series of underground tunnels and chambers.\nDuring the communist era, the fortress was used as a prison and later converted into a Museum of Armaments. Today it hosts the Gjirokastër National Folklore Festival every five years.'**
  String get gjirokasterConstructionInfo1;

  /// No description provided for @gjirokasterConstructionInfo2.
  ///
  /// In en, this message translates to:
  /// **'The city\'s iconic tower houses (kullë) are typically three to four stories tall, built of solid stone with slate roofs. The ground floor served as a cistern and storage, the first floor for winter living, and the upper floors for summer quarters and guest reception. Defensive features include small windows on lower floors and fortified entrances.'**
  String get gjirokasterConstructionInfo2;

  /// No description provided for @gjirokasterLocationInfo1.
  ///
  /// In en, this message translates to:
  /// **'Gjirokastër is located in the Drino River valley in southern Albania, about 18 miles (29 km) from the Greek border. The city is built on the steep slopes of the Mali i Gjerë mountain range, rising from the valley floor at approximately 980 feet (300 m) to the castle at over 1,100 feet (336 m).'**
  String get gjirokasterLocationInfo1;

  /// No description provided for @gjirokasterLocationInfo2.
  ///
  /// In en, this message translates to:
  /// **'The surrounding region, known as Dropull, has been a crossroads of cultures for millennia. The Drino Valley connects the Adriatic coast with the interior Balkans, and the ancient route from the coast at Butrint passed through this valley toward the Via Egnatia.'**
  String get gjirokasterLocationInfo2;

  /// No description provided for @gjirokaster1336ce.
  ///
  /// In en, this message translates to:
  /// **'Byzantine emperor John VI Kantakouzenos records the town as Argyrokastro, the first mention of its name.'**
  String get gjirokaster1336ce;

  /// No description provided for @gjirokaster1418ce.
  ///
  /// In en, this message translates to:
  /// **'After a siege, the Ottomans take the city from the Zenebishi family.'**
  String get gjirokaster1418ce;

  /// No description provided for @gjirokaster1811ce.
  ///
  /// In en, this message translates to:
  /// **'Gjirokastër becomes part of Ali Pasha\'s Pashalik of Yanina; he later enlarges the castle.'**
  String get gjirokaster1811ce;

  /// No description provided for @gjirokaster1932ce.
  ///
  /// In en, this message translates to:
  /// **'King Zog\'s government expands the prison inside the castle.'**
  String get gjirokaster1932ce;

  /// No description provided for @gjirokaster1936ce.
  ///
  /// In en, this message translates to:
  /// **'Writer Ismail Kadare is born in the city.'**
  String get gjirokaster1936ce;

  /// No description provided for @gjirokaster2005ce.
  ///
  /// In en, this message translates to:
  /// **'The historic centre is inscribed on the UNESCO World Heritage List.'**
  String get gjirokaster2005ce;

  /// No description provided for @apolloniaTitle.
  ///
  /// In en, this message translates to:
  /// **'Apollonia'**
  String get apolloniaTitle;

  /// No description provided for @apolloniaRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Fier, Albania'**
  String get apolloniaRegionTitle;

  /// No description provided for @apolloniaArtifactCulture.
  ///
  /// In en, this message translates to:
  /// **'Illyrian-Greek'**
  String get apolloniaArtifactCulture;

  /// No description provided for @apolloniaPullQuote1Top.
  ///
  /// In en, this message translates to:
  /// **'An Admirable City'**
  String get apolloniaPullQuote1Top;

  /// No description provided for @apolloniaPullQuote1Bottom.
  ///
  /// In en, this message translates to:
  /// **'With Excellent Laws'**
  String get apolloniaPullQuote1Bottom;

  /// No description provided for @apolloniaPullQuote2.
  ///
  /// In en, this message translates to:
  /// **'Apollonia is considered one of the most important cities of the ancient world, a center of learning where the young Octavian studied.'**
  String get apolloniaPullQuote2;

  /// No description provided for @apolloniaPullQuote2Author.
  ///
  /// In en, this message translates to:
  /// **'Strabo'**
  String get apolloniaPullQuote2Author;

  /// No description provided for @apolloniaCallout1.
  ///
  /// In en, this message translates to:
  /// **'The Roman statesman and orator Cicero described Apollonia as \"a great and important city\" (magna urbs et gravis) in his work Philippics.'**
  String get apolloniaCallout1;

  /// No description provided for @apolloniaCallout2.
  ///
  /// In en, this message translates to:
  /// **'The young Octavian (later Emperor Augustus) was studying in Apollonia when he received news of Julius Caesar\'s assassination in 44 BCE, a pivotal moment in Roman history.'**
  String get apolloniaCallout2;

  /// No description provided for @apolloniaVideoCaption.
  ///
  /// In en, this message translates to:
  /// **'“Apollonia, Albania by Drone.” Visit Albania, YouTube.'**
  String get apolloniaVideoCaption;

  /// No description provided for @apolloniaMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Map showing location of Apollonia near Fier in central Albania.'**
  String get apolloniaMapCaption;

  /// No description provided for @apolloniaHistoryInfo1.
  ///
  /// In en, this message translates to:
  /// **'Apollonia was an ancient Greek colony founded in 588 BCE by settlers from Corinth and Corcyra (modern Corfu) on the banks of the Aous River (modern Vjosa) in Illyria. Named after the god Apollo, the city quickly grew into one of the most important settlements on the eastern Adriatic coast.\nAt its peak, Apollonia had a population of around 60,000 and was a major stop along the Via Egnatia, the great Roman road connecting the Adriatic to Constantinople.'**
  String get apolloniaHistoryInfo1;

  /// No description provided for @apolloniaHistoryInfo2.
  ///
  /// In en, this message translates to:
  /// **'The city was renowned as a center of philosophy and learning. Numerous Roman nobles sent their sons to study there, most notably Octavian, the future Emperor Augustus. Apollonia\'s importance declined after the 3rd century CE when an earthquake altered the course of the Vjosa River, destroying the city\'s harbor and cutting off its trade routes.\nThe site was partially built over by the Byzantine-era Monastery of St. Mary, which still stands and houses an archaeological museum.'**
  String get apolloniaHistoryInfo2;

  /// No description provided for @apolloniaConstructionInfo1.
  ///
  /// In en, this message translates to:
  /// **'The archaeological park covers approximately 237 acres (96 hectares), though only a fraction has been excavated. Major structures include a monumental bouleuterion (council house) with 19 rows of stone seating, an impressive stoa (covered walkway) measuring over 260 feet (80 m) in length, and a well-preserved odeon (small theater).\nThe remains of a nymphaeum (ornamental fountain) and several temples demonstrate the city\'s wealth and architectural sophistication.'**
  String get apolloniaConstructionInfo1;

  /// No description provided for @apolloniaConstructionInfo2.
  ///
  /// In en, this message translates to:
  /// **'The city was built using locally quarried limestone and followed classical Greek urban planning with an agora, temples, and public buildings arranged along paved streets. The defensive walls, encircling approximately 1 square mile (2.5 sq km), were built with polygonal masonry typical of Hellenistic military architecture.\nThe 13th-century Monastery of St. Mary, built atop ancient ruins within the archaeological zone, features a beautifully decorated Byzantine church with carved stone facades.'**
  String get apolloniaConstructionInfo2;

  /// No description provided for @apolloniaLocationInfo1.
  ///
  /// In en, this message translates to:
  /// **'Apollonia is situated on a hilltop near the village of Pojani, approximately 7 miles (12 km) west of the city of Fier in central Albania. The site overlooks the Myzeqe plain and the Vjosa River valley, commanding views extending to the Adriatic Sea.'**
  String get apolloniaLocationInfo1;

  /// No description provided for @apolloniaLocationInfo2.
  ///
  /// In en, this message translates to:
  /// **'In antiquity, the Vjosa River flowed much closer to the city, providing direct access to the Adriatic coast and enabling Apollonia to function as an important port city. The fertile surrounding plain supported agricultural production, while the hilltop position offered natural defensive advantages.'**
  String get apolloniaLocationInfo2;

  /// No description provided for @apollonia588bce.
  ///
  /// In en, this message translates to:
  /// **'Greek colonists from Corinth and Corcyra found Apollonia on Illyrian land.'**
  String get apollonia588bce;

  /// No description provided for @apollonia229bce.
  ///
  /// In en, this message translates to:
  /// **'Apollonia comes under the control of the Roman Republic.'**
  String get apollonia229bce;

  /// No description provided for @apollonia148bce.
  ///
  /// In en, this message translates to:
  /// **'Apollonia becomes part of the new Roman province of Macedonia.'**
  String get apollonia148bce;

  /// No description provided for @apollonia44bce.
  ///
  /// In en, this message translates to:
  /// **'Young Octavian, the future Emperor Augustus, is studying in Apollonia.'**
  String get apollonia44bce;

  /// No description provided for @apollonia1272ce.
  ///
  /// In en, this message translates to:
  /// **'The Byzantine Monastery of St. Mary is built within the ruins of the ancient city.'**
  String get apollonia1272ce;

  /// No description provided for @apollonia1924ce.
  ///
  /// In en, this message translates to:
  /// **'A French archaeological mission begins systematic excavations, which last until 1938.'**
  String get apollonia1924ce;

  /// No description provided for @thethTitle.
  ///
  /// In en, this message translates to:
  /// **'Thethi'**
  String get thethTitle;

  /// No description provided for @thethRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Shkodër, Albania'**
  String get thethRegionTitle;

  /// No description provided for @thethArtifactCulture.
  ///
  /// In en, this message translates to:
  /// **'Albanian Highland'**
  String get thethArtifactCulture;

  /// No description provided for @thethPullQuote1Top.
  ///
  /// In en, this message translates to:
  /// **'A Living Fragment of'**
  String get thethPullQuote1Top;

  /// No description provided for @thethPullQuote1Bottom.
  ///
  /// In en, this message translates to:
  /// **'Europe\'s Last Wilderness'**
  String get thethPullQuote1Bottom;

  /// No description provided for @thethPullQuote1Author.
  ///
  /// In en, this message translates to:
  /// **'Edith Durham'**
  String get thethPullQuote1Author;

  /// No description provided for @thethPullQuote2.
  ///
  /// In en, this message translates to:
  /// **'The Albanian Alps are perhaps the last great wilderness in Europe, a place where time seems to have stood still.'**
  String get thethPullQuote2;

  /// No description provided for @thethPullQuote2Author.
  ///
  /// In en, this message translates to:
  /// **'Edith Durham'**
  String get thethPullQuote2Author;

  /// No description provided for @thethCallout1.
  ///
  /// In en, this message translates to:
  /// **'Thethi\'s iconic Lock-in Tower (Kulla e Ngujimit) was used as a refuge for men involved in blood feuds under the Kanun of Lëkë Dukagjini, the traditional Albanian code of law.'**
  String get thethCallout1;

  /// No description provided for @thethCallout2.
  ///
  /// In en, this message translates to:
  /// **'The Thethi valley sits at approximately 2,500 feet (760 m) above sea level, surrounded by peaks exceeding 8,000 feet (2,500 m), including the dramatic Radohima massif.'**
  String get thethCallout2;

  /// No description provided for @thethVideoCaption.
  ///
  /// In en, this message translates to:
  /// **'“Theth Albania - Albanian Alps.” Visit Albania, YouTube.'**
  String get thethVideoCaption;

  /// No description provided for @thethMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Map showing location of Thethi in the Albanian Alps, northern Albania.'**
  String get thethMapCaption;

  /// No description provided for @thethHistoryInfo1.
  ///
  /// In en, this message translates to:
  /// **'Thethi is a remote alpine village nestled in a glacial valley in the Albanian Alps (Bjeshkët e Nemuna), in the Shkodër district of northern Albania. The valley has been inhabited for centuries by Albanian highland clans, who maintained a fiercely independent way of life governed by the Kanun, a set of customary laws attributed to Lëkë Dukagjini.\nThe isolation of the valley — accessible only by mountain passes for most of its history — preserved a traditional way of life largely unchanged until the 20th century.'**
  String get thethHistoryInfo1;

  /// No description provided for @thethHistoryInfo2.
  ///
  /// In en, this message translates to:
  /// **'During the communist period (1944-1991), the Albanian government attempted to modernize the highlands, building roads and schools but also restricting traditional customs. After the fall of communism, many highland villages were depopulated as residents moved to lowland cities.\nIn recent years, Thethi has experienced a revival as a destination for hiking and ecotourism, with the Peaks of the Balkans trail bringing international attention to the region\'s natural beauty and cultural heritage.'**
  String get thethHistoryInfo2;

  /// No description provided for @thethConstructionInfo1.
  ///
  /// In en, this message translates to:
  /// **'Thethi\'s traditional stone houses (shtëpi) are built from local limestone and timber, designed to withstand harsh mountain winters. The houses typically feature thick stone walls, small windows to conserve heat, and wooden balconies. Stone-slab roofs, anchored with heavy rocks, protect against the heavy snowfall that blankets the valley for several months each year.\nThe most famous structure in Thethi is the Lock-in Tower (Kulla e Ngujimit), a stone tower used historically as a place of refuge for men targeted in blood feuds.'**
  String get thethConstructionInfo1;

  /// No description provided for @thethConstructionInfo2.
  ///
  /// In en, this message translates to:
  /// **'The Church of Thethi (Kisha e Thethit), built in the 19th century, is a small but picturesque stone church set against the dramatic mountain backdrop. Traditional highland architecture throughout the valley includes watermills along the Thethi River, stone bridges, and livestock enclosures built with dry-stone walling techniques passed down through generations.'**
  String get thethConstructionInfo2;

  /// No description provided for @thethLocationInfo1.
  ///
  /// In en, this message translates to:
  /// **'Thethi lies within the Thethi National Park, established in 1966, covering approximately 5,200 acres (2,100 hectares) of pristine alpine wilderness. The valley is surrounded by the peaks of the Albanian Alps, including Radohima at 8,146 feet (2,568 m) and Haj-Nehaj at 8,524 feet (2,598 m).'**
  String get thethLocationInfo1;

  /// No description provided for @thethLocationInfo2.
  ///
  /// In en, this message translates to:
  /// **'The Blue Eye of Thethi (Syri i Kaltër), a stunning natural spring pool of vivid turquoise water, is one of the valley\'s most remarkable natural features. The Grunas Waterfall, cascading 100 feet (30 m) down a limestone cliff, is another iconic landmark. The valley connects to Valbona via a popular mountain pass trek at approximately 5,900 feet (1,800 m).'**
  String get thethLocationInfo2;

  /// No description provided for @theth1892ce.
  ///
  /// In en, this message translates to:
  /// **'The village church of Theth is built.'**
  String get theth1892ce;

  /// No description provided for @theth1908ce.
  ///
  /// In en, this message translates to:
  /// **'Edith Durham travels through the highlands and describes Theth in High Albania (1909).'**
  String get theth1908ce;

  /// No description provided for @theth1966ce.
  ///
  /// In en, this message translates to:
  /// **'Theth National Park is created.'**
  String get theth1966ce;

  /// No description provided for @theth2011ce.
  ///
  /// In en, this message translates to:
  /// **'The Peaks of the Balkans trail opens, linking Theth with Kosovo and Montenegro.'**
  String get theth2011ce;

  /// No description provided for @theth2017ce.
  ///
  /// In en, this message translates to:
  /// **'Albanologist Robert Elsie is laid to rest in Theth.'**
  String get theth2017ce;

  /// No description provided for @theth2022ce.
  ///
  /// In en, this message translates to:
  /// **'Theth becomes part of the new Alps of Albania National Park.'**
  String get theth2022ce;

  /// No description provided for @krujaTitle.
  ///
  /// In en, this message translates to:
  /// **'Krujë'**
  String get krujaTitle;

  /// No description provided for @krujaRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Durrës County, Albania'**
  String get krujaRegionTitle;

  /// No description provided for @krujaArtifactCulture.
  ///
  /// In en, this message translates to:
  /// **'Medieval Albanian'**
  String get krujaArtifactCulture;

  /// No description provided for @krujaPullQuote1Top.
  ///
  /// In en, this message translates to:
  /// **'The Shield of Christendom'**
  String get krujaPullQuote1Top;

  /// No description provided for @krujaPullQuote1Bottom.
  ///
  /// In en, this message translates to:
  /// **'Against the Ottoman Tide'**
  String get krujaPullQuote1Bottom;

  /// No description provided for @krujaPullQuote1Author.
  ///
  /// In en, this message translates to:
  /// **'Pope Callixtus III'**
  String get krujaPullQuote1Author;

  /// No description provided for @krujaPullQuote2.
  ///
  /// In en, this message translates to:
  /// **'Skanderbeg\'s defense of Krujë is one of the most remarkable episodes of resistance in European military history.'**
  String get krujaPullQuote2;

  /// No description provided for @krujaPullQuote2Author.
  ///
  /// In en, this message translates to:
  /// **'Fan Noli'**
  String get krujaPullQuote2Author;

  /// No description provided for @krujaCallout1.
  ///
  /// In en, this message translates to:
  /// **'Gjergj Kastrioti Skanderbeg successfully defended Krujë against three major Ottoman sieges, earning him the title \"Athleta Christi\" (Champion of Christ) from the Pope.'**
  String get krujaCallout1;

  /// No description provided for @krujaCallout2.
  ///
  /// In en, this message translates to:
  /// **'The castle sits at an elevation of approximately 1,970 feet (600 m) atop the Skanderbeg Mountain (Mali i Sariut), providing a commanding view of the surrounding plains.'**
  String get krujaCallout2;

  /// No description provided for @krujaVideoCaption.
  ///
  /// In en, this message translates to:
  /// **'“KRUJA CITY & CASTLE 2021 | 4K DRONE CINEMATIC VIDEO.” GOGLA, YouTube.'**
  String get krujaVideoCaption;

  /// No description provided for @krujaMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Map showing location of Krujë in central Albania.'**
  String get krujaMapCaption;

  /// No description provided for @krujaHistoryInfo1.
  ///
  /// In en, this message translates to:
  /// **'Krujë is a city in north-central Albania, historically renowned as the seat of Gjergj Kastrioti Skanderbeg (1405-1468), Albania\'s national hero. The castle of Krujë has been fortified since at least the 5th century and became the capital of the Principality of Kastrioti in the 15th century.\nIn 1443, Skanderbeg raised the Albanian flag over the castle after abandoning his forced service in the Ottoman army, beginning a 25-year campaign of resistance against the Ottoman Empire.'**
  String get krujaHistoryInfo1;

  /// No description provided for @krujaHistoryInfo2.
  ///
  /// In en, this message translates to:
  /// **'Skanderbeg successfully defended Krujë against three major Ottoman sieges — in 1450, 1466, and 1467 — each time repelling vastly superior forces. His resistance prevented Ottoman expansion into Western Europe for decades and earned him admiration across the Christian world.\nAfter Skanderbeg\'s death in 1468, the castle fell to the Ottomans in 1478 after a prolonged fourth siege. The city remained under Ottoman control until Albanian independence in 1912.'**
  String get krujaHistoryInfo2;

  /// No description provided for @krujaConstructionInfo1.
  ///
  /// In en, this message translates to:
  /// **'The Krujë Castle is perched on a rocky outcrop at the edge of Skanderbeg Mountain (Mali i Sariut). The fortress walls follow the natural contours of the terrain, encircling an area that once contained a small town with houses, churches, and a bazaar.\nThe Skanderbeg Museum, designed by architects Pranvera Hoxha and Pirro Vaso and opened in 1982, sits within the castle walls. Built in a modernist style inspired by medieval Albanian architecture, it houses artifacts from the period of Albanian resistance.'**
  String get krujaConstructionInfo1;

  /// No description provided for @krujaConstructionInfo2.
  ///
  /// In en, this message translates to:
  /// **'Below the castle, the restored Old Bazaar (Pazari i Vjetër) stretches along a cobblestone street with traditional stone and timber shops. The bazaar has been in continuous use since the 15th century and today sells traditional Albanian crafts, antiques, and locally made goods. The Dollma Tekke, a small Bektashi shrine within the castle complex, features elegant Ottoman-era architecture with painted interiors.'**
  String get krujaConstructionInfo2;

  /// No description provided for @krujaLocationInfo1.
  ///
  /// In en, this message translates to:
  /// **'Krujë is located approximately 20 miles (32 km) north of Tirana in central Albania. The castle sits atop a mountain spur overlooking the vast western Albanian plain that stretches to the Adriatic Sea, providing strategic visibility over approaching forces — a key factor in Skanderbeg\'s successful defense.'**
  String get krujaLocationInfo1;

  /// No description provided for @krujaLocationInfo2.
  ///
  /// In en, this message translates to:
  /// **'The Skanderbeg Mountain (Mali i Sariut) rises steeply behind the castle to approximately 3,500 feet (1,070 m). The surrounding terrain of steep gorges and dense forests provided natural defensive advantages that Skanderbeg exploited in his guerrilla tactics against the much larger Ottoman forces. The nearby Sarisalltiku peak features a cave shrine venerated by both Muslims and Christians.'**
  String get krujaLocationInfo2;

  /// No description provided for @kruja1190ce.
  ///
  /// In en, this message translates to:
  /// **'Krujë becomes the capital of the Principality of Arbër, the first Albanian state of the Middle Ages.'**
  String get kruja1190ce;

  /// No description provided for @kruja1443ce.
  ///
  /// In en, this message translates to:
  /// **'On 28 November, Skanderbeg takes Krujë and raises the Albanian flag over the castle.'**
  String get kruja1443ce;

  /// No description provided for @kruja1450ce.
  ///
  /// In en, this message translates to:
  /// **'Skanderbeg\'s forces withstand the first Ottoman siege, led by Sultan Murad II.'**
  String get kruja1450ce;

  /// No description provided for @kruja1478ce.
  ///
  /// In en, this message translates to:
  /// **'After a siege of more than a year, Krujë falls to the Ottomans.'**
  String get kruja1478ce;

  /// No description provided for @kruja1982ce.
  ///
  /// In en, this message translates to:
  /// **'The Skanderbeg Museum opens beside the castle.'**
  String get kruja1982ce;

  /// No description provided for @kruja1989ce.
  ///
  /// In en, this message translates to:
  /// **'The National Ethnographic Museum opens in a Toptani family house built in 1764.'**
  String get kruja1989ce;

  /// No description provided for @albanianAlpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Albanian Alps'**
  String get albanianAlpsTitle;

  /// No description provided for @albanianAlpsRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Northern Albania'**
  String get albanianAlpsRegionTitle;

  /// No description provided for @albanianAlpsArtifactCulture.
  ///
  /// In en, this message translates to:
  /// **'Albanian Highland'**
  String get albanianAlpsArtifactCulture;

  /// No description provided for @albanianAlpsPullQuote1Top.
  ///
  /// In en, this message translates to:
  /// **'Europe\'s Last Great'**
  String get albanianAlpsPullQuote1Top;

  /// No description provided for @albanianAlpsPullQuote1Bottom.
  ///
  /// In en, this message translates to:
  /// **'Untouched Wilderness'**
  String get albanianAlpsPullQuote1Bottom;

  /// No description provided for @albanianAlpsPullQuote2.
  ///
  /// In en, this message translates to:
  /// **'The Accursed Mountains stand as a testament to the raw, untamed beauty of the natural world.'**
  String get albanianAlpsPullQuote2;

  /// No description provided for @albanianAlpsPullQuote2Author.
  ///
  /// In en, this message translates to:
  /// **'Edith Durham'**
  String get albanianAlpsPullQuote2Author;

  /// No description provided for @albanianAlpsCallout1.
  ///
  /// In en, this message translates to:
  /// **'The Albanian Alps, known locally as Bjeshkët e Nemuna (Accursed Mountains), contain some of the most pristine ecosystems in Europe, harboring lynx, wolves, bears, and golden eagles.'**
  String get albanianAlpsCallout1;

  /// No description provided for @albanianAlpsCallout2.
  ///
  /// In en, this message translates to:
  /// **'Jezerca, the highest peak at 8,839 feet (2,694 m), is one of the most dramatic limestone summits in the Balkans, featuring permanent snowfields and glacial cirques.'**
  String get albanianAlpsCallout2;

  /// No description provided for @albanianAlpsVideoCaption.
  ///
  /// In en, this message translates to:
  /// **'“Valbona, Albania.” Visit Albania, YouTube.'**
  String get albanianAlpsVideoCaption;

  /// No description provided for @albanianAlpsMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Map showing location of the Albanian Alps in northern Albania.'**
  String get albanianAlpsMapCaption;

  /// No description provided for @albanianAlpsHistoryInfo1.
  ///
  /// In en, this message translates to:
  /// **'The Albanian Alps (Bjeshkët e Nemuna), also known as the Accursed Mountains or the Prokletije, are a mountain range stretching across northern Albania, western Kosovo, and eastern Montenegro. In Albania, the range includes some of the most remote and pristine wilderness in all of Europe.\nThe mountains have been home to Albanian highland clans for centuries, who developed a unique culture of hospitality, honor, and self-governance codified in the Kanun of Lëkë Dukagjini.'**
  String get albanianAlpsHistoryInfo1;

  /// No description provided for @albanianAlpsHistoryInfo2.
  ///
  /// In en, this message translates to:
  /// **'The name \"Accursed Mountains\" has various folk etymologies — some say it comes from the difficulty of crossing them, others attribute it to a legend of feuding mountains cursed by the gods. The Albanian name \"Bjeshkët e Nemuna\" translates more accurately as \"Mountains of the Highlanders.\"\nBritish traveler Edith Durham extensively documented the highlands in the early 1900s, describing a society where ancient customs of blood feuds and sworn virgins (burrnesha) persisted alongside extraordinary hospitality and natural beauty.'**
  String get albanianAlpsHistoryInfo2;

  /// No description provided for @albanianAlpsConstructionInfo1.
  ///
  /// In en, this message translates to:
  /// **'Unlike man-made structures, the Albanian Alps are a monument of nature, sculpted by millions of years of geological processes. The range is composed primarily of Mesozoic-era limestone and dolomite, shaped by glacial and karst erosion into dramatic peaks, deep valleys, and underground cave systems.\nThe Blue Eye of Theth, turquoise glacial pools, and the Valbona valley\'s dramatic cliff faces are all products of this ongoing geological story.'**
  String get albanianAlpsConstructionInfo1;

  /// No description provided for @albanianAlpsConstructionInfo2.
  ///
  /// In en, this message translates to:
  /// **'Human structures in the Albanian Alps reflect the mountain environment. Traditional highland houses (kullë) are built from massive limestone blocks with timber interiors, designed to withstand heavy snowfall and provide defense. Stone-walled pastures, ancient mule trails, and small mountain churches dot the landscape.\nThe Peaks of the Balkans trail, a 120-mile (192 km) hiking route opened in 2011, connects communities across three countries using many of these traditional paths.'**
  String get albanianAlpsConstructionInfo2;

  /// No description provided for @albanianAlpsLocationInfo1.
  ///
  /// In en, this message translates to:
  /// **'The Albanian Alps extend across the districts of Shkodër and Kukës in northern Albania, forming the country\'s border with Montenegro and Kosovo. The range stretches approximately 40 miles (65 km) from the Kelmendi region in the northwest to the Valbona area in the east. Major valleys include Thethi, Valbona, and Kelmendi.'**
  String get albanianAlpsLocationInfo1;

  /// No description provided for @albanianAlpsLocationInfo2.
  ///
  /// In en, this message translates to:
  /// **'The Valbona Valley National Park and Thethi National Park protect much of the Albanian portion of the range. Lake Koman, accessible by ferry through a dramatic canyon often compared to Scandinavian fjords, provides a stunning approach to the mountains from the south. The region receives some of the highest precipitation in Europe, feeding numerous rivers and waterfalls.'**
  String get albanianAlpsLocationInfo2;

  /// No description provided for @albanianAlps1909ce.
  ///
  /// In en, this message translates to:
  /// **'Edith Durham publishes High Albania, the classic account of life among the highland clans.'**
  String get albanianAlps1909ce;

  /// No description provided for @albanianAlps1929ce.
  ///
  /// In en, this message translates to:
  /// **'British climbers make the first recorded ascent of Maja Jezercë (2,694 m), the range\'s highest peak.'**
  String get albanianAlps1929ce;

  /// No description provided for @albanianAlps1996ce.
  ///
  /// In en, this message translates to:
  /// **'Valbona Valley National Park is created.'**
  String get albanianAlps1996ce;

  /// No description provided for @albanianAlps2009ce.
  ///
  /// In en, this message translates to:
  /// **'A glacier is discovered in the Albanian part of the range.'**
  String get albanianAlps2009ce;

  /// No description provided for @albanianAlps2011ce.
  ///
  /// In en, this message translates to:
  /// **'The Peaks of the Balkans trail opens across Albania, Kosovo and Montenegro.'**
  String get albanianAlps2011ce;

  /// No description provided for @albanianAlps2022ce.
  ///
  /// In en, this message translates to:
  /// **'Theth, Valbona and nearby reserves merge into the Alps of Albania National Park.'**
  String get albanianAlps2022ce;

  /// No description provided for @korcaTitle.
  ///
  /// In en, this message translates to:
  /// **'Korçë'**
  String get korcaTitle;

  /// No description provided for @korcaRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Korçë, Albania'**
  String get korcaRegionTitle;

  /// No description provided for @korcaArtifactCulture.
  ///
  /// In en, this message translates to:
  /// **'Albanian Orthodox'**
  String get korcaArtifactCulture;

  /// No description provided for @korcaPullQuote1Top.
  ///
  /// In en, this message translates to:
  /// **'Not Just a Cathedral,'**
  String get korcaPullQuote1Top;

  /// No description provided for @korcaPullQuote1Bottom.
  ///
  /// In en, this message translates to:
  /// **'but the Soul of a Nation'**
  String get korcaPullQuote1Bottom;

  /// No description provided for @korcaPullQuote1Author.
  ///
  /// In en, this message translates to:
  /// **'Fan Noli'**
  String get korcaPullQuote1Author;

  /// No description provided for @korcaPullQuote2.
  ///
  /// In en, this message translates to:
  /// **'Korçë is the city where Albanian national consciousness first found its voice through schools, literature, and art.'**
  String get korcaPullQuote2;

  /// No description provided for @korcaPullQuote2Author.
  ///
  /// In en, this message translates to:
  /// **'Faik Konica'**
  String get korcaPullQuote2Author;

  /// No description provided for @korcaCallout1.
  ///
  /// In en, this message translates to:
  /// **'The Resurrection Cathedral (Katedralja Ngjallja e Krishtit) is the largest Orthodox cathedral in Albania, designed by renowned architect Fan Noli and completed in 2003.'**
  String get korcaCallout1;

  /// No description provided for @korcaCallout2.
  ///
  /// In en, this message translates to:
  /// **'Korçë is home to the first Albanian-language school, opened on March 7, 1887, a date now celebrated as Teacher\'s Day (Dita e Mësuesit) across Albania.'**
  String get korcaCallout2;

  /// No description provided for @korcaVideoCaption.
  ///
  /// In en, this message translates to:
  /// **'“Korçë, Dardhë | Dardhe Korce Albania.” Visit Albania, YouTube.'**
  String get korcaVideoCaption;

  /// No description provided for @korcaMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Map showing location of Korçë in southeastern Albania.'**
  String get korcaMapCaption;

  /// No description provided for @korcaHistoryInfo1.
  ///
  /// In en, this message translates to:
  /// **'Korçë is a city in southeastern Albania, situated in a high plateau at approximately 2,800 feet (850 m) above sea level. The city has been a center of Albanian culture, education, and art since the 19th century, earning it the title \"the cradle of Albanian culture.\"\nThe first Albanian-language school was opened here on March 7, 1887, by Pandeli Sotiri, marking a pivotal moment in the Albanian national awakening. Korçë also hosted the first Albanian printing press and numerous literary societies.'**
  String get korcaHistoryInfo1;

  /// No description provided for @korcaHistoryInfo2.
  ///
  /// In en, this message translates to:
  /// **'The original Orthodox Cathedral was destroyed during the communist period when Albania declared itself the world\'s first atheist state in 1967, demolishing nearly all religious buildings. The new Resurrection Cathedral (Katedralja Ngjallja e Krishtit) was built between 1994 and 2002 on the foundations of the old cathedral, symbolizing both religious revival and national cultural renewal.\nKorçë is also renowned for its contribution to Albanian music, art, and the famous annual Korçë Beer Festival, one of the largest in the Balkans.'**
  String get korcaHistoryInfo2;

  /// No description provided for @korcaConstructionInfo1.
  ///
  /// In en, this message translates to:
  /// **'The Resurrection Cathedral was designed in a neo-Byzantine style, drawing inspiration from traditional Orthodox church architecture while incorporating modern construction techniques. The cathedral features a cruciform plan with a large central dome reaching approximately 100 feet (30 m) in height, flanked by smaller domes.\nThe exterior is clad in light-colored stone with decorative arched windows, while the interior is adorned with frescoes and iconography painted by Albanian and Greek artists.'**
  String get korcaConstructionInfo1;

  /// No description provided for @korcaConstructionInfo2.
  ///
  /// In en, this message translates to:
  /// **'The cathedral was built between 1994 and 2002. Modern reinforced concrete and steel frame construction was used for structural integrity, while traditional stone and decorative elements maintain the Byzantine aesthetic.\nThe bell tower, rising beside the cathedral, houses a set of bells that ring across the city. The surrounding plaza and park create a cultural center for the city, connecting to the National Museum of Medieval Art, which houses one of the finest collections of Byzantine icons in the world.'**
  String get korcaConstructionInfo2;

  /// No description provided for @korcaLocationInfo1.
  ///
  /// In en, this message translates to:
  /// **'Korçë is located in the Korçë Basin, a fertile plateau surrounded by mountains in southeastern Albania. The city lies approximately 112 miles (180 km) southeast of Tirana, near the borders with both Greece and North Macedonia. The Morava Mountain range rises to the east, while Lake Ohrid lies to the northeast.'**
  String get korcaLocationInfo1;

  /// No description provided for @korcaLocationInfo2.
  ///
  /// In en, this message translates to:
  /// **'The Korçë plateau has been inhabited since prehistoric times due to its fertile soil and strategic position along ancient trade routes connecting the Adriatic and Aegean seas. The nearby archaeological site of Maliq, on the shores of a former lake, has yielded evidence of continuous habitation dating back to the Neolithic period, around 6000 BCE.'**
  String get korcaLocationInfo2;

  /// No description provided for @korca1769ce.
  ///
  /// In en, this message translates to:
  /// **'After nearby Voskopojë is sacked, part of its trade moves to Korçë.'**
  String get korca1769ce;

  /// No description provided for @korca1887ce.
  ///
  /// In en, this message translates to:
  /// **'The first Albanian-language school, the Mësonjëtorja, opens on 7 March.'**
  String get korca1887ce;

  /// No description provided for @korca1891ce.
  ///
  /// In en, this message translates to:
  /// **'Sevasti Qiriazi founds the first Albanian school for girls.'**
  String get korca1891ce;

  /// No description provided for @korca1916ce.
  ///
  /// In en, this message translates to:
  /// **'Under French protection, the Autonomous Albanian Republic of Korçë is proclaimed.'**
  String get korca1916ce;

  /// No description provided for @korca1968ce.
  ///
  /// In en, this message translates to:
  /// **'The communist regime demolishes the city\'s Orthodox cathedral of St. George.'**
  String get korca1968ce;

  /// No description provided for @korca1994ce.
  ///
  /// In en, this message translates to:
  /// **'Construction of the Resurrection Cathedral begins; it is consecrated in 2002.'**
  String get korca1994ce;

  /// No description provided for @timelineEventIllyrianTribes.
  ///
  /// In en, this message translates to:
  /// **'Illyrian peoples such as the Taulantii, Ardiaei, Dardani and Enchelei take shape across the western Balkans.'**
  String get timelineEventIllyrianTribes;

  /// No description provided for @timelineEventEpidamnos.
  ///
  /// In en, this message translates to:
  /// **'Settlers from Corcyra and Corinth found Epidamnos on Taulantian land. As Dyrrachium, today\'s Durrës, it becomes the great port of the Adriatic coast.'**
  String get timelineEventEpidamnos;

  /// No description provided for @timelineEventBardylisDefeatsMacedon.
  ///
  /// In en, this message translates to:
  /// **'The Illyrian king Bardylis defeats and kills King Perdiccas III of Macedon. A year later Perdiccas\'s brother, Philip II, strikes back and defeats him.'**
  String get timelineEventBardylisDefeatsMacedon;

  /// No description provided for @timelineEventAlexanderAtPelion.
  ///
  /// In en, this message translates to:
  /// **'At Pelion, in the south-east of today\'s Albania, the young Alexander the Great breaks an alliance of the Illyrian kings Cleitus and Glaukias.'**
  String get timelineEventAlexanderAtPelion;

  /// No description provided for @timelineEventGlaukiasShieldsPyrrhus.
  ///
  /// In en, this message translates to:
  /// **'King Glaukias of the Taulantii shelters the infant Pyrrhus of Epirus and refuses to hand him to his enemies. Years later he helps restore him to the Epirote throne.'**
  String get timelineEventGlaukiasShieldsPyrrhus;

  /// No description provided for @timelineEventTeutaTakesTheHelm.
  ///
  /// In en, this message translates to:
  /// **'After King Agron\'s sudden death, his widow Teuta rules the Ardiaean kingdom for his young son. Her fleets raid the Adriatic and Ionian coasts and sack Phoenice (today\'s Finiq), the richest city of Epirus.'**
  String get timelineEventTeutaTakesTheHelm;

  /// No description provided for @timelineEventTeutaDefiesRome.
  ///
  /// In en, this message translates to:
  /// **'Rome sends 200 ships against Queen Teuta. The First Illyrian War ends in 228 BCE with Corcyra, Epidamnos and Apollonia under Roman protection.'**
  String get timelineEventTeutaDefiesRome;

  /// No description provided for @timelineEventGentiusFalls.
  ///
  /// In en, this message translates to:
  /// **'In the Third Illyrian War, Rome defeats King Gentius within weeks and captures him at Scodra (Shkodër). His kingdom is broken up into districts under Roman control.'**
  String get timelineEventGentiusFalls;

  /// No description provided for @timelineEventEpirusSacked.
  ///
  /// In en, this message translates to:
  /// **'To punish Epirus for siding with Macedon, Rome sacks 70 of its towns and sells 150,000 people into slavery. The south of today\'s Albania is among the lands hit.'**
  String get timelineEventEpirusSacked;

  /// No description provided for @timelineEventViaEgnatia.
  ///
  /// In en, this message translates to:
  /// **'Rome builds the Via Egnatia, a road from Dyrrachium and Apollonia over the mountains to Thessalonica, later extended to Byzantium.'**
  String get timelineEventViaEgnatia;

  /// No description provided for @timelineEventCaesarAndPompey.
  ///
  /// In en, this message translates to:
  /// **'In Rome\'s civil war, Julius Caesar besieges Pompey at Dyrrachium (Durrës) but is driven off. Weeks later he wins the war at Pharsalus in Greece.'**
  String get timelineEventCaesarAndPompey;

  /// No description provided for @timelineEventPaulInIllyricum.
  ///
  /// In en, this message translates to:
  /// **'In his letter to the Romans, the apostle Paul writes that he has preached the gospel \'as far as Illyricum\'.'**
  String get timelineEventPaulInIllyricum;

  /// No description provided for @timelineEventEmpireSplits.
  ///
  /// In en, this message translates to:
  /// **'When Emperor Theodosius I dies, the Roman Empire is split for good. The Albanian lands fall to the eastern half, ruled from Constantinople.'**
  String get timelineEventEmpireSplits;

  /// No description provided for @timelineEventAnastasiusEmperor.
  ///
  /// In en, this message translates to:
  /// **'Anastasius I, born in Dyrrachium (Durrës), becomes Byzantine emperor and later strengthens the walls of his home city.'**
  String get timelineEventAnastasiusEmperor;

  /// No description provided for @timelineEventButrintBaptistery.
  ///
  /// In en, this message translates to:
  /// **'Butrint builds a great baptistery whose mosaic floor of birds, animals and vines is among the finest early Christian mosaics in the Balkans.'**
  String get timelineEventButrintBaptistery;

  /// No description provided for @timelineEventCodexBeratinus.
  ///
  /// In en, this message translates to:
  /// **'Scribes copy the Gospels of Matthew and Mark in silver ink on purple parchment. Kept in Berat since at least 1356, the Codex Beratinus is one of the oldest Gospel books in the world.'**
  String get timelineEventCodexBeratinus;

  /// No description provided for @timelineEventBasilReconquers.
  ///
  /// In en, this message translates to:
  /// **'Emperor Basil II destroys the Bulgarian state, which had ruled much of the region, and restores Byzantine rule through the Theme of Dyrrachium.'**
  String get timelineEventBasilReconquers;

  /// No description provided for @timelineEventAlbanoiNamed.
  ///
  /// In en, this message translates to:
  /// **'A Byzantine chronicle names \'Albanoi\' among the troops of the rebel general George Maniakes, one of the first written records of the Albanians.'**
  String get timelineEventAlbanoiNamed;

  /// No description provided for @timelineEventGreatSchism.
  ///
  /// In en, this message translates to:
  /// **'The churches of Rome and Constantinople split. Over time Albanian Christians divide along the same line: Catholic in the north, Orthodox in the south.'**
  String get timelineEventGreatSchism;

  /// No description provided for @timelineEventNormansAtDyrrachium.
  ///
  /// In en, this message translates to:
  /// **'Robert Guiscard\'s Normans defeat Emperor Alexios I at Dyrrachium, opening a long struggle between Normans, Venetians and Byzantines for the coast.'**
  String get timelineEventNormansAtDyrrachium;

  /// No description provided for @timelineEventArbanon.
  ///
  /// In en, this message translates to:
  /// **'Progon, lord of Krujë, founds Arbanon, the first Albanian state of the Middle Ages. His sons Gjin and Dhimitër rule after him.'**
  String get timelineEventArbanon;

  /// No description provided for @timelineEventRegnumAlbaniae.
  ///
  /// In en, this message translates to:
  /// **'Charles of Anjou, king of Sicily, is proclaimed King of Albania (Regnum Albaniae), a Crusader-era state on the coast around Durrës.'**
  String get timelineEventRegnumAlbaniae;

  /// No description provided for @timelineEventSiegeOfBerat.
  ///
  /// In en, this message translates to:
  /// **'An Angevin army besieges Berat, but a Byzantine relief force captures its commander, Hugh of Sully, and the besiegers flee towards Vlorë.'**
  String get timelineEventSiegeOfBerat;

  /// No description provided for @timelineEventVoiceInTheMountains.
  ///
  /// In en, this message translates to:
  /// **'A court record in Ragusa (Dubrovnik) notes: \'I heard a voice crying in the mountains in the Albanian language.\' It is the earliest known mention of spoken Albanian.'**
  String get timelineEventVoiceInTheMountains;

  /// No description provided for @timelineEventALanguageOfTheirOwn.
  ///
  /// In en, this message translates to:
  /// **'A Dominican report to the French king notes that the Albanians have a language quite unlike Latin, but use Latin letters in their books.'**
  String get timelineEventALanguageOfTheirOwn;

  /// No description provided for @timelineEventAlbanianPrincipalities.
  ///
  /// In en, this message translates to:
  /// **'Stefan Dušan\'s Serbian Empire, which had conquered most Albanian lands, breaks up after his death. Families such as the Balsha, Thopia, Muzaka, Dukagjini and Kastrioti rule their own principalities.'**
  String get timelineEventAlbanianPrincipalities;

  /// No description provided for @timelineEventBattleOfSavra.
  ///
  /// In en, this message translates to:
  /// **'At the Battle of Savra, an Ottoman army defeats and kills Balsha II, lord of Durrës. Many Albanian lords soon become Ottoman vassals.'**
  String get timelineEventBattleOfSavra;

  /// No description provided for @timelineEventBattleOfKosovo.
  ///
  /// In en, this message translates to:
  /// **'Albanian lords fight alongside Prince Lazar\'s Serbian army against the Ottomans on the Field of Kosovo. Both Lazar and Sultan Murad I are killed.'**
  String get timelineEventBattleOfKosovo;

  /// No description provided for @timelineEventOttomansTakeTheSouth.
  ///
  /// In en, this message translates to:
  /// **'Ottoman forces capture Vlorë, Kaninë and Berat. A year later Gjirokastër falls too.'**
  String get timelineEventOttomansTakeTheSouth;

  /// No description provided for @timelineEventRevoltOf1432.
  ///
  /// In en, this message translates to:
  /// **'Albanian lords led by Gjergj Arianiti rise against Ottoman rule and win several battles before the revolt is crushed in 1436.'**
  String get timelineEventRevoltOf1432;

  /// No description provided for @timelineEventSkanderbegReturns.
  ///
  /// In en, this message translates to:
  /// **'Gjergj Kastrioti, an Ottoman commander known as Skanderbeg, deserts at the Battle of Niš, takes Krujë on 28 November and raises his red flag with the black double-headed eagle.'**
  String get timelineEventSkanderbegReturns;

  /// No description provided for @timelineEventLeagueOfLezhe.
  ///
  /// In en, this message translates to:
  /// **'Albanian princes unite under Skanderbeg in the League of Lezhë. Months later they win their first great victory, at Torvioll.'**
  String get timelineEventLeagueOfLezhe;

  /// No description provided for @timelineEventFirstSiegeOfKruja.
  ///
  /// In en, this message translates to:
  /// **'Sultan Murad II besieges Krujë for months with a huge army, but the garrison holds out and he withdraws.'**
  String get timelineEventFirstSiegeOfKruja;

  /// No description provided for @timelineEventBattleOfAlbulena.
  ///
  /// In en, this message translates to:
  /// **'Skanderbeg routs a large Ottoman army at Albulena (Ujëbardha), one of his most celebrated victories.'**
  String get timelineEventBattleOfAlbulena;

  /// No description provided for @timelineEventBaptismalFormula.
  ///
  /// In en, this message translates to:
  /// **'Archbishop Pal Engjëlli writes a baptismal formula in Albanian into a Latin letter: \'Un\'te paghesont\' pr\'emenit t\'Atit e t\'Birit e t\'Spertit Senit.\' It is the oldest known written Albanian sentence.'**
  String get timelineEventBaptismalFormula;

  /// No description provided for @timelineEventMehmedsSieges.
  ///
  /// In en, this message translates to:
  /// **'Sultan Mehmed II, conqueror of Constantinople, besieges Krujë twice and builds the fortress of Elbasan to cut Skanderbeg\'s lands in two. Krujë still holds.'**
  String get timelineEventMehmedsSieges;

  /// No description provided for @timelineEventSkanderbegDies.
  ///
  /// In en, this message translates to:
  /// **'Skanderbeg dies of fever in Lezhë on 17 January. Without him, the resistance slowly gives way.'**
  String get timelineEventSkanderbegDies;

  /// No description provided for @timelineEventArbereshMigration.
  ///
  /// In en, this message translates to:
  /// **'As the Ottomans advance, thousands of Albanians cross to southern Italy and Sicily. Their descendants, the Arbëreshë, still speak Albanian in dozens of villages today.'**
  String get timelineEventArbereshMigration;

  /// No description provided for @timelineEventShkoderFalls.
  ///
  /// In en, this message translates to:
  /// **'After a long siege, Venice hands Shkodër to the Ottomans. Almost all of Albania is now under Ottoman rule; Durrës follows in 1501.'**
  String get timelineEventShkoderFalls;

  /// No description provided for @timelineEventMeshari.
  ///
  /// In en, this message translates to:
  /// **'Gjon Buzuku, a Catholic priest, completes the Meshari (Missal), the oldest surviving book in Albanian. A single copy survives, in the Vatican Library.'**
  String get timelineEventMeshari;

  /// No description provided for @timelineEventBardhiDictionary.
  ///
  /// In en, this message translates to:
  /// **'Frang Bardhi publishes a Latin–Albanian dictionary in Rome, the first dictionary of the Albanian language.'**
  String get timelineEventBardhiDictionary;

  /// No description provided for @timelineEventIslamization.
  ///
  /// In en, this message translates to:
  /// **'Over the 17th century most Albanians convert to Islam, often to escape heavy taxes and to rise in Ottoman service. Catholic and Orthodox communities endure.'**
  String get timelineEventIslamization;

  /// No description provided for @timelineEventCuneusProphetarum.
  ///
  /// In en, this message translates to:
  /// **'Archbishop Pjetër Bogdani publishes Cuneus Prophetarum (The Band of the Prophets) in Padua, the first major original work of Albanian prose.'**
  String get timelineEventCuneusProphetarum;

  /// No description provided for @timelineEventVoskopojePress.
  ///
  /// In en, this message translates to:
  /// **'Voskopojë, a rich trading town near Korçë, opens one of the first printing presses in the Ottoman Balkans. In 1744 it founds the New Academy.'**
  String get timelineEventVoskopojePress;

  /// No description provided for @timelineEventBushatiPashalik.
  ///
  /// In en, this message translates to:
  /// **'Mehmed Pasha Bushati makes Shkodër the seat of a near-independent pashalik that his family rules until 1831.'**
  String get timelineEventBushatiPashalik;

  /// No description provided for @timelineEventAliPashaRises.
  ///
  /// In en, this message translates to:
  /// **'Ali Pasha becomes ruler of Ioannina and builds a near-independent state across southern Albania and mainland Greece.'**
  String get timelineEventAliPashaRises;

  /// No description provided for @timelineEventAliPashaFalls.
  ///
  /// In en, this message translates to:
  /// **'After a long siege at Ioannina, the Sultan\'s agents kill the elderly Ali Pasha and send his head to Constantinople.'**
  String get timelineEventAliPashaFalls;

  /// No description provided for @timelineEventMassacreOfTheBeys.
  ///
  /// In en, this message translates to:
  /// **'The Ottoman grand vizier invites Albanian beys to Manastir with a promise of amnesty and has some 500 of them killed, breaking the power of the old lords.'**
  String get timelineEventMassacreOfTheBeys;

  /// No description provided for @timelineEventVeqilharxhiPrimer.
  ///
  /// In en, this message translates to:
  /// **'Naum Veqilharxhi publishes an Albanian spelling book in an alphabet of his own invention, one of the first works of the National Awakening.'**
  String get timelineEventVeqilharxhiPrimer;

  /// No description provided for @timelineEventLeagueOfPrizren.
  ///
  /// In en, this message translates to:
  /// **'As the Great Powers prepare to hand Albanian-inhabited lands to Serbia and Montenegro, Albanian leaders meet in Prizren to defend them. It is the first organised national movement; Ottoman troops crush it in 1881.'**
  String get timelineEventLeagueOfPrizren;

  /// No description provided for @timelineEventIstanbulAlphabet.
  ///
  /// In en, this message translates to:
  /// **'Sami Frashëri and fellow patriots found a society in Istanbul to print books in Albanian and publish an alphabet for the language.'**
  String get timelineEventIstanbulAlphabet;

  /// No description provided for @timelineEventHerdsAndFields.
  ///
  /// In en, this message translates to:
  /// **'Naim Frashëri publishes Bagëti e Bujqësi (Herds and Fields), a hymn to the Albanian countryside that becomes the best-loved poem of the Awakening.'**
  String get timelineEventHerdsAndFields;

  /// No description provided for @timelineEventFirstAlbanianSchool.
  ///
  /// In en, this message translates to:
  /// **'On 7 March, the Mësonjëtorja opens in Korçë, the first school to teach in Albanian.'**
  String get timelineEventFirstAlbanianSchool;

  /// No description provided for @timelineEventSchoolForGirls.
  ///
  /// In en, this message translates to:
  /// **'Sevasti Qiriazi founds the first Albanian school for girls in Korçë, where girls learn to read and write in their own language.'**
  String get timelineEventSchoolForGirls;

  /// No description provided for @timelineEventSamiManifesto.
  ///
  /// In en, this message translates to:
  /// **'Sami Frashëri publishes Albania: What It Was, What It Is and What It Will Be, a blueprint for a free Albanian state.'**
  String get timelineEventSamiManifesto;

  /// No description provided for @timelineEventFirstAlbanianLiturgy.
  ///
  /// In en, this message translates to:
  /// **'In Boston, Fan Noli celebrates the first Orthodox liturgy in the Albanian language, the start of an Albanian Orthodox church.'**
  String get timelineEventFirstAlbanianLiturgy;

  /// No description provided for @timelineEventCongressOfManastir.
  ///
  /// In en, this message translates to:
  /// **'The Congress of Manastir adopts the Latin-based Albanian alphabet that is still used today.'**
  String get timelineEventCongressOfManastir;

  /// No description provided for @timelineEventFlagAtDeciq.
  ///
  /// In en, this message translates to:
  /// **'During the highland uprising of 1911, Ded Gjo Luli\'s fighters win at Deçiq and raise the Albanian flag, for the first time since the 15th century.'**
  String get timelineEventFlagAtDeciq;

  /// No description provided for @timelineEventIndependence.
  ///
  /// In en, this message translates to:
  /// **'On 28 November, Ismail Qemali raises the flag in Vlorë and declares Albania independent of the Ottoman Empire.'**
  String get timelineEventIndependence;

  /// No description provided for @timelineEventLondonBorders.
  ///
  /// In en, this message translates to:
  /// **'The Great Powers recognise an independent Albania but leave Kosovo and other Albanian-inhabited lands outside its borders.'**
  String get timelineEventLondonBorders;

  /// No description provided for @timelineEventPrinceWied.
  ///
  /// In en, this message translates to:
  /// **'Prince Wilhelm of Wied arrives to rule the new Principality of Albania. Within six months, revolt and World War I drive him out.'**
  String get timelineEventPrinceWied;

  /// No description provided for @timelineEventRepublicOfKorca.
  ///
  /// In en, this message translates to:
  /// **'Under French military protection, Korçë becomes an autonomous Albanian republic with its own schools, stamps and flag.'**
  String get timelineEventRepublicOfKorca;

  /// No description provided for @timelineEventCongressOfLushnje.
  ///
  /// In en, this message translates to:
  /// **'The Congress of Lushnjë rejects plans to divide Albania among its neighbours and makes Tirana the capital.'**
  String get timelineEventCongressOfLushnje;

  /// No description provided for @timelineEventVloraWar.
  ///
  /// In en, this message translates to:
  /// **'Albanian volunteers besiege the Italian army in Vlorë, and by September Italy withdraws from mainland Albania. In December, Albania joins the League of Nations.'**
  String get timelineEventVloraWar;

  /// No description provided for @timelineEventOrthodoxAutocephaly.
  ///
  /// In en, this message translates to:
  /// **'The Congress of Berat declares the Albanian Orthodox Church autocephalous, independent of the Patriarchate of Constantinople.'**
  String get timelineEventOrthodoxAutocephaly;

  /// No description provided for @timelineEventJuneRevolution.
  ///
  /// In en, this message translates to:
  /// **'A revolt brings Bishop Fan Noli to power with a programme of reforms. Six months later Ahmet Zogu returns with foreign backing and Noli flees.'**
  String get timelineEventJuneRevolution;

  /// No description provided for @timelineEventKingZog.
  ///
  /// In en, this message translates to:
  /// **'President Ahmet Zogu proclaims himself Zog I, King of the Albanians.'**
  String get timelineEventKingZog;

  /// No description provided for @timelineEventBektashiCentre.
  ///
  /// In en, this message translates to:
  /// **'Banned in Turkey, the Bektashi Sufi order decides at a congress in Korçë to move its world headquarters to Tirana, where it remains today.'**
  String get timelineEventBektashiCentre;

  /// No description provided for @timelineEventKanunPublished.
  ///
  /// In en, this message translates to:
  /// **'Shtjefën Gjeçovi\'s collection of the Kanun of Lekë Dukagjini, the customary law of the northern highlands, is published in full.'**
  String get timelineEventKanunPublished;

  /// No description provided for @timelineEventItalianInvasion.
  ///
  /// In en, this message translates to:
  /// **'On 7 April, Mussolini\'s troops land at Durrës and other ports. King Zog flees, and Albania is joined to the Italian crown.'**
  String get timelineEventItalianInvasion;

  /// No description provided for @timelineEventKokalariBook.
  ///
  /// In en, this message translates to:
  /// **'Musine Kokalari publishes As My Old Mother Tells Me, stories in the dialect of Gjirokastër. She is the first Albanian woman to publish prose.'**
  String get timelineEventKokalariBook;

  /// No description provided for @timelineEventWarWithGreece.
  ///
  /// In en, this message translates to:
  /// **'Italy attacks Greece from Albanian soil. The Greek counter-attack pushes deep into the south, taking Korçë in November and Gjirokastër in December.'**
  String get timelineEventWarWithGreece;

  /// No description provided for @timelineEventResistanceOrganises.
  ///
  /// In en, this message translates to:
  /// **'At the Peza Conference, communists and nationalists form the National Liberation Movement. The rival nationalist Balli Kombëtar is founded later that year.'**
  String get timelineEventResistanceOrganises;

  /// No description provided for @timelineEventGermanOccupation.
  ///
  /// In en, this message translates to:
  /// **'Italy surrenders in September and German troops occupy Albania. The rival resistance groups now fight each other as well as the occupiers.'**
  String get timelineEventGermanOccupation;

  /// No description provided for @timelineEventBesaJews.
  ///
  /// In en, this message translates to:
  /// **'Albanian families, Muslim and Christian, hide Jewish refugees from the occupiers, honouring besa, a sacred promise. Albania ends the war with more Jews than it had before.'**
  String get timelineEventBesaJews;

  /// No description provided for @timelineEventGovernmentAtBerat.
  ///
  /// In en, this message translates to:
  /// **'Meeting in Berat in October, the communist-led resistance council forms a provisional government with Enver Hoxha as prime minister.'**
  String get timelineEventGovernmentAtBerat;

  /// No description provided for @timelineEventLiberation.
  ///
  /// In en, this message translates to:
  /// **'On 29 November the last German troops leave. The communist-led partisans take power, and Enver Hoxha begins four decades of one-party rule.'**
  String get timelineEventLiberation;

  /// No description provided for @timelineEventPeoplesRepublic.
  ///
  /// In en, this message translates to:
  /// **'Albania is proclaimed a People\'s Republic. Opponents are tried and imprisoned, among them the writer Musine Kokalari.'**
  String get timelineEventPeoplesRepublic;

  /// No description provided for @timelineEventCorfuChannel.
  ///
  /// In en, this message translates to:
  /// **'Mines in the Corfu Channel badly damage two British destroyers and kill 44 sailors. The dispute becomes the first case judged by the International Court of Justice.'**
  String get timelineEventCorfuChannel;

  /// No description provided for @timelineEventBreakWithYugoslavia.
  ///
  /// In en, this message translates to:
  /// **'When Tito breaks with Stalin, Hoxha cuts ties with Yugoslavia and turns to the Soviet Union.'**
  String get timelineEventBreakWithYugoslavia;

  /// No description provided for @timelineEventBreakWithMoscow.
  ///
  /// In en, this message translates to:
  /// **'Albania sides with China against Khrushchev. The Soviet Union breaks off relations and pulls its forces out of the naval base at Vlorë.'**
  String get timelineEventBreakWithMoscow;

  /// No description provided for @timelineEventAtheistState.
  ///
  /// In en, this message translates to:
  /// **'The regime closes or destroys mosques and churches and declares Albania the world\'s first atheist state.'**
  String get timelineEventAtheistState;

  /// No description provided for @timelineEventBunkers.
  ///
  /// In en, this message translates to:
  /// **'Fearing invasion, the regime covers the country with concrete bunkers, some 170,000 of them, built from the late 1960s to the mid-1980s.'**
  String get timelineEventBunkers;

  /// No description provided for @timelineEventChronicleInStone.
  ///
  /// In en, this message translates to:
  /// **'Ismail Kadare publishes Chronicle in Stone, which shows his native Gjirokastër during World War II through the eyes of a boy.'**
  String get timelineEventChronicleInStone;

  /// No description provided for @timelineEventOrthographicCongress.
  ///
  /// In en, this message translates to:
  /// **'The Congress of Orthography fixes a single standard for written Albanian, based mainly on the southern Tosk dialect.'**
  String get timelineEventOrthographicCongress;

  /// No description provided for @timelineEventBreakWithChina.
  ///
  /// In en, this message translates to:
  /// **'China ends its aid, and Albania breaks with its last ally, relying only on itself.'**
  String get timelineEventBreakWithChina;

  /// No description provided for @timelineEventMotherTeresaNobel.
  ///
  /// In en, this message translates to:
  /// **'Mother Teresa, born Anjezë Gonxhe Bojaxhiu to an Albanian family in Skopje, receives the Nobel Peace Prize for her work among the poor of Calcutta.'**
  String get timelineEventMotherTeresaNobel;

  /// No description provided for @timelineEventHoxhaDies.
  ///
  /// In en, this message translates to:
  /// **'Enver Hoxha dies on 11 April. His successor, Ramiz Alia, loosens controls only slowly.'**
  String get timelineEventHoxhaDies;

  /// No description provided for @timelineEventRegimeCracks.
  ///
  /// In en, this message translates to:
  /// **'In July, thousands of Albanians rush into foreign embassies to leave the country. In December, student protests in Tirana force the regime to allow opposition parties.'**
  String get timelineEventRegimeCracks;

  /// No description provided for @timelineEventFaithReturns.
  ///
  /// In en, this message translates to:
  /// **'On 4 November, the priest Simon Jubani says the first public Mass in decades, in a cemetery in Shkodër. Within months, mosques and churches reopen across the country.'**
  String get timelineEventFaithReturns;

  /// No description provided for @timelineEventFirstFreeElections.
  ///
  /// In en, this message translates to:
  /// **'In March, Albania holds its first multi-party elections in decades. The former communists win, but a year later the Democratic Party takes power.'**
  String get timelineEventFirstFreeElections;

  /// No description provided for @timelineEventVloraShip.
  ///
  /// In en, this message translates to:
  /// **'On 8 August the freighter Vlora reaches Bari carrying an estimated 20,000 Albanians, the defining image of a mass exodus.'**
  String get timelineEventVloraShip;

  /// No description provided for @timelineEventPyramidCrisis.
  ///
  /// In en, this message translates to:
  /// **'The collapse of pyramid investment schemes wipes out the savings of much of the country and sets off armed unrest in which more than 2,000 people die.'**
  String get timelineEventPyramidCrisis;

  /// No description provided for @timelineEventKosovoRefugees.
  ///
  /// In en, this message translates to:
  /// **'During the Kosovo war, Albania takes in some 450,000 refugees, most of them in private homes.'**
  String get timelineEventKosovoRefugees;

  /// No description provided for @timelineEventIsoPolyphony.
  ///
  /// In en, this message translates to:
  /// **'UNESCO proclaims Albanian folk iso-polyphony, the many-voiced singing of the south, a masterpiece of humanity\'s oral and intangible heritage.'**
  String get timelineEventIsoPolyphony;

  /// No description provided for @timelineEventKadareBooker.
  ///
  /// In en, this message translates to:
  /// **'Ismail Kadare wins the first Man Booker International Prize for his body of work.'**
  String get timelineEventKadareBooker;

  /// No description provided for @timelineEventNatoMembership.
  ///
  /// In en, this message translates to:
  /// **'Albania becomes a member of NATO on 1 April and applies to join the European Union weeks later.'**
  String get timelineEventNatoMembership;

  /// No description provided for @timelineEventEuCandidate.
  ///
  /// In en, this message translates to:
  /// **'Albania becomes an official candidate for membership of the European Union.'**
  String get timelineEventEuCandidate;

  /// No description provided for @timelineEventDurresEarthquake.
  ///
  /// In en, this message translates to:
  /// **'A magnitude 6.4 earthquake strikes near Durrës on 26 November, killing 51 people and leaving thousands homeless.'**
  String get timelineEventDurresEarthquake;

  /// No description provided for @timelineEventEuTalks.
  ///
  /// In en, this message translates to:
  /// **'Albania formally opens accession negotiations with the European Union on 19 July.'**
  String get timelineEventEuTalks;

  /// No description provided for @pageNotFoundBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back to civilization'**
  String get pageNotFoundBackButton;

  /// No description provided for @pageNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The page you are looking for does not exist.'**
  String get pageNotFoundMessage;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authSignInTitle;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue exploring Albania.'**
  String get authSignInSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get authSignInButton;

  /// No description provided for @authSignInError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authSignInError;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequired;

  /// No description provided for @buddyHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel Buddy'**
  String get buddyHeaderTitle;

  /// No description provided for @buddyHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Albania-native AI guide'**
  String get buddyHeaderSubtitle;

  /// No description provided for @buddyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'How can I help plan your trip?'**
  String get buddyEmptyTitle;

  /// No description provided for @buddyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask me about places, food, budgets, or itineraries in Albania.'**
  String get buddyEmptySubtitle;

  /// No description provided for @buddyComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Message your travel buddy…'**
  String get buddyComposerHint;

  /// No description provided for @buddySuggestionTirana.
  ///
  /// In en, this message translates to:
  /// **'Plan a 3-day Tirana trip'**
  String get buddySuggestionTirana;

  /// No description provided for @buddySuggestionBerat.
  ///
  /// In en, this message translates to:
  /// **'Best things to do in Berat'**
  String get buddySuggestionBerat;

  /// No description provided for @buddySuggestionBudget.
  ///
  /// In en, this message translates to:
  /// **'Albania on a tight budget'**
  String get buddySuggestionBudget;

  /// No description provided for @buddyErrorHint.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get buddyErrorHint;

  /// No description provided for @buddyErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buddyErrorRetry;

  /// No description provided for @buddyNotSavedHint.
  ///
  /// In en, this message translates to:
  /// **'Reply not saved on the server.'**
  String get buddyNotSavedHint;

  /// Soft inline footer shown on the assistant bubble when the backend rejected Claude's emit_itinerary tool payload during server-side validation. The natural-language reply is still visible above; this string explains why the structured Save card is missing without surfacing the technical reason.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t structure that itinerary — your reply is above.'**
  String get buddyItineraryUnstructured;

  /// Body button on the trip detail screen that opens a chat scoped to that saved trip. Tapping it routes to the buddy tab with the trip's 1:1 conversation hydrated.
  ///
  /// In en, this message translates to:
  /// **'Refine with Buddy'**
  String get refineWithBuddyButton;

  /// Replaces buddyComposerHint when the chat is in refine-with-buddy mode for a saved trip.
  ///
  /// In en, this message translates to:
  /// **'Ask Buddy to refine this trip…'**
  String get refineComposerHint;

  /// Welcome title shown on a fresh refine chat (scopedTrip != null, no messages yet). Replaces buddyEmptyTitle in refine mode so the user isn't greeted with planning-mode copy.
  ///
  /// In en, this message translates to:
  /// **'What should we change?'**
  String get refineEmptyTitle;

  /// Welcome subtitle shown on a fresh refine chat. Replaces buddyEmptySubtitle in refine mode.
  ///
  /// In en, this message translates to:
  /// **'Ask Buddy to tweak this trip — shorten a day, swap a stop, add something new.'**
  String get refineEmptySubtitle;

  /// Quick-pick chip on the refine welcome screen. Tapping sends this text verbatim to the chat.
  ///
  /// In en, this message translates to:
  /// **'Shorten day 2'**
  String get refineSuggestionShortenDay;

  /// Quick-pick chip on the refine welcome screen. Tapping sends this text verbatim to the chat.
  ///
  /// In en, this message translates to:
  /// **'Add a beach day'**
  String get refineSuggestionAddBeach;

  /// Quick-pick chip on the refine welcome screen. Tapping sends this text verbatim to the chat.
  ///
  /// In en, this message translates to:
  /// **'Swap a stop for something more local'**
  String get refineSuggestionSwapStop;

  /// Top banner on the chat screen while in refine mode.
  ///
  /// In en, this message translates to:
  /// **'Refining: {tripTitle}'**
  String refineBannerTitle(String tripTitle);

  /// Action on the refine banner that drops out of refine mode without changing the saved trip.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get refineBannerExit;

  /// Inline indicator on the assistant bubble after the server applied a refinement to the saved trip.
  ///
  /// In en, this message translates to:
  /// **'Trip updated'**
  String get refineTripUpdated;

  /// Link on the assistant bubble's trip-updated indicator. Routes back to the trip detail screen.
  ///
  /// In en, this message translates to:
  /// **'View trip'**
  String get refineViewTrip;

  /// Soft inline footer when Claude emitted a valid itinerary but the server-side replace transaction failed. The trip on disk is unchanged.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t apply the refinement. The chat reply describes the proposed change.'**
  String get refineFailedFooter;

  /// Inline error shown via TripErrorBanner when the trip detail screen fails to open the refine chat (network / auth).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open chat — try again.'**
  String get refineOpenFailed;

  /// No description provided for @buddySendTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get buddySendTooltip;

  /// No description provided for @buddyPlaceCardOpenInMap.
  ///
  /// In en, this message translates to:
  /// **'Open in map'**
  String get buddyPlaceCardOpenInMap;

  /// No description provided for @buddyVoiceHoldToTalk.
  ///
  /// In en, this message translates to:
  /// **'Hold to talk'**
  String get buddyVoiceHoldToTalk;

  /// No description provided for @buddyVoiceTapToTalk.
  ///
  /// In en, this message translates to:
  /// **'Tap to talk'**
  String get buddyVoiceTapToTalk;

  /// No description provided for @buddyVoiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get buddyVoiceListening;

  /// No description provided for @buddyVoiceCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buddyVoiceCancel;

  /// No description provided for @buddyVoiceStop.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get buddyVoiceStop;

  /// No description provided for @buddyVoiceSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get buddyVoiceSend;

  /// No description provided for @buddyVoicePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied. Enable it in Settings to use voice.'**
  String get buddyVoicePermissionDenied;

  /// No description provided for @buddyVoiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice recognition isn\'t available on this device.'**
  String get buddyVoiceUnavailable;

  /// No description provided for @buddyTtsPlay.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get buddyTtsPlay;

  /// No description provided for @buddyTtsStop.
  ///
  /// In en, this message translates to:
  /// **'Stop reading'**
  String get buddyTtsStop;

  /// No description provided for @buddyAttachTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get buddyAttachTooltip;

  /// No description provided for @buddyAttachCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get buddyAttachCamera;

  /// No description provided for @buddyAttachGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get buddyAttachGallery;

  /// No description provided for @buddyAttachUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get buddyAttachUploading;

  /// No description provided for @buddyAttachFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get buddyAttachFailed;

  /// No description provided for @buddyAttachRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get buddyAttachRemove;

  /// No description provided for @buddyAttachRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buddyAttachRetry;

  /// No description provided for @buddyAttachSizeError.
  ///
  /// In en, this message translates to:
  /// **'Image too large — try a smaller photo'**
  String get buddyAttachSizeError;

  /// No description provided for @buddyAttachFormatError.
  ///
  /// In en, this message translates to:
  /// **'Unsupported image — use JPG, PNG, GIF, or WebP'**
  String get buddyAttachFormatError;

  /// No description provided for @buddyHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Past conversations'**
  String get buddyHistoryTooltip;

  /// No description provided for @buddyNewChatTooltip.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get buddyNewChatTooltip;

  /// No description provided for @conversationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Past conversations'**
  String get conversationsTitle;

  /// No description provided for @conversationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get conversationsEmpty;

  /// No description provided for @conversationsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load conversations'**
  String get conversationsLoadFailed;

  /// No description provided for @conversationsNewChatTooltip.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get conversationsNewChatTooltip;

  /// No description provided for @conversationsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation?'**
  String get conversationsDeleteTitle;

  /// No description provided for @conversationsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get conversationsDeleteConfirm;

  /// No description provided for @conversationsDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get conversationsDeleteAction;

  /// No description provided for @conversationsDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get conversationsDeleteCancel;

  /// No description provided for @conversationsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete conversation.'**
  String get conversationsDeleteFailed;

  /// No description provided for @conversationsClearAllAction.
  ///
  /// In en, this message translates to:
  /// **'Clear all conversations'**
  String get conversationsClearAllAction;

  /// No description provided for @conversationsClearAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all conversations?'**
  String get conversationsClearAllTitle;

  /// No description provided for @conversationsClearAllBody.
  ///
  /// In en, this message translates to:
  /// **'Every conversation will be permanently deleted. This can\'t be undone.'**
  String get conversationsClearAllBody;

  /// No description provided for @conversationsClearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get conversationsClearAllConfirm;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get profileEmailLabel;

  /// No description provided for @profileSignOutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutButton;

  /// No description provided for @preferencesTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesTileTitle;

  /// No description provided for @preferencesTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your travel style'**
  String get preferencesTileSubtitle;

  /// No description provided for @preferencesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesScreenTitle;

  /// No description provided for @preferencesSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get preferencesSaveButton;

  /// No description provided for @preferencesSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved'**
  String get preferencesSaveSuccess;

  /// No description provided for @preferencesSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save preferences'**
  String get preferencesSaveError;

  /// No description provided for @preferencesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load preferences'**
  String get preferencesLoadError;

  /// No description provided for @preferencesNotSetYet.
  ///
  /// In en, this message translates to:
  /// **'Not set yet'**
  String get preferencesNotSetYet;

  /// No description provided for @preferencesPersonaSection.
  ///
  /// In en, this message translates to:
  /// **'Travel persona'**
  String get preferencesPersonaSection;

  /// No description provided for @preferencesPersonaEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tap Generate to create your travel persona'**
  String get preferencesPersonaEmpty;

  /// No description provided for @preferencesPersonaGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate persona'**
  String get preferencesPersonaGenerate;

  /// No description provided for @preferencesPersonaRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get preferencesPersonaRegenerate;

  /// No description provided for @preferencesPersonaError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t generate persona'**
  String get preferencesPersonaError;

  /// No description provided for @preferencesPersonaUseButton.
  ///
  /// In en, this message translates to:
  /// **'Use this persona'**
  String get preferencesPersonaUseButton;

  /// No description provided for @preferencesPersonaInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Pick the persona that feels closest to you right now. It\'s just the starting point — the more you chat with Travel Buddy, the better it understands how you actually travel. Your budget, your pace, what you skip, what you never miss. Over time, recommendations stop feeling generic and start feeling like they were made for you.'**
  String get preferencesPersonaInfoBody;

  /// No description provided for @preferencesPersonaInfoDismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get preferencesPersonaInfoDismiss;

  /// No description provided for @preferencesBudgetSection.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get preferencesBudgetSection;

  /// No description provided for @preferencesBudgetShoestring.
  ///
  /// In en, this message translates to:
  /// **'Shoestring'**
  String get preferencesBudgetShoestring;

  /// No description provided for @preferencesBudgetMidRange.
  ///
  /// In en, this message translates to:
  /// **'Mid-range'**
  String get preferencesBudgetMidRange;

  /// No description provided for @preferencesBudgetLuxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get preferencesBudgetLuxury;

  /// No description provided for @preferencesGroupSection.
  ///
  /// In en, this message translates to:
  /// **'Who\'s travelling'**
  String get preferencesGroupSection;

  /// No description provided for @preferencesGroupSolo.
  ///
  /// In en, this message translates to:
  /// **'Solo'**
  String get preferencesGroupSolo;

  /// No description provided for @preferencesGroupCouple.
  ///
  /// In en, this message translates to:
  /// **'Couple'**
  String get preferencesGroupCouple;

  /// No description provided for @preferencesGroupFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get preferencesGroupFamily;

  /// No description provided for @preferencesGroupFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get preferencesGroupFriends;

  /// No description provided for @preferencesStyleSection.
  ///
  /// In en, this message translates to:
  /// **'Travel style'**
  String get preferencesStyleSection;

  /// No description provided for @preferencesStyleAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get preferencesStyleAdventure;

  /// No description provided for @preferencesStyleCultural.
  ///
  /// In en, this message translates to:
  /// **'Cultural'**
  String get preferencesStyleCultural;

  /// No description provided for @preferencesStyleRelaxation.
  ///
  /// In en, this message translates to:
  /// **'Relaxation'**
  String get preferencesStyleRelaxation;

  /// No description provided for @preferencesStyleFoodie.
  ///
  /// In en, this message translates to:
  /// **'Foodie'**
  String get preferencesStyleFoodie;

  /// No description provided for @preferencesStyleBeach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get preferencesStyleBeach;

  /// No description provided for @preferencesStyleNightlife.
  ///
  /// In en, this message translates to:
  /// **'Nightlife'**
  String get preferencesStyleNightlife;

  /// No description provided for @preferencesStyleHiddenGem.
  ///
  /// In en, this message translates to:
  /// **'Off-the-beaten-path'**
  String get preferencesStyleHiddenGem;

  /// No description provided for @preferencesAccommodationSection.
  ///
  /// In en, this message translates to:
  /// **'Accommodation'**
  String get preferencesAccommodationSection;

  /// No description provided for @preferencesAccommodationHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get preferencesAccommodationHotel;

  /// No description provided for @preferencesAccommodationHostel.
  ///
  /// In en, this message translates to:
  /// **'Hostel'**
  String get preferencesAccommodationHostel;

  /// No description provided for @preferencesAccommodationAirbnb.
  ///
  /// In en, this message translates to:
  /// **'Airbnb'**
  String get preferencesAccommodationAirbnb;

  /// No description provided for @preferencesAccommodationBoutique.
  ///
  /// In en, this message translates to:
  /// **'Boutique'**
  String get preferencesAccommodationBoutique;

  /// No description provided for @preferencesAccommodationCamping.
  ///
  /// In en, this message translates to:
  /// **'Camping'**
  String get preferencesAccommodationCamping;

  /// No description provided for @preferencesTransportSection.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get preferencesTransportSection;

  /// No description provided for @preferencesTransportCar.
  ///
  /// In en, this message translates to:
  /// **'Car rental'**
  String get preferencesTransportCar;

  /// No description provided for @preferencesTransportPublic.
  ///
  /// In en, this message translates to:
  /// **'Public transit'**
  String get preferencesTransportPublic;

  /// No description provided for @preferencesTransportWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get preferencesTransportWalking;

  /// No description provided for @preferencesPaceSection.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get preferencesPaceSection;

  /// No description provided for @preferencesPaceChill.
  ///
  /// In en, this message translates to:
  /// **'Chill'**
  String get preferencesPaceChill;

  /// No description provided for @preferencesPaceModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get preferencesPaceModerate;

  /// No description provided for @preferencesPacePacked.
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get preferencesPacePacked;

  /// No description provided for @preferencesFoodSection.
  ///
  /// In en, this message translates to:
  /// **'Dietary'**
  String get preferencesFoodSection;

  /// No description provided for @preferencesFoodVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get preferencesFoodVegetarian;

  /// No description provided for @preferencesFoodVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get preferencesFoodVegan;

  /// No description provided for @preferencesFoodHalal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get preferencesFoodHalal;

  /// No description provided for @preferencesFoodGluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten-free'**
  String get preferencesFoodGluten;

  /// No description provided for @preferencesFoodNone.
  ///
  /// In en, this message translates to:
  /// **'No restrictions'**
  String get preferencesFoodNone;

  /// No description provided for @preferencesInterestsSection.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get preferencesInterestsSection;

  /// No description provided for @preferencesInterestsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get preferencesInterestsHistory;

  /// No description provided for @preferencesInterestsNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get preferencesInterestsNature;

  /// No description provided for @preferencesInterestsHiking.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get preferencesInterestsHiking;

  /// No description provided for @preferencesInterestsBeaches.
  ///
  /// In en, this message translates to:
  /// **'Beaches'**
  String get preferencesInterestsBeaches;

  /// No description provided for @preferencesInterestsFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get preferencesInterestsFood;

  /// No description provided for @preferencesInterestsNightlife.
  ///
  /// In en, this message translates to:
  /// **'Nightlife'**
  String get preferencesInterestsNightlife;

  /// No description provided for @preferencesInterestsArchitecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get preferencesInterestsArchitecture;

  /// No description provided for @preferencesInterestsReligion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get preferencesInterestsReligion;

  /// No description provided for @preferencesInterestsPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get preferencesInterestsPhotography;

  /// No description provided for @photoGalleryLabelNoPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get photoGalleryLabelNoPhotos;

  /// No description provided for @artifactCarouselLabelNoArtifacts.
  ///
  /// In en, this message translates to:
  /// **'No artifacts to show'**
  String get artifactCarouselLabelNoArtifacts;

  /// No description provided for @buddySaveItinerary.
  ///
  /// In en, this message translates to:
  /// **'Save itinerary'**
  String get buddySaveItinerary;

  /// No description provided for @buddyItinerarySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved ✓ — View in My Trips'**
  String get buddyItinerarySaved;

  /// No description provided for @buddyItinerarySaveRetry.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save — tap to retry'**
  String get buddyItinerarySaveRetry;

  /// No description provided for @buddyItineraryPickStartDateHelp.
  ///
  /// In en, this message translates to:
  /// **'When does this trip start?'**
  String get buddyItineraryPickStartDateHelp;

  /// No description provided for @buddySaveLimitHelper.
  ///
  /// In en, this message translates to:
  /// **'Limit reached — delete a trip to save a new one'**
  String get buddySaveLimitHelper;

  /// No description provided for @myTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTripsTitle;

  /// No description provided for @myTripsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved trips yet'**
  String get myTripsEmptyTitle;

  /// No description provided for @myTripsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan one with Buddy and tap Save itinerary.'**
  String get myTripsEmptySubtitle;

  /// No description provided for @myTripsDatesNotSet.
  ///
  /// In en, this message translates to:
  /// **'Dates not set'**
  String get myTripsDatesNotSet;

  /// No description provided for @myTripsDaysOne.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get myTripsDaysOne;

  /// No description provided for @myTripsDaysOther.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String myTripsDaysOther(int count);

  /// No description provided for @myTripsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete trip?'**
  String get myTripsDeleteTitle;

  /// No description provided for @myTripsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get myTripsDeleteBody;

  /// No description provided for @myTripsDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get myTripsDeleteCancel;

  /// No description provided for @myTripsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get myTripsDeleteConfirm;

  /// No description provided for @myTripsClearAllAction.
  ///
  /// In en, this message translates to:
  /// **'Clear all trips'**
  String get myTripsClearAllAction;

  /// No description provided for @myTripsClearAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all trips?'**
  String get myTripsClearAllTitle;

  /// No description provided for @myTripsClearAllBody.
  ///
  /// In en, this message translates to:
  /// **'Every saved trip will be permanently deleted. This can\'t be undone.'**
  String get myTripsClearAllBody;

  /// No description provided for @myTripsClearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get myTripsClearAllConfirm;

  /// No description provided for @myTripsCounter.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max}'**
  String myTripsCounter(int count, int max);

  /// No description provided for @tripDetailDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {dayNumber}'**
  String tripDetailDayLabel(int dayNumber);

  /// No description provided for @tripDetailAddStop.
  ///
  /// In en, this message translates to:
  /// **'Add stop'**
  String get tripDetailAddStop;

  /// No description provided for @tripDetailAddDay.
  ///
  /// In en, this message translates to:
  /// **'Add day'**
  String get tripDetailAddDay;

  /// No description provided for @tripDetailDialogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tripDetailDialogSave;

  /// No description provided for @tripDetailDialogClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get tripDetailDialogClear;

  /// No description provided for @tripDetailStartDateNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get tripDetailStartDateNotSet;

  /// No description provided for @tripDetailRailMarkVisited.
  ///
  /// In en, this message translates to:
  /// **'Mark as visited'**
  String get tripDetailRailMarkVisited;

  /// No description provided for @tripDetailRailResetUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Reset to upcoming'**
  String get tripDetailRailResetUpcoming;

  /// No description provided for @tripDetailVisitedAt.
  ///
  /// In en, this message translates to:
  /// **'Visited {time}'**
  String tripDetailVisitedAt(String time);

  /// No description provided for @tripDetailDayProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} visited'**
  String tripDetailDayProgress(int done, int total);

  /// No description provided for @tripDetailAutoTrackPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-check stops as you visit?'**
  String get tripDetailAutoTrackPromptTitle;

  /// No description provided for @tripDetailAutoTrackPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Travel Buddy can check off stops automatically when you\'re nearby during their scheduled time. Location stays on your device.'**
  String get tripDetailAutoTrackPromptBody;

  /// No description provided for @tripDetailAutoTrackEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get tripDetailAutoTrackEnable;

  /// No description provided for @tripDetailAutoTrackDecline.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get tripDetailAutoTrackDecline;

  /// No description provided for @tripDetailAutoTrackEnableMenu.
  ///
  /// In en, this message translates to:
  /// **'Enable visit auto-tracking'**
  String get tripDetailAutoTrackEnableMenu;

  /// No description provided for @tripDetailAutoTrackDisableMenu.
  ///
  /// In en, this message translates to:
  /// **'Disable visit auto-tracking'**
  String get tripDetailAutoTrackDisableMenu;

  /// Title of the sheet shown when the user taps Enable visit auto-tracking but location permission is currently denied.
  ///
  /// In en, this message translates to:
  /// **'Auto-tracking needs location access'**
  String get tripDetailAutoTrackErrorPermissionTitle;

  /// Body of the auto-track error sheet when the user denied location once (re-prompt may still work).
  ///
  /// In en, this message translates to:
  /// **'Auto-tracking checks off stops when you\'re near them. Allow location access while using the app to turn it on.'**
  String get tripDetailAutoTrackErrorPermissionBody;

  /// Body of the auto-track error sheet when location permission is permanently denied — only Settings can re-enable it.
  ///
  /// In en, this message translates to:
  /// **'Location access is currently blocked. Open Settings to allow it for Travel Buddy.'**
  String get tripDetailAutoTrackErrorBlockedBody;

  /// Title of the auto-track error sheet when device-wide Location Services are off.
  ///
  /// In en, this message translates to:
  /// **'Turn on Location Services'**
  String get tripDetailAutoTrackErrorServiceTitle;

  /// Body of the auto-track error sheet when device-wide Location Services are off.
  ///
  /// In en, this message translates to:
  /// **'Location Services are off for this device. Auto-tracking can\'t run until they\'re back on.'**
  String get tripDetailAutoTrackErrorServiceBody;

  /// Primary CTA on the auto-track error sheet that opens the OS Settings (app or location).
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get tripDetailAutoTrackErrorOpenSettings;

  /// Primary CTA on the auto-track error sheet that re-requests location permission when denial was non-permanent.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tripDetailAutoTrackErrorRetry;

  /// No description provided for @tripDetailAddDayDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add day'**
  String get tripDetailAddDayDialogTitle;

  /// No description provided for @tripDetailAddDayNumberField.
  ///
  /// In en, this message translates to:
  /// **'Day number'**
  String get tripDetailAddDayNumberField;

  /// No description provided for @tripDetailAddDayTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get tripDetailAddDayTitleField;

  /// No description provided for @tripDetailAddDayBaseCityField.
  ///
  /// In en, this message translates to:
  /// **'Base city (optional)'**
  String get tripDetailAddDayBaseCityField;

  /// Italic placeholder shown on the trip detail summary section when the trip has no summary yet; tapping opens the summary editor.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a summary'**
  String get tripDetailSummaryPlaceholder;

  /// Hint shown inside an empty day's placeholder, telling the user to use the Add stop button below.
  ///
  /// In en, this message translates to:
  /// **'No stops yet — tap + to add one'**
  String get tripDetailEmptyDayHint;

  /// Trip detail kebab item that opens the summary editor.
  ///
  /// In en, this message translates to:
  /// **'Edit summary'**
  String get tripDetailKebabEditSummary;

  /// Trip detail kebab item that opens the start-date picker.
  ///
  /// In en, this message translates to:
  /// **'Change start date'**
  String get tripDetailKebabChangeStartDate;

  /// Trip detail kebab item that clears the start date (only present when a start date is set).
  ///
  /// In en, this message translates to:
  /// **'Clear start date'**
  String get tripDetailKebabClearStartDate;

  /// Day-header overflow menu: opens a text dialog to rename the day.
  ///
  /// In en, this message translates to:
  /// **'Rename day'**
  String get tripDetailDayActionRename;

  /// Day-header overflow menu: opens the add-stop sheet for that day.
  ///
  /// In en, this message translates to:
  /// **'Add stop here'**
  String get tripDetailDayActionAddStop;

  /// Day-header overflow menu: opens the destructive confirm sheet to delete the day.
  ///
  /// In en, this message translates to:
  /// **'Delete day'**
  String get tripDetailDayActionDelete;

  /// Title of the inline dialog that renames a day.
  ///
  /// In en, this message translates to:
  /// **'Rename day'**
  String get tripDetailRenameDayDialogTitle;

  /// Stop long-press action that creates a copy of the stop right after it.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get tripDetailStopActionDuplicate;

  /// Inline undo banner that occupies the deleted stop's slot for ~5s after a delete. Pairs with the tripDetailUndoStopButton action.
  ///
  /// In en, this message translates to:
  /// **'Stop deleted: {stopName}'**
  String tripDetailUndoStopBanner(String stopName);

  /// Action text on the inline undo banner. Capitalized for emphasis — it's the only path to recover a misclicked delete inside the 5s window.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get tripDetailUndoStopButton;

  /// Long-press action sheet on a stop card in edit mode — opens the stop editor.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tripDetailStopActionEdit;

  /// Long-press action that opens a day picker to move the stop to another day.
  ///
  /// In en, this message translates to:
  /// **'Move to day…'**
  String get tripDetailStopActionMove;

  /// Long-press action that deletes the stop after confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tripDetailStopActionDelete;

  /// Label of the fallback button shown above the timeline when a saved trip has no static-map thumbnail. Tapping it opens the full-screen interactive map.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get tripDetailViewOnMapButton;

  /// Header of the bottom sheet listing other days as move targets.
  ///
  /// In en, this message translates to:
  /// **'Move to day'**
  String get tripDetailMoveStopSheetTitle;

  /// Subtitle for the move-to-day picker showing the stop being moved.
  ///
  /// In en, this message translates to:
  /// **'Where should \"{stopName}\" go?'**
  String tripDetailMoveStopSheetSubtitle(String stopName);

  /// One day row in the move-to-day picker. `label` is day.title, day.baseCity, or a fallback.
  ///
  /// In en, this message translates to:
  /// **'Day {dayNumber} · {label}'**
  String tripDetailMoveStopOption(int dayNumber, String label);

  /// Suffix shown when a day has 0 stops, in the move-to-day picker.
  ///
  /// In en, this message translates to:
  /// **'no stops yet'**
  String get tripDetailMoveStopOptionEmpty;

  /// Stop-count suffix in the move-to-day picker, e.g. '3 stops'.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stop} other{{count} stops}}'**
  String tripDetailMoveStopOptionCount(int count);

  /// Error banner shown when PATCH /trips/{id}/stops/{sid}/move fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t move stop — try again.'**
  String get tripDetailMoveStopFailed;

  /// No description provided for @tripsErrorSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to save changes.'**
  String get tripsErrorSignIn;

  /// No description provided for @tripsErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This trip no longer exists.'**
  String get tripsErrorNotFound;

  /// No description provided for @tripsErrorConflict.
  ///
  /// In en, this message translates to:
  /// **'Trip changed elsewhere — refreshing.'**
  String get tripsErrorConflict;

  /// No description provided for @tripsErrorTripLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can only save up to 3 trips. Delete one to save this trip.'**
  String get tripsErrorTripLimitReached;

  /// No description provided for @tripsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your change.'**
  String get tripsErrorGeneric;

  /// No description provided for @conversationsUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled chat'**
  String get conversationsUntitled;

  /// No description provided for @profileDeleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccountButton;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes your trips, conversations, uploaded photos, and preferences. This can\'t be undone.'**
  String get profileDeleteAccountBody;

  /// No description provided for @profileDeleteAccountInstruction.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm:'**
  String get profileDeleteAccountInstruction;

  /// No description provided for @profileDeleteAccountConfirmWord.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get profileDeleteAccountConfirmWord;

  /// No description provided for @profileDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get profileDeleteAccountConfirm;

  /// No description provided for @profileDeleteAccountCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileDeleteAccountCancel;

  /// No description provided for @profileDeleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your account. Please try again.'**
  String get profileDeleteAccountFailed;

  /// Button on a buddy place card that opens the place in the maps app.
  ///
  /// In en, this message translates to:
  /// **'Open in maps'**
  String get placeCardOpenInMaps;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sq'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sq':
      return AppLocalizationsSq();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
