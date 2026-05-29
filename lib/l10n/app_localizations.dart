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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Travel Buddy'**
  String get appName;

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

  /// No description provided for @bottomScrubberSemanticScrubber.
  ///
  /// In en, this message translates to:
  /// **'scrubber'**
  String get bottomScrubberSemanticScrubber;

  /// No description provided for @bottomScrubberSemanticTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline Scrubber, drag horizontally to navigate the timeline.'**
  String get bottomScrubberSemanticTimeline;

  /// No description provided for @rangeSelector.
  ///
  /// In en, this message translates to:
  /// **'Range selector, drag horizontally to adjust the range.'**
  String get rangeSelector;

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

  /// No description provided for @eventsListButtonOpenGlobal.
  ///
  /// In en, this message translates to:
  /// **'Open global timeline'**
  String get eventsListButtonOpenGlobal;

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

  /// No description provided for @resultsPopupEnglishContent.
  ///
  /// In en, this message translates to:
  /// **'This content is provided by the Metropolitan Museum of Art Collection API, and is only available in English.'**
  String get resultsPopupEnglishContent;

  /// No description provided for @resultsSemanticDismiss.
  ///
  /// In en, this message translates to:
  /// **'dismiss message'**
  String get resultsSemanticDismiss;

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

  /// No description provided for @searchInputTitleSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get searchInputTitleSuggestions;

  /// No description provided for @searchInputHintSearch.
  ///
  /// In en, this message translates to:
  /// **'Search (ex. type or material)'**
  String get searchInputHintSearch;

  /// No description provided for @searchInputSemanticClear.
  ///
  /// In en, this message translates to:
  /// **'clear search'**
  String get searchInputSemanticClear;

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

  /// No description provided for @artifactsSemanticsPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous artifact'**
  String get artifactsSemanticsPrevious;

  /// No description provided for @artifactsSemanticsNext.
  ///
  /// In en, this message translates to:
  /// **'Next artifact'**
  String get artifactsSemanticsNext;

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

  /// No description provided for @circleButtonsSemanticClose.
  ///
  /// In en, this message translates to:
  /// **'close'**
  String get circleButtonsSemanticClose;

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

  /// No description provided for @eightWaySemanticSwipeDetector.
  ///
  /// In en, this message translates to:
  /// **'eight-way swipe detector'**
  String get eightWaySemanticSwipeDetector;

  /// No description provided for @expandingTimeSelectorSemanticSelector.
  ///
  /// In en, this message translates to:
  /// **'time range selector'**
  String get expandingTimeSelectorSemanticSelector;

  /// No description provided for @fullscreenImageViewerSemanticFull.
  ///
  /// In en, this message translates to:
  /// **'full screen image, no description available'**
  String get fullscreenImageViewerSemanticFull;

  /// No description provided for @homeMenuButtonExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore the timeline'**
  String get homeMenuButtonExplore;

  /// No description provided for @homeMenuButtonView.
  ///
  /// In en, this message translates to:
  /// **'View your collection'**
  String get homeMenuButtonView;

  /// No description provided for @homeMenuButtonAbout.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get homeMenuButtonAbout;

  /// No description provided for @homeMenuViewingLabel.
  ///
  /// In en, this message translates to:
  /// **'Viewing'**
  String get homeMenuViewingLabel;

  /// No description provided for @homeMenuJumpToDestination.
  ///
  /// In en, this message translates to:
  /// **'Jump to a destination'**
  String get homeMenuJumpToDestination;

  /// No description provided for @homeMenuConversations.
  ///
  /// In en, this message translates to:
  /// **'My conversations'**
  String get homeMenuConversations;

  /// No description provided for @homeMenuPreferences.
  ///
  /// In en, this message translates to:
  /// **'Travel preferences'**
  String get homeMenuPreferences;

  /// No description provided for @homeMenuPlanTrip.
  ///
  /// In en, this message translates to:
  /// **'Plan a trip'**
  String get homeMenuPlanTrip;

  /// No description provided for @homeMenuAskBuddy.
  ///
  /// In en, this message translates to:
  /// **'Ask Buddy'**
  String get homeMenuAskBuddy;

  /// Chat message sent verbatim to Buddy when the user taps Plan a trip.
  ///
  /// In en, this message translates to:
  /// **'Plan a trip to {destination}, Albania.'**
  String homeMenuPlanTripPrompt(String destination);

  /// Chat message sent verbatim to Buddy when the user taps Ask Buddy.
  ///
  /// In en, this message translates to:
  /// **'Tell me about {destination}, Albania — what\'s special and what should I see?'**
  String homeMenuAskBuddyPrompt(String destination);

  /// No description provided for @homeMenuAboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Travel Buddy is your AI-powered guide to the eight destinations of Albania. '**
  String get homeMenuAboutTagline;

  /// No description provided for @homeMenuAboutBuilt.
  ///
  /// In en, this message translates to:
  /// **'Built with {flutterUrl}.'**
  String homeMenuAboutBuilt(Object flutterUrl);

  /// No description provided for @homeMenuAboutLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn more at {appUrl}.'**
  String homeMenuAboutLearn(Object appUrl);

  /// No description provided for @homeMenuAboutSource.
  ///
  /// In en, this message translates to:
  /// **'To see the source code for this app, please visit the {githubUrl}.'**
  String homeMenuAboutSource(Object githubUrl);

  /// No description provided for @homeMenuAboutRepo.
  ///
  /// In en, this message translates to:
  /// **'Travel Buddy github repo'**
  String get homeMenuAboutRepo;

  /// No description provided for @homeMenuAboutFlutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get homeMenuAboutFlutter;

  /// No description provided for @homeMenuAboutApp.
  ///
  /// In en, this message translates to:
  /// **'travelbuddy.app'**
  String get homeMenuAboutApp;

  /// No description provided for @homeMenuAboutPublic.
  ///
  /// In en, this message translates to:
  /// **'Public-domain artworks from {metUrl}.'**
  String homeMenuAboutPublic(Object metUrl);

  /// No description provided for @homeMenuAboutMet.
  ///
  /// In en, this message translates to:
  /// **'The Metropolitan Museum of Art, New York'**
  String get homeMenuAboutMet;

  /// No description provided for @homeMenuAboutPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography from {unsplashUrl}.'**
  String homeMenuAboutPhotography(Object unsplashUrl);

  /// No description provided for @homeMenuAboutUnsplash.
  ///
  /// In en, this message translates to:
  /// **'Unsplash'**
  String get homeMenuAboutUnsplash;

  /// No description provided for @introTitleJourney.
  ///
  /// In en, this message translates to:
  /// **'Journey to the past'**
  String get introTitleJourney;

  /// No description provided for @introDescriptionNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate the intersection of time, art, and culture.'**
  String get introDescriptionNavigate;

  /// No description provided for @introTitleExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore places'**
  String get introTitleExplore;

  /// No description provided for @introDescriptionUncover.
  ///
  /// In en, this message translates to:
  /// **'Uncover remarkable human-made structures from around the world.'**
  String get introDescriptionUncover;

  /// No description provided for @introTitleDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover artifacts'**
  String get introTitleDiscover;

  /// No description provided for @introDescriptionLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn about cultures throughout time by examining things they left behind.'**
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

  /// No description provided for @labelledToggleSemanticToggle.
  ///
  /// In en, this message translates to:
  /// **'toggle'**
  String get labelledToggleSemanticToggle;

  /// No description provided for @photoGallerySemanticCollectible.
  ///
  /// In en, this message translates to:
  /// **'collectible!'**
  String get photoGallerySemanticCollectible;

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

  /// No description provided for @eraClassical.
  ///
  /// In en, this message translates to:
  /// **'Classical Era'**
  String get eraClassical;

  /// No description provided for @eraEarlyModern.
  ///
  /// In en, this message translates to:
  /// **'Early Modern Era'**
  String get eraEarlyModern;

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

  /// No description provided for @timelineLabelConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction of {title} begins.'**
  String timelineLabelConstruction(Object title);

  /// No description provided for @timelineTitleGlobalTimeline.
  ///
  /// In en, this message translates to:
  /// **'Global Timeline'**
  String get timelineTitleGlobalTimeline;

  /// No description provided for @wallpaperModalSave.
  ///
  /// In en, this message translates to:
  /// **'Save this poster to your photo gallery?'**
  String get wallpaperModalSave;

  /// No description provided for @wallpaperModalSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving Image. Please wait...'**
  String get wallpaperModalSaving;

  /// No description provided for @wallpaperModalSaveComplete.
  ///
  /// In en, this message translates to:
  /// **'Save complete!'**
  String get wallpaperModalSaveComplete;

  /// No description provided for @wallpaperSemanticSharePhoto.
  ///
  /// In en, this message translates to:
  /// **'share photo'**
  String get wallpaperSemanticSharePhoto;

  /// No description provided for @wallpaperSemanticTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'take photo'**
  String get wallpaperSemanticTakePhoto;

  /// No description provided for @wallpaperCheckboxShowTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Title'**
  String get wallpaperCheckboxShowTitle;

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

  /// No description provided for @homeSemanticOpenMain.
  ///
  /// In en, this message translates to:
  /// **'Open main menu'**
  String get homeSemanticOpenMain;

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

  /// No description provided for @butrintSubTitle.
  ///
  /// In en, this message translates to:
  /// **'The Ancient Crossroads'**
  String get butrintSubTitle;

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

  /// No description provided for @butrintArtifactGeolocation.
  ///
  /// In en, this message translates to:
  /// **'Southern Albania'**
  String get butrintArtifactGeolocation;

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
  /// **'“Butrint - Albania\'s UNESCO World Heritage Site.” Youtube.'**
  String get butrintVideoCaption;

  /// No description provided for @butrintMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Map showing location of Butrint National Park in southern Albania.'**
  String get butrintMapCaption;

  /// No description provided for @butrintHistoryInfo1.
  ///
  /// In en, this message translates to:
  /// **'Butrint is an archaeological site in southern Albania, opposite the Greek island of Corfu. First settled by Greek colonists from Corfu in the 8th century BCE, it grew into an important city of the ancient world. According to legend, the city was founded by Trojan refugees led by Aeneas.\nThe Romans conquered Butrint in 167 BCE, and Julius Caesar later designated it a colony for veterans. Under Roman rule, the city flourished with the construction of an aqueduct, public baths, and a forum.'**
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

  /// No description provided for @butrint600ce.
  ///
  /// In en, this message translates to:
  /// **'Greek colonists from Corfu establish a settlement at Butrint, which grows into a significant trading post'**
  String get butrint600ce;

  /// No description provided for @butrint832ce.
  ///
  /// In en, this message translates to:
  /// **'Butrint serves as a major Byzantine ecclesiastical center with construction of the Great Basilica'**
  String get butrint832ce;

  /// No description provided for @butrint998ce.
  ///
  /// In en, this message translates to:
  /// **'The city comes under various regional powers as the Byzantine Empire\'s control weakens'**
  String get butrint998ce;

  /// No description provided for @butrint1100ce.
  ///
  /// In en, this message translates to:
  /// **'Normans and Angevins contest control of Butrint as part of broader Mediterranean conflicts'**
  String get butrint1100ce;

  /// No description provided for @butrint1527ce.
  ///
  /// In en, this message translates to:
  /// **'The Venetian Republic fortifies Butrint, constructing a castle and tower to defend against Ottoman expansion'**
  String get butrint1527ce;

  /// No description provided for @butrint1535ce.
  ///
  /// In en, this message translates to:
  /// **'Ottoman forces gain control of the wider region, and Butrint gradually declines as a settlement'**
  String get butrint1535ce;

  /// No description provided for @butrintCollectible1Title.
  ///
  /// In en, this message translates to:
  /// **'Pendant'**
  String get butrintCollectible1Title;

  /// No description provided for @butrintCollectible1Icon.
  ///
  /// In en, this message translates to:
  /// **'jewelry'**
  String get butrintCollectible1Icon;

  /// No description provided for @butrintCollectible2Title.
  ///
  /// In en, this message translates to:
  /// **'Bird Ornament'**
  String get butrintCollectible2Title;

  /// No description provided for @butrintCollectible2Icon.
  ///
  /// In en, this message translates to:
  /// **'jewelry'**
  String get butrintCollectible2Icon;

  /// No description provided for @butrintCollectible3Title.
  ///
  /// In en, this message translates to:
  /// **'Vue de Buthrotum'**
  String get butrintCollectible3Title;

  /// No description provided for @butrintCollectible3Icon.
  ///
  /// In en, this message translates to:
  /// **'picture'**
  String get butrintCollectible3Icon;

  /// No description provided for @beratTitle.
  ///
  /// In en, this message translates to:
  /// **'Berat'**
  String get beratTitle;

  /// No description provided for @beratSubTitle.
  ///
  /// In en, this message translates to:
  /// **'City of a Thousand Windows'**
  String get beratSubTitle;

  /// No description provided for @beratRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Berat, Albania'**
  String get beratRegionTitle;

  /// No description provided for @beratArtifactGeolocation.
  ///
  /// In en, this message translates to:
  /// **'Central Albania'**
  String get beratArtifactGeolocation;

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
  /// **'“Berat - City of a Thousand Windows, Albania.” Youtube.'**
  String get beratVideoCaption;

  /// No description provided for @beratMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Map showing location of Berat in central Albania.'**
  String get beratMapCaption;

  /// No description provided for @beratHistoryInfo1.
  ///
  /// In en, this message translates to:
  /// **'Berat is one of the oldest continuously inhabited cities in Albania, located along the banks of the Osum River. The castle on the hilltop has been inhabited since the 4th century BCE, when it was an important Illyrian settlement known as Antipatrea, founded by the Illyrian king Antipater.\nUnder Roman rule, the city served as a strategic military outpost along the Via Egnatia trade route.'**
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

  /// No description provided for @berat1850ce.
  ///
  /// In en, this message translates to:
  /// **'Berat experiences a cultural renaissance under the Ottoman Tanzimat reforms, with new schools and civic buildings constructed'**
  String get berat1850ce;

  /// No description provided for @berat1921ce.
  ///
  /// In en, this message translates to:
  /// **'Following Albanian independence, Berat becomes an important administrative center of the new Albanian state'**
  String get berat1921ce;

  /// No description provided for @berat1922ce.
  ///
  /// In en, this message translates to:
  /// **'The first modern schools in Albanian language are established in Berat, advancing the national education movement'**
  String get berat1922ce;

  /// No description provided for @berat1926ce.
  ///
  /// In en, this message translates to:
  /// **'Archaeological surveys begin documenting the historic architecture of Berat\'s castle and Ottoman quarters'**
  String get berat1926ce;

  /// No description provided for @berat1931ce.
  ///
  /// In en, this message translates to:
  /// **'Restoration work begins on the castle walls and Byzantine churches within the Kalaja quarter'**
  String get berat1931ce;

  /// No description provided for @berat2006ce.
  ///
  /// In en, this message translates to:
  /// **'Berat\'s historic center receives preliminary recognition leading to its UNESCO World Heritage inscription in 2008'**
  String get berat2006ce;

  /// No description provided for @beratCollectible1Title.
  ///
  /// In en, this message translates to:
  /// **'Engraved Horn'**
  String get beratCollectible1Title;

  /// No description provided for @beratCollectible1Icon.
  ///
  /// In en, this message translates to:
  /// **'statue'**
  String get beratCollectible1Icon;

  /// No description provided for @beratCollectible2Title.
  ///
  /// In en, this message translates to:
  /// **'Fixed fan'**
  String get beratCollectible2Title;

  /// No description provided for @beratCollectible2Icon.
  ///
  /// In en, this message translates to:
  /// **'jewelry'**
  String get beratCollectible2Icon;

  /// No description provided for @beratCollectible3Title.
  ///
  /// In en, this message translates to:
  /// **'Handkerchiefs (one of two)'**
  String get beratCollectible3Title;

  /// No description provided for @beratCollectible3Icon.
  ///
  /// In en, this message translates to:
  /// **'textile'**
  String get beratCollectible3Icon;

  /// No description provided for @gjirokasterTitle.
  ///
  /// In en, this message translates to:
  /// **'Gjirokastër'**
  String get gjirokasterTitle;

  /// No description provided for @gjirokasterSubTitle.
  ///
  /// In en, this message translates to:
  /// **'The Stone City'**
  String get gjirokasterSubTitle;

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

  /// No description provided for @gjirokasterArtifactGeolocation.
  ///
  /// In en, this message translates to:
  /// **'Southern Albania'**
  String get gjirokasterArtifactGeolocation;

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
  /// **'“Gjirokastër - Albania\'s Stone City, UNESCO World Heritage.” Youtube.'**
  String get gjirokasterVideoCaption;

  /// No description provided for @gjirokasterMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Map showing location of Gjirokastër in southern Albania.'**
  String get gjirokasterMapCaption;

  /// No description provided for @gjirokasterHistoryInfo1.
  ///
  /// In en, this message translates to:
  /// **'Gjirokastër is a city in southern Albania, situated in the Drino River valley. The area has been settled since at least the 1st century CE, and a fortress has stood on the hilltop since the 3rd century. The name Gjirokastër likely derives from the medieval Greek \"Argyrokastron\" meaning \"Silver Castle.\"\nThe city rose to prominence in the 13th century as a center of the Despotate of Epirus and later became an important stronghold contested between Byzantine, Serbian, and Ottoman forces.'**
  String get gjirokasterHistoryInfo1;

  /// No description provided for @gjirokasterHistoryInfo2.
  ///
  /// In en, this message translates to:
  /// **'Under Ottoman rule from 1417 onward, Gjirokastër became the center of a large sanjak (administrative district) and thrived as a bazaar city. Wealthy landowners built the distinctive fortified tower houses that define the city\'s character.\nThe city was inscribed as a UNESCO World Heritage Site in 2005 as \"a rare example of a well-preserved Ottoman town, built by farmers of large estates.\" It is the birthplace of both former Albanian dictator Enver Hoxha and Nobel Prize-winning author Ismail Kadare.'**
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

  /// No description provided for @gjirokaster70ce.
  ///
  /// In en, this message translates to:
  /// **'Early Roman-era settlement exists in the Drino Valley region, with fortifications on the hilltop that would later become Gjirokastër'**
  String get gjirokaster70ce;

  /// No description provided for @gjirokaster82ce.
  ///
  /// In en, this message translates to:
  /// **'The hilltop fortress is expanded as a strategic defensive position guarding the Drino Valley trade routes'**
  String get gjirokaster82ce;

  /// No description provided for @gjirokaster1140ce.
  ///
  /// In en, this message translates to:
  /// **'Argyrokastron emerges as a significant Byzantine settlement and is contested during the Norman invasions of the Balkans'**
  String get gjirokaster1140ce;

  /// No description provided for @gjirokaster1490ce.
  ///
  /// In en, this message translates to:
  /// **'Under Ottoman rule, Gjirokastër develops into a thriving bazaar town with construction of the Old Bazaar and early tower houses'**
  String get gjirokaster1490ce;

  /// No description provided for @gjirokaster1829ce.
  ///
  /// In en, this message translates to:
  /// **'Ali Pasha of Ioannina undertakes major expansion of the fortress, adding fortifications, an aqueduct, and a clock tower'**
  String get gjirokaster1829ce;

  /// No description provided for @gjirokaster1990ce.
  ///
  /// In en, this message translates to:
  /// **'Following the fall of communism, restoration efforts begin and Gjirokastër receives UNESCO World Heritage status in 2005'**
  String get gjirokaster1990ce;

  /// No description provided for @gjirokasterCollectible1Title.
  ///
  /// In en, this message translates to:
  /// **'Glass hexagonal amphoriskos'**
  String get gjirokasterCollectible1Title;

  /// No description provided for @gjirokasterCollectible1Icon.
  ///
  /// In en, this message translates to:
  /// **'vase'**
  String get gjirokasterCollectible1Icon;

  /// No description provided for @gjirokasterCollectible2Title.
  ///
  /// In en, this message translates to:
  /// **'Bronze plaque of Mithras slaying the bull'**
  String get gjirokasterCollectible2Title;

  /// No description provided for @gjirokasterCollectible2Icon.
  ///
  /// In en, this message translates to:
  /// **'statue'**
  String get gjirokasterCollectible2Icon;

  /// No description provided for @gjirokasterCollectible3Title.
  ///
  /// In en, this message translates to:
  /// **'Veduta di Argirocastro'**
  String get gjirokasterCollectible3Title;

  /// No description provided for @gjirokasterCollectible3Icon.
  ///
  /// In en, this message translates to:
  /// **'picture'**
  String get gjirokasterCollectible3Icon;

  /// No description provided for @apolloniaTitle.
  ///
  /// In en, this message translates to:
  /// **'Apollonia'**
  String get apolloniaTitle;

  /// No description provided for @apolloniaSubTitle.
  ///
  /// In en, this message translates to:
  /// **'The Ancient City of Learning'**
  String get apolloniaSubTitle;

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

  /// No description provided for @apolloniaArtifactGeolocation.
  ///
  /// In en, this message translates to:
  /// **'Central Albania'**
  String get apolloniaArtifactGeolocation;

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
  /// **'“Apollonia Archaeological Park - Ancient Albania.” Youtube.'**
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

  /// No description provided for @apollonia700bce.
  ///
  /// In en, this message translates to:
  /// **'Greek colonists from Corinth and Corcyra found Apollonia in 588 BCE on Illyrian territory, establishing a settlement that would grow into a major city'**
  String get apollonia700bce;

  /// No description provided for @apollonia214bce.
  ///
  /// In en, this message translates to:
  /// **'Apollonia becomes a key Roman ally during the Illyrian Wars and serves as a staging ground for Roman military campaigns in the eastern Mediterranean'**
  String get apollonia214bce;

  /// No description provided for @apollonia121bce.
  ///
  /// In en, this message translates to:
  /// **'The city flourishes as a center of trade along the Via Egnatia, connecting Rome to its eastern provinces'**
  String get apollonia121bce;

  /// No description provided for @apollonia556ce.
  ///
  /// In en, this message translates to:
  /// **'An earthquake alters the course of the Vjosa River, destroying Apollonia\'s harbor and beginning the city\'s irreversible decline'**
  String get apollonia556ce;

  /// No description provided for @apollonia618ce.
  ///
  /// In en, this message translates to:
  /// **'The remains of the city serve as a quarry for building materials; the Byzantine Monastery of St. Mary is constructed within the ancient walls'**
  String get apollonia618ce;

  /// No description provided for @apollonia1487ce.
  ///
  /// In en, this message translates to:
  /// **'The site lies largely forgotten and overgrown until systematic archaeological excavations begin under Austrian and later French archaeologists in the early 20th century'**
  String get apollonia1487ce;

  /// No description provided for @apolloniaCollectible1Title.
  ///
  /// In en, this message translates to:
  /// **'Biographies of Lian Po and Lin Xiangru'**
  String get apolloniaCollectible1Title;

  /// No description provided for @apolloniaCollectible1Icon.
  ///
  /// In en, this message translates to:
  /// **'scroll'**
  String get apolloniaCollectible1Icon;

  /// No description provided for @apolloniaCollectible2Title.
  ///
  /// In en, this message translates to:
  /// **'Jar with Dragon'**
  String get apolloniaCollectible2Title;

  /// No description provided for @apolloniaCollectible2Icon.
  ///
  /// In en, this message translates to:
  /// **'vase'**
  String get apolloniaCollectible2Icon;

  /// No description provided for @apolloniaCollectible3Title.
  ///
  /// In en, this message translates to:
  /// **'Panel with Peonies and Butterfly'**
  String get apolloniaCollectible3Title;

  /// No description provided for @apolloniaCollectible3Icon.
  ///
  /// In en, this message translates to:
  /// **'textile'**
  String get apolloniaCollectible3Icon;

  /// No description provided for @thethTitle.
  ///
  /// In en, this message translates to:
  /// **'Thethi'**
  String get thethTitle;

  /// No description provided for @thethSubTitle.
  ///
  /// In en, this message translates to:
  /// **'The Alpine Sanctuary'**
  String get thethSubTitle;

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

  /// No description provided for @thethArtifactGeolocation.
  ///
  /// In en, this message translates to:
  /// **'Northern Albania'**
  String get thethArtifactGeolocation;

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
  /// **'“Thethi National Park - Albania\'s Hidden Alpine Paradise.” Youtube.'**
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

  /// No description provided for @theth1438ce.
  ///
  /// In en, this message translates to:
  /// **'Albanian highland clans are well established in the Thethi valley, governed by the Kanun of Lëkë Dukagjini'**
  String get theth1438ce;

  /// No description provided for @theth1572ce.
  ///
  /// In en, this message translates to:
  /// **'The highland communities resist Ottoman control, maintaining autonomy through the rugged terrain of the Albanian Alps'**
  String get theth1572ce;

  /// No description provided for @theth1867ce.
  ///
  /// In en, this message translates to:
  /// **'British traveler and diplomat Edith Durham visits the Albanian highlands, later documenting the traditional way of life in her celebrated writings'**
  String get theth1867ce;

  /// No description provided for @theth1911ce.
  ///
  /// In en, this message translates to:
  /// **'Albania declares independence in 1912; the highland regions play a crucial role in the national awakening and resistance movements'**
  String get theth1911ce;

  /// No description provided for @theth1964ce.
  ///
  /// In en, this message translates to:
  /// **'Thethi National Park is established in 1966, one of Albania\'s first protected areas, preserving the alpine ecosystem'**
  String get theth1964ce;

  /// No description provided for @theth1997ce.
  ///
  /// In en, this message translates to:
  /// **'The Peaks of the Balkans trail is inaugurated, connecting Albania, Kosovo, and Montenegro and bringing renewed international attention to Thethi'**
  String get theth1997ce;

  /// No description provided for @thethCollectible1Title.
  ///
  /// In en, this message translates to:
  /// **'Eight-Pointed Star Tunic'**
  String get thethCollectible1Title;

  /// No description provided for @thethCollectible1Icon.
  ///
  /// In en, this message translates to:
  /// **'textile'**
  String get thethCollectible1Icon;

  /// No description provided for @thethCollectible2Title.
  ///
  /// In en, this message translates to:
  /// **'Camelid figurine'**
  String get thethCollectible2Title;

  /// No description provided for @thethCollectible2Icon.
  ///
  /// In en, this message translates to:
  /// **'statue'**
  String get thethCollectible2Icon;

  /// No description provided for @thethCollectible3Title.
  ///
  /// In en, this message translates to:
  /// **'Double Bowl'**
  String get thethCollectible3Title;

  /// No description provided for @thethCollectible3Icon.
  ///
  /// In en, this message translates to:
  /// **'vase'**
  String get thethCollectible3Icon;

  /// No description provided for @krujaTitle.
  ///
  /// In en, this message translates to:
  /// **'Krujë'**
  String get krujaTitle;

  /// No description provided for @krujaSubTitle.
  ///
  /// In en, this message translates to:
  /// **'The Fortress of Skanderbeg'**
  String get krujaSubTitle;

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

  /// No description provided for @krujaArtifactGeolocation.
  ///
  /// In en, this message translates to:
  /// **'Central Albania'**
  String get krujaArtifactGeolocation;

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
  /// **'“Krujë Castle and the Legacy of Skanderbeg - Albania.” Youtube.'**
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

  /// No description provided for @kruja1200bce.
  ///
  /// In en, this message translates to:
  /// **'Early Illyrian settlements exist in the Krujë region, taking advantage of the natural fortress position'**
  String get kruja1200bce;

  /// No description provided for @kruja106bce.
  ///
  /// In en, this message translates to:
  /// **'The region falls under Roman control as part of the province of Illyricum'**
  String get kruja106bce;

  /// No description provided for @kruja551ce.
  ///
  /// In en, this message translates to:
  /// **'Byzantine-era fortifications are constructed on the hilltop, establishing the castle as a strategic defensive position'**
  String get kruja551ce;

  /// No description provided for @kruja1812ce.
  ///
  /// In en, this message translates to:
  /// **'The castle ruins and old bazaar are documented by European travelers as interest in Albanian history grows'**
  String get kruja1812ce;

  /// No description provided for @kruja1958ce.
  ///
  /// In en, this message translates to:
  /// **'The Skanderbeg Museum within the castle is established, becoming Albania\'s most important national memorial'**
  String get kruja1958ce;

  /// No description provided for @kruja1989ce.
  ///
  /// In en, this message translates to:
  /// **'Krujë becomes a major tourist destination and symbol of Albanian national identity after the fall of communism'**
  String get kruja1989ce;

  /// No description provided for @krujaCollectible1Title.
  ///
  /// In en, this message translates to:
  /// **'Camel and riders'**
  String get krujaCollectible1Title;

  /// No description provided for @krujaCollectible1Icon.
  ///
  /// In en, this message translates to:
  /// **'statue'**
  String get krujaCollectible1Icon;

  /// No description provided for @krujaCollectible2Title.
  ///
  /// In en, this message translates to:
  /// **'Vessel'**
  String get krujaCollectible2Title;

  /// No description provided for @krujaCollectible2Icon.
  ///
  /// In en, this message translates to:
  /// **'vase'**
  String get krujaCollectible2Icon;

  /// No description provided for @krujaCollectible3Title.
  ///
  /// In en, this message translates to:
  /// **'Open bowl'**
  String get krujaCollectible3Title;

  /// No description provided for @krujaCollectible3Icon.
  ///
  /// In en, this message translates to:
  /// **'vase'**
  String get krujaCollectible3Icon;

  /// No description provided for @albanianAlpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Albanian Alps'**
  String get albanianAlpsTitle;

  /// No description provided for @albanianAlpsSubTitle.
  ///
  /// In en, this message translates to:
  /// **'The Accursed Mountains'**
  String get albanianAlpsSubTitle;

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

  /// No description provided for @albanianAlpsArtifactGeolocation.
  ///
  /// In en, this message translates to:
  /// **'Northern Albania'**
  String get albanianAlpsArtifactGeolocation;

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
  /// **'“Albanian Alps - Bjeshkët e Nemuna, Europe\'s Last Wilderness.” Youtube.'**
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
  /// **'Human structures in the Albanian Alps reflect the mountain environment. Traditional highland houses (kullë) are built from massive limestone blocks with timber interiors, designed to withstand heavy snowfall and provide defense. Stone-walled pastures, ancient mule trails, and small mountain churches dot the landscape.\nThe Peaks of the Balkans trail, a 120-mile (192 km) hiking route established in 2013, connects communities across three countries using many of these traditional paths.'**
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

  /// No description provided for @albanianAlps2575bce.
  ///
  /// In en, this message translates to:
  /// **'Early human habitation in the Albanian Alps region dates back to the Bronze Age, with evidence of pastoral communities in the highland valleys'**
  String get albanianAlps2575bce;

  /// No description provided for @albanianAlps2465bce.
  ///
  /// In en, this message translates to:
  /// **'Illyrian tribes establish seasonal settlements in the mountain pastures, developing the transhumance traditions that continue to this day'**
  String get albanianAlps2465bce;

  /// No description provided for @albanianAlps443bce.
  ///
  /// In en, this message translates to:
  /// **'Greek and Roman writers document the fierce independence of the mountain-dwelling Illyrian tribes and the difficult terrain of the region'**
  String get albanianAlps443bce;

  /// No description provided for @albanianAlps1925ce.
  ///
  /// In en, this message translates to:
  /// **'British traveler Edith Durham publishes detailed accounts of life in the Albanian highlands, bringing international attention to the region'**
  String get albanianAlps1925ce;

  /// No description provided for @albanianAlps1979ce.
  ///
  /// In en, this message translates to:
  /// **'Thethi National Park and Valbona Valley are designated as protected areas, preserving the alpine ecosystems'**
  String get albanianAlps1979ce;

  /// No description provided for @albanianAlps1990ce.
  ///
  /// In en, this message translates to:
  /// **'After the fall of communism, the Albanian Alps open to international hikers and the Peaks of the Balkans trail is eventually established in 2013'**
  String get albanianAlps1990ce;

  /// No description provided for @albanianAlpsCollectible1Title.
  ///
  /// In en, this message translates to:
  /// **'Two papyrus fragments'**
  String get albanianAlpsCollectible1Title;

  /// No description provided for @albanianAlpsCollectible1Icon.
  ///
  /// In en, this message translates to:
  /// **'scroll'**
  String get albanianAlpsCollectible1Icon;

  /// No description provided for @albanianAlpsCollectible2Title.
  ///
  /// In en, this message translates to:
  /// **'Fragmentary Face of King Khafre'**
  String get albanianAlpsCollectible2Title;

  /// No description provided for @albanianAlpsCollectible2Icon.
  ///
  /// In en, this message translates to:
  /// **'statue'**
  String get albanianAlpsCollectible2Icon;

  /// No description provided for @albanianAlpsCollectible3Title.
  ///
  /// In en, this message translates to:
  /// **'Jewelry Elements'**
  String get albanianAlpsCollectible3Title;

  /// No description provided for @albanianAlpsCollectible3Icon.
  ///
  /// In en, this message translates to:
  /// **'jewelry'**
  String get albanianAlpsCollectible3Icon;

  /// No description provided for @korcaTitle.
  ///
  /// In en, this message translates to:
  /// **'Korçë'**
  String get korcaTitle;

  /// No description provided for @korcaSubTitle.
  ///
  /// In en, this message translates to:
  /// **'The Cradle of Albanian Culture'**
  String get korcaSubTitle;

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

  /// No description provided for @korcaArtifactGeolocation.
  ///
  /// In en, this message translates to:
  /// **'Southeastern Albania'**
  String get korcaArtifactGeolocation;

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
  /// **'“Korçë - The Cradle of Albanian Culture and the Resurrection Cathedral.” Youtube.'**
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
  /// **'The original Orthodox Cathedral was destroyed during the communist period when Albania declared itself the world\'s first atheist state in 1967, demolishing nearly all religious buildings. The new Resurrection Cathedral (Katedralja Ngjallja e Krishtit) was built between 1992 and 2003 on the foundations of the old cathedral, symbolizing both religious revival and national cultural renewal.\nKorçë is also renowned for its contribution to Albanian music, art, and the famous annual Korçë Beer Festival, one of the largest in the Balkans.'**
  String get korcaHistoryInfo2;

  /// No description provided for @korcaConstructionInfo1.
  ///
  /// In en, this message translates to:
  /// **'The Resurrection Cathedral was designed in a neo-Byzantine style, drawing inspiration from traditional Orthodox church architecture while incorporating modern construction techniques. The cathedral features a cruciform plan with a large central dome reaching approximately 100 feet (30 m) in height, flanked by smaller domes.\nThe exterior is clad in light-colored stone with decorative arched windows, while the interior is adorned with frescoes and iconography painted by Albanian and Greek artists.'**
  String get korcaConstructionInfo1;

  /// No description provided for @korcaConstructionInfo2.
  ///
  /// In en, this message translates to:
  /// **'The cathedral\'s construction spanned over a decade, from 1992 to 2003. Modern reinforced concrete and steel frame construction was used for structural integrity, while traditional stone and decorative elements maintain the Byzantine aesthetic.\nThe bell tower, rising beside the cathedral, houses a set of bells that ring across the city. The surrounding plaza and park create a cultural center for the city, connecting to the National Museum of Medieval Art, which houses one of the finest collections of Byzantine icons in the world.'**
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

  /// No description provided for @korca1631ce.
  ///
  /// In en, this message translates to:
  /// **'Korçë develops as an Ottoman administrative and trade center with construction of mosques, bazaars, and hans (inns)'**
  String get korca1631ce;

  /// No description provided for @korca1647ce.
  ///
  /// In en, this message translates to:
  /// **'The city\'s importance grows as a crossroads of trade routes connecting Thessaloniki, Ioannina, and the Albanian coast'**
  String get korca1647ce;

  /// No description provided for @korca1658ce.
  ///
  /// In en, this message translates to:
  /// **'Cultural and religious communities flourish in Korçë, establishing it as a multi-ethnic center of learning'**
  String get korca1658ce;

  /// No description provided for @korca1901ce.
  ///
  /// In en, this message translates to:
  /// **'Korçë becomes a center of the Albanian national movement with the opening of the first Albanian-language school in 1887'**
  String get korca1901ce;

  /// No description provided for @korca1984ce.
  ///
  /// In en, this message translates to:
  /// **'During the communist era, the original Orthodox Cathedral and most religious buildings are demolished as Albania is declared an atheist state'**
  String get korca1984ce;

  /// No description provided for @korca1998ce.
  ///
  /// In en, this message translates to:
  /// **'Construction of the new Resurrection Cathedral begins after the fall of communism, completed in 2003 as a symbol of cultural renewal'**
  String get korca1998ce;

  /// No description provided for @korcaCollectible1Title.
  ///
  /// In en, this message translates to:
  /// **'Dagger with Scabbard'**
  String get korcaCollectible1Title;

  /// No description provided for @korcaCollectible1Icon.
  ///
  /// In en, this message translates to:
  /// **'jewelry'**
  String get korcaCollectible1Icon;

  /// No description provided for @korcaCollectible2Title.
  ///
  /// In en, this message translates to:
  /// **'The House of Bijapur'**
  String get korcaCollectible2Title;

  /// No description provided for @korcaCollectible2Icon.
  ///
  /// In en, this message translates to:
  /// **'picture'**
  String get korcaCollectible2Icon;

  /// No description provided for @korcaCollectible3Title.
  ///
  /// In en, this message translates to:
  /// **'Panel of Nasta\'liq Calligraphy'**
  String get korcaCollectible3Title;

  /// No description provided for @korcaCollectible3Icon.
  ///
  /// In en, this message translates to:
  /// **'scroll'**
  String get korcaCollectible3Icon;

  /// No description provided for @timelineEvent2900bce.
  ///
  /// In en, this message translates to:
  /// **'Bronze Age tumuli traditions emerge across the Western Balkans'**
  String get timelineEvent2900bce;

  /// No description provided for @timelineEvent2700bce.
  ///
  /// In en, this message translates to:
  /// **'The Maliq settlement near Korçë grows into one of the earliest agrarian communities of the southern Balkans'**
  String get timelineEvent2700bce;

  /// No description provided for @timelineEvent2600bce.
  ///
  /// In en, this message translates to:
  /// **'Early Bronze Age communities flourish along the Adriatic coast of present-day Albania'**
  String get timelineEvent2600bce;

  /// No description provided for @timelineEvent2560bce.
  ///
  /// In en, this message translates to:
  /// **'The Cetina cultural horizon links communities across the Western Balkans'**
  String get timelineEvent2560bce;

  /// No description provided for @timelineEvent1200bce.
  ///
  /// In en, this message translates to:
  /// **'Illyrian tribes — Taulantii, Ardiaei, Dardani, Enchelei, Chaones — consolidate across the western Balkans'**
  String get timelineEvent1200bce;

  /// No description provided for @timelineEvent627bce.
  ///
  /// In en, this message translates to:
  /// **'Greek settlers from Corinth and Corcyra found Epidamnos, the future Dyrrhachium and modern Durrës'**
  String get timelineEvent627bce;

  /// No description provided for @timelineEvent358bce.
  ///
  /// In en, this message translates to:
  /// **'Bardylis I of the Dardanian Kingdom defeats Macedonia under Perdiccas III'**
  String get timelineEvent358bce;

  /// No description provided for @timelineEvent229bce.
  ///
  /// In en, this message translates to:
  /// **'First Illyrian War: Queen Teuta of the Ardiaeans clashes with Rome over Adriatic piracy'**
  String get timelineEvent229bce;

  /// No description provided for @timelineEvent168bce.
  ///
  /// In en, this message translates to:
  /// **'Third Illyrian War ends; King Gentius is defeated and Illyria becomes a Roman protectorate'**
  String get timelineEvent168bce;

  /// No description provided for @timelineEvent146bce.
  ///
  /// In en, this message translates to:
  /// **'Rome begins constructing the Via Egnatia, linking Dyrrhachium across Illyria to Byzantium'**
  String get timelineEvent146bce;

  /// No description provided for @timelineEvent395ce.
  ///
  /// In en, this message translates to:
  /// **'The Roman Empire splits; Illyria is absorbed into the Eastern Byzantine realm'**
  String get timelineEvent395ce;

  /// No description provided for @timelineEvent500ce.
  ///
  /// In en, this message translates to:
  /// **'The Albanian coast flourishes as a key Byzantine corridor between Constantinople and the western Mediterranean'**
  String get timelineEvent500ce;

  /// No description provided for @timelineEvent632ce.
  ///
  /// In en, this message translates to:
  /// **'Death of Muhammad (61) and founding of Islam — the faith that will later reshape Albania under Ottoman rule'**
  String get timelineEvent632ce;

  /// No description provided for @timelineEvent1018ce.
  ///
  /// In en, this message translates to:
  /// **'Basil II reconquers Illyria; the Byzantine Theme of Dyrrhachium is re-established'**
  String get timelineEvent1018ce;

  /// No description provided for @timelineEvent1043ce.
  ///
  /// In en, this message translates to:
  /// **'First written reference to the name Albanoi — Albanians take part in the revolt of George Maniakes'**
  String get timelineEvent1043ce;

  /// No description provided for @timelineEvent1081ce.
  ///
  /// In en, this message translates to:
  /// **'Battle of Dyrrhachium: Norman forces under Robert Guiscard defeat the Byzantines'**
  String get timelineEvent1081ce;

  /// No description provided for @timelineEvent1190ce.
  ///
  /// In en, this message translates to:
  /// **'Progon founds the Principality of Arbanon — the first Albanian medieval state'**
  String get timelineEvent1190ce;

  /// No description provided for @timelineEvent1271ce.
  ///
  /// In en, this message translates to:
  /// **'Charles of Anjou proclaims the Kingdom of Albania (Regnum Albaniae)'**
  String get timelineEvent1271ce;

  /// No description provided for @timelineEvent1347ce.
  ///
  /// In en, this message translates to:
  /// **'The Black Death plague sweeps Europe and devastates Balkan populations, including Albania'**
  String get timelineEvent1347ce;

  /// No description provided for @timelineEvent1355ce.
  ///
  /// In en, this message translates to:
  /// **'After the death of Stefan Dušan, the Albanian principalities of Balsha, Topia, Muzaka and Kastrioti rise'**
  String get timelineEvent1355ce;

  /// No description provided for @timelineEvent1389ce.
  ///
  /// In en, this message translates to:
  /// **'Albanian nobles fight beside Serbian forces at the Battle of Kosovo'**
  String get timelineEvent1389ce;

  /// No description provided for @timelineEvent1428ce.
  ///
  /// In en, this message translates to:
  /// **'Gjergj Kastrioti, the future Skanderbeg, comes of age in the Ottoman court before returning to lead Albanian resistance'**
  String get timelineEvent1428ce;

  /// No description provided for @timelineEvent1443ce.
  ///
  /// In en, this message translates to:
  /// **'Skanderbeg defects from the Ottoman army at the Battle of Niš and seizes Krujë'**
  String get timelineEvent1443ce;

  /// No description provided for @timelineEvent1444ce.
  ///
  /// In en, this message translates to:
  /// **'The League of Lezhë unites Albanian princes under Skanderbeg\'s command'**
  String get timelineEvent1444ce;

  /// No description provided for @timelineEvent1450ce.
  ///
  /// In en, this message translates to:
  /// **'First Siege of Krujë: Skanderbeg withstands Sultan Murad II'**
  String get timelineEvent1450ce;

  /// No description provided for @timelineEvent1466ce.
  ///
  /// In en, this message translates to:
  /// **'Sultan Mehmed II launches the Second Siege of Krujë and builds the fortress of Elbasan'**
  String get timelineEvent1466ce;

  /// No description provided for @timelineEvent1468ce.
  ///
  /// In en, this message translates to:
  /// **'Death of Skanderbeg in Lezhë; Albanian resistance gradually crumbles'**
  String get timelineEvent1468ce;

  /// No description provided for @timelineEvent1479ce.
  ///
  /// In en, this message translates to:
  /// **'Fall of Shkodër — Ottoman conquest of Albania is complete'**
  String get timelineEvent1479ce;

  /// No description provided for @timelineEvent1571ce.
  ///
  /// In en, this message translates to:
  /// **'Battle of Lepanto — Albanian sailors fight on both sides of the Christian–Ottoman naval struggle'**
  String get timelineEvent1571ce;

  /// No description provided for @timelineEvent1788ce.
  ///
  /// In en, this message translates to:
  /// **'Ali Pasha of Tepelenë establishes the semi-autonomous Pashalik of Yanina'**
  String get timelineEvent1788ce;

  /// No description provided for @timelineEvent1789ce.
  ///
  /// In en, this message translates to:
  /// **'The French Revolution begins; its ideals later inspire the Albanian National Awakening (Rilindja)'**
  String get timelineEvent1789ce;

  /// No description provided for @timelineEvent1830ce.
  ///
  /// In en, this message translates to:
  /// **'The Massacre of the Beys at Manastir ends Albanian feudal autonomy under Ottoman reforms'**
  String get timelineEvent1830ce;

  /// No description provided for @timelineEvent1878ce.
  ///
  /// In en, this message translates to:
  /// **'The League of Prizren is founded — the first organised Albanian national movement'**
  String get timelineEvent1878ce;

  /// No description provided for @timelineEvent1908ce.
  ///
  /// In en, this message translates to:
  /// **'The Congress of Manastir standardises the Albanian Latin alphabet'**
  String get timelineEvent1908ce;

  /// No description provided for @timelineEvent1912ce.
  ///
  /// In en, this message translates to:
  /// **'Ismail Qemali proclaims Albanian independence in Vlorë on 28 November'**
  String get timelineEvent1912ce;

  /// No description provided for @timelineEvent1914ce.
  ///
  /// In en, this message translates to:
  /// **'World War I — Albania becomes a contested battleground for several European powers'**
  String get timelineEvent1914ce;

  /// No description provided for @timelineEvent1920ce.
  ///
  /// In en, this message translates to:
  /// **'The Congress of Lushnjë makes Tirana the capital of Albania'**
  String get timelineEvent1920ce;

  /// No description provided for @timelineEvent1928ce.
  ///
  /// In en, this message translates to:
  /// **'Ahmet Zogu is crowned King Zog I of the Albanians'**
  String get timelineEvent1928ce;

  /// No description provided for @timelineEvent1939ce.
  ///
  /// In en, this message translates to:
  /// **'World War II begins'**
  String get timelineEvent1939ce;

  /// No description provided for @timelineEvent1939ceAlbania.
  ///
  /// In en, this message translates to:
  /// **'Italy invades Albania, beginning the Axis occupation'**
  String get timelineEvent1939ceAlbania;

  /// No description provided for @timelineEvent1944ce.
  ///
  /// In en, this message translates to:
  /// **'Albania is liberated by partisan forces; Enver Hoxha\'s communist regime begins'**
  String get timelineEvent1944ce;

  /// No description provided for @timelineEvent1967ce.
  ///
  /// In en, this message translates to:
  /// **'Albania declares itself the world\'s first officially atheist state'**
  String get timelineEvent1967ce;

  /// No description provided for @timelineEvent1991ce.
  ///
  /// In en, this message translates to:
  /// **'First multi-party elections end 46 years of communist rule'**
  String get timelineEvent1991ce;

  /// No description provided for @timelineEvent1997ce.
  ///
  /// In en, this message translates to:
  /// **'The collapse of nationwide pyramid schemes triggers civil unrest'**
  String get timelineEvent1997ce;

  /// No description provided for @timelineEvent2009ce.
  ///
  /// In en, this message translates to:
  /// **'Albania joins NATO'**
  String get timelineEvent2009ce;

  /// No description provided for @timelineEvent2019ce.
  ///
  /// In en, this message translates to:
  /// **'A devastating earthquake strikes the Durrës region'**
  String get timelineEvent2019ce;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyStatement.
  ///
  /// In en, this message translates to:
  /// **'As explained in our {privacyUrl} we do not collect any personal information.'**
  String privacyStatement(Object privacyUrl);

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

  /// Day-header overflow menu: opens a text dialog to change the day's base city.
  ///
  /// In en, this message translates to:
  /// **'Change base city'**
  String get tripDetailDayActionChangeBaseCity;

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

  /// Title of the inline dialog that changes a day's base city.
  ///
  /// In en, this message translates to:
  /// **'Change base city'**
  String get tripDetailChangeBaseCityDialogTitle;

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
