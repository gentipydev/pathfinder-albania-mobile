// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Albanian (`sq`).
class AppLocalizationsSq extends AppLocalizations {
  AppLocalizationsSq([String locale = 'sq']) : super(locale);

  @override
  String get appName => 'Travel Buddy';

  @override
  String get localeSwapButton => 'English';

  @override
  String animatedArrowSemanticSwipe(Object title) {
    return 'Eksploroni detajet rreth $title.';
  }

  @override
  String get appBarTitleFactsHistory => 'Fakte dhe Histori';

  @override
  String get appBarTitleConstruction => 'Ndërtimi';

  @override
  String get appBarTitleLocation => 'Informacioni i Vendndodhjes';

  @override
  String get bottomScrubberSemanticScrubber => 'rrëshqitës';

  @override
  String get bottomScrubberSemanticTimeline =>
      'Rrëshqitësi i vijës kohore, tërhiqeni horizontalisht për të lundruar në vijën kohore.';

  @override
  String get rangeSelector => 'Zgjedhësi i diapazonit, tërhiqeni horizontalisht për të rregulluar diapazonin.';

  @override
  String collectionLabelDiscovered(Object percentage) {
    return '$percentage% e zbuluar';
  }

  @override
  String collectionLabelCount(Object count, Object total) {
    return '$count nga $total';
  }

  @override
  String get collectionButtonReset => 'Rivendos Koleksionin';

  @override
  String get eventsListButtonOpenGlobal => 'Hap vijën kohore globale';

  @override
  String newlyDiscoveredSemanticNew(Object count, Object suffix) {
    return '$count artikuj$suffix të rinj për të eksploruar. Shkoni te artikulli i ri';
  }

  @override
  String newlyDiscoveredLabelNew(Object count, Object suffix) {
    return '$count artikuj$suffix të rinj për të eksploruar';
  }

  @override
  String get resultsPopupEnglishContent =>
      'Ky përmbajtje ofrohet nga API-ja e Koleksionit të Muzeut Metropolitan të Artit, dhe është e disponueshme vetëm në anglisht.';

  @override
  String get resultsSemanticDismiss => 'hiq mesazhin';

  @override
  String get scrollingContentSemanticYoutube => 'Miniatura e Youtube';

  @override
  String get scrollingContentSemanticOpen => 'Hap pamjen e hartës në ekran të plotë';

  @override
  String get searchInputTitleSuggestions => 'Sugjerime';

  @override
  String get searchInputHintSearch => 'Kërko (p.sh. lloji ose materiali)';

  @override
  String get searchInputSemanticClear => 'pastro kërkimin';

  @override
  String timelineSemanticDate(Object fromDate, Object endDate) {
    return '$fromDate deri $endDate';
  }

  @override
  String titleLabelDate(Object fromDate, Object endDate) {
    return '$fromDate deri $endDate';
  }

  @override
  String get appModalsButtonOk => 'Në rregull';

  @override
  String get appModalsButtonCancel => 'Anulo';

  @override
  String get appPageDefaultTitlePage => 'faqe';

  @override
  String appPageSemanticSwipe(Object pageTitle, Object current, Object total) {
    return '$pageTitle $current nga $total.';
  }

  @override
  String get artifactsTitleArtifacts => 'ARTEFAKTE';

  @override
  String semanticsPrevious(Object title) {
    return '$title i mëparshëm';
  }

  @override
  String semanticsNext(Object title) {
    return '$title tjetër';
  }

  @override
  String get artifactsSemanticsPrevious => 'Artefakti i mëparshëm';

  @override
  String get artifactsSemanticsNext => 'Artefakti tjetër';

  @override
  String get artifactsSemanticArtifact => 'Artefakt';

  @override
  String get artifactDetailsLabelDate => 'Data';

  @override
  String get artifactDetailsLabelPeriod => 'Periudha';

  @override
  String get artifactDetailsLabelGeography => 'Gjeografia';

  @override
  String get artifactDetailsLabelMedium => 'Materiali';

  @override
  String get artifactDetailsLabelDimension => 'Dimensioni';

  @override
  String get artifactDetailsLabelClassification => 'Klasifikimi';

  @override
  String get artifactDetailsSemanticThumbnail => 'imazh miniaturë';

  @override
  String artifactDetailsErrorNotFound(Object artifactId) {
    return 'Nuk u gjet informacion për artefaktin $artifactId';
  }

  @override
  String get circleButtonsSemanticClose => 'mbyll';

  @override
  String get circleButtonsSemanticBack => 'kthehu';

  @override
  String get collectibleFoundTitleArtifactDiscovered => 'Artefakt i Zbuluar';

  @override
  String get collectibleFoundButtonViewCollection => 'shiko në koleksionin tim';

  @override
  String get collectibleItemSemanticCollectible => 'artikull koleksioni';

  @override
  String get collectionTitleCollection => 'Koleksioni';

  @override
  String get collectionPopupResetConfirm => 'Jeni të sigurt që dëshironi të rivendosni koleksionin tuaj?';

  @override
  String get eightWaySemanticSwipeDetector => 'detektor rrëshqitjeje tetëdrejtimësh';

  @override
  String get expandingTimeSelectorSemanticSelector => 'zgjedhës i diapazonit kohor';

  @override
  String get fullscreenImageViewerSemanticFull => 'imazh në ekran të plotë, nuk ka përshkrim të disponueshëm';

  @override
  String get homeMenuButtonExplore => 'Eksploroni vijën kohore';

  @override
  String get homeMenuButtonView => 'Shikoni koleksionin tuaj';

  @override
  String get homeMenuButtonAbout => 'Rreth këtij aplikacioni';

  @override
  String get homeMenuAboutTagline =>
      'Travel Buddy është udhërrëfyesi juaj me inteligjencë artificiale për tetë mrekullitë e Shqipërisë. ';

  @override
  String homeMenuAboutBuilt(Object flutterUrl) {
    return 'Ndërtuar me $flutterUrl.';
  }

  @override
  String homeMenuAboutLearn(Object appUrl) {
    return 'Mësoni më shumë në $appUrl.';
  }

  @override
  String homeMenuAboutSource(Object githubUrl) {
    return 'Për të parë kodin burimor të këtij aplikacioni, vizitoni $githubUrl.';
  }

  @override
  String get homeMenuAboutRepo => 'Depoja e Travel Buddy në github';

  @override
  String get homeMenuAboutFlutter => 'Flutter';

  @override
  String get homeMenuAboutApp => 'travelbuddy.app';

  @override
  String homeMenuAboutPublic(Object metUrl) {
    return 'Vepra arti në pronësi publike nga $metUrl.';
  }

  @override
  String get homeMenuAboutMet => 'Muzeu Metropolitan i Artit, Nju Jork';

  @override
  String homeMenuAboutPhotography(Object unsplashUrl) {
    return 'Fotografi nga $unsplashUrl.';
  }

  @override
  String get homeMenuAboutUnsplash => 'Unsplash';

  @override
  String get introTitleJourney => 'Udhëtim në të kaluarën';

  @override
  String get introDescriptionNavigate => 'Lundroni në kryqëzimin e kohës, artit dhe kulturës.';

  @override
  String get introTitleExplore => 'Eksploroni vende';

  @override
  String get introDescriptionUncover =>
      'Zbuloni struktura të jashtëzakonshme të ndërtuara nga njeriu nga e gjithë bota.';

  @override
  String get introTitleDiscover => 'Zbuloni artefakte';

  @override
  String get introDescriptionLearn => 'Mësoni rreth kulturave përgjatë kohës duke ekzaminuar gjërat që lanë pas.';

  @override
  String get introSemanticNavigate => 'Lundro';

  @override
  String get introSemanticSwipeLeft => 'Rrëshqitni majtas për të vazhduar';

  @override
  String get introSemanticEnterApp => 'Hyni në aplikacion';

  @override
  String get introSemanticAppName => 'Travel Buddy';

  @override
  String get labelledToggleSemanticToggle => 'ndërro';

  @override
  String get photoGallerySemanticCollectible => 'koleksionueshme!';

  @override
  String photoGallerySemanticFocus(Object photoIndex, Object photoTotal) {
    return 'Foto $photoIndex nga $photoTotal. Prekni për fokus.';
  }

  @override
  String photoGallerySemanticFullscreen(Object photoIndex, Object photoTotal) {
    return 'Foto $photoIndex nga $photoTotal. Prekni për pamje në ekran të plotë.';
  }

  @override
  String get eraPrehistory => 'Parahistoria';

  @override
  String get eraClassical => 'Epoka Klasike';

  @override
  String get eraEarlyModern => 'Epoka e Hershme Moderne';

  @override
  String get eraModern => 'Epoka Moderne';

  @override
  String get yearBCE => 'p.e.s.';

  @override
  String get yearCE => 'e.s.';

  @override
  String yearFormat(Object date, Object era) {
    return '$date $era';
  }

  @override
  String get year => 'Viti';

  @override
  String timelineLabelConstruction(Object title) {
    return 'Fillon ndërtimi i $title.';
  }

  @override
  String get timelineTitleGlobalTimeline => 'Vija Kohore Globale';

  @override
  String get wallpaperModalSave => 'Ruani këtë poster në galerinë tuaj të fotove?';

  @override
  String get wallpaperModalSaving => 'Duke ruajtur imazhin. Ju lutem prisni...';

  @override
  String get wallpaperModalSaveComplete => 'Ruajtja u kompletua!';

  @override
  String get wallpaperSemanticSharePhoto => 'ndaj foton';

  @override
  String get wallpaperSemanticTakePhoto => 'bëj foto';

  @override
  String get wallpaperCheckboxShowTitle => 'Shfaq Titullin';

  @override
  String get destinationDetailsTabLabelInformation => 'informacion dhe histori';

  @override
  String get destinationDetailsTabLabelImages => 'galeri fotosh';

  @override
  String get destinationDetailsTabLabelArtifacts => 'artefakte';

  @override
  String get destinationDetailsTabLabelEvents => 'ngjarje';

  @override
  String get destinationDetailsTabSemanticBack => 'kthehu te zgjedhja e destinacionit';

  @override
  String get homeSemanticOpenMain => 'Hap menunë kryesore';

  @override
  String get homeSemanticDestination => 'destinacion';

  @override
  String get butrintTitle => 'Butrinti';

  @override
  String get butrintSubTitle => 'Udhëkryqi i Lashtë';

  @override
  String get butrintRegionTitle => 'Sarandë, Shqipëri';

  @override
  String get butrintArtifactCulture => 'Iliro-Romake';

  @override
  String get butrintArtifactGeolocation => 'Shqipëria Jugore';

  @override
  String get butrintPullQuote1Top => 'Një Mikrokozëm i';

  @override
  String get butrintPullQuote1Bottom => 'Historisë Mesdhetare';

  @override
  String get butrintPullQuote2 =>
      'Butrinti është një dëshmi e pasurisë dhe diversitetit të një peizazhi kulturor të formësuar nga shekuj vendosjesh njerëzore.';

  @override
  String get butrintPullQuote2Author => 'UNESCO';

  @override
  String get butrintCallout1 =>
      'Butrinti ka qenë i banuar që nga të paktën shekulli i 8-të p.e.s. dhe ka shërbyer si koloni greke, qytet romak, peshkopësi bizantine dhe pozitë veneciane.';

  @override
  String get butrintCallout2 =>
      'Teatri antik, i ndërtuar në shekullin e 3-të p.e.s., mund të mbante rreth 1,500 spektatorë dhe është një nga më të ruajturit në rajon.';

  @override
  String get butrintVideoCaption => '“Butrinti - Vendi i Trashëgimisë Botërore të UNESCO-s në Shqipëri.” Youtube.';

  @override
  String get butrintMapCaption => 'Harta që tregon vendndodhjen e Parkut Kombëtar të Butrintit në Shqipërinë jugore.';

  @override
  String get butrintHistoryInfo1 =>
      'Butrinti është një sit arkeologjik në Shqipërinë jugore, përballë ishullit grek të Korfuzit. I vendosur fillimisht nga kolonistët grekë nga Korfuzi në shekullin e 8-të p.e.s., ai u rrit në një qytet të rëndësishëm të botës antike. Sipas legjendës, qyteti u themelua nga refugjatë trojanë të udhëhequr nga Enea.\nRomakët pushtuan Butrintin në vitin 167 p.e.s., dhe Jul Çezari më vonë e caktoi atë si koloni për veteranët. Nën sundimin romak, qyteti lulëzoi me ndërtimin e një akuedukti, banjave publike dhe një forumi.';

  @override
  String get butrintHistoryInfo2 =>
      'Butrinti vazhdoi të lulëzojë si një qendër e rëndësishme kishtare në periudhën bizantine. Një bazilikë e madhe dhe një pagëzimore u ndërtuan në shekullin e 6-të e.s. Vendi ndërroi duart shumë herë — nga bizantinët te anzhuvët, nga venecianët te osmanët — secili duke lënë gjurmën e tij arkitektonike në këtë peizazh të jashtëzakonshëm.';

  @override
  String get butrintConstructionInfo1 =>
      'Teatri antik është gdhendur në shpatin jugor të kodrës së akropolit, duke përfituar nga terreni natyror. I ndërtuar me gur gëlqeror lokal në periudhën helenistike, teatri ka një orkestër gjysmërrethore, ulëse me shkallë (kavea) dhe një ndërtesë skene (skene).\nSanktuari i afërt i Asklepionit, i kushtuar perëndisë së shërimit, ka relieve guri të punuara bukur dhe kolona në stilin korintian.';

  @override
  String get butrintConstructionInfo2 =>
      'Pagëzimorja e shekullit të 6-të është një nga strukturat më të mëdha të krishterimit të hershëm në Ballkan. Dyshemeja e saj është e zbukuruar me mozaikë të ndërlikuara që paraqesin kafshë dhe modele gjeometrike, duke treguar sofistikimin artistik të epokës. Struktura përdor një plan rrethor me 16 kolona graniti që mbajnë brendësinë.';

  @override
  String get butrintLocationInfo1 =>
      'Butrinti ndodhet në një gadishull midis Kanalit të Vivarit dhe Liqenit të Butrintit në zonën e Ksamilit në Shqipërinë jugore, rreth 23 km (14 milje) në jug të Sarandës. Vendi ndodhet brenda një parku kombëtar që përfshin zona ligatinore, pyje dhe vetë liqenin.';

  @override
  String get butrintLocationInfo2 =>
      'Pozicioni strategjik i Butrintit, në një ngushticë midis tokës kryesore dhe Korfuzit, e bëri atë një ndalesë të rëndësishme përgjatë rrugëve tregtare antike të Mesdheut. Peizazhi përreth i moçaleve, lagunave dhe bregdetit të Detit Jon ka qenë vendimtar për historinë e vendit si pozicion mbrojtës ashtu edhe si port i lulëzuar.';

  @override
  String get butrint600ce =>
      'Kolonistët grekë nga Korfuzi vendosin një vendbanim në Butrint, i cili rritet në një pikë tregtare të rëndësishme';

  @override
  String get butrint832ce =>
      'Butrinti shërben si një qendër e madhe kishtare bizantine me ndërtimin e Bazilikës së Madhe';

  @override
  String get butrint998ce =>
      'Qyteti bie nën fuqi të ndryshme rajonale ndërsa kontrolli i Perandorisë Bizantine dobësohet';

  @override
  String get butrint1100ce =>
      'Normanët dhe anzhuvët kontestojnë kontrollin e Butrintit si pjesë e konflikteve më të gjera mesdhetare';

  @override
  String get butrint1527ce =>
      'Republika e Venedikut forcon Butrintin, duke ndërtuar një kështjellë dhe kullë për t\'u mbrojtuar kundër zgjerimit osman';

  @override
  String get butrint1535ce =>
      'Forcat osmane marrin kontrollin e rajonit më të gjerë, dhe Butrinti gradualisht bie si vendbanim';

  @override
  String get butrintCollectible1Title => 'Varëse';

  @override
  String get butrintCollectible1Icon => 'jewelry';

  @override
  String get butrintCollectible2Title => 'Ornament Zogu';

  @override
  String get butrintCollectible2Icon => 'jewelry';

  @override
  String get butrintCollectible3Title => 'Vue de Buthrotum';

  @override
  String get butrintCollectible3Icon => 'picture';

  @override
  String get beratTitle => 'Berati';

  @override
  String get beratSubTitle => 'Qyteti i Një Mijë Dritareve';

  @override
  String get beratRegionTitle => 'Berat, Shqipëri';

  @override
  String get beratArtifactGeolocation => 'Shqipëria Qendrore';

  @override
  String get beratPullQuote1Top => 'Një Shembull i Rrallë i';

  @override
  String get beratPullQuote1Bottom => 'Arkitekturës Osmane të Ruajtur Mirë';

  @override
  String get beratPullQuote2 =>
      'Berati dëshmon bashkëjetesën e komuniteteve të ndryshme fetare dhe kulturore përgjatë shekujve.';

  @override
  String get beratPullQuote2Author => 'UNESCO';

  @override
  String get beratCallout1 =>
      'Berati njihet për shtëpitë e tij të dallueshme të bardha osmane që ngjiten përgjatë kodrës, me dritaret e shumta që i japin qytetit epitetin e tij të famshëm.';

  @override
  String get beratCallout2 =>
      'Lagja e kështjellës (Kalaja) ka qenë e banuar vazhdimisht për mbi 2,400 vjet dhe ende strehon një komunitet të gjallë brenda mureve të saj të shekullit të 13-të.';

  @override
  String get beratVideoCaption => '“Berati - Qyteti i Një Mijë Dritareve, Shqipëri.” Youtube.';

  @override
  String get beratMapCaption => 'Harta që tregon vendndodhjen e Beratit në Shqipërinë qendrore.';

  @override
  String get beratHistoryInfo1 =>
      'Berati është një nga qytetet më të vjetra të banuara vazhdimisht në Shqipëri, i vendosur përgjatë brigjeve të Lumit Osum. Kështjella në majë të kodrës ka qenë e banuar që nga shekulli i 4-të p.e.s., kur ishte një vendbanim i rëndësishëm ilir i njohur si Antipatrea, i themeluar nga mbreti ilir Antipater.\nNën sundimin romak, qyteti shërbeu si një bazë ushtarake strategjike përgjatë rrugës tregtare Via Egnatia.';

  @override
  String get beratHistoryInfo2 =>
      'Gjatë periudhës bizantine, qyteti u njoh si Pulcheriopolis dhe më vonë Beligrad. Osmanët pushtuan Beratin në 1417 dhe ai u bë një qendër e madhe tregtie dhe zejtarie.\nTre lagjet historike të qytetit — Mangalemi, Gorica dhe Kalaja — ruajnë një përzierje të jashtëzakonshme të arkitekturës lindore dhe perëndimore, duke i fituar statusin e Trashëgimisë Botërore të UNESCO-s në 2008 si pjesë e \"Qendrave Historike të Beratit dhe Gjirokastrës.\"';

  @override
  String get beratConstructionInfo1 =>
      'Kështjella e Beratit ndodhet në 187 m (614 këmbë) mbi nivelin e detit mbi një kodër shkëmbore. Muret aktuale datojnë kryesisht nga shekulli i 13-të nën Despotatin e Epirit, megjithëse themelet janë shumë më të vjetra. Fortesa përfshin një sipërfaqe prej rreth 10 hektarësh (24 akra) dhe fillimisht kishte 24 kulla përgjatë mureve.\nBreda mureve të kështjellës, disa kisha bizantine mbijetojnë, përfshirë Kishën e Shën Trinisë dhe Kishën e Shën Mërisë së Vllahernës, me afreske të jashtëzakonshme të shekullit të 16-të nga piktori i shquar Onufri.';

  @override
  String get beratConstructionInfo2 =>
      'Lagja e Mangalemit poshtë kështjellës është e famshme për shtëpitë e saj të epokës osmane të ndërtuara në shpatin e pjerrët. Këto shtëpi tradicionale kanë themele guri, kate të sipërme me skelet druri, dhe dritare të mëdha të rregulluara simetrikisht në fasada të bardha — firma arkitektonike që i jep Beratit emrin \"Qyteti i Një Mijë Dritareve.\"';

  @override
  String get beratLocationInfo1 =>
      'Berati ndodhet në Shqipërinë jug-qendrore, rreth 120 km (75 milje) në jug të kryeqytetit Tiranë. Qyteti është ndërtuar përgjatë dy brigjeve të Lumit Osum, në këmbët e Malit Tomorr, një nga malet më të shenjta të Shqipërisë që arrin 2,416 m (8,042 këmbë).';

  @override
  String get beratLocationInfo2 =>
      'Kanioni i Lumit Osum, që shtrihet në juglindje të qytetit, është një nga tiparet natyrore më dramatike në Shqipëri, me mure kanjoni vertikale që arrijnë mbi 80 m (260 këmbë). Rajoni përreth është kultivuar që nga antikiteti, duke prodhuar ullinj, rrush dhe fiq në klimën e butë me ndikim mesdhetar.';

  @override
  String get berat1850ce =>
      'Berati përjeton një rilindje kulturore nën reformat osmane të Tanzimatit, me ndërtimin e shkollave dhe ndërtesave të reja qytetare';

  @override
  String get berat1921ce =>
      'Pas pavarësisë shqiptare, Berati bëhet një qendër e rëndësishme administrative e shtetit të ri shqiptar';

  @override
  String get berat1922ce =>
      'Shkollat e para moderne në gjuhën shqipe krijohen në Berat, duke avancuar lëvizjen e arsimit kombëtar';

  @override
  String get berat1926ce =>
      'Studimet arkeologjike fillojnë dokumentimin e arkitekturës historike të kështjellës së Beratit dhe lagjeve osmane';

  @override
  String get berat1931ce =>
      'Puna e restaurimit fillon në muret e kështjellës dhe kishat bizantine brenda lagjes së Kalasë';

  @override
  String get berat2006ce =>
      'Qendra historike e Beratit merr njohje paraprake që çon në regjistrimin e saj në UNESCO në 2008';

  @override
  String get beratCollectible1Title => 'Bri i Gdhendur';

  @override
  String get beratCollectible1Icon => 'statue';

  @override
  String get beratCollectible2Title => 'Frerë e fiksuar';

  @override
  String get beratCollectible2Icon => 'jewelry';

  @override
  String get beratCollectible3Title => 'Shami dore (një nga dy)';

  @override
  String get beratCollectible3Icon => 'textile';

  @override
  String get gjirokasterTitle => 'Gjirokastra';

  @override
  String get gjirokasterSubTitle => 'Qyteti i Gurit';

  @override
  String get gjirokasterRegionTitle => 'Gjirokastër, Shqipëri';

  @override
  String get gjirokasterArtifactCulture => 'Osmano-Shqiptare';

  @override
  String get gjirokasterArtifactGeolocation => 'Shqipëria Jugore';

  @override
  String get gjirokasterPullQuote1Top => 'Një Shembull i Rrallë i';

  @override
  String get gjirokasterPullQuote1Bottom => 'një Qyteti Osman të Ruajtur Mirë';

  @override
  String get gjirokasterPullQuote2 =>
      'Gjirokastra është një shembull i shquar i një qyteti osman të ruajtur mirë, i ndërtuar nga fermerë të pronave të mëdha.';

  @override
  String get gjirokasterPullQuote2Author => 'UNESCO';

  @override
  String get gjirokasterCallout1 =>
      'Kalaja e Gjirokastrës është një nga më të mëdhatë në Ballkan, duke dominuar qytetin nga maja e kodrës në mbi 336 m (1,100 këmbë) mbi nivelin e detit.';

  @override
  String get gjirokasterCallout2 =>
      'Shtëpitë karakteristike kullë të qytetit, të njohura si \"kullë,\" kanë çati me pllaka guri dhe arkitekturë të forcuar unike për rajonin, duke i dhënë Gjirokastrës emrin \"Qyteti i Gurit.\"';

  @override
  String get gjirokasterVideoCaption =>
      '“Gjirokastra - Qyteti i Gurit i Shqipërisë, Trashëgimi Botërore e UNESCO-s.” Youtube.';

  @override
  String get gjirokasterMapCaption => 'Harta që tregon vendndodhjen e Gjirokastrës në Shqipërinë jugore.';

  @override
  String get gjirokasterHistoryInfo1 =>
      'Gjirokastra është një qytet në Shqipërinë jugore, i vendosur në luginën e Lumit Drino. Zona ka qenë e banuar që nga të paktën shekulli i 1-rë e.s., dhe një fortesë ka qëndruar në majë të kodrës që nga shekulli i 3-të. Emri Gjirokastër ka të ngjarë të rrjedh nga greqishtja mesjetare \"Argyrokastron\" që do të thotë \"Kështjella e Argjenditë.\"\nQyteti u ngrit në rëndësi në shekullin e 13-të si qendër e Despotëtit të Epirit dhe më vonë u bë një kala e rëndësishme e kontestuar midis forcave bizantine, serbe dhe osmane.';

  @override
  String get gjirokasterHistoryInfo2 =>
      'Nën sundimin osman nga 1417 e tutje, Gjirokastra u bë qendra e një sanxhaku të madh (njësi administrative) dhe lulëzoi si qytet pazar. Pronarët e pasur të tokës ndërtuan shtëpitë e dallueshme kullë të forcuara që përcaktojnë karakterin e qytetit.\nQyteti u regjistrua si Vend i Trashëgimisë Botërore të UNESCO-s në 2005 si \"një shembull i rrallë i një qyteti osman të ruajtur mirë, i ndërtuar nga fermerë të pronave të mëdha.\" Është vendlindja e ish-diktatorit shqiptar Enver Hoxha dhe autorit fitues të Çmimit Nobel, Ismail Kadare.';

  @override
  String get gjirokasterConstructionInfo1 =>
      'Kalaja e Gjirokastrës mbulon një sipërfaqe prej rreth 7.3 hektarësh (18 akra) në majë të kodrës. E zgjeruar ndjeshëm nga Ali Pashë Tepelena në fillim të shekullit të 19-të, kalaja ka mure masive guri, një kullë sahati, një akuadukt dhe një seri tunelesh dhe dhomash nëntokësore.\nGjatë epokës komuniste, kalaja u përdor si burg dhe më vonë u kthye në Muzeu të Armëve. Sot ajo pret Festivalin Kombëtar Folklorik të Gjirokastrës çdo pesë vjet.';

  @override
  String get gjirokasterConstructionInfo2 =>
      'Shtëpitë ikonike kullë të qytetit janë zakonisht tre deri katër kate, të ndërtuara nga guri i fortë me çati prej pllakash. Kati përdhesë shërbente si cisternë dhe magazinë, kati i parë për jetesë dimërore, dhe katet e sipërme për banimin veror dhe pritjen e mysafirëve. Tiparet mbrojtëse përfshijnë dritare të vogla në katet e ulëta dhe hyrje të forcuara.';

  @override
  String get gjirokasterLocationInfo1 =>
      'Gjirokastra ndodhet në luginën e Lumit Drino në Shqipërinë jugore, rreth 29 km (18 milje) nga kufiri grek. Qyteti është ndërtuar në shpatat e pjerrëta të vargmalit Mali i Gjerë, duke u ngritur nga fundit i luginës në rreth 300 m (980 këmbë) deri te kalaja në mbi 336 m (1,100 këmbë).';

  @override
  String get gjirokasterLocationInfo2 =>
      'Rajoni përreth, i njohur si Dropulli, ka qenë një udhëkryq kulturash për mijëvjeçarë. Lugina e Drinit lidh bregdetin adriatik me Ballkanin e brendshëm, dhe rruga antike nga bregdeti në Butrint kalonte nëpër këtë luginë drejt Via Egnatia-s.';

  @override
  String get gjirokaster70ce =>
      'Vendbanimi i hershëm i epokës romake ekziston në rajonin e Luginës së Drinit, me fortime në majë të kodrës që më vonë do të bëhej Gjirokastra';

  @override
  String get gjirokaster82ce =>
      'Fortesa në majë të kodrës zgjerohet si pozicion mbrojtës strategjik që ruante rrugët tregtare të Luginës së Drinit';

  @override
  String get gjirokaster1140ce =>
      'Argyrokastron shfaqet si vendbanim i rëndësishëm bizantin dhe kontestohet gjatë pushtimeve normane të Ballkanit';

  @override
  String get gjirokaster1490ce =>
      'Nën sundimin osman, Gjirokastra zhvillohet në një qytet pazar të lulëzuar me ndërtimin e Pazarit të Vjetër dhe shtëpive të para kullë';

  @override
  String get gjirokaster1829ce =>
      'Ali Pashë Tepelena ndërmerr zgjerimin e madh të kalasë, duke shtuar fortime, akuadukt dhe kullë sahati';

  @override
  String get gjirokaster1990ce =>
      'Pas rënies së komunizmit, fillojnë përpjekjet e restaurimit dhe Gjirokastra merr statusin e Trashëgimisë Botërore të UNESCO-s në 2005';

  @override
  String get gjirokasterCollectible1Title => 'Amforiskos gjashtëkëndësh qelqi';

  @override
  String get gjirokasterCollectible1Icon => 'vase';

  @override
  String get gjirokasterCollectible2Title => 'Pllakë bronzi e Mitrës duke vrarë demin';

  @override
  String get gjirokasterCollectible2Icon => 'statue';

  @override
  String get gjirokasterCollectible3Title => 'Veduta di Argirocastro';

  @override
  String get gjirokasterCollectible3Icon => 'picture';

  @override
  String get apolloniaTitle => 'Apolonia';

  @override
  String get apolloniaSubTitle => 'Qyteti i Lashtë i Dijes';

  @override
  String get apolloniaRegionTitle => 'Fier, Shqipëri';

  @override
  String get apolloniaArtifactCulture => 'Iliro-Greke';

  @override
  String get apolloniaArtifactGeolocation => 'Shqipëria Qendrore';

  @override
  String get apolloniaPullQuote1Top => 'Një Qytet i Admirueshëm';

  @override
  String get apolloniaPullQuote1Bottom => 'Me Ligje të Shkëlqyera';

  @override
  String get apolloniaPullQuote2 =>
      'Apolonia konsiderohet një nga qytetet më të rëndësishme të botës antike, një qendër dijeje ku studioi i riu Oktavian.';

  @override
  String get apolloniaPullQuote2Author => 'Straboni';

  @override
  String get apolloniaCallout1 =>
      'Shtëtari dhe oratori romak Ciceroni e përshkroi Apoloninë si \"një qytet i madh dhe i rëndësishëm\" (magna urbs et gravis) në veprën e tij Filipikat.';

  @override
  String get apolloniaCallout2 =>
      'I riu Oktavian (më vonë Perandori August) po studionte në Apoloni kur mori lajmin e vrasjes së Jul Çezarit në 44 p.e.s., një moment vendimtar në historinë romake.';

  @override
  String get apolloniaVideoCaption => '“Parku Arkeologjik i Apolonisë - Shqipëria Antike.” Youtube.';

  @override
  String get apolloniaMapCaption => 'Harta që tregon vendndodhjen e Apolonisë pranë Fierit në Shqipërinë qendrore.';

  @override
  String get apolloniaHistoryInfo1 =>
      'Apolonia ishte një koloni e lashtë greke e themeluar në 588 p.e.s. nga vendosës nga Korinti dhe Korkira (Korfuzi modern) në brigjet e Lumit Aous (Vjosa moderne) në Iliri. E emëruar sipas perëndisë Apoloni, qyteti u rrit shpejt në një nga vendbanimet më të rëndësishme në bregdetin lindor të Adriatikut.\nNë kulmin e saj, Apolonia kishte një popullsi prej rreth 60,000 dhe ishte një ndalesë kryesore përgjatë Via Egnatia-s, rrugës së madhe romake që lidhte Adriatikun me Kostandinopojën.';

  @override
  String get apolloniaHistoryInfo2 =>
      'Qyteti ishte i njohur si qendër e filozofisë dhe dijes. Shumë fisnikë romakë dërgonin bijtë e tyre për të studiuar atje, më i njohuri Oktaviani, i ardhshmi Perandor August. Rëndësia e Apolonisë ra pas shekullit të 3-të e.s. kur një tërmet ndryshoi rrjedhën e Lumit Vjosa, duke shkatërruar portin e qytetit dhe duke prerë rrugët e tij tregtare.\nVendi u ndërtua pjesërisht mbi nga Manastiri bizantin i Shën Mërisë, i cili ende qëndron dhe strehon një muze arkeologjik.';

  @override
  String get apolloniaConstructionInfo1 =>
      'Parku arkeologjik mbulon rreth 96 hektarë (237 akra), megjithëse vetëm një fraksion është gërmuar. Strukturat kryesore përfshijnë një bouleuterion monumental (shtëpi këshilli) me 19 rreshta ulësesh guri, një stoa mbresëlënëse (korridor i mbuluar) që mat mbi 80 m (260 këmbë) në gjatësi, dhe një odeon të ruajtur mirë (teatër i vogël).\nMbetjet e një nimfeumi (shatërvani dekorativ) dhe disa tempujsh tregojnë pasurinë dhe sofistikimin arkitektonik të qytetit.';

  @override
  String get apolloniaConstructionInfo2 =>
      'Qyteti u ndërtua duke përdorur gur gëlqeror të gërmuar lokalisht dhe ndoqi planifikimin urban klasik grek me një agorë, tempuj dhe ndërtesa publike të rregulluara përgjatë rrugëve të shtruara. Muret mbrojtëse, që rrethonin rreth 2.5 km katrore (1 milje katrore), u ndërtuan me muraturë poligonale tipike e arkitekturës ushtarake helenistike.\nManastiri i shekullit të 13-të i Shën Mërisë, i ndërtuar mbi rrënojat antike brenda zonës arkeologjike, ka një kishë bizantine të zbukuruar bukur me fasada guri të gdhendura.';

  @override
  String get apolloniaLocationInfo1 =>
      'Apolonia ndodhet në një kodër pranë fshatit Pojanë, rreth 12 km (7 milje) në perëndim të qytetit të Fierit në Shqipërinë qendrore. Vendi ka pamje mbi fushën e Myzeqesë dhe luginën e Lumit Vjosa, me pamje që shtrihen deri te Deti Adriatik.';

  @override
  String get apolloniaLocationInfo2 =>
      'Në antikitet, Lumi Vjosa rrinte shumë më pranë qytetit, duke siguruar qasje të drejtpërdrejtë në bregdetin adriatik dhe duke mundësuar që Apolonia të funksiononte si një qytet i rëndësishëm portual. Fusha pjellore përreth mbështeste prodhimin bujqësor, ndërsa pozicioni në kodër ofronte avantazhe natyrore mbrojtëse.';

  @override
  String get apollonia700bce =>
      'Kolonistët grekë nga Korinti dhe Korkira themelojnë Apoloninë në 588 p.e.s. në territorin ilir, duke vendosur një vendbanim që do të rritet në një qytet të madh';

  @override
  String get apollonia214bce =>
      'Apolonia bëhet një aleate kyçe romake gjatë Luftërave Ilire dhe shërben si bazë për fushatat ushtarake romake në Mesdheun lindor';

  @override
  String get apollonia121bce =>
      'Qyteti lulëzon si qendër tregtie përgjatë Via Egnatia-s, duke lidhur Romën me provincat e saj lindore';

  @override
  String get apollonia556ce =>
      'Një tërmet ndryshon rrjedhën e Lumit Vjosa, duke shkatërruar portin e Apolonisë dhe duke filluar rënien e pakthyeshme të qytetit';

  @override
  String get apollonia618ce =>
      'Mbetjet e qytetit shërbejnë si guroré për materiale ndërtimi; Manastiri Bizantin i Shën Mërisë ndërtohet brenda mureve antike';

  @override
  String get apollonia1487ce =>
      'Vendi mbetet kryesisht i harruar dhe i mbuluar nga bimësia derisa gërmimet sistematike arkeologjike fillojnë nën arkeologët austriakë dhe më vonë francezë në fillim të shekullit të 20-të';

  @override
  String get apolloniaCollectible1Title => 'Biografitë e Lian Po-s dhe Lin Xiangru-s';

  @override
  String get apolloniaCollectible1Icon => 'scroll';

  @override
  String get apolloniaCollectible2Title => 'Vazo me Dragua';

  @override
  String get apolloniaCollectible2Icon => 'vase';

  @override
  String get apolloniaCollectible3Title => 'Panel me Peoni dhe Flutur';

  @override
  String get apolloniaCollectible3Icon => 'textile';

  @override
  String get thethTitle => 'Thethi';

  @override
  String get thethSubTitle => 'Streha Alpine';

  @override
  String get thethRegionTitle => 'Shkodër, Shqipëri';

  @override
  String get thethArtifactCulture => 'Malësia Shqiptare';

  @override
  String get thethArtifactGeolocation => 'Shqipëria Veriore';

  @override
  String get thethPullQuote1Top => 'Një Fragment i Gjallë i';

  @override
  String get thethPullQuote1Bottom => 'Natyrës së Fundit të Virgjër të Evropës';

  @override
  String get thethPullQuote1Author => 'Edith Durham';

  @override
  String get thethPullQuote2 =>
      'Alpet Shqiptare janë ndoshta natyra e fundit e madhe e virgjër në Evropë, një vend ku koha duket se ka ndalur.';

  @override
  String get thethPullQuote2Author => 'Edith Durham';

  @override
  String get thethCallout1 =>
      'Kulla ikonike e Ngujimit të Thethit u përdor si strehë për burrat e përfshirë në gjakmarrje sipas Kanunit të Lëkë Dukagjinit, kodit tradicional shqiptar të ligjit.';

  @override
  String get thethCallout2 =>
      'Lugina e Thethit ndodhet në rreth 760 m (2,500 këmbë) mbi nivelin e detit, e rrethuar nga maja që tejkalojnë 2,500 m (8,000 këmbë), përfshirë masivin dramatik të Radohimës.';

  @override
  String get thethVideoCaption => '“Parku Kombëtar i Thethit - Parajsa e Fshehur Alpine e Shqipërisë.” Youtube.';

  @override
  String get thethMapCaption => 'Harta që tregon vendndodhjen e Thethit në Alpet Shqiptare, Shqipëria veriore.';

  @override
  String get thethHistoryInfo1 =>
      'Thethi është një fshat i largët alpín i vendosur në një luginë akullnajore në Alpet Shqiptare (Bjeshkët e Nemuna), në rrethin e Shkodrës në Shqipërinë veriore. Lugina ka qenë e banuar për shekuj nga fiset malësore shqiptare, të cilët mbanin një mënyrë jetese ferocisht të pavarur të qeverisur nga Kanuni, një tërësi ligjesh zakonore të atribuara Lëkë Dukagjinit.\nIzolimi i luginës — e aksesueshme vetëm nëpërmjet kalimeve malore për shumicën e historisë së saj — ruajti një mënyrë jetese tradicionale kryesisht të pandryshuar deri në shekullin e 20-të.';

  @override
  String get thethHistoryInfo2 =>
      'Gjatë periudhës komuniste (1944-1991), qeveria shqiptare u përpoq të modernizonte malësinë, duke ndërtuar rrugë dhe shkolla por edhe duke kufizuar zakonet tradicionale. Pas rënies së komunizmit, shumë fshatra malësore u zbrazën pasi banorët u zhvendosën në qytetet e ultësirës.\nNë vitet e fundit, Thethi ka përjetuar një ringjallje si destinacion për ecje në natyrë dhe ekoturizëm, me shtegun e Majave të Ballkanit duke sjellë vëmendje ndërkombëtare në bukurinë natyrore dhe trashëgiminë kulturore të rajonit.';

  @override
  String get thethConstructionInfo1 =>
      'Shtëpitë tradicionale prej guri të Thethit (shtëpi) janë ndërtuara nga guri gëlqeror lokal dhe lëndë druri, të dizajnuara për t\'i rezistuar dimrave të ashpër malor. Shtëpitë zakonisht kanë mure të trasha guri, dritare të vogla për të ruajtur ngrohtësinë, dhe ballkone druri. Çatitë me pllaka guri, të fiksuara me gurë të rëndë, mbrojnë nga bora e rëndë që mbulon luginën për disa muaj çdo vit.\nStruktura më e famshme në Theth është Kulla e Ngujimit, një kullë guri e përdorur historikisht si vend strehimi për burrat e shënuar nga gjakmarrja.';

  @override
  String get thethConstructionInfo2 =>
      'Kisha e Thethit (Kisha e Thethit), e ndërtuar në shekullin e 19-të, është një kishë e vogël por pittoreske prej guri e vendosur përballë sfondit dramatik malor. Arkitektura tradicionale malësore në të gjithë luginën përfshin mullinj uji përgjatë Lumit të Thethit, ura guri, dhe vathë bagëtish të ndërtuara me teknika murature guri të thatë të trashëguara brez pas brezi.';

  @override
  String get thethLocationInfo1 =>
      'Thethi ndodhet brenda Parkut Kombëtar të Thethit, të krijuar në 1966, duke mbuluar rreth 2,100 hektarë (5,200 akra) natyrë të virgjër alpine. Lugina është e rrethuar nga majat e Alpeve Shqiptare, përfshirë Radohimën në 2,568 m (8,146 këmbë) dhe Haj-Nehajn në 2,598 m (8,524 këmbë).';

  @override
  String get thethLocationInfo2 =>
      'Syri i Kaltër i Thethit, një pellg natyror burimi me ujë të kaltërt të gjallë turkuaz, është një nga tiparet natyrore më të jashtëzakonshme të luginës. Ujëvara e Grunasit, që bie 30 m (100 këmbë) poshtë një shkëmbi gëlqeror, është një tjetër pikë referimi ikonike. Lugina lidhet me Valbonën nëpërmjet një shtegu të njohur kalimi malor në rreth 1,800 m (5,900 këmbë).';

  @override
  String get theth1438ce =>
      'Fiset malësore shqiptare janë vendosur mirë në luginën e Thethit, të qeverisur nga Kanuni i Lëkë Dukagjinit';

  @override
  String get theth1572ce =>
      'Komunitetet malësore i rezistojnë kontrollit osman, duke ruajtur autonominë nëpërmjet terrenit të ashpër të Alpeve Shqiptare';

  @override
  String get theth1867ce =>
      'Udhëtarja dhe diplomtja britanike Edith Durham viziton malësinë shqiptare, duke dokumentuar më vonë mënyrën tradicionale të jetesës në shkrimet e saj të çmuara';

  @override
  String get theth1911ce =>
      'Shqipëria shpall pavarësinë në 1912; rajonet malësore luajnë një rol vendimtar në zgjimin kombëtar dhe lëvizjet e rezistencës';

  @override
  String get theth1964ce =>
      'Parku Kombëtar i Thethit krijohet në 1966, një nga zonat e para të mbrojtuar të Shqipërisë, duke ruajtur ekosistemin alpin';

  @override
  String get theth1997ce =>
      'Shtegu i Majave të Ballkanit inaugurohet, duke lidhur Shqipërinë, Kosovën dhe Malin e Zi dhe duke sjellë vëmendje të ripërtëritur ndërkombëtare në Theth';

  @override
  String get thethCollectible1Title => 'Tunika me Yll Tetëcepësh';

  @override
  String get thethCollectible1Icon => 'textile';

  @override
  String get thethCollectible2Title => 'Figurinë kamelide';

  @override
  String get thethCollectible2Icon => 'statue';

  @override
  String get thethCollectible3Title => 'Tas i Dyfishtë';

  @override
  String get thethCollectible3Icon => 'vase';

  @override
  String get krujaTitle => 'Kruja';

  @override
  String get krujaSubTitle => 'Kalaja e Skënderbeut';

  @override
  String get krujaRegionTitle => 'Qarku i Durrësit, Shqipëri';

  @override
  String get krujaArtifactCulture => 'Mesjetare Shqiptare';

  @override
  String get krujaArtifactGeolocation => 'Shqipëria Qendrore';

  @override
  String get krujaPullQuote1Top => 'Mburoja e Krishterimit';

  @override
  String get krujaPullQuote1Bottom => 'Kundër Valës Osmane';

  @override
  String get krujaPullQuote1Author => 'Papa Kaliksti III';

  @override
  String get krujaPullQuote2 =>
      'Mbrojtja e Krujës nga Skënderbeu është një nga episodet më të jashtëzakonshme të rezistencës në historinë ushtarake evropiane.';

  @override
  String get krujaPullQuote2Author => 'Fan Noli';

  @override
  String get krujaCallout1 =>
      'Gjergj Kastrioti Skënderbeu mbrojti me sukses Krujën kundër tre rrethimeve të mëdha osmane, duke fituar titullin \"Athleta Christi\" (Kampioni i Krishtit) nga Papa.';

  @override
  String get krujaCallout2 =>
      'Kalaja ndodhet në një lartësi prej rreth 600 m (1,970 këmbë) në majë të Malit të Skënderbeut (Mali i Sariut), duke ofruar një pamje komanduese mbi fushat përreth.';

  @override
  String get krujaVideoCaption => '“Kalaja e Krujës dhe Trashëgimia e Skënderbeut - Shqipëri.” Youtube.';

  @override
  String get krujaMapCaption => 'Harta që tregon vendndodhjen e Krujës në Shqipërinë qendrore.';

  @override
  String get krujaHistoryInfo1 =>
      'Kruja është një qytet në Shqipërinë veri-qendrore, historikisht i njohur si selia e Gjergj Kastrioti Skënderbeut (1405-1468), heroit kombëtar të Shqipërisë. Kalaja e Krujës ka qenë e forcuar që nga të paktën shekulli i 5-të dhe u bë kryeqyteti i Principatës së Kastriotëve në shekullin e 15-të.\nNë 1443, Skënderbeu ngriti flamurin shqiptar mbi kështjellë pas braktisjes së shërbimit të detyruar në ushtrinë osmane, duke filluar një fushatë 25-vjeçare rezistence kundër Perandorisë Osmane.';

  @override
  String get krujaHistoryInfo2 =>
      'Skënderbeu mbrojti me sukses Krujën kundër tre rrethimeve të mëdha osmane — në 1450, 1466 dhe 1467 — çdo herë duke zmbrapsur forca shumë më të mëdha. Rezistenca e tij parandaloi zgjerimin osman në Evropën Perëndimore për dekada dhe i fitoi admirimin në mbarë botën e krishtere.\nPas vdekjes së Skënderbeut në 1468, kalaja ra në duart e osmanëve në 1478 pas një rrethimi të gjatë të katërt. Qyteti mbeti nën kontrollin osman deri në pavarësinë e Shqipërisë në 1912.';

  @override
  String get krujaConstructionInfo1 =>
      'Kalaja e Krujës është vendosur mbi një shkëmb në buzë të Malit të Skënderbeut (Mali i Sariut). Muret e fortesës ndjekin konturet natyrore të terrenit, duke rrethuar një zonë që dikur përmbante një qytet të vogël me shtëpi, kisha dhe një pazar.\nMuzeu i Skënderbeut, i dizajnuar nga arkitektët Pranvera Hoxha dhe Pirro Vaso dhe i hapur në 1982, ndodhet brenda mureve të kështjellës. I ndërtuar në stil modernist të frymëzuar nga arkitektura mesjetare shqiptare, ai strehon artefakte nga periudha e rezistencës shqiptare.';

  @override
  String get krujaConstructionInfo2 =>
      'Poshtë kalasë, Pazari i Vjetër i restauruar shtrihet përgjatë një rruge me kalldrëm me dyqane tradicionale prej guri dhe druri. Pazari ka qenë në përdorim të vazhdueshëm që nga shekulli i 15-të dhe sot shet artizanat tradicionale shqiptare, antikuariate dhe produkte të bëra lokalisht. Teqeja e Dollmës, një faltore e vogël bektashiane brenda kompleksit të kështjellës, ka arkitekturë elegante të epokës osmane me brendësi të pikturuara.';

  @override
  String get krujaLocationInfo1 =>
      'Kruja ndodhet rreth 32 km (20 milje) në veri të Tiranës në Shqipërinë qendrore. Kalaja ndodhet mbi një kreshtë malore që shikon mbi fushën e gjerë perëndimore shqiptare që shtrihet deri te Deti Adriatik, duke siguruar dukshmëri strategjike mbi forcat që afroheshin — një faktor kyç në mbrojtjen e suksesshme të Skënderbeut.';

  @override
  String get krujaLocationInfo2 =>
      'Mali i Skënderbeut (Mali i Sariut) ngrihet pjerrësisht prapa kalasë deri në rreth 1,070 m (3,500 këmbë). Terreni përreth i grykave të pjerrëta dhe pyjeve të dendura ofroi avantazhe natyrore mbrojtëse që Skënderbeu i shfrytëzoi në taktikat e tij guerile kundër forcave shumë më të mëdha osmane. Maja e afërt e Sarisalltikut ka një shpellë-faltore të nderuar nga myslimanët dhe të krishterët.';

  @override
  String get kruja1200bce =>
      'Vendbanimet e hershme ilire ekzistojnë në rajonin e Krujës, duke shfrytëzuar pozicionin natyror të fortesës';

  @override
  String get kruja106bce => 'Rajoni bie nën kontrollin romak si pjesë e provincës së Ilirikut';

  @override
  String get kruja551ce =>
      'Fortimet e epokës bizantine ndërtohen në majë të kodrës, duke krijuar kështjellën si pozicion mbrojtës strategjik';

  @override
  String get kruja1812ce =>
      'Rrënojat e kalasë dhe pazari i vjetër dokumentohen nga udhëtarët evropianë ndërsa interesi për historinë shqiptare rritet';

  @override
  String get kruja1958ce =>
      'Muzeu i Skënderbeut brenda kalasë krijohet, duke u bërë memoriali më i rëndësishëm kombëtar i Shqipërisë';

  @override
  String get kruja1989ce =>
      'Kruja bëhet një destinacion i madh turistik dhe simbol i identitetit kombëtar shqiptar pas rënies së komunizmit';

  @override
  String get krujaCollectible1Title => 'Deve me kalorës';

  @override
  String get krujaCollectible1Icon => 'statue';

  @override
  String get krujaCollectible2Title => 'Enë';

  @override
  String get krujaCollectible2Icon => 'vase';

  @override
  String get krujaCollectible3Title => 'Tas i hapur';

  @override
  String get krujaCollectible3Icon => 'vase';

  @override
  String get albanianAlpsTitle => 'Alpet Shqiptare';

  @override
  String get albanianAlpsSubTitle => 'Bjeshkët e Nemuna';

  @override
  String get albanianAlpsRegionTitle => 'Shqipëria Veriore';

  @override
  String get albanianAlpsArtifactCulture => 'Malësia Shqiptare';

  @override
  String get albanianAlpsArtifactGeolocation => 'Shqipëria Veriore';

  @override
  String get albanianAlpsPullQuote1Top => 'Natyra e Fundit e Madhe';

  @override
  String get albanianAlpsPullQuote1Bottom => 'e Paprekur e Evropës';

  @override
  String get albanianAlpsPullQuote2 =>
      'Bjeshkët e Nemuna qëndrojnë si dëshmi e bukurisë së papërpunuar dhe të pazbuar të botës natyrore.';

  @override
  String get albanianAlpsPullQuote2Author => 'Edith Durham';

  @override
  String get albanianAlpsCallout1 =>
      'Alpet Shqiptare, të njohura lokalisht si Bjeshkët e Nemuna, përmbajnë disa nga ekosistemet më të paprekura në Evropë, duke strehuar rrëqebull, ujq, arin dhe shqiponjë të artë.';

  @override
  String get albanianAlpsCallout2 =>
      'Jezerca, maja më e lartë me 2,694 m (8,839 këmbë), është një nga majat më dramatike prej guri gëlqeror në Ballkan, me fusha të përhershme bore dhe cirqe akullnajore.';

  @override
  String get albanianAlpsVideoCaption =>
      '“Alpet Shqiptare - Bjeshkët e Nemuna, Natyra e Fundit e Virgjër e Evropës.” Youtube.';

  @override
  String get albanianAlpsMapCaption => 'Harta që tregon vendndodhjen e Alpeve Shqiptare në Shqipërinë veriore.';

  @override
  String get albanianAlpsHistoryInfo1 =>
      'Alpet Shqiptare (Bjeshkët e Nemuna), të njohura gjithashtu si Malet e Namuna ose Prokletije, janë një varg malor që shtrihet nëpër Shqipërinë veriore, Kosovën perëndimore dhe Malin e Zi lindor. Në Shqipëri, vargu përfshin disa nga zonat më të largëta dhe të paprekura natyrore në të gjithë Evropën.\nMalet kanë qenë shtëpia e fiseve malësore shqiptare për shekuj, të cilët zhvilluan një kulturë unike mikpritjeje, nderi dhe vetëqeverisjeje të kodifikuar në Kanunin e Lëkë Dukagjinit.';

  @override
  String get albanianAlpsHistoryInfo2 =>
      'Emri \"Bjeshkët e Nemuna\" ka etimologji të ndryshme popullore — disa thonë se vjen nga vështirësia e kalimit të tyre, të tjerë ia atribuojnë një legjende malesh të mallkuara nga perënditë. Emri shqip \"Bjeshkët e Nemuna\" përkthehet më saktë si \"Malet e Malësorëve.\"\nUdhëtarja britanike Edith Durham dokumentoi gjerësisht malësinë në fillim të viteve 1900, duke përshkruar një shoqëri ku zakonet e lashta të gjakmarrjes dhe burrneshave mbijetonin krahas mikpritjes së jashtëzakonshme dhe bukurisë natyrore.';

  @override
  String get albanianAlpsConstructionInfo1 =>
      'Ndryshe nga strukturat e bëra nga njeriu, Alpet Shqiptare janë një monument i natyrës, i skulpturuar nga miliona vite procesesh gjeologjike. Vargu përbëhet kryesisht nga guri gëlqeror dhe dolomiti i epokës Mezozoike, i formësuar nga erozioni akullnajor dhe karstik në maja dramatike, lugina të thella dhe sisteme shpellash nëntokësore.\nSyri i Kaltër i Thethit, pellgjet akullnajore turkuaz, dhe fytyrat dramatike të shkëmbinjve të luginës së Valbonës janë të gjitha produkte të kësaj historie gjeologjike të vazhdueshme.';

  @override
  String get albanianAlpsConstructionInfo2 =>
      'Strukturat njerëzore në Alpet Shqiptare pasqyrojnë mjedisin malor. Shtëpitë tradicionale malësore (kullë) janë ndërtuara nga blloqe masive guri gëlqeror me brendësi druri, të dizajnuara për t\'i rezistuar borës së rëndë dhe për të siguruar mbrojtje. Kullosa me mure guri, shtigje antike mushkash dhe kisha të vogla malore mbushin peizazhin.\nShtegu i Majave të Ballkanit, një itinerar ecjeje prej 192 km (120 miljesh) i krijuar në 2013, lidh komunitete nëpër tre vende duke përdorur shumë nga këto shtigje tradicionale.';

  @override
  String get albanianAlpsLocationInfo1 =>
      'Alpet Shqiptare shtrihen nëpër rrethet e Shkodrës dhe Kukësit në Shqipërinë veriore, duke formuar kufirin e vendit me Malin e Zi dhe Kosovën. Vargu shtrihet rreth 65 km (40 milje) nga rajoni i Kelmendit në veriperëndim deri te zona e Valbonës në lindje. Luginat kryesore përfshijnë Thethin, Valbonën dhe Kelmendin.';

  @override
  String get albanianAlpsLocationInfo2 =>
      'Parku Kombëtar i Luginës së Valbonës dhe Parku Kombëtar i Thethit mbrojnë shumicën e pjesës shqiptare të vargut. Liqeni i Komanit, i aksesueshëm me traget nëpër një kanjon dramatik shpesh të krahasuar me fjordet skandinave, ofron një qasje mahnitëse në male nga jugu. Rajoni merr disa nga reshjet më të larta në Evropë, duke ushqyer lumenj dhe ujëvara të shumta.';

  @override
  String get albanianAlps2575bce =>
      'Banimi i hershëm njerëzor në rajonin e Alpeve Shqiptare daton në Epokën e Bronzit, me dëshmi të komuniteteve baritore në luginat malësore';

  @override
  String get albanianAlps2465bce =>
      'Fiset ilire vendosin vendbanime sezonale në kullotat malore, duke zhvilluar traditat e transhumancës që vazhdojnë deri më sot';

  @override
  String get albanianAlps443bce =>
      'Shkrimtarët grekë dhe romakë dokumentojnë pavarësinë e egër të fiseve ilire malore dhe terrenin e vështirë të rajonit';

  @override
  String get albanianAlps1925ce =>
      'Udhëtarja britanike Edith Durham publikon tregime të detajuara të jetës në malësinë shqiptare, duke sjellë vëmendje ndërkombëtare në rajon';

  @override
  String get albanianAlps1979ce =>
      'Parku Kombëtar i Thethit dhe Lugina e Valbonës caktohen si zona të mbrojtuar, duke ruajtur ekosistemet alpine';

  @override
  String get albanianAlps1990ce =>
      'Pas rënies së komunizmit, Alpet Shqiptare hapen për ecësit ndërkombëtarë dhe shtegu i Majave të Ballkanit krijohet përfundimisht në 2013';

  @override
  String get albanianAlpsCollectible1Title => 'Dy fragmente papirusi';

  @override
  String get albanianAlpsCollectible1Icon => 'scroll';

  @override
  String get albanianAlpsCollectible2Title => 'Fytyra fragmentare e Mbretit Khafre';

  @override
  String get albanianAlpsCollectible2Icon => 'statue';

  @override
  String get albanianAlpsCollectible3Title => 'Elemente Stoli';

  @override
  String get albanianAlpsCollectible3Icon => 'jewelry';

  @override
  String get korcaTitle => 'Korça';

  @override
  String get korcaSubTitle => 'Djepi i Kulturës Shqiptare';

  @override
  String get korcaRegionTitle => 'Korçë, Shqipëri';

  @override
  String get korcaArtifactCulture => 'Ortodokse Shqiptare';

  @override
  String get korcaArtifactGeolocation => 'Shqipëria Juglindore';

  @override
  String get korcaPullQuote1Top => 'Jo Vetëm një Katedrale,';

  @override
  String get korcaPullQuote1Bottom => 'por Shpirti i një Kombi';

  @override
  String get korcaPullQuote1Author => 'Fan Noli';

  @override
  String get korcaPullQuote2 =>
      'Korça është qyteti ku ndërgjegjja kombëtare shqiptare gjeti zërin e saj për herë të parë nëpërmjet shkollave, letërsisë dhe artit.';

  @override
  String get korcaPullQuote2Author => 'Faik Konica';

  @override
  String get korcaCallout1 =>
      'Katedralja e Ringjalljes (Katedralja Ngjallja e Krishtit) është katedralja ortodokse më e madhe në Shqipëri, e dizajnuar nga arkitekti i shquar Fan Noli dhe e përfunduar në 2003.';

  @override
  String get korcaCallout2 =>
      'Korça është shtëpia e shkollës së parë në gjuhën shqipe, e hapur më 7 mars 1887, një datë që tani festohet si Dita e Mësuesit në të gjithë Shqipërinë.';

  @override
  String get korcaVideoCaption => '“Korça - Djepi i Kulturës Shqiptare dhe Katedralja e Ringjalljes.” Youtube.';

  @override
  String get korcaMapCaption => 'Harta që tregon vendndodhjen e Korçës në Shqipërinë juglindore.';

  @override
  String get korcaHistoryInfo1 =>
      'Korça është një qytet në Shqipërinë juglindore, i vendosur në një platformë të lartë në rreth 850 m (2,800 këmbë) mbi nivelin e detit. Qyteti ka qenë një qendër e kulturës, arsimit dhe artit shqiptar që nga shekulli i 19-të, duke fituar titullin \"djepi i kulturës shqiptare.\"\nShkolla e parë në gjuhën shqipe u hap këtu më 7 mars 1887, nga Pandeli Sotiri, duke shënuar një moment vendimtar në zgjimin kombëtar shqiptar. Korça gjithashtu priti shtypshkronjën e parë shqiptare dhe shoqëri të shumta letrare.';

  @override
  String get korcaHistoryInfo2 =>
      'Katedralja origjinale ortodokse u shkatërrua gjatë periudhës komuniste kur Shqipëria u shpall shteti i parë ateist në botë në 1967, duke shembur pothuajse të gjitha ndërtesat fetare. Katedralja e re e Ringjalljes (Katedralja Ngjallja e Krishtit) u ndërtua midis 1992 dhe 2003 mbi themelet e katedrales së vjetër, duke simbolizuar si ringjalljen fetare ashtu edhe ripërtëritjen kulturore kombëtare.\nKorça është gjithashtu e njohur për kontributin e saj në muzikën, artin shqiptar dhe Festivalin e famshëm vjetor të Birrës së Korçës, një nga më të mëdhenjtë në Ballkan.';

  @override
  String get korcaConstructionInfo1 =>
      'Katedralja e Ringjalljes u dizajnua në stil neo-bizantin, duke marrë frymëzim nga arkitektura tradicionale e kishave ortodokse ndërsa inkorporon teknika moderne ndërtimi. Katedralja ka një plan kryqëzor me një kupolë qendrore të madhe që arrin rreth 30 m (100 këmbë) në lartësi, të shoqëruar nga kupola më të vogla.\nJashtësia është e veshur me gur me ngjyrë të çelët me dritare dekorative me harqe, ndërsa brendësia është e zbukuruar me afreske dhe ikonografi të pikturuara nga artistë shqiptarë dhe grekë.';

  @override
  String get korcaConstructionInfo2 =>
      'Ndërtimi i katedrales zgjati mbi një dekadë, nga 1992 deri në 2003. Ndërtimi modern me beton të armuar dhe skelet çeliku u përdor për integritetin strukturor, ndërsa elementet tradicionale prej guri dhe dekorative ruajnë estetikën bizantine.\nKambanorja, që ngrihet pranë katedrales, strehon një set kambanash që biën nëpër qytet. Sheshi dhe parku përreth krijojnë një qendër kulturore për qytetin, duke u lidhur me Muzeun Kombëtar të Artit Mesjetar, i cili strehon një nga koleksionet më të mira të ikonave bizantine në botë.';

  @override
  String get korcaLocationInfo1 =>
      'Korça ndodhet në Pellgun e Korçës, një platformë pjellore e rrethuar nga male në Shqipërinë juglindore. Qyteti ndodhet rreth 180 km (112 milje) në juglindje të Tiranës, pranë kufinjve me Greqinë dhe Maqedoninë e Veriut. Vargu malor i Moravës ngrihet në lindje, ndërsa Liqeni i Ohrit ndodhet në verilindje.';

  @override
  String get korcaLocationInfo2 =>
      'Platforma e Korçës ka qenë e banuar që nga kohërat parahistorike për shkak të tokës së pjellore dhe pozicionit strategjik përgjatë rrugëve antike tregtare që lidhnin Detin Adriatik me Detin Egje. Vendi arkeologjik i afërt i Maliqit, në brigjet e një liqeni të dikurshëm, ka dhënë dëshmi të banimit të vazhdueshëm që daton nga periudha neolitike, rreth 6000 p.e.s.';

  @override
  String get korca1631ce =>
      'Korça zhvillohet si qendër administrative dhe tregtare osmane me ndërtimin e xhamive, pazareve dhe haneve';

  @override
  String get korca1647ce =>
      'Rëndësia e qytetit rritet si udhëkryq i rrugëve tregtare që lidhin Selanikun, Joaninën dhe bregdetin shqiptar';

  @override
  String get korca1658ce =>
      'Komunitetet kulturore dhe fetare lulëzojnë në Korçë, duke e vendosur atë si qendër shumëtnike dijeje';

  @override
  String get korca1901ce =>
      'Korça bëhet qendër e lëvizjes kombëtare shqiptare me hapjen e shkollës së parë në gjuhën shqipe në 1887';

  @override
  String get korca1984ce =>
      'Gjatë epokës komuniste, Katedralja origjinale Ortodokse dhe shumica e ndërtesave fetare shemben ndërsa Shqipëria shpallet shtet ateist';

  @override
  String get korca1998ce =>
      'Ndërtimi i Katedrales së re të Ringjalljes fillon pas rënies së komunizmit, e përfunduar në 2003 si simbol i ripërtëritjes kulturore';

  @override
  String get korcaCollectible1Title => 'Hanxhar me Këllëf';

  @override
  String get korcaCollectible1Icon => 'jewelry';

  @override
  String get korcaCollectible2Title => 'Shtëpia e Bijapur-it';

  @override
  String get korcaCollectible2Icon => 'picture';

  @override
  String get korcaCollectible3Title => 'Panel i Kaligrafisë Nasta\'liq';

  @override
  String get korcaCollectible3Icon => 'scroll';

  @override
  String get timelineEvent2900bce => 'Traditat e tumujve të Epokës së Bronzit shfaqen në Ballkanin Perëndimor';

  @override
  String get timelineEvent2700bce =>
      'Vendbanimi i Maliqit pranë Korçës rritet në një nga komunitetet bujqësore më të hershme të Ballkanit jugor';

  @override
  String get timelineEvent2600bce =>
      'Komunitetet e Epokës së Hershme të Bronzit lulëzojnë përgjatë bregdetit të Adriatikut në Shqipërinë e sotme';

  @override
  String get timelineEvent2560bce => 'Horizonti kulturor i Cetinës lidh komunitetet në të gjithë Ballkanin Perëndimor';

  @override
  String get timelineEvent1200bce =>
      'Fiset ilire — Taulantët, Ardianët, Dardanët, Enkelejtë, Kaonët — konsolidohen në të gjithë Ballkanin Perëndimor';

  @override
  String get timelineEvent627bce =>
      'Kolonë grekë nga Korinthi dhe Korkyra themelojnë Epidamnin, Dyrrahun e ardhshëm dhe Durrësin e sotëm';

  @override
  String get timelineEvent358bce => 'Bardyli I i Mbretërisë Dardane mund Perdikën III të Maqedonisë';

  @override
  String get timelineEvent229bce =>
      'Lufta e Parë Ilire: Mbretëresha Teuta e Ardianëve përballet me Romën për pirateri në Adriatik';

  @override
  String get timelineEvent168bce =>
      'Lufta e Tretë Ilire mbaron; mbreti Genti mposhtet dhe Iliria bëhet protektorat romak';

  @override
  String get timelineEvent146bce =>
      'Roma fillon ndërtimin e Rrugës Egnatia, duke lidhur Dyrrahun përmes Ilirisë me Bizantin';

  @override
  String get timelineEvent395ce => 'Perandoria Romake ndahet; Iliria përfshihet në Perandorinë Lindore Bizantine';

  @override
  String get timelineEvent500ce =>
      'Bregdeti shqiptar lulëzon si një korridor kyç bizantin midis Kostandinopojës dhe Mesdheut perëndimor';

  @override
  String get timelineEvent632ce =>
      'Vdekja e Muhametit (61) dhe themelimi i Islamit — feja që më vonë do të riformësojë Shqipërinë nën sundimin osman';

  @override
  String get timelineEvent1018ce => 'Bazili II ripushton Ilirinë; Tema bizantine e Dyrrahut rivendoset';

  @override
  String get timelineEvent1043ce =>
      'Përmendja e parë e shkruar e emrit Albanoi — shqiptarët marrin pjesë në kryengritjen e Gjergj Maniakut';

  @override
  String get timelineEvent1081ce => 'Beteja e Dyrrahut: forcat normane nën Robert Guiscardin mundin bizantinët';

  @override
  String get timelineEvent1190ce => 'Progoni themelon Principatën e Arbanonit — shteti i parë mesjetar shqiptar';

  @override
  String get timelineEvent1271ce => 'Karli i Anzhuit shpall Mbretërinë e Arbërisë (Regnum Albaniae)';

  @override
  String get timelineEvent1347ce =>
      'Murtaja e Zezë përhapet në Evropë dhe shkretëron popullsitë ballkanike, përfshirë Shqipërinë';

  @override
  String get timelineEvent1355ce =>
      'Pas vdekjes së Stefan Dushanit, ngrihen principatat shqiptare të Balshajve, Topiajve, Muzakajve dhe Kastriotëve';

  @override
  String get timelineEvent1389ce => 'Fisnikët shqiptarë luftojnë krah forcave serbe në Betejën e Kosovës';

  @override
  String get timelineEvent1428ce =>
      'Gjergj Kastrioti, Skënderbeu i ardhshëm, rritet në oborrin osman para se të kthehet për të udhëhequr rezistencën shqiptare';

  @override
  String get timelineEvent1443ce => 'Skënderbeu braktis ushtrinë osmane në Betejën e Nishit dhe merr Krujën';

  @override
  String get timelineEvent1444ce => 'Besëlidhja e Lezhës bashkon princat shqiptarë nën komandën e Skënderbeut';

  @override
  String get timelineEvent1450ce => 'Rrethimi i Parë i Krujës: Skënderbeu përballon sulltan Muratin II';

  @override
  String get timelineEvent1466ce => 'Sulltan Mehmeti II nis Rrethimin e Dytë të Krujës dhe ndërton kalanë e Elbasanit';

  @override
  String get timelineEvent1468ce => 'Vdekja e Skënderbeut në Lezhë; rezistenca shqiptare shuhet gradualisht';

  @override
  String get timelineEvent1479ce => 'Rënia e Shkodrës — pushtimi osman i Shqipërisë përfundon';

  @override
  String get timelineEvent1571ce =>
      'Beteja e Lepantos — marinarë shqiptarë luftojnë në të dy palët e përballjes detare të krishterë–osmane';

  @override
  String get timelineEvent1788ce => 'Ali Pashë Tepelena themelon Pashallëkun gjysmë të pavarur të Janinës';

  @override
  String get timelineEvent1789ce =>
      'Fillon Revolucioni Francez; idealet e tij më vonë frymëzojnë Rilindjen Kombëtare Shqiptare';

  @override
  String get timelineEvent1830ce =>
      'Masakra e Bejlerëve në Manastir i jep fund autonomisë feudale shqiptare nën reformat osmane';

  @override
  String get timelineEvent1878ce => 'Themelohet Lidhja e Prizrenit — lëvizja e parë e organizuar kombëtare shqiptare';

  @override
  String get timelineEvent1908ce => 'Kongresi i Manastirit standardizon alfabetin shqip me bazë latine';

  @override
  String get timelineEvent1912ce => 'Ismail Qemali shpall pavarësinë e Shqipërisë në Vlorë më 28 Nëntor';

  @override
  String get timelineEvent1914ce =>
      'Lufta e Parë Botërore — Shqipëria bëhet fushëbeteje e disputuar mes disa fuqive evropiane';

  @override
  String get timelineEvent1920ce => 'Kongresi i Lushnjës e bën Tiranën kryeqytetin e Shqipërisë';

  @override
  String get timelineEvent1928ce => 'Ahmet Zogu kurorëzohet Mbreti Zog I i Shqiptarëve';

  @override
  String get timelineEvent1939ce => 'Fillon Lufta e Dytë Botërore';

  @override
  String get timelineEvent1939ceAlbania => 'Italia pushton Shqipërinë dhe nis pushtimin e fuqive të Boshtit';

  @override
  String get timelineEvent1944ce => 'Shqipëria çlirohet nga forcat partizane; nis regjimi komunist i Enver Hoxhës';

  @override
  String get timelineEvent1967ce => 'Shqipëria shpall veten shtetin e parë zyrtarisht ateist në botë';

  @override
  String get timelineEvent1991ce => 'Zgjedhjet e para shumëpartiake i japin fund 46 viteve të sundimit komunist';

  @override
  String get timelineEvent1997ce => 'Rënia e skemave piramidale në mbarë vendin shkakton trazira civile';

  @override
  String get timelineEvent2009ce => 'Shqipëria anëtarësohet në NATO';

  @override
  String get timelineEvent2019ce => 'Një tërmet shkatërrues godet rajonin e Durrësit';

  @override
  String get privacyPolicy => 'Politika e Privatësisë';

  @override
  String privacyStatement(Object privacyUrl) {
    return 'Siç shpjegohet në $privacyUrl tonë, ne nuk mbledhim asnjë informacion personal.';
  }

  @override
  String get pageNotFoundBackButton => 'Kthehu në qytetërim';

  @override
  String get pageNotFoundMessage => 'Faqja që po kërkoni nuk ekziston.';

  @override
  String get authSignInTitle => 'Mirësevini përsëri';

  @override
  String get authSignInSubtitle => 'Hyni për të vazhduar eksplorimin e Shqipërisë.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Fjalëkalimi';

  @override
  String get authSignInButton => 'HYR';

  @override
  String get authSignInError => 'Diçka shkoi keq. Ju lutemi provoni përsëri.';

  @override
  String get authEmailRequired => 'Email-i është i detyrueshëm';

  @override
  String get authEmailInvalid => 'Shkruani një email të vlefshëm';

  @override
  String get authPasswordRequired => 'Fjalëkalimi është i detyrueshëm';

  @override
  String get buddyHeaderTitle => 'Shoku i Udhëtimit';

  @override
  String get buddyHeaderSubtitle => 'Udhërrëfyesi juaj AI për Shqipërinë';

  @override
  String get buddyEmptyTitle => 'Si mund të ju ndihmoj me udhëtimin?';

  @override
  String get buddyEmptySubtitle => 'Më pyesni për vende, ushqim, buxhet ose itinerare në Shqipëri.';

  @override
  String get buddyComposerHint => 'Shkruaji shokut tuaj të udhëtimit…';

  @override
  String get buddySuggestionTirana => 'Planifikoni një udhëtim 3-ditor në Tiranë';

  @override
  String get buddySuggestionBerat => 'Gjërat më të mira për të bërë në Berat';

  @override
  String get buddySuggestionBudget => 'Shqipëria me buxhet të kufizuar';

  @override
  String get buddyErrorHint => 'Diçka shkoi keq.';

  @override
  String get buddyErrorRetry => 'Riprovo';

  @override
  String get buddyNotSavedHint => 'Përgjigja nuk u ruajt në server.';

  @override
  String get buddyItineraryUnstructured => 'Nuk arritëm ta strukturojmë këtë itinerar — përgjigja është më sipër.';

  @override
  String buddyRagSourcesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count burime',
      one: '1 burim',
    );
    return '$_temp0';
  }

  @override
  String get refineWithBuddyButton => 'Përsosni me Buddy';

  @override
  String get refineComposerHint => 'Kërkoji Buddy-t të përmirësojë këtë udhëtim…';

  @override
  String get refineEmptyTitle => 'Çfarë duhet të ndryshojmë?';

  @override
  String get refineEmptySubtitle =>
      'Kërkoji Buddy-t ta përshtasë këtë udhëtim — shkurto një ditë, ndrysho një ndalesë, shto diçka të re.';

  @override
  String get refineSuggestionShortenDay => 'Shkurto ditën 2';

  @override
  String get refineSuggestionAddBeach => 'Shto një ditë plazhi';

  @override
  String get refineSuggestionSwapStop => 'Zëvendëso një ndalesë me diçka më lokale';

  @override
  String refineBannerTitle(String tripTitle) {
    return 'Po përsoset: $tripTitle';
  }

  @override
  String get refineBannerExit => 'Dil';

  @override
  String get refineTripUpdated => 'Udhëtimi u përditësua';

  @override
  String get refineViewTrip => 'Shihe udhëtimin';

  @override
  String get refineFailedFooter => 'Përmirësimi nuk u zbatua. Përgjigja më sipër e përshkruan ndryshimin e propozuar.';

  @override
  String get refineOpenFailed => 'Nuk u hap biseda — provo sërish.';

  @override
  String get buddySendTooltip => 'Dërgo mesazhin';

  @override
  String get buddyPlaceCardOpenInMap => 'Shihe në hartë';

  @override
  String get buddyVoiceHoldToTalk => 'Mbaj për të folur';

  @override
  String get buddyVoiceTapToTalk => 'Prek për të folur';

  @override
  String get buddyVoiceListening => 'Po dëgjoj…';

  @override
  String get buddyVoiceCancel => 'Anulo';

  @override
  String get buddyVoiceStop => 'Ndalo regjistrimin';

  @override
  String get buddyVoiceSend => 'Dërgo';

  @override
  String get buddyVoicePermissionDenied =>
      'Leja për mikrofonin u refuzua. Aktivizoje te Cilësimet për të përdorur zërin.';

  @override
  String get buddyVoiceUnavailable => 'Njohja e zërit nuk është e disponueshme në këtë pajisje.';

  @override
  String get buddyTtsPlay => 'Lexo me zë';

  @override
  String get buddyTtsStop => 'Ndalo leximin';

  @override
  String get buddyAttachTooltip => 'Shto foto';

  @override
  String get buddyAttachCamera => 'Kamera';

  @override
  String get buddyAttachGallery => 'Galeria e fotove';

  @override
  String get buddyAttachUploading => 'Duke ngarkuar…';

  @override
  String get buddyAttachFailed => 'Ngarkimi dështoi';

  @override
  String get buddyAttachRemove => 'Hiqe';

  @override
  String get buddyAttachRetry => 'Riprovo';

  @override
  String get buddyAttachSizeError => 'Fotoja është shumë e madhe — provo një më të vogël';

  @override
  String get buddyHistoryTooltip => 'Bisedat e mëparshme';

  @override
  String get buddyNewChatTooltip => 'Bisedë e re';

  @override
  String get conversationsTitle => 'Bisedat e mëparshme';

  @override
  String get conversationsEmpty => 'Asnjë bisedë ende';

  @override
  String get conversationsLoadFailed => 'Bisedat nuk u ngarkuan';

  @override
  String get conversationsNewChatTooltip => 'Bisedë e re';

  @override
  String get conversationsDeleteTitle => 'Fshi bisedën?';

  @override
  String get conversationsDeleteConfirm => 'Ky veprim s\'mund të zhbëhet.';

  @override
  String get conversationsDeleteAction => 'Fshi';

  @override
  String get conversationsDeleteCancel => 'Anulo';

  @override
  String get conversationsDeleteFailed => 'Fshirja e bisedës dështoi.';

  @override
  String get conversationsClearAllAction => 'Clear all conversations';

  @override
  String get conversationsClearAllTitle => 'Clear all conversations?';

  @override
  String get conversationsClearAllBody => 'Every conversation will be permanently deleted. This can\'t be undone.';

  @override
  String get conversationsClearAllConfirm => 'Clear all';

  @override
  String get profileTitle => 'Profili';

  @override
  String get profileEmailLabel => 'Të identifikuar si';

  @override
  String get profileSignOutButton => 'Dil';

  @override
  String get preferencesTileTitle => 'Preferencat';

  @override
  String get preferencesTileSubtitle => 'Përshtatni stilin tuaj të udhëtimit';

  @override
  String get preferencesScreenTitle => 'Preferencat';

  @override
  String get preferencesSaveButton => 'Ruaj';

  @override
  String get preferencesSaveSuccess => 'Preferencat u ruajtën';

  @override
  String get preferencesSaveError => 'Ruajtja e preferencave dështoi';

  @override
  String get preferencesLoadError => 'Ngarkimi i preferencave dështoi';

  @override
  String get preferencesNotSetYet => 'Ende e pacaktuar';

  @override
  String get preferencesPersonaSection => 'Profili i udhëtarit';

  @override
  String get preferencesPersonaEmpty => 'Trokit Gjenero për të krijuar profilin tuaj të udhëtarit';

  @override
  String get preferencesPersonaGenerate => 'Gjenero profilin';

  @override
  String get preferencesPersonaRegenerate => 'Rigjenero';

  @override
  String get preferencesPersonaError => 'Gjenerimi i profilit dështoi';

  @override
  String get preferencesPersonaUseButton => 'Përdor këtë profil';

  @override
  String get preferencesPersonaInfoBody =>
      'Zgjidh profilin që të ngjan më shumë tani. Është vetëm pikënisja — sa më shumë të bisedosh me Travel Buddy, aq më mirë do ta kuptojë se si udhëton në të vërtetë. Buxhetin tënd, ritmin tënd, çfarë anashkalon, çfarë nuk e humb kurrë. Me kohën, rekomandimet nuk do të duken më të përgjithshme, por sikur janë krijuar enkas për ty.';

  @override
  String get preferencesPersonaInfoDismiss => 'E kuptova';

  @override
  String get preferencesBudgetSection => 'Buxheti';

  @override
  String get preferencesBudgetShoestring => 'I kufizuar';

  @override
  String get preferencesBudgetMidRange => 'Mesatar';

  @override
  String get preferencesBudgetLuxury => 'Luksoz';

  @override
  String get preferencesGroupSection => 'Me kë udhëtoni';

  @override
  String get preferencesGroupSolo => 'Vetëm';

  @override
  String get preferencesGroupCouple => 'Çift';

  @override
  String get preferencesGroupFamily => 'Familje';

  @override
  String get preferencesGroupFriends => 'Me shokë';

  @override
  String get preferencesStyleSection => 'Stili i udhëtimit';

  @override
  String get preferencesStyleAdventure => 'Aventurë';

  @override
  String get preferencesStyleCultural => 'Kulturor';

  @override
  String get preferencesStyleRelaxation => 'Pushim';

  @override
  String get preferencesStyleFoodie => 'Gastronomik';

  @override
  String get preferencesStyleBeach => 'Plazh';

  @override
  String get preferencesStyleNightlife => 'Jeta e natës';

  @override
  String get preferencesStyleHiddenGem => 'Vende të fshehta';

  @override
  String get preferencesAccommodationSection => 'Akomodimi';

  @override
  String get preferencesAccommodationHotel => 'Hotel';

  @override
  String get preferencesAccommodationHostel => 'Hostel';

  @override
  String get preferencesAccommodationAirbnb => 'Airbnb';

  @override
  String get preferencesAccommodationBoutique => 'Butik';

  @override
  String get preferencesAccommodationCamping => 'Kamping';

  @override
  String get preferencesTransportSection => 'Transporti';

  @override
  String get preferencesTransportCar => 'Makinë me qira';

  @override
  String get preferencesTransportPublic => 'Transport publik';

  @override
  String get preferencesTransportWalking => 'Në këmbë';

  @override
  String get preferencesPaceSection => 'Ritmi';

  @override
  String get preferencesPaceChill => 'I qetë';

  @override
  String get preferencesPaceModerate => 'Mesatar';

  @override
  String get preferencesPacePacked => 'Intensiv';

  @override
  String get preferencesFoodSection => 'Ushqimi';

  @override
  String get preferencesFoodVegetarian => 'Vegjetarian';

  @override
  String get preferencesFoodVegan => 'Vegan';

  @override
  String get preferencesFoodHalal => 'Hallall';

  @override
  String get preferencesFoodGluten => 'Pa gluten';

  @override
  String get preferencesFoodNone => 'Pa kufizime';

  @override
  String get preferencesInterestsSection => 'Interesat';

  @override
  String get preferencesInterestsHistory => 'Histori';

  @override
  String get preferencesInterestsNature => 'Natyrë';

  @override
  String get preferencesInterestsHiking => 'Ecje malore';

  @override
  String get preferencesInterestsBeaches => 'Plazhe';

  @override
  String get preferencesInterestsFood => 'Ushqim';

  @override
  String get preferencesInterestsNightlife => 'Jeta e natës';

  @override
  String get preferencesInterestsArchitecture => 'Arkitekturë';

  @override
  String get preferencesInterestsReligion => 'Fe';

  @override
  String get preferencesInterestsPhotography => 'Fotografi';

  @override
  String get photoGalleryLabelNoPhotos => 'Ende pa fotografi';

  @override
  String get artifactCarouselLabelNoArtifacts => 'Asnjë artefakt për të shfaqur';

  @override
  String get buddySaveItinerary => 'Ruaj itinerarin';

  @override
  String get buddyItinerarySaved => 'U ruajt ✓ — Shfaq te Udhëtimet e mia';

  @override
  String get buddyItinerarySaveRetry => 'Nuk u ruajt — prek për ta riprovuar';

  @override
  String get buddyItineraryPickStartDateHelp => 'Kur fillon ky udhëtim?';

  @override
  String get buddySaveLimitHelper => 'Kufiri u arrit — fshini një udhëtim për të ruajtur një të ri';

  @override
  String get myTripsTitle => 'Udhëtimet e mia';

  @override
  String get myTripsEmptyTitle => 'Ende nuk ka udhëtime të ruajtura';

  @override
  String get myTripsEmptySubtitle => 'Planifiko një me Buddy dhe prek Ruaj itinerarin.';

  @override
  String get myTripsDatesNotSet => 'Data nuk është caktuar';

  @override
  String get myTripsDaysOne => '1 ditë';

  @override
  String myTripsDaysOther(int count) {
    return '$count ditë';
  }

  @override
  String get myTripsDeleteTitle => 'Ta fshijmë udhëtimin?';

  @override
  String get myTripsDeleteBody => 'Ky veprim nuk mund të kthehet.';

  @override
  String get myTripsDeleteCancel => 'Anulo';

  @override
  String get myTripsDeleteConfirm => 'Fshi';

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
    return 'Dita $dayNumber';
  }

  @override
  String get tripDetailAddStop => 'Shto ndalesë';

  @override
  String get tripDetailAddDay => 'Shto ditë';

  @override
  String get tripDetailDialogSave => 'Ruaj';

  @override
  String get tripDetailDialogClear => 'Pastro';

  @override
  String get tripDetailStartDateNotSet => 'Nuk është caktuar';

  @override
  String get tripDetailRailMarkVisited => 'Shëno si të vizituar';

  @override
  String get tripDetailRailResetUpcoming => 'Riktheje në të planifikuar';

  @override
  String tripDetailVisitedAt(String time) {
    return 'Vizituar $time';
  }

  @override
  String tripDetailDayProgress(int done, int total) {
    return '$done / $total të vizituara';
  }

  @override
  String get tripDetailAutoTrackPromptTitle => 'Të kontrollojmë automatikisht ndalesat?';

  @override
  String get tripDetailAutoTrackPromptBody =>
      'Travel Buddy mund t\'i shënojë automatikisht ndalesat kur je afër tyre brenda orarit. Vendndodhja qëndron në pajisjen tënde.';

  @override
  String get tripDetailAutoTrackEnable => 'Aktivizo';

  @override
  String get tripDetailAutoTrackDecline => 'Jo tani';

  @override
  String get tripDetailAutoTrackEnableMenu => 'Aktivizo gjurmimin automatik';

  @override
  String get tripDetailAutoTrackDisableMenu => 'Çaktivizo gjurmimin automatik';

  @override
  String get tripDetailAutoTrackErrorPermissionTitle => 'Gjurmimi automatik kërkon qasje në vendndodhje';

  @override
  String get tripDetailAutoTrackErrorPermissionBody =>
      'Gjurmimi automatik i shënon ndalesat kur je afër tyre. Lejo qasjen në vendndodhje gjatë përdorimit të aplikacionit për ta aktivizuar.';

  @override
  String get tripDetailAutoTrackErrorBlockedBody =>
      'Qasja në vendndodhje është bllokuar. Hap Cilësimet për ta lejuar Travel Buddy.';

  @override
  String get tripDetailAutoTrackErrorServiceTitle => 'Aktivizo Shërbimet e Vendndodhjes';

  @override
  String get tripDetailAutoTrackErrorServiceBody =>
      'Shërbimet e Vendndodhjes janë të çaktivizuara në pajisje. Gjurmimi automatik nuk funksionon derisa t\'i kthesh në punë.';

  @override
  String get tripDetailAutoTrackErrorOpenSettings => 'Hap Cilësimet';

  @override
  String get tripDetailAutoTrackErrorRetry => 'Provo përsëri';

  @override
  String get tripDetailAddDayDialogTitle => 'Shto ditë';

  @override
  String get tripDetailAddDayNumberField => 'Numri i ditës';

  @override
  String get tripDetailAddDayTitleField => 'Titulli (opsional)';

  @override
  String get tripDetailAddDayBaseCityField => 'Qyteti bazë (opsional)';

  @override
  String get tripDetailSummaryPlaceholder => 'Trokit për të shtuar një përmbledhje';

  @override
  String get tripDetailEmptyDayHint => 'Ende pa ndalesa — trokit + për të shtuar një';

  @override
  String get tripDetailKebabEditSummary => 'Modifiko përmbledhjen';

  @override
  String get tripDetailKebabChangeStartDate => 'Ndrysho datën e nisjes';

  @override
  String get tripDetailKebabClearStartDate => 'Hiq datën e nisjes';

  @override
  String get tripDetailDayActionRename => 'Riemërto ditën';

  @override
  String get tripDetailDayActionChangeBaseCity => 'Ndrysho qytetin bazë';

  @override
  String get tripDetailDayActionAddStop => 'Shto ndalesë këtu';

  @override
  String get tripDetailDayActionDelete => 'Fshi ditën';

  @override
  String get tripDetailRenameDayDialogTitle => 'Riemërto ditën';

  @override
  String get tripDetailChangeBaseCityDialogTitle => 'Ndrysho qytetin bazë';

  @override
  String get tripDetailStopActionDuplicate => 'Dubliko';

  @override
  String tripDetailUndoStopBanner(String stopName) {
    return 'Ndalesa u fshi: $stopName';
  }

  @override
  String get tripDetailUndoStopButton => 'ZHBËJ';

  @override
  String get tripDetailStopActionEdit => 'Modifiko';

  @override
  String get tripDetailStopActionMove => 'Zhvendos te dita…';

  @override
  String get tripDetailStopActionDelete => 'Fshi';

  @override
  String get tripDetailViewOnMapButton => 'Shiko në hartë';

  @override
  String get tripDetailMoveStopSheetTitle => 'Zhvendos te dita';

  @override
  String tripDetailMoveStopSheetSubtitle(String stopName) {
    return 'Ku të shkojë \"$stopName\"?';
  }

  @override
  String tripDetailMoveStopOption(int dayNumber, String label) {
    return 'Dita $dayNumber · $label';
  }

  @override
  String get tripDetailMoveStopOptionEmpty => 'ende pa ndalesa';

  @override
  String tripDetailMoveStopOptionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ndalesa',
      one: '1 ndalesë',
    );
    return '$_temp0';
  }

  @override
  String get tripDetailMoveStopFailed => 'Nuk munda ta zhvendos ndalesën — provo sërish.';

  @override
  String get tripsErrorSignIn => 'Identifikohu sërish për të ruajtur ndryshimet.';

  @override
  String get tripsErrorNotFound => 'Ky udhëtim nuk ekziston më.';

  @override
  String get tripsErrorConflict => 'Udhëtimi u ndryshua diku tjetër — duke rifreskuar.';

  @override
  String get tripsErrorTripLimitReached => 'Mund të ruani deri në 3 udhëtime. Fshini një për të ruajtur këtë.';

  @override
  String get tripsErrorGeneric => 'Nuk munda ta ruaj ndryshimin tënd.';

  @override
  String get conversationsUntitled => 'Bisedë pa titull';

  @override
  String get profileDeleteAccountButton => 'Fshi llogarinë';

  @override
  String get profileDeleteAccountTitle => 'Të fshijmë llogarinë?';

  @override
  String get profileDeleteAccountBody =>
      'Ky veprim heq përgjithmonë udhëtimet, bisedat, fotot e ngarkuara dhe preferencat. Nuk mund të kthehet.';

  @override
  String get profileDeleteAccountInstruction => 'Shkruaj DELETE për të konfirmuar:';

  @override
  String get profileDeleteAccountConfirmWord => 'DELETE';

  @override
  String get profileDeleteAccountConfirm => 'Fshi llogarinë time';

  @override
  String get profileDeleteAccountCancel => 'Anulo';

  @override
  String get profileDeleteAccountFailed => 'Nuk u arrit fshirja e llogarisë. Provo sërish.';
}
