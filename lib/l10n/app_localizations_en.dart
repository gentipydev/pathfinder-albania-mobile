// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Travel Buddy';

  @override
  String get localeSwapButton => 'Shqip';

  @override
  String animatedArrowSemanticSwipe(Object title) {
    return 'Explore details about $title.';
  }

  @override
  String get appBarTitleFactsHistory => 'Facts and History';

  @override
  String get appBarTitleConstruction => 'Construction';

  @override
  String get appBarTitleLocation => 'Location Info';

  @override
  String get bottomScrubberSemanticScrubber => 'scrubber';

  @override
  String get bottomScrubberSemanticTimeline => 'Timeline Scrubber, drag horizontally to navigate the timeline.';

  @override
  String get rangeSelector => 'Range selector, drag horizontally to adjust the range.';

  @override
  String collectionLabelDiscovered(Object percentage) {
    return '$percentage% discovered';
  }

  @override
  String collectionLabelCount(Object count, Object total) {
    return '$count of $total';
  }

  @override
  String get collectionButtonReset => 'Reset Collection';

  @override
  String get eventsListButtonOpenGlobal => 'Open global timeline';

  @override
  String newlyDiscoveredSemanticNew(Object count, Object suffix) {
    return '$count new item$suffix to explore. Scroll to new item';
  }

  @override
  String newlyDiscoveredLabelNew(Object count, Object suffix) {
    return '$count new item$suffix to explore';
  }

  @override
  String get resultsPopupEnglishContent =>
      'This content is provided by the Metropolitan Museum of Art Collection API, and is only available in English.';

  @override
  String get resultsSemanticDismiss => 'dismiss message';

  @override
  String get scrollingContentSemanticYoutube => 'Youtube thumbnail';

  @override
  String get scrollingContentSemanticOpen => 'Open fullscreen maps view';

  @override
  String get searchInputTitleSuggestions => 'Suggestions';

  @override
  String get searchInputHintSearch => 'Search (ex. type or material)';

  @override
  String get searchInputSemanticClear => 'clear search';

  @override
  String timelineSemanticDate(Object fromDate, Object endDate) {
    return '$fromDate to $endDate';
  }

  @override
  String titleLabelDate(Object fromDate, Object endDate) {
    return '$fromDate to $endDate';
  }

  @override
  String get appModalsButtonOk => 'Ok';

  @override
  String get appModalsButtonCancel => 'Cancel';

  @override
  String get appPageDefaultTitlePage => 'page';

  @override
  String appPageSemanticSwipe(Object pageTitle, Object current, Object total) {
    return '$pageTitle $current of $total.';
  }

  @override
  String get artifactsTitleArtifacts => 'ARTIFACTS';

  @override
  String semanticsPrevious(Object title) {
    return 'Previous $title';
  }

  @override
  String semanticsNext(Object title) {
    return 'Next $title';
  }

  @override
  String get artifactsSemanticsPrevious => 'Previous artifact';

  @override
  String get artifactsSemanticsNext => 'Next artifact';

  @override
  String get artifactsSemanticArtifact => 'Artifact';

  @override
  String get artifactDetailsLabelDate => 'Date';

  @override
  String get artifactDetailsLabelPeriod => 'Period';

  @override
  String get artifactDetailsLabelGeography => 'Geography';

  @override
  String get artifactDetailsLabelMedium => 'Medium';

  @override
  String get artifactDetailsLabelDimension => 'Dimension';

  @override
  String get artifactDetailsLabelClassification => 'Classification';

  @override
  String get artifactDetailsSemanticThumbnail => 'thumbnail image';

  @override
  String artifactDetailsErrorNotFound(Object artifactId) {
    return 'Unable to find info for artifact $artifactId ';
  }

  @override
  String get circleButtonsSemanticClose => 'close';

  @override
  String get circleButtonsSemanticBack => 'back';

  @override
  String get collectibleFoundTitleArtifactDiscovered => 'Artifact Discovered';

  @override
  String get collectibleFoundButtonViewCollection => 'view in my collection';

  @override
  String get collectibleItemSemanticCollectible => 'collectible item';

  @override
  String get collectionTitleCollection => 'Collection';

  @override
  String get collectionPopupResetConfirm => 'Are you sure you want to reset your collection?';

  @override
  String get eightWaySemanticSwipeDetector => 'eight-way swipe detector';

  @override
  String get expandingTimeSelectorSemanticSelector => 'time range selector';

  @override
  String get fullscreenImageViewerSemanticFull => 'full screen image, no description available';

  @override
  String get homeMenuButtonExplore => 'Explore the timeline';

  @override
  String get homeMenuButtonView => 'View your collection';

  @override
  String get homeMenuButtonAbout => 'About this app';

  @override
  String get homeMenuViewingLabel => 'Viewing';

  @override
  String get homeMenuJumpToDestination => 'Jump to a destination';

  @override
  String get homeMenuConversations => 'My conversations';

  @override
  String get homeMenuPreferences => 'Travel preferences';

  @override
  String get homeMenuPlanTrip => 'Plan a trip';

  @override
  String get homeMenuAskBuddy => 'Ask Buddy';

  @override
  String homeMenuPlanTripPrompt(String destination) {
    return 'Plan a trip to $destination, Albania.';
  }

  @override
  String homeMenuAskBuddyPrompt(String destination) {
    return 'Tell me about $destination, Albania — what\'s special and what should I see?';
  }

  @override
  String get homeMenuAboutTagline => 'Travel Buddy is your AI-powered guide to the eight destinations of Albania. ';

  @override
  String homeMenuAboutBuilt(Object flutterUrl) {
    return 'Built with $flutterUrl.';
  }

  @override
  String homeMenuAboutLearn(Object appUrl) {
    return 'Learn more at $appUrl.';
  }

  @override
  String homeMenuAboutSource(Object githubUrl) {
    return 'To see the source code for this app, please visit the $githubUrl.';
  }

  @override
  String get homeMenuAboutRepo => 'Travel Buddy github repo';

  @override
  String get homeMenuAboutFlutter => 'Flutter';

  @override
  String get homeMenuAboutApp => 'travelbuddy.app';

  @override
  String homeMenuAboutPublic(Object metUrl) {
    return 'Public-domain artworks from $metUrl.';
  }

  @override
  String get homeMenuAboutMet => 'The Metropolitan Museum of Art, New York';

  @override
  String homeMenuAboutPhotography(Object unsplashUrl) {
    return 'Photography from $unsplashUrl.';
  }

  @override
  String get homeMenuAboutUnsplash => 'Unsplash';

  @override
  String get introTitleJourney => 'Journey to the past';

  @override
  String get introDescriptionNavigate => 'Navigate the intersection of time, art, and culture.';

  @override
  String get introTitleExplore => 'Explore places';

  @override
  String get introDescriptionUncover => 'Uncover remarkable human-made structures from around the world.';

  @override
  String get introTitleDiscover => 'Discover artifacts';

  @override
  String get introDescriptionLearn => 'Learn about cultures throughout time by examining things they left behind.';

  @override
  String get introSemanticNavigate => 'Navigate';

  @override
  String get introSemanticSwipeLeft => 'Swipe left to continue';

  @override
  String get introSemanticEnterApp => 'Enter the app';

  @override
  String get introSemanticAppName => 'Travel Buddy';

  @override
  String get labelledToggleSemanticToggle => 'toggle';

  @override
  String get photoGallerySemanticCollectible => 'collectible!';

  @override
  String photoGallerySemanticFocus(Object photoIndex, Object photoTotal) {
    return 'Photo $photoIndex of $photoTotal. Tap to focus.';
  }

  @override
  String photoGallerySemanticFullscreen(Object photoIndex, Object photoTotal) {
    return 'Photo $photoIndex of $photoTotal. Tap to open fullscreen view.';
  }

  @override
  String get eraPrehistory => 'Prehistory';

  @override
  String get eraClassical => 'Classical Era';

  @override
  String get eraEarlyModern => 'Early Modern Era';

  @override
  String get eraModern => 'Modern Era';

  @override
  String get yearBCE => 'BCE';

  @override
  String get yearCE => 'CE';

  @override
  String yearFormat(Object date, Object era) {
    return '$date $era';
  }

  @override
  String get year => 'Year';

  @override
  String timelineLabelConstruction(Object title) {
    return 'Construction of $title begins.';
  }

  @override
  String get timelineTitleGlobalTimeline => 'Global Timeline';

  @override
  String get wallpaperModalSave => 'Save this poster to your photo gallery?';

  @override
  String get wallpaperModalSaving => 'Saving Image. Please wait...';

  @override
  String get wallpaperModalSaveComplete => 'Save complete!';

  @override
  String get wallpaperSemanticSharePhoto => 'share photo';

  @override
  String get wallpaperSemanticTakePhoto => 'take photo';

  @override
  String get wallpaperCheckboxShowTitle => 'Show Title';

  @override
  String get destinationDetailsTabLabelInformation => 'information and history';

  @override
  String get destinationDetailsTabLabelImages => 'photo gallery';

  @override
  String get destinationDetailsTabLabelArtifacts => 'artifacts';

  @override
  String get destinationDetailsTabLabelEvents => 'events';

  @override
  String get destinationDetailsTabSemanticBack => 'back to destination selection';

  @override
  String get homeSemanticOpenMain => 'Open main menu';

  @override
  String get homeSemanticDestination => 'destination';

  @override
  String get butrintTitle => 'Butrint';

  @override
  String get butrintSubTitle => 'The Ancient Crossroads';

  @override
  String get butrintRegionTitle => 'Sarandë, Albania';

  @override
  String get butrintArtifactCulture => 'Illyrian-Roman';

  @override
  String get butrintArtifactGeolocation => 'Southern Albania';

  @override
  String get butrintPullQuote1Top => 'A Microcosm of';

  @override
  String get butrintPullQuote1Bottom => 'Mediterranean History';

  @override
  String get butrintPullQuote2 =>
      'Butrint is a testament to the richness and diversity of a cultural landscape shaped by centuries of human settlement.';

  @override
  String get butrintPullQuote2Author => 'UNESCO';

  @override
  String get butrintCallout1 =>
      'Butrint has been inhabited since at least the 8th century BCE and served as a Greek colony, a Roman city, a Byzantine bishopric, and a Venetian outpost.';

  @override
  String get butrintCallout2 =>
      'The ancient theater, built in the 3rd century BCE, could seat approximately 1,500 spectators and is one of the best-preserved in the region.';

  @override
  String get butrintVideoCaption => '“Butrint - Albania\'s UNESCO World Heritage Site.” Youtube.';

  @override
  String get butrintMapCaption => 'Map showing location of Butrint National Park in southern Albania.';

  @override
  String get butrintHistoryInfo1 =>
      'Butrint is an archaeological site in southern Albania, opposite the Greek island of Corfu. First settled by Greek colonists from Corfu in the 8th century BCE, it grew into an important city of the ancient world. According to legend, the city was founded by Trojan refugees led by Aeneas.\nThe Romans conquered Butrint in 167 BCE, and Julius Caesar later designated it a colony for veterans. Under Roman rule, the city flourished with the construction of an aqueduct, public baths, and a forum.';

  @override
  String get butrintHistoryInfo2 =>
      'Butrint continued to thrive as an important ecclesiastical center in the Byzantine period. A large basilica and baptistery were built in the 6th century CE. The site changed hands many times — from Byzantines to Angevins, from Venetians to Ottomans — each leaving their architectural mark on this remarkable landscape.';

  @override
  String get butrintConstructionInfo1 =>
      'The ancient theater is carved into the southern slope of the acropolis hill, taking advantage of the natural terrain. Built with local limestone in the Hellenistic period, the theater features a semicircular orchestra, tiered seating (cavea), and a stage building (skene).\nThe nearby Asclepion sanctuary, dedicated to the god of healing, features finely carved stone reliefs and columns in the Corinthian style.';

  @override
  String get butrintConstructionInfo2 =>
      'The 6th-century baptistery is one of the largest early Christian structures in the Balkans. Its floor is adorned with intricate mosaics depicting animals and geometric patterns, showcasing the artistic sophistication of the era. The structure uses a circular plan with 16 granite columns supporting the interior.';

  @override
  String get butrintLocationInfo1 =>
      'Butrint is located on a peninsula between the Vivari Channel and Lake Butrint in the Ksamil area of southern Albania, approximately 14 miles (23 km) south of Sarandë. The site sits within a national park encompassing wetlands, forests, and the lake itself.';

  @override
  String get butrintLocationInfo2 =>
      'The strategic position of Butrint, on a narrow strait between the mainland and Corfu, made it an important stop along ancient Mediterranean trade routes. The surrounding landscape of marshes, lagoons, and the Ionian Sea coast has been crucial to the site\'s history as both a defensive position and a thriving port.';

  @override
  String get butrint600ce =>
      'Greek colonists from Corfu establish a settlement at Butrint, which grows into a significant trading post';

  @override
  String get butrint832ce =>
      'Butrint serves as a major Byzantine ecclesiastical center with construction of the Great Basilica';

  @override
  String get butrint998ce => 'The city comes under various regional powers as the Byzantine Empire\'s control weakens';

  @override
  String get butrint1100ce =>
      'Normans and Angevins contest control of Butrint as part of broader Mediterranean conflicts';

  @override
  String get butrint1527ce =>
      'The Venetian Republic fortifies Butrint, constructing a castle and tower to defend against Ottoman expansion';

  @override
  String get butrint1535ce =>
      'Ottoman forces gain control of the wider region, and Butrint gradually declines as a settlement';

  @override
  String get butrintCollectible1Title => 'Pendant';

  @override
  String get butrintCollectible1Icon => 'jewelry';

  @override
  String get butrintCollectible2Title => 'Bird Ornament';

  @override
  String get butrintCollectible2Icon => 'jewelry';

  @override
  String get butrintCollectible3Title => 'Vue de Buthrotum';

  @override
  String get butrintCollectible3Icon => 'picture';

  @override
  String get beratTitle => 'Berat';

  @override
  String get beratSubTitle => 'City of a Thousand Windows';

  @override
  String get beratRegionTitle => 'Berat, Albania';

  @override
  String get beratArtifactGeolocation => 'Central Albania';

  @override
  String get beratPullQuote1Top => 'A Rare Example of';

  @override
  String get beratPullQuote1Bottom => 'Well-Preserved Ottoman Architecture';

  @override
  String get beratPullQuote2 =>
      'Berat bears witness to the coexistence of various religious and cultural communities down the centuries.';

  @override
  String get beratPullQuote2Author => 'UNESCO';

  @override
  String get beratCallout1 =>
      'Berat is known for its distinctive white Ottoman houses climbing up the hillside, their many windows giving the city its famous epithet.';

  @override
  String get beratCallout2 =>
      'The castle quarter (Kalaja) has been continuously inhabited for over 2,400 years and still houses a living community within its 13th-century walls.';

  @override
  String get beratVideoCaption => '“Berat - City of a Thousand Windows, Albania.” Youtube.';

  @override
  String get beratMapCaption => 'Map showing location of Berat in central Albania.';

  @override
  String get beratHistoryInfo1 =>
      'Berat is one of the oldest continuously inhabited cities in Albania, located along the banks of the Osum River. The castle on the hilltop has been inhabited since the 4th century BCE, when it was an important Illyrian settlement known as Antipatrea, founded by the Illyrian king Antipater.\nUnder Roman rule, the city served as a strategic military outpost along the Via Egnatia trade route.';

  @override
  String get beratHistoryInfo2 =>
      'During the Byzantine period, the city was known as Pulcheriopolis and later Beligrad. The Ottomans captured Berat in 1417 and it became a major center of trade and craftsmanship.\nThe city\'s three historic quarters — Mangalem, Gorica, and Kalaja — preserve an extraordinary blend of Eastern and Western architecture, earning it UNESCO World Heritage status in 2008 as part of the \"Historic Centres of Berat and Gjirokastër.\"';

  @override
  String get beratConstructionInfo1 =>
      'The Berat Castle sits at 614 feet (187 m) above sea level atop a rocky hill. The current walls date primarily to the 13th century under the Despotate of Epirus, though foundations are much older. The fortress encompasses an area of about 24 acres (10 hectares) and originally had 24 towers along its walls.\nWithin the castle walls, several Byzantine churches survive, including the Church of the Holy Trinity and the Church of St. Mary of Blachernae, featuring remarkable 16th-century frescoes by the renowned painter Onufri.';

  @override
  String get beratConstructionInfo2 =>
      'The Mangalem quarter below the castle is famous for its Ottoman-era houses built on the steep hillside. These traditional houses feature stone foundations, timber-framed upper stories, and large windows arranged symmetrically on whitewashed facades — the architectural signature that gives Berat its name \"City of a Thousand Windows.\"';

  @override
  String get beratLocationInfo1 =>
      'Berat is situated in south-central Albania, approximately 75 miles (120 km) south of the capital Tirana. The city is built along both banks of the Osum River, at the foot of Mount Tomorr, one of Albania\'s most sacred mountains reaching 8,042 feet (2,416 m).';

  @override
  String get beratLocationInfo2 =>
      'The Osum River canyon, stretching southeast of the city, is one of the most dramatic natural features in Albania, with vertical canyon walls reaching over 260 feet (80 m). The surrounding region has been cultivated since antiquity, producing olives, grapes, and figs in the mild Mediterranean-influenced climate.';

  @override
  String get berat1850ce =>
      'Berat experiences a cultural renaissance under the Ottoman Tanzimat reforms, with new schools and civic buildings constructed';

  @override
  String get berat1921ce =>
      'Following Albanian independence, Berat becomes an important administrative center of the new Albanian state';

  @override
  String get berat1922ce =>
      'The first modern schools in Albanian language are established in Berat, advancing the national education movement';

  @override
  String get berat1926ce =>
      'Archaeological surveys begin documenting the historic architecture of Berat\'s castle and Ottoman quarters';

  @override
  String get berat1931ce =>
      'Restoration work begins on the castle walls and Byzantine churches within the Kalaja quarter';

  @override
  String get berat2006ce =>
      'Berat\'s historic center receives preliminary recognition leading to its UNESCO World Heritage inscription in 2008';

  @override
  String get beratCollectible1Title => 'Engraved Horn';

  @override
  String get beratCollectible1Icon => 'statue';

  @override
  String get beratCollectible2Title => 'Fixed fan';

  @override
  String get beratCollectible2Icon => 'jewelry';

  @override
  String get beratCollectible3Title => 'Handkerchiefs (one of two)';

  @override
  String get beratCollectible3Icon => 'textile';

  @override
  String get gjirokasterTitle => 'Gjirokastër';

  @override
  String get gjirokasterSubTitle => 'The Stone City';

  @override
  String get gjirokasterRegionTitle => 'Gjirokastër, Albania';

  @override
  String get gjirokasterArtifactCulture => 'Ottoman-Albanian';

  @override
  String get gjirokasterArtifactGeolocation => 'Southern Albania';

  @override
  String get gjirokasterPullQuote1Top => 'A Rare Example of';

  @override
  String get gjirokasterPullQuote1Bottom => 'a Well-Preserved Ottoman Town';

  @override
  String get gjirokasterPullQuote2 =>
      'Gjirokastër is an outstanding example of a well-preserved Ottoman town, built by farmers of large estates.';

  @override
  String get gjirokasterPullQuote2Author => 'UNESCO';

  @override
  String get gjirokasterCallout1 =>
      'The Gjirokastër Fortress is one of the largest in the Balkans, dominating the city from a hilltop at over 1,100 feet (336 m) above sea level.';

  @override
  String get gjirokasterCallout2 =>
      'The city\'s distinctive tower houses, known as \"kullë,\" feature slate-stone roofs and fortified architecture unique to the region, giving Gjirokastër its name \"The Stone City.\"';

  @override
  String get gjirokasterVideoCaption => '“Gjirokastër - Albania\'s Stone City, UNESCO World Heritage.” Youtube.';

  @override
  String get gjirokasterMapCaption => 'Map showing location of Gjirokastër in southern Albania.';

  @override
  String get gjirokasterHistoryInfo1 =>
      'Gjirokastër is a city in southern Albania, situated in the Drino River valley. The area has been settled since at least the 1st century CE, and a fortress has stood on the hilltop since the 3rd century. The name Gjirokastër likely derives from the medieval Greek \"Argyrokastron\" meaning \"Silver Castle.\"\nThe city rose to prominence in the 13th century as a center of the Despotate of Epirus and later became an important stronghold contested between Byzantine, Serbian, and Ottoman forces.';

  @override
  String get gjirokasterHistoryInfo2 =>
      'Under Ottoman rule from 1417 onward, Gjirokastër became the center of a large sanjak (administrative district) and thrived as a bazaar city. Wealthy landowners built the distinctive fortified tower houses that define the city\'s character.\nThe city was inscribed as a UNESCO World Heritage Site in 2005 as \"a rare example of a well-preserved Ottoman town, built by farmers of large estates.\" It is the birthplace of both former Albanian dictator Enver Hoxha and Nobel Prize-winning author Ismail Kadare.';

  @override
  String get gjirokasterConstructionInfo1 =>
      'The Gjirokastër Fortress covers an area of approximately 18 acres (7.3 hectares) on the hilltop. Expanded significantly by Ali Pasha of Ioannina in the early 19th century, the fortress features massive stone walls, a clock tower, an aqueduct, and a series of underground tunnels and chambers.\nDuring the communist era, the fortress was used as a prison and later converted into a Museum of Armaments. Today it hosts the Gjirokastër National Folklore Festival every five years.';

  @override
  String get gjirokasterConstructionInfo2 =>
      'The city\'s iconic tower houses (kullë) are typically three to four stories tall, built of solid stone with slate roofs. The ground floor served as a cistern and storage, the first floor for winter living, and the upper floors for summer quarters and guest reception. Defensive features include small windows on lower floors and fortified entrances.';

  @override
  String get gjirokasterLocationInfo1 =>
      'Gjirokastër is located in the Drino River valley in southern Albania, about 18 miles (29 km) from the Greek border. The city is built on the steep slopes of the Mali i Gjerë mountain range, rising from the valley floor at approximately 980 feet (300 m) to the castle at over 1,100 feet (336 m).';

  @override
  String get gjirokasterLocationInfo2 =>
      'The surrounding region, known as Dropull, has been a crossroads of cultures for millennia. The Drino Valley connects the Adriatic coast with the interior Balkans, and the ancient route from the coast at Butrint passed through this valley toward the Via Egnatia.';

  @override
  String get gjirokaster70ce =>
      'Early Roman-era settlement exists in the Drino Valley region, with fortifications on the hilltop that would later become Gjirokastër';

  @override
  String get gjirokaster82ce =>
      'The hilltop fortress is expanded as a strategic defensive position guarding the Drino Valley trade routes';

  @override
  String get gjirokaster1140ce =>
      'Argyrokastron emerges as a significant Byzantine settlement and is contested during the Norman invasions of the Balkans';

  @override
  String get gjirokaster1490ce =>
      'Under Ottoman rule, Gjirokastër develops into a thriving bazaar town with construction of the Old Bazaar and early tower houses';

  @override
  String get gjirokaster1829ce =>
      'Ali Pasha of Ioannina undertakes major expansion of the fortress, adding fortifications, an aqueduct, and a clock tower';

  @override
  String get gjirokaster1990ce =>
      'Following the fall of communism, restoration efforts begin and Gjirokastër receives UNESCO World Heritage status in 2005';

  @override
  String get gjirokasterCollectible1Title => 'Glass hexagonal amphoriskos';

  @override
  String get gjirokasterCollectible1Icon => 'vase';

  @override
  String get gjirokasterCollectible2Title => 'Bronze plaque of Mithras slaying the bull';

  @override
  String get gjirokasterCollectible2Icon => 'statue';

  @override
  String get gjirokasterCollectible3Title => 'Veduta di Argirocastro';

  @override
  String get gjirokasterCollectible3Icon => 'picture';

  @override
  String get apolloniaTitle => 'Apollonia';

  @override
  String get apolloniaSubTitle => 'The Ancient City of Learning';

  @override
  String get apolloniaRegionTitle => 'Fier, Albania';

  @override
  String get apolloniaArtifactCulture => 'Illyrian-Greek';

  @override
  String get apolloniaArtifactGeolocation => 'Central Albania';

  @override
  String get apolloniaPullQuote1Top => 'An Admirable City';

  @override
  String get apolloniaPullQuote1Bottom => 'With Excellent Laws';

  @override
  String get apolloniaPullQuote2 =>
      'Apollonia is considered one of the most important cities of the ancient world, a center of learning where the young Octavian studied.';

  @override
  String get apolloniaPullQuote2Author => 'Strabo';

  @override
  String get apolloniaCallout1 =>
      'The Roman statesman and orator Cicero described Apollonia as \"a great and important city\" (magna urbs et gravis) in his work Philippics.';

  @override
  String get apolloniaCallout2 =>
      'The young Octavian (later Emperor Augustus) was studying in Apollonia when he received news of Julius Caesar\'s assassination in 44 BCE, a pivotal moment in Roman history.';

  @override
  String get apolloniaVideoCaption => '“Apollonia Archaeological Park - Ancient Albania.” Youtube.';

  @override
  String get apolloniaMapCaption => 'Map showing location of Apollonia near Fier in central Albania.';

  @override
  String get apolloniaHistoryInfo1 =>
      'Apollonia was an ancient Greek colony founded in 588 BCE by settlers from Corinth and Corcyra (modern Corfu) on the banks of the Aous River (modern Vjosa) in Illyria. Named after the god Apollo, the city quickly grew into one of the most important settlements on the eastern Adriatic coast.\nAt its peak, Apollonia had a population of around 60,000 and was a major stop along the Via Egnatia, the great Roman road connecting the Adriatic to Constantinople.';

  @override
  String get apolloniaHistoryInfo2 =>
      'The city was renowned as a center of philosophy and learning. Numerous Roman nobles sent their sons to study there, most notably Octavian, the future Emperor Augustus. Apollonia\'s importance declined after the 3rd century CE when an earthquake altered the course of the Vjosa River, destroying the city\'s harbor and cutting off its trade routes.\nThe site was partially built over by the Byzantine-era Monastery of St. Mary, which still stands and houses an archaeological museum.';

  @override
  String get apolloniaConstructionInfo1 =>
      'The archaeological park covers approximately 237 acres (96 hectares), though only a fraction has been excavated. Major structures include a monumental bouleuterion (council house) with 19 rows of stone seating, an impressive stoa (covered walkway) measuring over 260 feet (80 m) in length, and a well-preserved odeon (small theater).\nThe remains of a nymphaeum (ornamental fountain) and several temples demonstrate the city\'s wealth and architectural sophistication.';

  @override
  String get apolloniaConstructionInfo2 =>
      'The city was built using locally quarried limestone and followed classical Greek urban planning with an agora, temples, and public buildings arranged along paved streets. The defensive walls, encircling approximately 1 square mile (2.5 sq km), were built with polygonal masonry typical of Hellenistic military architecture.\nThe 13th-century Monastery of St. Mary, built atop ancient ruins within the archaeological zone, features a beautifully decorated Byzantine church with carved stone facades.';

  @override
  String get apolloniaLocationInfo1 =>
      'Apollonia is situated on a hilltop near the village of Pojani, approximately 7 miles (12 km) west of the city of Fier in central Albania. The site overlooks the Myzeqe plain and the Vjosa River valley, commanding views extending to the Adriatic Sea.';

  @override
  String get apolloniaLocationInfo2 =>
      'In antiquity, the Vjosa River flowed much closer to the city, providing direct access to the Adriatic coast and enabling Apollonia to function as an important port city. The fertile surrounding plain supported agricultural production, while the hilltop position offered natural defensive advantages.';

  @override
  String get apollonia700bce =>
      'Greek colonists from Corinth and Corcyra found Apollonia in 588 BCE on Illyrian territory, establishing a settlement that would grow into a major city';

  @override
  String get apollonia214bce =>
      'Apollonia becomes a key Roman ally during the Illyrian Wars and serves as a staging ground for Roman military campaigns in the eastern Mediterranean';

  @override
  String get apollonia121bce =>
      'The city flourishes as a center of trade along the Via Egnatia, connecting Rome to its eastern provinces';

  @override
  String get apollonia556ce =>
      'An earthquake alters the course of the Vjosa River, destroying Apollonia\'s harbor and beginning the city\'s irreversible decline';

  @override
  String get apollonia618ce =>
      'The remains of the city serve as a quarry for building materials; the Byzantine Monastery of St. Mary is constructed within the ancient walls';

  @override
  String get apollonia1487ce =>
      'The site lies largely forgotten and overgrown until systematic archaeological excavations begin under Austrian and later French archaeologists in the early 20th century';

  @override
  String get apolloniaCollectible1Title => 'Biographies of Lian Po and Lin Xiangru';

  @override
  String get apolloniaCollectible1Icon => 'scroll';

  @override
  String get apolloniaCollectible2Title => 'Jar with Dragon';

  @override
  String get apolloniaCollectible2Icon => 'vase';

  @override
  String get apolloniaCollectible3Title => 'Panel with Peonies and Butterfly';

  @override
  String get apolloniaCollectible3Icon => 'textile';

  @override
  String get thethTitle => 'Thethi';

  @override
  String get thethSubTitle => 'The Alpine Sanctuary';

  @override
  String get thethRegionTitle => 'Shkodër, Albania';

  @override
  String get thethArtifactCulture => 'Albanian Highland';

  @override
  String get thethArtifactGeolocation => 'Northern Albania';

  @override
  String get thethPullQuote1Top => 'A Living Fragment of';

  @override
  String get thethPullQuote1Bottom => 'Europe\'s Last Wilderness';

  @override
  String get thethPullQuote1Author => 'Edith Durham';

  @override
  String get thethPullQuote2 =>
      'The Albanian Alps are perhaps the last great wilderness in Europe, a place where time seems to have stood still.';

  @override
  String get thethPullQuote2Author => 'Edith Durham';

  @override
  String get thethCallout1 =>
      'Thethi\'s iconic Lock-in Tower (Kulla e Ngujimit) was used as a refuge for men involved in blood feuds under the Kanun of Lëkë Dukagjini, the traditional Albanian code of law.';

  @override
  String get thethCallout2 =>
      'The Thethi valley sits at approximately 2,500 feet (760 m) above sea level, surrounded by peaks exceeding 8,000 feet (2,500 m), including the dramatic Radohima massif.';

  @override
  String get thethVideoCaption => '“Thethi National Park - Albania\'s Hidden Alpine Paradise.” Youtube.';

  @override
  String get thethMapCaption => 'Map showing location of Thethi in the Albanian Alps, northern Albania.';

  @override
  String get thethHistoryInfo1 =>
      'Thethi is a remote alpine village nestled in a glacial valley in the Albanian Alps (Bjeshkët e Nemuna), in the Shkodër district of northern Albania. The valley has been inhabited for centuries by Albanian highland clans, who maintained a fiercely independent way of life governed by the Kanun, a set of customary laws attributed to Lëkë Dukagjini.\nThe isolation of the valley — accessible only by mountain passes for most of its history — preserved a traditional way of life largely unchanged until the 20th century.';

  @override
  String get thethHistoryInfo2 =>
      'During the communist period (1944-1991), the Albanian government attempted to modernize the highlands, building roads and schools but also restricting traditional customs. After the fall of communism, many highland villages were depopulated as residents moved to lowland cities.\nIn recent years, Thethi has experienced a revival as a destination for hiking and ecotourism, with the Peaks of the Balkans trail bringing international attention to the region\'s natural beauty and cultural heritage.';

  @override
  String get thethConstructionInfo1 =>
      'Thethi\'s traditional stone houses (shtëpi) are built from local limestone and timber, designed to withstand harsh mountain winters. The houses typically feature thick stone walls, small windows to conserve heat, and wooden balconies. Stone-slab roofs, anchored with heavy rocks, protect against the heavy snowfall that blankets the valley for several months each year.\nThe most famous structure in Thethi is the Lock-in Tower (Kulla e Ngujimit), a stone tower used historically as a place of refuge for men targeted in blood feuds.';

  @override
  String get thethConstructionInfo2 =>
      'The Church of Thethi (Kisha e Thethit), built in the 19th century, is a small but picturesque stone church set against the dramatic mountain backdrop. Traditional highland architecture throughout the valley includes watermills along the Thethi River, stone bridges, and livestock enclosures built with dry-stone walling techniques passed down through generations.';

  @override
  String get thethLocationInfo1 =>
      'Thethi lies within the Thethi National Park, established in 1966, covering approximately 5,200 acres (2,100 hectares) of pristine alpine wilderness. The valley is surrounded by the peaks of the Albanian Alps, including Radohima at 8,146 feet (2,568 m) and Haj-Nehaj at 8,524 feet (2,598 m).';

  @override
  String get thethLocationInfo2 =>
      'The Blue Eye of Thethi (Syri i Kaltër), a stunning natural spring pool of vivid turquoise water, is one of the valley\'s most remarkable natural features. The Grunas Waterfall, cascading 100 feet (30 m) down a limestone cliff, is another iconic landmark. The valley connects to Valbona via a popular mountain pass trek at approximately 5,900 feet (1,800 m).';

  @override
  String get theth1438ce =>
      'Albanian highland clans are well established in the Thethi valley, governed by the Kanun of Lëkë Dukagjini';

  @override
  String get theth1572ce =>
      'The highland communities resist Ottoman control, maintaining autonomy through the rugged terrain of the Albanian Alps';

  @override
  String get theth1867ce =>
      'British traveler and diplomat Edith Durham visits the Albanian highlands, later documenting the traditional way of life in her celebrated writings';

  @override
  String get theth1911ce =>
      'Albania declares independence in 1912; the highland regions play a crucial role in the national awakening and resistance movements';

  @override
  String get theth1964ce =>
      'Thethi National Park is established in 1966, one of Albania\'s first protected areas, preserving the alpine ecosystem';

  @override
  String get theth1997ce =>
      'The Peaks of the Balkans trail is inaugurated, connecting Albania, Kosovo, and Montenegro and bringing renewed international attention to Thethi';

  @override
  String get thethCollectible1Title => 'Eight-Pointed Star Tunic';

  @override
  String get thethCollectible1Icon => 'textile';

  @override
  String get thethCollectible2Title => 'Camelid figurine';

  @override
  String get thethCollectible2Icon => 'statue';

  @override
  String get thethCollectible3Title => 'Double Bowl';

  @override
  String get thethCollectible3Icon => 'vase';

  @override
  String get krujaTitle => 'Krujë';

  @override
  String get krujaSubTitle => 'The Fortress of Skanderbeg';

  @override
  String get krujaRegionTitle => 'Durrës County, Albania';

  @override
  String get krujaArtifactCulture => 'Medieval Albanian';

  @override
  String get krujaArtifactGeolocation => 'Central Albania';

  @override
  String get krujaPullQuote1Top => 'The Shield of Christendom';

  @override
  String get krujaPullQuote1Bottom => 'Against the Ottoman Tide';

  @override
  String get krujaPullQuote1Author => 'Pope Callixtus III';

  @override
  String get krujaPullQuote2 =>
      'Skanderbeg\'s defense of Krujë is one of the most remarkable episodes of resistance in European military history.';

  @override
  String get krujaPullQuote2Author => 'Fan Noli';

  @override
  String get krujaCallout1 =>
      'Gjergj Kastrioti Skanderbeg successfully defended Krujë against three major Ottoman sieges, earning him the title \"Athleta Christi\" (Champion of Christ) from the Pope.';

  @override
  String get krujaCallout2 =>
      'The castle sits at an elevation of approximately 1,970 feet (600 m) atop the Skanderbeg Mountain (Mali i Sariut), providing a commanding view of the surrounding plains.';

  @override
  String get krujaVideoCaption => '“Krujë Castle and the Legacy of Skanderbeg - Albania.” Youtube.';

  @override
  String get krujaMapCaption => 'Map showing location of Krujë in central Albania.';

  @override
  String get krujaHistoryInfo1 =>
      'Krujë is a city in north-central Albania, historically renowned as the seat of Gjergj Kastrioti Skanderbeg (1405-1468), Albania\'s national hero. The castle of Krujë has been fortified since at least the 5th century and became the capital of the Principality of Kastrioti in the 15th century.\nIn 1443, Skanderbeg raised the Albanian flag over the castle after abandoning his forced service in the Ottoman army, beginning a 25-year campaign of resistance against the Ottoman Empire.';

  @override
  String get krujaHistoryInfo2 =>
      'Skanderbeg successfully defended Krujë against three major Ottoman sieges — in 1450, 1466, and 1467 — each time repelling vastly superior forces. His resistance prevented Ottoman expansion into Western Europe for decades and earned him admiration across the Christian world.\nAfter Skanderbeg\'s death in 1468, the castle fell to the Ottomans in 1478 after a prolonged fourth siege. The city remained under Ottoman control until Albanian independence in 1912.';

  @override
  String get krujaConstructionInfo1 =>
      'The Krujë Castle is perched on a rocky outcrop at the edge of Skanderbeg Mountain (Mali i Sariut). The fortress walls follow the natural contours of the terrain, encircling an area that once contained a small town with houses, churches, and a bazaar.\nThe Skanderbeg Museum, designed by architects Pranvera Hoxha and Pirro Vaso and opened in 1982, sits within the castle walls. Built in a modernist style inspired by medieval Albanian architecture, it houses artifacts from the period of Albanian resistance.';

  @override
  String get krujaConstructionInfo2 =>
      'Below the castle, the restored Old Bazaar (Pazari i Vjetër) stretches along a cobblestone street with traditional stone and timber shops. The bazaar has been in continuous use since the 15th century and today sells traditional Albanian crafts, antiques, and locally made goods. The Dollma Tekke, a small Bektashi shrine within the castle complex, features elegant Ottoman-era architecture with painted interiors.';

  @override
  String get krujaLocationInfo1 =>
      'Krujë is located approximately 20 miles (32 km) north of Tirana in central Albania. The castle sits atop a mountain spur overlooking the vast western Albanian plain that stretches to the Adriatic Sea, providing strategic visibility over approaching forces — a key factor in Skanderbeg\'s successful defense.';

  @override
  String get krujaLocationInfo2 =>
      'The Skanderbeg Mountain (Mali i Sariut) rises steeply behind the castle to approximately 3,500 feet (1,070 m). The surrounding terrain of steep gorges and dense forests provided natural defensive advantages that Skanderbeg exploited in his guerrilla tactics against the much larger Ottoman forces. The nearby Sarisalltiku peak features a cave shrine venerated by both Muslims and Christians.';

  @override
  String get kruja1200bce =>
      'Early Illyrian settlements exist in the Krujë region, taking advantage of the natural fortress position';

  @override
  String get kruja106bce => 'The region falls under Roman control as part of the province of Illyricum';

  @override
  String get kruja551ce =>
      'Byzantine-era fortifications are constructed on the hilltop, establishing the castle as a strategic defensive position';

  @override
  String get kruja1812ce =>
      'The castle ruins and old bazaar are documented by European travelers as interest in Albanian history grows';

  @override
  String get kruja1958ce =>
      'The Skanderbeg Museum within the castle is established, becoming Albania\'s most important national memorial';

  @override
  String get kruja1989ce =>
      'Krujë becomes a major tourist destination and symbol of Albanian national identity after the fall of communism';

  @override
  String get krujaCollectible1Title => 'Camel and riders';

  @override
  String get krujaCollectible1Icon => 'statue';

  @override
  String get krujaCollectible2Title => 'Vessel';

  @override
  String get krujaCollectible2Icon => 'vase';

  @override
  String get krujaCollectible3Title => 'Open bowl';

  @override
  String get krujaCollectible3Icon => 'vase';

  @override
  String get albanianAlpsTitle => 'Albanian Alps';

  @override
  String get albanianAlpsSubTitle => 'The Accursed Mountains';

  @override
  String get albanianAlpsRegionTitle => 'Northern Albania';

  @override
  String get albanianAlpsArtifactCulture => 'Albanian Highland';

  @override
  String get albanianAlpsArtifactGeolocation => 'Northern Albania';

  @override
  String get albanianAlpsPullQuote1Top => 'Europe\'s Last Great';

  @override
  String get albanianAlpsPullQuote1Bottom => 'Untouched Wilderness';

  @override
  String get albanianAlpsPullQuote2 =>
      'The Accursed Mountains stand as a testament to the raw, untamed beauty of the natural world.';

  @override
  String get albanianAlpsPullQuote2Author => 'Edith Durham';

  @override
  String get albanianAlpsCallout1 =>
      'The Albanian Alps, known locally as Bjeshkët e Nemuna (Accursed Mountains), contain some of the most pristine ecosystems in Europe, harboring lynx, wolves, bears, and golden eagles.';

  @override
  String get albanianAlpsCallout2 =>
      'Jezerca, the highest peak at 8,839 feet (2,694 m), is one of the most dramatic limestone summits in the Balkans, featuring permanent snowfields and glacial cirques.';

  @override
  String get albanianAlpsVideoCaption => '“Albanian Alps - Bjeshkët e Nemuna, Europe\'s Last Wilderness.” Youtube.';

  @override
  String get albanianAlpsMapCaption => 'Map showing location of the Albanian Alps in northern Albania.';

  @override
  String get albanianAlpsHistoryInfo1 =>
      'The Albanian Alps (Bjeshkët e Nemuna), also known as the Accursed Mountains or the Prokletije, are a mountain range stretching across northern Albania, western Kosovo, and eastern Montenegro. In Albania, the range includes some of the most remote and pristine wilderness in all of Europe.\nThe mountains have been home to Albanian highland clans for centuries, who developed a unique culture of hospitality, honor, and self-governance codified in the Kanun of Lëkë Dukagjini.';

  @override
  String get albanianAlpsHistoryInfo2 =>
      'The name \"Accursed Mountains\" has various folk etymologies — some say it comes from the difficulty of crossing them, others attribute it to a legend of feuding mountains cursed by the gods. The Albanian name \"Bjeshkët e Nemuna\" translates more accurately as \"Mountains of the Highlanders.\"\nBritish traveler Edith Durham extensively documented the highlands in the early 1900s, describing a society where ancient customs of blood feuds and sworn virgins (burrnesha) persisted alongside extraordinary hospitality and natural beauty.';

  @override
  String get albanianAlpsConstructionInfo1 =>
      'Unlike man-made structures, the Albanian Alps are a monument of nature, sculpted by millions of years of geological processes. The range is composed primarily of Mesozoic-era limestone and dolomite, shaped by glacial and karst erosion into dramatic peaks, deep valleys, and underground cave systems.\nThe Blue Eye of Theth, turquoise glacial pools, and the Valbona valley\'s dramatic cliff faces are all products of this ongoing geological story.';

  @override
  String get albanianAlpsConstructionInfo2 =>
      'Human structures in the Albanian Alps reflect the mountain environment. Traditional highland houses (kullë) are built from massive limestone blocks with timber interiors, designed to withstand heavy snowfall and provide defense. Stone-walled pastures, ancient mule trails, and small mountain churches dot the landscape.\nThe Peaks of the Balkans trail, a 120-mile (192 km) hiking route established in 2013, connects communities across three countries using many of these traditional paths.';

  @override
  String get albanianAlpsLocationInfo1 =>
      'The Albanian Alps extend across the districts of Shkodër and Kukës in northern Albania, forming the country\'s border with Montenegro and Kosovo. The range stretches approximately 40 miles (65 km) from the Kelmendi region in the northwest to the Valbona area in the east. Major valleys include Thethi, Valbona, and Kelmendi.';

  @override
  String get albanianAlpsLocationInfo2 =>
      'The Valbona Valley National Park and Thethi National Park protect much of the Albanian portion of the range. Lake Koman, accessible by ferry through a dramatic canyon often compared to Scandinavian fjords, provides a stunning approach to the mountains from the south. The region receives some of the highest precipitation in Europe, feeding numerous rivers and waterfalls.';

  @override
  String get albanianAlps2575bce =>
      'Early human habitation in the Albanian Alps region dates back to the Bronze Age, with evidence of pastoral communities in the highland valleys';

  @override
  String get albanianAlps2465bce =>
      'Illyrian tribes establish seasonal settlements in the mountain pastures, developing the transhumance traditions that continue to this day';

  @override
  String get albanianAlps443bce =>
      'Greek and Roman writers document the fierce independence of the mountain-dwelling Illyrian tribes and the difficult terrain of the region';

  @override
  String get albanianAlps1925ce =>
      'British traveler Edith Durham publishes detailed accounts of life in the Albanian highlands, bringing international attention to the region';

  @override
  String get albanianAlps1979ce =>
      'Thethi National Park and Valbona Valley are designated as protected areas, preserving the alpine ecosystems';

  @override
  String get albanianAlps1990ce =>
      'After the fall of communism, the Albanian Alps open to international hikers and the Peaks of the Balkans trail is eventually established in 2013';

  @override
  String get albanianAlpsCollectible1Title => 'Two papyrus fragments';

  @override
  String get albanianAlpsCollectible1Icon => 'scroll';

  @override
  String get albanianAlpsCollectible2Title => 'Fragmentary Face of King Khafre';

  @override
  String get albanianAlpsCollectible2Icon => 'statue';

  @override
  String get albanianAlpsCollectible3Title => 'Jewelry Elements';

  @override
  String get albanianAlpsCollectible3Icon => 'jewelry';

  @override
  String get korcaTitle => 'Korçë';

  @override
  String get korcaSubTitle => 'The Cradle of Albanian Culture';

  @override
  String get korcaRegionTitle => 'Korçë, Albania';

  @override
  String get korcaArtifactCulture => 'Albanian Orthodox';

  @override
  String get korcaArtifactGeolocation => 'Southeastern Albania';

  @override
  String get korcaPullQuote1Top => 'Not Just a Cathedral,';

  @override
  String get korcaPullQuote1Bottom => 'but the Soul of a Nation';

  @override
  String get korcaPullQuote1Author => 'Fan Noli';

  @override
  String get korcaPullQuote2 =>
      'Korçë is the city where Albanian national consciousness first found its voice through schools, literature, and art.';

  @override
  String get korcaPullQuote2Author => 'Faik Konica';

  @override
  String get korcaCallout1 =>
      'The Resurrection Cathedral (Katedralja Ngjallja e Krishtit) is the largest Orthodox cathedral in Albania, designed by renowned architect Fan Noli and completed in 2003.';

  @override
  String get korcaCallout2 =>
      'Korçë is home to the first Albanian-language school, opened on March 7, 1887, a date now celebrated as Teacher\'s Day (Dita e Mësuesit) across Albania.';

  @override
  String get korcaVideoCaption => '“Korçë - The Cradle of Albanian Culture and the Resurrection Cathedral.” Youtube.';

  @override
  String get korcaMapCaption => 'Map showing location of Korçë in southeastern Albania.';

  @override
  String get korcaHistoryInfo1 =>
      'Korçë is a city in southeastern Albania, situated in a high plateau at approximately 2,800 feet (850 m) above sea level. The city has been a center of Albanian culture, education, and art since the 19th century, earning it the title \"the cradle of Albanian culture.\"\nThe first Albanian-language school was opened here on March 7, 1887, by Pandeli Sotiri, marking a pivotal moment in the Albanian national awakening. Korçë also hosted the first Albanian printing press and numerous literary societies.';

  @override
  String get korcaHistoryInfo2 =>
      'The original Orthodox Cathedral was destroyed during the communist period when Albania declared itself the world\'s first atheist state in 1967, demolishing nearly all religious buildings. The new Resurrection Cathedral (Katedralja Ngjallja e Krishtit) was built between 1992 and 2003 on the foundations of the old cathedral, symbolizing both religious revival and national cultural renewal.\nKorçë is also renowned for its contribution to Albanian music, art, and the famous annual Korçë Beer Festival, one of the largest in the Balkans.';

  @override
  String get korcaConstructionInfo1 =>
      'The Resurrection Cathedral was designed in a neo-Byzantine style, drawing inspiration from traditional Orthodox church architecture while incorporating modern construction techniques. The cathedral features a cruciform plan with a large central dome reaching approximately 100 feet (30 m) in height, flanked by smaller domes.\nThe exterior is clad in light-colored stone with decorative arched windows, while the interior is adorned with frescoes and iconography painted by Albanian and Greek artists.';

  @override
  String get korcaConstructionInfo2 =>
      'The cathedral\'s construction spanned over a decade, from 1992 to 2003. Modern reinforced concrete and steel frame construction was used for structural integrity, while traditional stone and decorative elements maintain the Byzantine aesthetic.\nThe bell tower, rising beside the cathedral, houses a set of bells that ring across the city. The surrounding plaza and park create a cultural center for the city, connecting to the National Museum of Medieval Art, which houses one of the finest collections of Byzantine icons in the world.';

  @override
  String get korcaLocationInfo1 =>
      'Korçë is located in the Korçë Basin, a fertile plateau surrounded by mountains in southeastern Albania. The city lies approximately 112 miles (180 km) southeast of Tirana, near the borders with both Greece and North Macedonia. The Morava Mountain range rises to the east, while Lake Ohrid lies to the northeast.';

  @override
  String get korcaLocationInfo2 =>
      'The Korçë plateau has been inhabited since prehistoric times due to its fertile soil and strategic position along ancient trade routes connecting the Adriatic and Aegean seas. The nearby archaeological site of Maliq, on the shores of a former lake, has yielded evidence of continuous habitation dating back to the Neolithic period, around 6000 BCE.';

  @override
  String get korca1631ce =>
      'Korçë develops as an Ottoman administrative and trade center with construction of mosques, bazaars, and hans (inns)';

  @override
  String get korca1647ce =>
      'The city\'s importance grows as a crossroads of trade routes connecting Thessaloniki, Ioannina, and the Albanian coast';

  @override
  String get korca1658ce =>
      'Cultural and religious communities flourish in Korçë, establishing it as a multi-ethnic center of learning';

  @override
  String get korca1901ce =>
      'Korçë becomes a center of the Albanian national movement with the opening of the first Albanian-language school in 1887';

  @override
  String get korca1984ce =>
      'During the communist era, the original Orthodox Cathedral and most religious buildings are demolished as Albania is declared an atheist state';

  @override
  String get korca1998ce =>
      'Construction of the new Resurrection Cathedral begins after the fall of communism, completed in 2003 as a symbol of cultural renewal';

  @override
  String get korcaCollectible1Title => 'Dagger with Scabbard';

  @override
  String get korcaCollectible1Icon => 'jewelry';

  @override
  String get korcaCollectible2Title => 'The House of Bijapur';

  @override
  String get korcaCollectible2Icon => 'picture';

  @override
  String get korcaCollectible3Title => 'Panel of Nasta\'liq Calligraphy';

  @override
  String get korcaCollectible3Icon => 'scroll';

  @override
  String get timelineEvent2900bce => 'Bronze Age tumuli traditions emerge across the Western Balkans';

  @override
  String get timelineEvent2700bce =>
      'The Maliq settlement near Korçë grows into one of the earliest agrarian communities of the southern Balkans';

  @override
  String get timelineEvent2600bce =>
      'Early Bronze Age communities flourish along the Adriatic coast of present-day Albania';

  @override
  String get timelineEvent2560bce => 'The Cetina cultural horizon links communities across the Western Balkans';

  @override
  String get timelineEvent1200bce =>
      'Illyrian tribes — Taulantii, Ardiaei, Dardani, Enchelei, Chaones — consolidate across the western Balkans';

  @override
  String get timelineEvent627bce =>
      'Greek settlers from Corinth and Corcyra found Epidamnos, the future Dyrrhachium and modern Durrës';

  @override
  String get timelineEvent358bce => 'Bardylis I of the Dardanian Kingdom defeats Macedonia under Perdiccas III';

  @override
  String get timelineEvent229bce =>
      'First Illyrian War: Queen Teuta of the Ardiaeans clashes with Rome over Adriatic piracy';

  @override
  String get timelineEvent168bce =>
      'Third Illyrian War ends; King Gentius is defeated and Illyria becomes a Roman protectorate';

  @override
  String get timelineEvent146bce =>
      'Rome begins constructing the Via Egnatia, linking Dyrrhachium across Illyria to Byzantium';

  @override
  String get timelineEvent395ce => 'The Roman Empire splits; Illyria is absorbed into the Eastern Byzantine realm';

  @override
  String get timelineEvent500ce =>
      'The Albanian coast flourishes as a key Byzantine corridor between Constantinople and the western Mediterranean';

  @override
  String get timelineEvent632ce =>
      'Death of Muhammad (61) and founding of Islam — the faith that will later reshape Albania under Ottoman rule';

  @override
  String get timelineEvent1018ce => 'Basil II reconquers Illyria; the Byzantine Theme of Dyrrhachium is re-established';

  @override
  String get timelineEvent1043ce =>
      'First written reference to the name Albanoi — Albanians take part in the revolt of George Maniakes';

  @override
  String get timelineEvent1081ce => 'Battle of Dyrrhachium: Norman forces under Robert Guiscard defeat the Byzantines';

  @override
  String get timelineEvent1190ce => 'Progon founds the Principality of Arbanon — the first Albanian medieval state';

  @override
  String get timelineEvent1271ce => 'Charles of Anjou proclaims the Kingdom of Albania (Regnum Albaniae)';

  @override
  String get timelineEvent1347ce =>
      'The Black Death plague sweeps Europe and devastates Balkan populations, including Albania';

  @override
  String get timelineEvent1355ce =>
      'After the death of Stefan Dušan, the Albanian principalities of Balsha, Topia, Muzaka and Kastrioti rise';

  @override
  String get timelineEvent1389ce => 'Albanian nobles fight beside Serbian forces at the Battle of Kosovo';

  @override
  String get timelineEvent1428ce =>
      'Gjergj Kastrioti, the future Skanderbeg, comes of age in the Ottoman court before returning to lead Albanian resistance';

  @override
  String get timelineEvent1443ce => 'Skanderbeg defects from the Ottoman army at the Battle of Niš and seizes Krujë';

  @override
  String get timelineEvent1444ce => 'The League of Lezhë unites Albanian princes under Skanderbeg\'s command';

  @override
  String get timelineEvent1450ce => 'First Siege of Krujë: Skanderbeg withstands Sultan Murad II';

  @override
  String get timelineEvent1466ce =>
      'Sultan Mehmed II launches the Second Siege of Krujë and builds the fortress of Elbasan';

  @override
  String get timelineEvent1468ce => 'Death of Skanderbeg in Lezhë; Albanian resistance gradually crumbles';

  @override
  String get timelineEvent1479ce => 'Fall of Shkodër — Ottoman conquest of Albania is complete';

  @override
  String get timelineEvent1571ce =>
      'Battle of Lepanto — Albanian sailors fight on both sides of the Christian–Ottoman naval struggle';

  @override
  String get timelineEvent1788ce => 'Ali Pasha of Tepelenë establishes the semi-autonomous Pashalik of Yanina';

  @override
  String get timelineEvent1789ce =>
      'The French Revolution begins; its ideals later inspire the Albanian National Awakening (Rilindja)';

  @override
  String get timelineEvent1830ce =>
      'The Massacre of the Beys at Manastir ends Albanian feudal autonomy under Ottoman reforms';

  @override
  String get timelineEvent1878ce => 'The League of Prizren is founded — the first organised Albanian national movement';

  @override
  String get timelineEvent1908ce => 'The Congress of Manastir standardises the Albanian Latin alphabet';

  @override
  String get timelineEvent1912ce => 'Ismail Qemali proclaims Albanian independence in Vlorë on 28 November';

  @override
  String get timelineEvent1914ce =>
      'World War I — Albania becomes a contested battleground for several European powers';

  @override
  String get timelineEvent1920ce => 'The Congress of Lushnjë makes Tirana the capital of Albania';

  @override
  String get timelineEvent1928ce => 'Ahmet Zogu is crowned King Zog I of the Albanians';

  @override
  String get timelineEvent1939ce => 'World War II begins';

  @override
  String get timelineEvent1939ceAlbania => 'Italy invades Albania, beginning the Axis occupation';

  @override
  String get timelineEvent1944ce => 'Albania is liberated by partisan forces; Enver Hoxha\'s communist regime begins';

  @override
  String get timelineEvent1967ce => 'Albania declares itself the world\'s first officially atheist state';

  @override
  String get timelineEvent1991ce => 'First multi-party elections end 46 years of communist rule';

  @override
  String get timelineEvent1997ce => 'The collapse of nationwide pyramid schemes triggers civil unrest';

  @override
  String get timelineEvent2009ce => 'Albania joins NATO';

  @override
  String get timelineEvent2019ce => 'A devastating earthquake strikes the Durrës region';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String privacyStatement(Object privacyUrl) {
    return 'As explained in our $privacyUrl we do not collect any personal information.';
  }

  @override
  String get pageNotFoundBackButton => 'Back to civilization';

  @override
  String get pageNotFoundMessage => 'The page you are looking for does not exist.';

  @override
  String get authSignInTitle => 'Welcome back';

  @override
  String get authSignInSubtitle => 'Sign in to continue exploring Albania.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authSignInButton => 'SIGN IN';

  @override
  String get authSignInError => 'Something went wrong. Please try again.';

  @override
  String get authEmailRequired => 'Email is required';

  @override
  String get authEmailInvalid => 'Enter a valid email';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get buddyHeaderTitle => 'Travel Buddy';

  @override
  String get buddyHeaderSubtitle => 'Your Albania-native AI guide';

  @override
  String get buddyEmptyTitle => 'How can I help plan your trip?';

  @override
  String get buddyEmptySubtitle => 'Ask me about places, food, budgets, or itineraries in Albania.';

  @override
  String get buddyComposerHint => 'Message your travel buddy…';

  @override
  String get buddySuggestionTirana => 'Plan a 3-day Tirana trip';

  @override
  String get buddySuggestionBerat => 'Best things to do in Berat';

  @override
  String get buddySuggestionBudget => 'Albania on a tight budget';

  @override
  String get buddyErrorHint => 'Something went wrong.';

  @override
  String get buddyErrorRetry => 'Retry';

  @override
  String get buddyNotSavedHint => 'Reply not saved on the server.';

  @override
  String get buddyItineraryUnstructured => 'Couldn\'t structure that itinerary — your reply is above.';

  @override
  String get refineWithBuddyButton => 'Refine with Buddy';

  @override
  String get refineComposerHint => 'Ask Buddy to refine this trip…';

  @override
  String get refineEmptyTitle => 'What should we change?';

  @override
  String get refineEmptySubtitle => 'Ask Buddy to tweak this trip — shorten a day, swap a stop, add something new.';

  @override
  String get refineSuggestionShortenDay => 'Shorten day 2';

  @override
  String get refineSuggestionAddBeach => 'Add a beach day';

  @override
  String get refineSuggestionSwapStop => 'Swap a stop for something more local';

  @override
  String refineBannerTitle(String tripTitle) {
    return 'Refining: $tripTitle';
  }

  @override
  String get refineBannerExit => 'Exit';

  @override
  String get refineTripUpdated => 'Trip updated';

  @override
  String get refineViewTrip => 'View trip';

  @override
  String get refineFailedFooter => 'Couldn\'t apply the refinement. The chat reply describes the proposed change.';

  @override
  String get refineOpenFailed => 'Couldn\'t open chat — try again.';

  @override
  String get buddySendTooltip => 'Send message';

  @override
  String get buddyPlaceCardOpenInMap => 'Open in map';

  @override
  String get buddyVoiceHoldToTalk => 'Hold to talk';

  @override
  String get buddyVoiceTapToTalk => 'Tap to talk';

  @override
  String get buddyVoiceListening => 'Listening…';

  @override
  String get buddyVoiceCancel => 'Cancel';

  @override
  String get buddyVoiceStop => 'Stop recording';

  @override
  String get buddyVoiceSend => 'Send';

  @override
  String get buddyVoicePermissionDenied => 'Microphone permission denied. Enable it in Settings to use voice.';

  @override
  String get buddyVoiceUnavailable => 'Voice recognition isn\'t available on this device.';

  @override
  String get buddyTtsPlay => 'Read aloud';

  @override
  String get buddyTtsStop => 'Stop reading';

  @override
  String get buddyAttachTooltip => 'Add photo';

  @override
  String get buddyAttachCamera => 'Camera';

  @override
  String get buddyAttachGallery => 'Photo library';

  @override
  String get buddyAttachUploading => 'Uploading…';

  @override
  String get buddyAttachFailed => 'Upload failed';

  @override
  String get buddyAttachRemove => 'Remove';

  @override
  String get buddyAttachRetry => 'Retry';

  @override
  String get buddyAttachSizeError => 'Image too large — try a smaller photo';

  @override
  String get buddyAttachFormatError => 'Unsupported image — use JPG, PNG, GIF, or WebP';

  @override
  String get buddyHistoryTooltip => 'Past conversations';

  @override
  String get buddyNewChatTooltip => 'New chat';

  @override
  String get conversationsTitle => 'Past conversations';

  @override
  String get conversationsEmpty => 'No conversations yet';

  @override
  String get conversationsLoadFailed => 'Couldn\'t load conversations';

  @override
  String get conversationsNewChatTooltip => 'New chat';

  @override
  String get conversationsDeleteTitle => 'Delete conversation?';

  @override
  String get conversationsDeleteConfirm => 'This can\'t be undone.';

  @override
  String get conversationsDeleteAction => 'Delete';

  @override
  String get conversationsDeleteCancel => 'Cancel';

  @override
  String get conversationsDeleteFailed => 'Failed to delete conversation.';

  @override
  String get conversationsClearAllAction => 'Clear all conversations';

  @override
  String get conversationsClearAllTitle => 'Clear all conversations?';

  @override
  String get conversationsClearAllBody => 'Every conversation will be permanently deleted. This can\'t be undone.';

  @override
  String get conversationsClearAllConfirm => 'Clear all';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEmailLabel => 'Signed in as';

  @override
  String get profileSignOutButton => 'Sign out';

  @override
  String get preferencesTileTitle => 'Preferences';

  @override
  String get preferencesTileSubtitle => 'Customize your travel style';

  @override
  String get preferencesScreenTitle => 'Preferences';

  @override
  String get preferencesSaveButton => 'Save';

  @override
  String get preferencesSaveSuccess => 'Preferences saved';

  @override
  String get preferencesSaveError => 'Couldn\'t save preferences';

  @override
  String get preferencesLoadError => 'Couldn\'t load preferences';

  @override
  String get preferencesNotSetYet => 'Not set yet';

  @override
  String get preferencesPersonaSection => 'Travel persona';

  @override
  String get preferencesPersonaEmpty => 'Tap Generate to create your travel persona';

  @override
  String get preferencesPersonaGenerate => 'Generate persona';

  @override
  String get preferencesPersonaRegenerate => 'Regenerate';

  @override
  String get preferencesPersonaError => 'Couldn\'t generate persona';

  @override
  String get preferencesPersonaUseButton => 'Use this persona';

  @override
  String get preferencesPersonaInfoBody =>
      'Pick the persona that feels closest to you right now. It\'s just the starting point — the more you chat with Travel Buddy, the better it understands how you actually travel. Your budget, your pace, what you skip, what you never miss. Over time, recommendations stop feeling generic and start feeling like they were made for you.';

  @override
  String get preferencesPersonaInfoDismiss => 'Got it';

  @override
  String get preferencesBudgetSection => 'Budget';

  @override
  String get preferencesBudgetShoestring => 'Shoestring';

  @override
  String get preferencesBudgetMidRange => 'Mid-range';

  @override
  String get preferencesBudgetLuxury => 'Luxury';

  @override
  String get preferencesGroupSection => 'Who\'s travelling';

  @override
  String get preferencesGroupSolo => 'Solo';

  @override
  String get preferencesGroupCouple => 'Couple';

  @override
  String get preferencesGroupFamily => 'Family';

  @override
  String get preferencesGroupFriends => 'Friends';

  @override
  String get preferencesStyleSection => 'Travel style';

  @override
  String get preferencesStyleAdventure => 'Adventure';

  @override
  String get preferencesStyleCultural => 'Cultural';

  @override
  String get preferencesStyleRelaxation => 'Relaxation';

  @override
  String get preferencesStyleFoodie => 'Foodie';

  @override
  String get preferencesStyleBeach => 'Beach';

  @override
  String get preferencesStyleNightlife => 'Nightlife';

  @override
  String get preferencesStyleHiddenGem => 'Off-the-beaten-path';

  @override
  String get preferencesAccommodationSection => 'Accommodation';

  @override
  String get preferencesAccommodationHotel => 'Hotel';

  @override
  String get preferencesAccommodationHostel => 'Hostel';

  @override
  String get preferencesAccommodationAirbnb => 'Airbnb';

  @override
  String get preferencesAccommodationBoutique => 'Boutique';

  @override
  String get preferencesAccommodationCamping => 'Camping';

  @override
  String get preferencesTransportSection => 'Transport';

  @override
  String get preferencesTransportCar => 'Car rental';

  @override
  String get preferencesTransportPublic => 'Public transit';

  @override
  String get preferencesTransportWalking => 'Walking';

  @override
  String get preferencesPaceSection => 'Pace';

  @override
  String get preferencesPaceChill => 'Chill';

  @override
  String get preferencesPaceModerate => 'Moderate';

  @override
  String get preferencesPacePacked => 'Packed';

  @override
  String get preferencesFoodSection => 'Dietary';

  @override
  String get preferencesFoodVegetarian => 'Vegetarian';

  @override
  String get preferencesFoodVegan => 'Vegan';

  @override
  String get preferencesFoodHalal => 'Halal';

  @override
  String get preferencesFoodGluten => 'Gluten-free';

  @override
  String get preferencesFoodNone => 'No restrictions';

  @override
  String get preferencesInterestsSection => 'Interests';

  @override
  String get preferencesInterestsHistory => 'History';

  @override
  String get preferencesInterestsNature => 'Nature';

  @override
  String get preferencesInterestsHiking => 'Hiking';

  @override
  String get preferencesInterestsBeaches => 'Beaches';

  @override
  String get preferencesInterestsFood => 'Food';

  @override
  String get preferencesInterestsNightlife => 'Nightlife';

  @override
  String get preferencesInterestsArchitecture => 'Architecture';

  @override
  String get preferencesInterestsReligion => 'Religion';

  @override
  String get preferencesInterestsPhotography => 'Photography';

  @override
  String get photoGalleryLabelNoPhotos => 'No photos yet';

  @override
  String get artifactCarouselLabelNoArtifacts => 'No artifacts to show';

  @override
  String get buddySaveItinerary => 'Save itinerary';

  @override
  String get buddyItinerarySaved => 'Saved ✓ — View in My Trips';

  @override
  String get buddyItinerarySaveRetry => 'Couldn\'t save — tap to retry';

  @override
  String get buddyItineraryPickStartDateHelp => 'When does this trip start?';

  @override
  String get buddySaveLimitHelper => 'Limit reached — delete a trip to save a new one';

  @override
  String get myTripsTitle => 'My Trips';

  @override
  String get myTripsEmptyTitle => 'No saved trips yet';

  @override
  String get myTripsEmptySubtitle => 'Plan one with Buddy and tap Save itinerary.';

  @override
  String get myTripsDatesNotSet => 'Dates not set';

  @override
  String get myTripsDaysOne => '1 day';

  @override
  String myTripsDaysOther(int count) {
    return '$count days';
  }

  @override
  String get myTripsDeleteTitle => 'Delete trip?';

  @override
  String get myTripsDeleteBody => 'This can\'t be undone.';

  @override
  String get myTripsDeleteCancel => 'Cancel';

  @override
  String get myTripsDeleteConfirm => 'Delete';

  @override
  String get myTripsClearAllAction => 'Clear all trips';

  @override
  String get myTripsClearAllTitle => 'Clear all trips?';

  @override
  String get myTripsClearAllBody => 'Every saved trip will be permanently deleted. This can\'t be undone.';

  @override
  String get myTripsClearAllConfirm => 'Clear all';

  @override
  String myTripsCounter(int count, int max) {
    return '$count / $max';
  }

  @override
  String tripDetailDayLabel(int dayNumber) {
    return 'Day $dayNumber';
  }

  @override
  String get tripDetailAddStop => 'Add stop';

  @override
  String get tripDetailAddDay => 'Add day';

  @override
  String get tripDetailDialogSave => 'Save';

  @override
  String get tripDetailDialogClear => 'Clear';

  @override
  String get tripDetailStartDateNotSet => 'Not set';

  @override
  String get tripDetailRailMarkVisited => 'Mark as visited';

  @override
  String get tripDetailRailResetUpcoming => 'Reset to upcoming';

  @override
  String tripDetailVisitedAt(String time) {
    return 'Visited $time';
  }

  @override
  String tripDetailDayProgress(int done, int total) {
    return '$done / $total visited';
  }

  @override
  String get tripDetailAutoTrackPromptTitle => 'Auto-check stops as you visit?';

  @override
  String get tripDetailAutoTrackPromptBody =>
      'Travel Buddy can check off stops automatically when you\'re nearby during their scheduled time. Location stays on your device.';

  @override
  String get tripDetailAutoTrackEnable => 'Enable';

  @override
  String get tripDetailAutoTrackDecline => 'Not now';

  @override
  String get tripDetailAutoTrackEnableMenu => 'Enable visit auto-tracking';

  @override
  String get tripDetailAutoTrackDisableMenu => 'Disable visit auto-tracking';

  @override
  String get tripDetailAutoTrackErrorPermissionTitle => 'Auto-tracking needs location access';

  @override
  String get tripDetailAutoTrackErrorPermissionBody =>
      'Auto-tracking checks off stops when you\'re near them. Allow location access while using the app to turn it on.';

  @override
  String get tripDetailAutoTrackErrorBlockedBody =>
      'Location access is currently blocked. Open Settings to allow it for Travel Buddy.';

  @override
  String get tripDetailAutoTrackErrorServiceTitle => 'Turn on Location Services';

  @override
  String get tripDetailAutoTrackErrorServiceBody =>
      'Location Services are off for this device. Auto-tracking can\'t run until they\'re back on.';

  @override
  String get tripDetailAutoTrackErrorOpenSettings => 'Open Settings';

  @override
  String get tripDetailAutoTrackErrorRetry => 'Try again';

  @override
  String get tripDetailAddDayDialogTitle => 'Add day';

  @override
  String get tripDetailAddDayNumberField => 'Day number';

  @override
  String get tripDetailAddDayTitleField => 'Title (optional)';

  @override
  String get tripDetailAddDayBaseCityField => 'Base city (optional)';

  @override
  String get tripDetailSummaryPlaceholder => 'Tap to add a summary';

  @override
  String get tripDetailEmptyDayHint => 'No stops yet — tap + to add one';

  @override
  String get tripDetailKebabEditSummary => 'Edit summary';

  @override
  String get tripDetailKebabChangeStartDate => 'Change start date';

  @override
  String get tripDetailKebabClearStartDate => 'Clear start date';

  @override
  String get tripDetailDayActionRename => 'Rename day';

  @override
  String get tripDetailDayActionAddStop => 'Add stop here';

  @override
  String get tripDetailDayActionDelete => 'Delete day';

  @override
  String get tripDetailRenameDayDialogTitle => 'Rename day';

  @override
  String get tripDetailStopActionDuplicate => 'Duplicate';

  @override
  String tripDetailUndoStopBanner(String stopName) {
    return 'Stop deleted: $stopName';
  }

  @override
  String get tripDetailUndoStopButton => 'UNDO';

  @override
  String get tripDetailStopActionEdit => 'Edit';

  @override
  String get tripDetailStopActionMove => 'Move to day…';

  @override
  String get tripDetailStopActionDelete => 'Delete';

  @override
  String get tripDetailViewOnMapButton => 'View on map';

  @override
  String get tripDetailMoveStopSheetTitle => 'Move to day';

  @override
  String tripDetailMoveStopSheetSubtitle(String stopName) {
    return 'Where should \"$stopName\" go?';
  }

  @override
  String tripDetailMoveStopOption(int dayNumber, String label) {
    return 'Day $dayNumber · $label';
  }

  @override
  String get tripDetailMoveStopOptionEmpty => 'no stops yet';

  @override
  String tripDetailMoveStopOptionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops',
      one: '1 stop',
    );
    return '$_temp0';
  }

  @override
  String get tripDetailMoveStopFailed => 'Couldn\'t move stop — try again.';

  @override
  String get tripsErrorSignIn => 'Sign in again to save changes.';

  @override
  String get tripsErrorNotFound => 'This trip no longer exists.';

  @override
  String get tripsErrorConflict => 'Trip changed elsewhere — refreshing.';

  @override
  String get tripsErrorTripLimitReached => 'You can only save up to 3 trips. Delete one to save this trip.';

  @override
  String get tripsErrorGeneric => 'Couldn\'t save your change.';

  @override
  String get conversationsUntitled => 'Untitled chat';

  @override
  String get profileDeleteAccountButton => 'Delete account';

  @override
  String get profileDeleteAccountTitle => 'Delete account?';

  @override
  String get profileDeleteAccountBody =>
      'This permanently removes your trips, conversations, uploaded photos, and preferences. This can\'t be undone.';

  @override
  String get profileDeleteAccountInstruction => 'Type DELETE to confirm:';

  @override
  String get profileDeleteAccountConfirmWord => 'DELETE';

  @override
  String get profileDeleteAccountConfirm => 'Delete my account';

  @override
  String get profileDeleteAccountCancel => 'Cancel';

  @override
  String get profileDeleteAccountFailed => 'Couldn\'t delete your account. Please try again.';

  @override
  String get placeCardOpenInMaps => 'Open in maps';
}
