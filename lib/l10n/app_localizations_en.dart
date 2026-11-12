// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get bottomScrubberSemanticTimeline => 'Timeline Scrubber, drag horizontally to navigate the timeline.';

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
  String get eventsListButtonOpenTimeline => 'Open the story timeline';

  @override
  String newlyDiscoveredSemanticNew(Object count, Object suffix) {
    return '$count new item$suffix to explore. Scroll to new item';
  }

  @override
  String newlyDiscoveredLabelNew(Object count, Object suffix) {
    return '$count new item$suffix to explore';
  }

  @override
  String get scrollingContentSemanticYoutube => 'Youtube thumbnail';

  @override
  String get scrollingContentSemanticOpen => 'Open fullscreen maps view';

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
  String get fullscreenImageViewerSemanticFull => 'full screen image, no description available';

  @override
  String get introTitleWelcome => 'Meet Pathfinder Albania';

  @override
  String get introDescWelcome => 'Your guide to Albania, from the Ionian coast to the Accursed Mountains.';

  @override
  String get introTitleExplore => 'Explore eight destinations';

  @override
  String get introDescExplore =>
      'Ancient cities, castle towns and mountain valleys, each with its story, photos and timeline.';

  @override
  String get introTitleStory => 'Three thousand years of story';

  @override
  String get introDescStory =>
      'Walk the timeline from Illyrian hill forts to Ottoman bazaars and collect hidden artifacts on the way.';

  @override
  String get introSkip => 'Skip';

  @override
  String get introSemanticNavigate => 'Navigate';

  @override
  String get introSemanticSwipeLeft => 'Swipe left to continue';

  @override
  String get introSemanticEnterApp => 'Enter the app';

  @override
  String get appName => 'Pathfinder Albania';

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
  String get eraAntiquity => 'Antiquity';

  @override
  String get eraMiddleAges => 'Middle Ages';

  @override
  String get eraOttoman => 'Ottoman Era';

  @override
  String get eraModern => 'Modern Era';

  @override
  String get yearBCE => 'BCE';

  @override
  String get yearCE => 'CE';

  @override
  String get yearToday => 'today';

  @override
  String yearFormat(Object date, Object era) {
    return '$date $era';
  }

  @override
  String get year => 'Year';

  @override
  String timelineLabelOrigin(Object title) {
    return '$title: the story begins.';
  }

  @override
  String get timelineTitle => 'Albanian Story Timeline';

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
  String get homeSemanticDestination => 'destination';

  @override
  String get butrintTitle => 'Butrint';

  @override
  String get butrintRegionTitle => 'Sarandë, Albania';

  @override
  String get butrintArtifactCulture => 'Illyrian-Roman';

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
  String get butrintVideoCaption => '“Butrint Albania | The ruins of Butrinti Albania.” Visit Albania, YouTube.';

  @override
  String get butrintMapCaption => 'Map showing location of Butrint National Park in southern Albania.';

  @override
  String get butrintHistoryInfo1 =>
      'Butrint is an archaeological site in southern Albania, opposite the Greek island of Corfu. First settled by Greek colonists from Corfu in the 8th century BCE, it grew into an important city of the ancient world. According to legend, the city was founded by Trojan refugees led by Aeneas.\nButrint became a Roman protectorate in 228 BCE, and Julius Caesar later designated it a colony for veterans. Under Roman rule, the city flourished with the construction of an aqueduct, public baths, and a forum.';

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
  String get butrint228bce => 'Butrint becomes a Roman protectorate, together with Corfu.';

  @override
  String get butrint44bce =>
      'Julius Caesar makes Butrint a colony for his veterans; under Augustus the town doubles in size.';

  @override
  String get butrint1386ce => 'Venice buys Corfu and Butrint from the Angevins and keeps Butrint as an outpost.';

  @override
  String get butrint1798ce => 'Ali Pasha of Tepelena takes Butrint from the French.';

  @override
  String get butrint1928ce => 'Italian archaeologist Luigi Maria Ugolini begins the first modern excavations.';

  @override
  String get butrint1992ce => 'Butrint is inscribed on the UNESCO World Heritage List.';

  @override
  String get beratTitle => 'Berat';

  @override
  String get beratRegionTitle => 'Berat, Albania';

  @override
  String get beratArtifactCulture => 'Byzantine-Albanian';

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
  String get beratVideoCaption => '“Berat, Albania - The pride of Albanian architecture.” Visit Albania, YouTube.';

  @override
  String get beratMapCaption => 'Map showing location of Berat in central Albania.';

  @override
  String get beratHistoryInfo1 =>
      'Berat is one of the oldest continuously inhabited cities in Albania, located along the banks of the Osum River. The castle hill has been inhabited since at least the 7th century BCE; in antiquity the fortified town here was known as Antipatrea, a name probably honouring the Macedonian regent Antipater.\nUnder Roman rule, the city served as a strategic military outpost along the Via Egnatia trade route.';

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
  String get berat200bce => 'The Romans storm and burn Antipatrea, the fortified town on Berat\'s hill.';

  @override
  String get berat1417ce => 'Berat becomes part of the Ottoman Empire.';

  @override
  String get berat1547ce =>
      'The icon painter Onufri signs a church fresco dated 23 July 1547; Berat\'s castle museum now bears his name.';

  @override
  String get berat1922ce => 'The Congress of Berat proclaims the autocephaly of the Albanian Orthodox Church.';

  @override
  String get berat1961ce => 'Berat is declared a \"Museum City\", protecting its historic quarters.';

  @override
  String get berat2008ce => 'Berat joins Gjirokastër on the UNESCO World Heritage List.';

  @override
  String get gjirokasterTitle => 'Gjirokastër';

  @override
  String get gjirokasterRegionTitle => 'Gjirokastër, Albania';

  @override
  String get gjirokasterArtifactCulture => 'Ottoman-Albanian';

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
  String get gjirokasterVideoCaption => '“Gjirokaster Albania | Gjirokastra Albania.” Visit Albania, YouTube.';

  @override
  String get gjirokasterMapCaption => 'Map showing location of Gjirokastër in southern Albania.';

  @override
  String get gjirokasterHistoryInfo1 =>
      'Gjirokastër is a city in southern Albania, situated in the Drino River valley. The first fortress on the hilltop dates to the 5th–6th centuries CE. The name Gjirokastër likely derives from the medieval Greek \"Argyrokastron\" meaning \"Silver Castle.\"\nThe city rose to prominence in the 13th century as a center of the Despotate of Epirus and later became an important stronghold contested between Byzantine, Serbian, and Ottoman forces.';

  @override
  String get gjirokasterHistoryInfo2 =>
      'Under Ottoman rule from 1418 onward, Gjirokastër became the center of a large sanjak (administrative district) and thrived as a bazaar city. Wealthy landowners built the distinctive fortified tower houses that define the city\'s character.\nThe city was inscribed as a UNESCO World Heritage Site in 2005 as \"a rare example of a well-preserved Ottoman town, built by farmers of large estates.\" It is the birthplace of both former Albanian dictator Enver Hoxha and Nobel Prize-winning author Ismail Kadare.';

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
  String get gjirokaster1336ce =>
      'Byzantine emperor John VI Kantakouzenos records the town as Argyrokastro, the first mention of its name.';

  @override
  String get gjirokaster1418ce => 'After a siege, the Ottomans take the city from the Zenebishi family.';

  @override
  String get gjirokaster1811ce =>
      'Gjirokastër becomes part of Ali Pasha\'s Pashalik of Yanina; he later enlarges the castle.';

  @override
  String get gjirokaster1932ce => 'King Zog\'s government expands the prison inside the castle.';

  @override
  String get gjirokaster1936ce => 'Writer Ismail Kadare is born in the city.';

  @override
  String get gjirokaster2005ce => 'The historic centre is inscribed on the UNESCO World Heritage List.';

  @override
  String get apolloniaTitle => 'Apollonia';

  @override
  String get apolloniaRegionTitle => 'Fier, Albania';

  @override
  String get apolloniaArtifactCulture => 'Illyrian-Greek';

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
  String get apolloniaVideoCaption => '“Apollonia, Albania by Drone.” Visit Albania, YouTube.';

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
  String get apollonia588bce => 'Greek colonists from Corinth and Corcyra found Apollonia on Illyrian land.';

  @override
  String get apollonia229bce => 'Apollonia comes under the control of the Roman Republic.';

  @override
  String get apollonia148bce => 'Apollonia becomes part of the new Roman province of Macedonia.';

  @override
  String get apollonia44bce => 'Young Octavian, the future Emperor Augustus, is studying in Apollonia.';

  @override
  String get apollonia1272ce => 'The Byzantine Monastery of St. Mary is built within the ruins of the ancient city.';

  @override
  String get apollonia1924ce => 'A French archaeological mission begins systematic excavations, which last until 1938.';

  @override
  String get thethTitle => 'Thethi';

  @override
  String get thethRegionTitle => 'Shkodër, Albania';

  @override
  String get thethArtifactCulture => 'Albanian Highland';

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
  String get thethVideoCaption => '“Theth Albania - Albanian Alps.” Visit Albania, YouTube.';

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
  String get theth1892ce => 'The village church of Theth is built.';

  @override
  String get theth1908ce => 'Edith Durham travels through the highlands and describes Theth in High Albania (1909).';

  @override
  String get theth1966ce => 'Theth National Park is created.';

  @override
  String get theth2011ce => 'The Peaks of the Balkans trail opens, linking Theth with Kosovo and Montenegro.';

  @override
  String get theth2017ce => 'Albanologist Robert Elsie is laid to rest in Theth.';

  @override
  String get theth2022ce => 'Theth becomes part of the new Alps of Albania National Park.';

  @override
  String get krujaTitle => 'Krujë';

  @override
  String get krujaRegionTitle => 'Durrës County, Albania';

  @override
  String get krujaArtifactCulture => 'Medieval Albanian';

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
  String get krujaVideoCaption => '“KRUJA CITY & CASTLE 2021 | 4K DRONE CINEMATIC VIDEO.” GOGLA, YouTube.';

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
  String get kruja1190ce =>
      'Krujë becomes the capital of the Principality of Arbër, the first Albanian state of the Middle Ages.';

  @override
  String get kruja1443ce => 'On 28 November, Skanderbeg takes Krujë and raises the Albanian flag over the castle.';

  @override
  String get kruja1450ce => 'Skanderbeg\'s forces withstand the first Ottoman siege, led by Sultan Murad II.';

  @override
  String get kruja1478ce => 'After a siege of more than a year, Krujë falls to the Ottomans.';

  @override
  String get kruja1982ce => 'The Skanderbeg Museum opens beside the castle.';

  @override
  String get kruja1989ce => 'The National Ethnographic Museum opens in a Toptani family house built in 1764.';

  @override
  String get albanianAlpsTitle => 'Albanian Alps';

  @override
  String get albanianAlpsRegionTitle => 'Northern Albania';

  @override
  String get albanianAlpsArtifactCulture => 'Albanian Highland';

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
  String get albanianAlpsVideoCaption => '“Valbona, Albania.” Visit Albania, YouTube.';

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
      'Human structures in the Albanian Alps reflect the mountain environment. Traditional highland houses (kullë) are built from massive limestone blocks with timber interiors, designed to withstand heavy snowfall and provide defense. Stone-walled pastures, ancient mule trails, and small mountain churches dot the landscape.\nThe Peaks of the Balkans trail, a 120-mile (192 km) hiking route opened in 2011, connects communities across three countries using many of these traditional paths.';

  @override
  String get albanianAlpsLocationInfo1 =>
      'The Albanian Alps extend across the districts of Shkodër and Kukës in northern Albania, forming the country\'s border with Montenegro and Kosovo. The range stretches approximately 40 miles (65 km) from the Kelmendi region in the northwest to the Valbona area in the east. Major valleys include Thethi, Valbona, and Kelmendi.';

  @override
  String get albanianAlpsLocationInfo2 =>
      'The Valbona Valley National Park and Thethi National Park protect much of the Albanian portion of the range. Lake Koman, accessible by ferry through a dramatic canyon often compared to Scandinavian fjords, provides a stunning approach to the mountains from the south. The region receives some of the highest precipitation in Europe, feeding numerous rivers and waterfalls.';

  @override
  String get albanianAlps1909ce =>
      'Edith Durham publishes High Albania, the classic account of life among the highland clans.';

  @override
  String get albanianAlps1929ce =>
      'British climbers make the first recorded ascent of Maja Jezercë (2,694 m), the range\'s highest peak.';

  @override
  String get albanianAlps1996ce => 'Valbona Valley National Park is created.';

  @override
  String get albanianAlps2009ce => 'A glacier is discovered in the Albanian part of the range.';

  @override
  String get albanianAlps2011ce => 'The Peaks of the Balkans trail opens across Albania, Kosovo and Montenegro.';

  @override
  String get albanianAlps2022ce => 'Theth, Valbona and nearby reserves merge into the Alps of Albania National Park.';

  @override
  String get korcaTitle => 'Korçë';

  @override
  String get korcaRegionTitle => 'Korçë, Albania';

  @override
  String get korcaArtifactCulture => 'Albanian Orthodox';

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
  String get korcaVideoCaption => '“Korçë, Dardhë | Dardhe Korce Albania.” Visit Albania, YouTube.';

  @override
  String get korcaMapCaption => 'Map showing location of Korçë in southeastern Albania.';

  @override
  String get korcaHistoryInfo1 =>
      'Korçë is a city in southeastern Albania, situated in a high plateau at approximately 2,800 feet (850 m) above sea level. The city has been a center of Albanian culture, education, and art since the 19th century, earning it the title \"the cradle of Albanian culture.\"\nThe first Albanian-language school was opened here on March 7, 1887, by Pandeli Sotiri, marking a pivotal moment in the Albanian national awakening. Korçë also hosted the first Albanian printing press and numerous literary societies.';

  @override
  String get korcaHistoryInfo2 =>
      'The original Orthodox Cathedral was destroyed during the communist period when Albania declared itself the world\'s first atheist state in 1967, demolishing nearly all religious buildings. The new Resurrection Cathedral (Katedralja Ngjallja e Krishtit) was built between 1994 and 2002 on the foundations of the old cathedral, symbolizing both religious revival and national cultural renewal.\nKorçë is also renowned for its contribution to Albanian music, art, and the famous annual Korçë Beer Festival, one of the largest in the Balkans.';

  @override
  String get korcaConstructionInfo1 =>
      'The Resurrection Cathedral was designed in a neo-Byzantine style, drawing inspiration from traditional Orthodox church architecture while incorporating modern construction techniques. The cathedral features a cruciform plan with a large central dome reaching approximately 100 feet (30 m) in height, flanked by smaller domes.\nThe exterior is clad in light-colored stone with decorative arched windows, while the interior is adorned with frescoes and iconography painted by Albanian and Greek artists.';

  @override
  String get korcaConstructionInfo2 =>
      'The cathedral was built between 1994 and 2002. Modern reinforced concrete and steel frame construction was used for structural integrity, while traditional stone and decorative elements maintain the Byzantine aesthetic.\nThe bell tower, rising beside the cathedral, houses a set of bells that ring across the city. The surrounding plaza and park create a cultural center for the city, connecting to the National Museum of Medieval Art, which houses one of the finest collections of Byzantine icons in the world.';

  @override
  String get korcaLocationInfo1 =>
      'Korçë is located in the Korçë Basin, a fertile plateau surrounded by mountains in southeastern Albania. The city lies approximately 112 miles (180 km) southeast of Tirana, near the borders with both Greece and North Macedonia. The Morava Mountain range rises to the east, while Lake Ohrid lies to the northeast.';

  @override
  String get korcaLocationInfo2 =>
      'The Korçë plateau has been inhabited since prehistoric times due to its fertile soil and strategic position along ancient trade routes connecting the Adriatic and Aegean seas. The nearby archaeological site of Maliq, on the shores of a former lake, has yielded evidence of continuous habitation dating back to the Neolithic period, around 6000 BCE.';

  @override
  String get korca1769ce => 'After nearby Voskopojë is sacked, part of its trade moves to Korçë.';

  @override
  String get korca1887ce => 'The first Albanian-language school, the Mësonjëtorja, opens on 7 March.';

  @override
  String get korca1891ce => 'Sevasti Qiriazi founds the first Albanian school for girls.';

  @override
  String get korca1916ce => 'Under French protection, the Autonomous Albanian Republic of Korçë is proclaimed.';

  @override
  String get korca1968ce => 'The communist regime demolishes the city\'s Orthodox cathedral of St. George.';

  @override
  String get korca1994ce => 'Construction of the Resurrection Cathedral begins; it is consecrated in 2002.';

  @override
  String get timelineEventIllyrianTribes =>
      'Illyrian peoples such as the Taulantii, Ardiaei, Dardani and Enchelei take shape across the western Balkans.';

  @override
  String get timelineEventEpidamnos =>
      'Settlers from Corcyra and Corinth found Epidamnos on Taulantian land. As Dyrrachium, today\'s Durrës, it becomes the great port of the Adriatic coast.';

  @override
  String get timelineEventBardylisDefeatsMacedon =>
      'The Illyrian king Bardylis defeats and kills King Perdiccas III of Macedon. A year later Perdiccas\'s brother, Philip II, strikes back and defeats him.';

  @override
  String get timelineEventAlexanderAtPelion =>
      'At Pelion, in the south-east of today\'s Albania, the young Alexander the Great breaks an alliance of the Illyrian kings Cleitus and Glaukias.';

  @override
  String get timelineEventGlaukiasShieldsPyrrhus =>
      'King Glaukias of the Taulantii shelters the infant Pyrrhus of Epirus and refuses to hand him to his enemies. Years later he helps restore him to the Epirote throne.';

  @override
  String get timelineEventTeutaTakesTheHelm =>
      'After King Agron\'s sudden death, his widow Teuta rules the Ardiaean kingdom for his young son. Her fleets raid the Adriatic and Ionian coasts and sack Phoenice (today\'s Finiq), the richest city of Epirus.';

  @override
  String get timelineEventTeutaDefiesRome =>
      'Rome sends 200 ships against Queen Teuta. The First Illyrian War ends in 228 BCE with Corcyra, Epidamnos and Apollonia under Roman protection.';

  @override
  String get timelineEventGentiusFalls =>
      'In the Third Illyrian War, Rome defeats King Gentius within weeks and captures him at Scodra (Shkodër). His kingdom is broken up into districts under Roman control.';

  @override
  String get timelineEventEpirusSacked =>
      'To punish Epirus for siding with Macedon, Rome sacks 70 of its towns and sells 150,000 people into slavery. The south of today\'s Albania is among the lands hit.';

  @override
  String get timelineEventViaEgnatia =>
      'Rome builds the Via Egnatia, a road from Dyrrachium and Apollonia over the mountains to Thessalonica, later extended to Byzantium.';

  @override
  String get timelineEventCaesarAndPompey =>
      'In Rome\'s civil war, Julius Caesar besieges Pompey at Dyrrachium (Durrës) but is driven off. Weeks later he wins the war at Pharsalus in Greece.';

  @override
  String get timelineEventPaulInIllyricum =>
      'In his letter to the Romans, the apostle Paul writes that he has preached the gospel \'as far as Illyricum\'.';

  @override
  String get timelineEventEmpireSplits =>
      'When Emperor Theodosius I dies, the Roman Empire is split for good. The Albanian lands fall to the eastern half, ruled from Constantinople.';

  @override
  String get timelineEventAnastasiusEmperor =>
      'Anastasius I, born in Dyrrachium (Durrës), becomes Byzantine emperor and later strengthens the walls of his home city.';

  @override
  String get timelineEventButrintBaptistery =>
      'Butrint builds a great baptistery whose mosaic floor of birds, animals and vines is among the finest early Christian mosaics in the Balkans.';

  @override
  String get timelineEventCodexBeratinus =>
      'Scribes copy the Gospels of Matthew and Mark in silver ink on purple parchment. Kept in Berat since at least 1356, the Codex Beratinus is one of the oldest Gospel books in the world.';

  @override
  String get timelineEventBasilReconquers =>
      'Emperor Basil II destroys the Bulgarian state, which had ruled much of the region, and restores Byzantine rule through the Theme of Dyrrachium.';

  @override
  String get timelineEventAlbanoiNamed =>
      'A Byzantine chronicle names \'Albanoi\' among the troops of the rebel general George Maniakes, one of the first written records of the Albanians.';

  @override
  String get timelineEventGreatSchism =>
      'The churches of Rome and Constantinople split. Over time Albanian Christians divide along the same line: Catholic in the north, Orthodox in the south.';

  @override
  String get timelineEventNormansAtDyrrachium =>
      'Robert Guiscard\'s Normans defeat Emperor Alexios I at Dyrrachium, opening a long struggle between Normans, Venetians and Byzantines for the coast.';

  @override
  String get timelineEventArbanon =>
      'Progon, lord of Krujë, founds Arbanon, the first Albanian state of the Middle Ages. His sons Gjin and Dhimitër rule after him.';

  @override
  String get timelineEventRegnumAlbaniae =>
      'Charles of Anjou, king of Sicily, is proclaimed King of Albania (Regnum Albaniae), a Crusader-era state on the coast around Durrës.';

  @override
  String get timelineEventSiegeOfBerat =>
      'An Angevin army besieges Berat, but a Byzantine relief force captures its commander, Hugh of Sully, and the besiegers flee towards Vlorë.';

  @override
  String get timelineEventVoiceInTheMountains =>
      'A court record in Ragusa (Dubrovnik) notes: \'I heard a voice crying in the mountains in the Albanian language.\' It is the earliest known mention of spoken Albanian.';

  @override
  String get timelineEventALanguageOfTheirOwn =>
      'A Dominican report to the French king notes that the Albanians have a language quite unlike Latin, but use Latin letters in their books.';

  @override
  String get timelineEventAlbanianPrincipalities =>
      'Stefan Dušan\'s Serbian Empire, which had conquered most Albanian lands, breaks up after his death. Families such as the Balsha, Thopia, Muzaka, Dukagjini and Kastrioti rule their own principalities.';

  @override
  String get timelineEventBattleOfSavra =>
      'At the Battle of Savra, an Ottoman army defeats and kills Balsha II, lord of Durrës. Many Albanian lords soon become Ottoman vassals.';

  @override
  String get timelineEventBattleOfKosovo =>
      'Albanian lords fight alongside Prince Lazar\'s Serbian army against the Ottomans on the Field of Kosovo. Both Lazar and Sultan Murad I are killed.';

  @override
  String get timelineEventOttomansTakeTheSouth =>
      'Ottoman forces capture Vlorë, Kaninë and Berat. A year later Gjirokastër falls too.';

  @override
  String get timelineEventRevoltOf1432 =>
      'Albanian lords led by Gjergj Arianiti rise against Ottoman rule and win several battles before the revolt is crushed in 1436.';

  @override
  String get timelineEventSkanderbegReturns =>
      'Gjergj Kastrioti, an Ottoman commander known as Skanderbeg, deserts at the Battle of Niš, takes Krujë on 28 November and raises his red flag with the black double-headed eagle.';

  @override
  String get timelineEventLeagueOfLezhe =>
      'Albanian princes unite under Skanderbeg in the League of Lezhë. Months later they win their first great victory, at Torvioll.';

  @override
  String get timelineEventFirstSiegeOfKruja =>
      'Sultan Murad II besieges Krujë for months with a huge army, but the garrison holds out and he withdraws.';

  @override
  String get timelineEventBattleOfAlbulena =>
      'Skanderbeg routs a large Ottoman army at Albulena (Ujëbardha), one of his most celebrated victories.';

  @override
  String get timelineEventBaptismalFormula =>
      'Archbishop Pal Engjëlli writes a baptismal formula in Albanian into a Latin letter: \'Un\'te paghesont\' pr\'emenit t\'Atit e t\'Birit e t\'Spertit Senit.\' It is the oldest known written Albanian sentence.';

  @override
  String get timelineEventMehmedsSieges =>
      'Sultan Mehmed II, conqueror of Constantinople, besieges Krujë twice and builds the fortress of Elbasan to cut Skanderbeg\'s lands in two. Krujë still holds.';

  @override
  String get timelineEventSkanderbegDies =>
      'Skanderbeg dies of fever in Lezhë on 17 January. Without him, the resistance slowly gives way.';

  @override
  String get timelineEventArbereshMigration =>
      'As the Ottomans advance, thousands of Albanians cross to southern Italy and Sicily. Their descendants, the Arbëreshë, still speak Albanian in dozens of villages today.';

  @override
  String get timelineEventShkoderFalls =>
      'After a long siege, Venice hands Shkodër to the Ottomans. Almost all of Albania is now under Ottoman rule; Durrës follows in 1501.';

  @override
  String get timelineEventMeshari =>
      'Gjon Buzuku, a Catholic priest, completes the Meshari (Missal), the oldest surviving book in Albanian. A single copy survives, in the Vatican Library.';

  @override
  String get timelineEventBardhiDictionary =>
      'Frang Bardhi publishes a Latin–Albanian dictionary in Rome, the first dictionary of the Albanian language.';

  @override
  String get timelineEventIslamization =>
      'Over the 17th century most Albanians convert to Islam, often to escape heavy taxes and to rise in Ottoman service. Catholic and Orthodox communities endure.';

  @override
  String get timelineEventCuneusProphetarum =>
      'Archbishop Pjetër Bogdani publishes Cuneus Prophetarum (The Band of the Prophets) in Padua, the first major original work of Albanian prose.';

  @override
  String get timelineEventVoskopojePress =>
      'Voskopojë, a rich trading town near Korçë, opens one of the first printing presses in the Ottoman Balkans. In 1744 it founds the New Academy.';

  @override
  String get timelineEventBushatiPashalik =>
      'Mehmed Pasha Bushati makes Shkodër the seat of a near-independent pashalik that his family rules until 1831.';

  @override
  String get timelineEventAliPashaRises =>
      'Ali Pasha becomes ruler of Ioannina and builds a near-independent state across southern Albania and mainland Greece.';

  @override
  String get timelineEventAliPashaFalls =>
      'After a long siege at Ioannina, the Sultan\'s agents kill the elderly Ali Pasha and send his head to Constantinople.';

  @override
  String get timelineEventMassacreOfTheBeys =>
      'The Ottoman grand vizier invites Albanian beys to Manastir with a promise of amnesty and has some 500 of them killed, breaking the power of the old lords.';

  @override
  String get timelineEventVeqilharxhiPrimer =>
      'Naum Veqilharxhi publishes an Albanian spelling book in an alphabet of his own invention, one of the first works of the National Awakening.';

  @override
  String get timelineEventLeagueOfPrizren =>
      'As the Great Powers prepare to hand Albanian-inhabited lands to Serbia and Montenegro, Albanian leaders meet in Prizren to defend them. It is the first organised national movement; Ottoman troops crush it in 1881.';

  @override
  String get timelineEventIstanbulAlphabet =>
      'Sami Frashëri and fellow patriots found a society in Istanbul to print books in Albanian and publish an alphabet for the language.';

  @override
  String get timelineEventHerdsAndFields =>
      'Naim Frashëri publishes Bagëti e Bujqësi (Herds and Fields), a hymn to the Albanian countryside that becomes the best-loved poem of the Awakening.';

  @override
  String get timelineEventFirstAlbanianSchool =>
      'On 7 March, the Mësonjëtorja opens in Korçë, the first school to teach in Albanian.';

  @override
  String get timelineEventSchoolForGirls =>
      'Sevasti Qiriazi founds the first Albanian school for girls in Korçë, where girls learn to read and write in their own language.';

  @override
  String get timelineEventSamiManifesto =>
      'Sami Frashëri publishes Albania: What It Was, What It Is and What It Will Be, a blueprint for a free Albanian state.';

  @override
  String get timelineEventFirstAlbanianLiturgy =>
      'In Boston, Fan Noli celebrates the first Orthodox liturgy in the Albanian language, the start of an Albanian Orthodox church.';

  @override
  String get timelineEventCongressOfManastir =>
      'The Congress of Manastir adopts the Latin-based Albanian alphabet that is still used today.';

  @override
  String get timelineEventFlagAtDeciq =>
      'During the highland uprising of 1911, Ded Gjo Luli\'s fighters win at Deçiq and raise the Albanian flag, for the first time since the 15th century.';

  @override
  String get timelineEventIndependence =>
      'On 28 November, Ismail Qemali raises the flag in Vlorë and declares Albania independent of the Ottoman Empire.';

  @override
  String get timelineEventLondonBorders =>
      'The Great Powers recognise an independent Albania but leave Kosovo and other Albanian-inhabited lands outside its borders.';

  @override
  String get timelineEventPrinceWied =>
      'Prince Wilhelm of Wied arrives to rule the new Principality of Albania. Within six months, revolt and World War I drive him out.';

  @override
  String get timelineEventRepublicOfKorca =>
      'Under French military protection, Korçë becomes an autonomous Albanian republic with its own schools, stamps and flag.';

  @override
  String get timelineEventCongressOfLushnje =>
      'The Congress of Lushnjë rejects plans to divide Albania among its neighbours and makes Tirana the capital.';

  @override
  String get timelineEventVloraWar =>
      'Albanian volunteers besiege the Italian army in Vlorë, and by September Italy withdraws from mainland Albania. In December, Albania joins the League of Nations.';

  @override
  String get timelineEventOrthodoxAutocephaly =>
      'The Congress of Berat declares the Albanian Orthodox Church autocephalous, independent of the Patriarchate of Constantinople.';

  @override
  String get timelineEventJuneRevolution =>
      'A revolt brings Bishop Fan Noli to power with a programme of reforms. Six months later Ahmet Zogu returns with foreign backing and Noli flees.';

  @override
  String get timelineEventKingZog => 'President Ahmet Zogu proclaims himself Zog I, King of the Albanians.';

  @override
  String get timelineEventBektashiCentre =>
      'Banned in Turkey, the Bektashi Sufi order decides at a congress in Korçë to move its world headquarters to Tirana, where it remains today.';

  @override
  String get timelineEventKanunPublished =>
      'Shtjefën Gjeçovi\'s collection of the Kanun of Lekë Dukagjini, the customary law of the northern highlands, is published in full.';

  @override
  String get timelineEventItalianInvasion =>
      'On 7 April, Mussolini\'s troops land at Durrës and other ports. King Zog flees, and Albania is joined to the Italian crown.';

  @override
  String get timelineEventKokalariBook =>
      'Musine Kokalari publishes As My Old Mother Tells Me, stories in the dialect of Gjirokastër. She is the first Albanian woman to publish prose.';

  @override
  String get timelineEventWarWithGreece =>
      'Italy attacks Greece from Albanian soil. The Greek counter-attack pushes deep into the south, taking Korçë in November and Gjirokastër in December.';

  @override
  String get timelineEventResistanceOrganises =>
      'At the Peza Conference, communists and nationalists form the National Liberation Movement. The rival nationalist Balli Kombëtar is founded later that year.';

  @override
  String get timelineEventGermanOccupation =>
      'Italy surrenders in September and German troops occupy Albania. The rival resistance groups now fight each other as well as the occupiers.';

  @override
  String get timelineEventBesaJews =>
      'Albanian families, Muslim and Christian, hide Jewish refugees from the occupiers, honouring besa, a sacred promise. Albania ends the war with more Jews than it had before.';

  @override
  String get timelineEventGovernmentAtBerat =>
      'Meeting in Berat in October, the communist-led resistance council forms a provisional government with Enver Hoxha as prime minister.';

  @override
  String get timelineEventLiberation =>
      'On 29 November the last German troops leave. The communist-led partisans take power, and Enver Hoxha begins four decades of one-party rule.';

  @override
  String get timelineEventPeoplesRepublic =>
      'Albania is proclaimed a People\'s Republic. Opponents are tried and imprisoned, among them the writer Musine Kokalari.';

  @override
  String get timelineEventCorfuChannel =>
      'Mines in the Corfu Channel badly damage two British destroyers and kill 44 sailors. The dispute becomes the first case judged by the International Court of Justice.';

  @override
  String get timelineEventBreakWithYugoslavia =>
      'When Tito breaks with Stalin, Hoxha cuts ties with Yugoslavia and turns to the Soviet Union.';

  @override
  String get timelineEventBreakWithMoscow =>
      'Albania sides with China against Khrushchev. The Soviet Union breaks off relations and pulls its forces out of the naval base at Vlorë.';

  @override
  String get timelineEventAtheistState =>
      'The regime closes or destroys mosques and churches and declares Albania the world\'s first atheist state.';

  @override
  String get timelineEventBunkers =>
      'Fearing invasion, the regime covers the country with concrete bunkers, some 170,000 of them, built from the late 1960s to the mid-1980s.';

  @override
  String get timelineEventChronicleInStone =>
      'Ismail Kadare publishes Chronicle in Stone, which shows his native Gjirokastër during World War II through the eyes of a boy.';

  @override
  String get timelineEventOrthographicCongress =>
      'The Congress of Orthography fixes a single standard for written Albanian, based mainly on the southern Tosk dialect.';

  @override
  String get timelineEventBreakWithChina =>
      'China ends its aid, and Albania breaks with its last ally, relying only on itself.';

  @override
  String get timelineEventMotherTeresaNobel =>
      'Mother Teresa, born Anjezë Gonxhe Bojaxhiu to an Albanian family in Skopje, receives the Nobel Peace Prize for her work among the poor of Calcutta.';

  @override
  String get timelineEventHoxhaDies =>
      'Enver Hoxha dies on 11 April. His successor, Ramiz Alia, loosens controls only slowly.';

  @override
  String get timelineEventRegimeCracks =>
      'In July, thousands of Albanians rush into foreign embassies to leave the country. In December, student protests in Tirana force the regime to allow opposition parties.';

  @override
  String get timelineEventFaithReturns =>
      'On 4 November, the priest Simon Jubani says the first public Mass in decades, in a cemetery in Shkodër. Within months, mosques and churches reopen across the country.';

  @override
  String get timelineEventFirstFreeElections =>
      'In March, Albania holds its first multi-party elections in decades. The former communists win, but a year later the Democratic Party takes power.';

  @override
  String get timelineEventVloraShip =>
      'On 8 August the freighter Vlora reaches Bari carrying an estimated 20,000 Albanians, the defining image of a mass exodus.';

  @override
  String get timelineEventPyramidCrisis =>
      'The collapse of pyramid investment schemes wipes out the savings of much of the country and sets off armed unrest in which more than 2,000 people die.';

  @override
  String get timelineEventKosovoRefugees =>
      'During the Kosovo war, Albania takes in some 450,000 refugees, most of them in private homes.';

  @override
  String get timelineEventIsoPolyphony =>
      'UNESCO proclaims Albanian folk iso-polyphony, the many-voiced singing of the south, a masterpiece of humanity\'s oral and intangible heritage.';

  @override
  String get timelineEventKadareBooker =>
      'Ismail Kadare wins the first Man Booker International Prize for his body of work.';

  @override
  String get timelineEventNatoMembership =>
      'Albania becomes a member of NATO on 1 April and applies to join the European Union weeks later.';

  @override
  String get timelineEventEuCandidate => 'Albania becomes an official candidate for membership of the European Union.';

  @override
  String get timelineEventDurresEarthquake =>
      'A magnitude 6.4 earthquake strikes near Durrës on 26 November, killing 51 people and leaving thousands homeless.';

  @override
  String get timelineEventEuTalks =>
      'Albania formally opens accession negotiations with the European Union on 19 July.';

  @override
  String get pageNotFoundBackButton => 'Back to civilization';

  @override
  String get pageNotFoundMessage => 'The page you are looking for does not exist.';

  @override
  String get photoGalleryLabelNoPhotos => 'No photos yet';

  @override
  String get artifactCarouselLabelNoArtifacts => 'No artifacts to show';
}
