// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Albanian (`sq`).
class AppLocalizationsSq extends AppLocalizations {
  AppLocalizationsSq([String locale = 'sq']) : super(locale);

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
  String get bottomScrubberSemanticTimeline =>
      'Rrëshqitësi i vijës kohore, tërhiqeni horizontalisht për të lundruar në vijën kohore.';

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
  String get eventsListButtonOpenTimeline => 'Hap historinë e Shqipërisë';

  @override
  String newlyDiscoveredSemanticNew(Object count, Object suffix) {
    return '$count artikuj$suffix të rinj për të eksploruar. Shkoni te artikulli i ri';
  }

  @override
  String newlyDiscoveredLabelNew(Object count, Object suffix) {
    return '$count artikuj$suffix të rinj për të eksploruar';
  }

  @override
  String get scrollingContentSemanticYoutube => 'Miniatura e Youtube';

  @override
  String get scrollingContentSemanticOpen => 'Hap pamjen e hartës në ekran të plotë';

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
  String get fullscreenImageViewerSemanticFull => 'imazh në ekran të plotë, nuk ka përshkrim të disponueshëm';

  @override
  String get introTitleWelcome => 'Njihuni me Pathfinder Albania';

  @override
  String get introDescWelcome => 'Asistenti yt AI i udhëtimit për Shqipërinë, nga bregdeti Jon te Bjeshkët e Namuna.';

  @override
  String get introTitleExplore => 'Eksploroni tetë destinacione';

  @override
  String get introDescExplore =>
      'Qytete antike, qytete me kala dhe lugina malore, secila me historinë, fotot dhe kronologjinë e vet.';

  @override
  String get introTitleStory => 'Tre mijë vjet histori';

  @override
  String get introDescStory =>
      'Përshkoni kronologjinë nga kalatë ilire te pazaret osmane dhe mblidhni artefakte të fshehura rrugës.';

  @override
  String get introTitleAsk => 'Pyet, planifiko, nisu';

  @override
  String get introDescAsk =>
      'Bisedo me Pathfinder për të planifikuar itinerarin, gjetur vende dhe ruajtur udhëtimet. E njeh Shqipërinë si një vendas.';

  @override
  String get introSkip => 'Kalo';

  @override
  String get introSemanticNavigate => 'Lundro';

  @override
  String get introSemanticSwipeLeft => 'Rrëshqitni majtas për të vazhduar';

  @override
  String get introSemanticEnterApp => 'Hyni në aplikacion';

  @override
  String get appName => 'Pathfinder Albania';

  @override
  String get appTagline => 'Asistenti AI i udhëtimit për Shqipërinë';

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
  String get eraAntiquity => 'Antikiteti';

  @override
  String get eraMiddleAges => 'Mesjeta';

  @override
  String get eraOttoman => 'Periudha Osmane';

  @override
  String get eraModern => 'Epoka Moderne';

  @override
  String get yearBCE => 'p.e.s.';

  @override
  String get yearCE => 'e.s.';

  @override
  String get yearToday => 'sot';

  @override
  String yearFormat(Object date, Object era) {
    return '$date $era';
  }

  @override
  String get year => 'Viti';

  @override
  String timelineLabelOrigin(Object title) {
    return '$title: nis historia.';
  }

  @override
  String get timelineTitle => 'Historia e Shqipërisë';

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
  String get homeSemanticDestination => 'destinacion';

  @override
  String get butrintTitle => 'Butrinti';

  @override
  String get butrintRegionTitle => 'Sarandë, Shqipëri';

  @override
  String get butrintArtifactCulture => 'Iliro-Romake';

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
  String get butrintVideoCaption => '“Butrint Albania | The ruins of Butrinti Albania.” Visit Albania, YouTube.';

  @override
  String get butrintMapCaption => 'Harta që tregon vendndodhjen e Parkut Kombëtar të Butrintit në Shqipërinë jugore.';

  @override
  String get butrintHistoryInfo1 =>
      'Butrinti është një sit arkeologjik në Shqipërinë jugore, përballë ishullit grek të Korfuzit. I vendosur fillimisht nga kolonistët grekë nga Korfuzi në shekullin e 8-të p.e.s., ai u rrit në një qytet të rëndësishëm të botës antike. Sipas legjendës, qyteti u themelua nga refugjatë trojanë të udhëhequr nga Enea.\nButrinti u bë protektorat romak në vitin 228 p.e.s., dhe Jul Çezari më vonë e caktoi atë si koloni për veteranët. Nën sundimin romak, qyteti lulëzoi me ndërtimin e një akuedukti, banjave publike dhe një forumi.';

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
  String get butrint228bce => 'Butrinti bëhet protektorat romak, së bashku me Korfuzin.';

  @override
  String get butrint44bce => 'Jul Çezari e bën Butrintin koloni për veteranët e tij; nën Augustin qyteti dyfishohet.';

  @override
  String get butrint1386ce =>
      'Venediku blen Korfuzin dhe Butrintin nga Anzhuinët dhe e mban Butrintin si pikë të përparme.';

  @override
  String get butrint1798ce => 'Ali Pashë Tepelena ua merr Butrintin francezëve.';

  @override
  String get butrint1928ce => 'Arkeologu italian Luigi Maria Ugolini nis gërmimet e para moderne.';

  @override
  String get butrint1992ce => 'Butrinti regjistrohet në Listën e Trashëgimisë Botërore të UNESCO-s.';

  @override
  String get beratTitle => 'Berati';

  @override
  String get beratRegionTitle => 'Berat, Shqipëri';

  @override
  String get beratArtifactCulture => 'Bizantino-Shqiptare';

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
  String get beratVideoCaption => '“Berat, Albania - The pride of Albanian architecture.” Visit Albania, YouTube.';

  @override
  String get beratMapCaption => 'Harta që tregon vendndodhjen e Beratit në Shqipërinë qendrore.';

  @override
  String get beratHistoryInfo1 =>
      'Berati është një nga qytetet më të vjetra të banuara vazhdimisht në Shqipëri, i vendosur përgjatë brigjeve të Lumit Osum. Kodra e kështjellës ka qenë e banuar të paktën që nga shekulli i 7-të p.e.s.; në antikitet qyteti i fortifikuar këtu njihej si Antipatrea, emër që ka të ngjarë t\'i kushtohet regjentit maqedonas Antipatri.\nNën sundimin romak, qyteti shërbeu si një bazë ushtarake strategjike përgjatë rrugës tregtare Via Egnatia.';

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
  String get berat200bce => 'Romakët sulmojnë dhe djegin Antipatrean, qytetin e fortifikuar në kodrën e Beratit.';

  @override
  String get berat1417ce => 'Berati bëhet pjesë e Perandorisë Osmane.';

  @override
  String get berat1547ce =>
      'Piktori i ikonave Onufri nënshkruan një afresk kishe të datuar më 23 korrik 1547; muzeu në kalanë e Beratit sot mban emrin e tij.';

  @override
  String get berat1922ce => 'Kongresi i Beratit shpall autoqefalinë e Kishës Ortodokse Shqiptare.';

  @override
  String get berat1961ce => 'Berati shpallet \"Qytet-Muze\", duke mbrojtur lagjet e tij historike.';

  @override
  String get berat2008ce => 'Berati i bashkohet Gjirokastrës në Listën e Trashëgimisë Botërore të UNESCO-s.';

  @override
  String get gjirokasterTitle => 'Gjirokastra';

  @override
  String get gjirokasterRegionTitle => 'Gjirokastër, Shqipëri';

  @override
  String get gjirokasterArtifactCulture => 'Osmano-Shqiptare';

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
  String get gjirokasterVideoCaption => '“Gjirokaster Albania | Gjirokastra Albania.” Visit Albania, YouTube.';

  @override
  String get gjirokasterMapCaption => 'Harta që tregon vendndodhjen e Gjirokastrës në Shqipërinë jugore.';

  @override
  String get gjirokasterHistoryInfo1 =>
      'Gjirokastra është një qytet në Shqipërinë jugore, i vendosur në luginën e Lumit Drino. Fortesa e parë në majë të kodrës daton nga shekujt e 5-të dhe të 6-të e.s. Emri Gjirokastër ka të ngjarë të rrjedh nga greqishtja mesjetare \"Argyrokastron\" që do të thotë \"Kështjella e Argjenditë.\"\nQyteti u ngrit në rëndësi në shekullin e 13-të si qendër e Despotëtit të Epirit dhe më vonë u bë një kala e rëndësishme e kontestuar midis forcave bizantine, serbe dhe osmane.';

  @override
  String get gjirokasterHistoryInfo2 =>
      'Nën sundimin osman nga 1418 e tutje, Gjirokastra u bë qendra e një sanxhaku të madh (njësi administrative) dhe lulëzoi si qytet pazar. Pronarët e pasur të tokës ndërtuan shtëpitë e dallueshme kullë të forcuara që përcaktojnë karakterin e qytetit.\nQyteti u regjistrua si Vend i Trashëgimisë Botërore të UNESCO-s në 2005 si \"një shembull i rrallë i një qyteti osman të ruajtur mirë, i ndërtuar nga fermerë të pronave të mëdha.\" Është vendlindja e ish-diktatorit shqiptar Enver Hoxha dhe autorit fitues të Çmimit Nobel, Ismail Kadare.';

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
  String get gjirokaster1336ce =>
      'Perandori bizantin Joan VI Kantakuzeni e përmend qytetin si Argjirokastro, përmendja e parë e emrit të tij.';

  @override
  String get gjirokaster1418ce => 'Pas një rrethimi, osmanët e marrin qytetin nga familja Zenebishi.';

  @override
  String get gjirokaster1811ce =>
      'Gjirokastra bëhet pjesë e Pashallëkut të Janinës së Ali Pashës; më pas ai e zgjeron kalanë.';

  @override
  String get gjirokaster1932ce => 'Qeveria e Mbretit Zog zgjeron burgun brenda kalasë.';

  @override
  String get gjirokaster1936ce => 'Shkrimtari Ismail Kadare lind në këtë qytet.';

  @override
  String get gjirokaster2005ce => 'Qendra historike regjistrohet në Listën e Trashëgimisë Botërore të UNESCO-s.';

  @override
  String get apolloniaTitle => 'Apolonia';

  @override
  String get apolloniaRegionTitle => 'Fier, Shqipëri';

  @override
  String get apolloniaArtifactCulture => 'Iliro-Greke';

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
  String get apolloniaVideoCaption => '“Apollonia, Albania by Drone.” Visit Albania, YouTube.';

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
  String get apollonia588bce => 'Kolonë grekë nga Korinti dhe Korkyra themelojnë Apoloninë në tokë ilire.';

  @override
  String get apollonia229bce => 'Apolonia kalon nën kontrollin e Republikës Romake.';

  @override
  String get apollonia148bce => 'Apolonia bëhet pjesë e provincës së re romake të Maqedonisë.';

  @override
  String get apollonia44bce => 'I riu Oktavian, perandori i ardhshëm August, studion në Apoloni.';

  @override
  String get apollonia1272ce => 'Manastiri bizantin i Shën Mërisë ngrihet mes rrënojave të qytetit antik.';

  @override
  String get apollonia1924ce => 'Një mision arkeologjik francez nis gërmimet sistematike, që zgjasin deri më 1938.';

  @override
  String get thethTitle => 'Thethi';

  @override
  String get thethRegionTitle => 'Shkodër, Shqipëri';

  @override
  String get thethArtifactCulture => 'Malësia Shqiptare';

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
  String get thethVideoCaption => '“Theth Albania - Albanian Alps.” Visit Albania, YouTube.';

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
  String get theth1892ce => 'Ndërtohet kisha e fshatit Theth.';

  @override
  String get theth1908ce =>
      'Edith Durham udhëton nëpër malësi dhe e përshkruan Thethin në librin \"High Albania\" (1909).';

  @override
  String get theth1966ce => 'Krijohet Parku Kombëtar i Thethit.';

  @override
  String get theth2011ce => 'Hapet shtegu \"Majat e Ballkanit\", që e lidh Thethin me Kosovën dhe Malin e Zi.';

  @override
  String get theth2017ce => 'Albanologu Robert Elsie prehet në Theth.';

  @override
  String get theth2022ce => 'Thethi bëhet pjesë e Parkut të ri Kombëtar \"Alpet e Shqipërisë\".';

  @override
  String get krujaTitle => 'Kruja';

  @override
  String get krujaRegionTitle => 'Qarku i Durrësit, Shqipëri';

  @override
  String get krujaArtifactCulture => 'Mesjetare Shqiptare';

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
  String get krujaVideoCaption => '“KRUJA CITY & CASTLE 2021 | 4K DRONE CINEMATIC VIDEO.” GOGLA, YouTube.';

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
  String get kruja1190ce => 'Kruja bëhet kryeqyteti i Principatës së Arbrit, shteti i parë shqiptar i Mesjetës.';

  @override
  String get kruja1443ce => 'Më 28 nëntor, Skënderbeu merr Krujën dhe ngre flamurin shqiptar mbi kala.';

  @override
  String get kruja1450ce =>
      'Forcat e Skënderbeut i rezistojnë rrethimit të parë osman, të udhëhequr nga sulltan Murati II.';

  @override
  String get kruja1478ce => 'Pas një rrethimi mbi një vjeçar, Kruja bie në duart e osmanëve.';

  @override
  String get kruja1982ce => 'Muzeu i Skënderbeut hapet pranë kalasë.';

  @override
  String get kruja1989ce => 'Muzeu Etnografik Kombëtar hapet në një shtëpi të familjes Toptani, të ndërtuar më 1764.';

  @override
  String get albanianAlpsTitle => 'Alpet Shqiptare';

  @override
  String get albanianAlpsRegionTitle => 'Shqipëria Veriore';

  @override
  String get albanianAlpsArtifactCulture => 'Malësia Shqiptare';

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
  String get albanianAlpsVideoCaption => '“Valbona, Albania.” Visit Albania, YouTube.';

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
      'Strukturat njerëzore në Alpet Shqiptare pasqyrojnë mjedisin malor. Shtëpitë tradicionale malësore (kullë) janë ndërtuara nga blloqe masive guri gëlqeror me brendësi druri, të dizajnuara për t\'i rezistuar borës së rëndë dhe për të siguruar mbrojtje. Kullosa me mure guri, shtigje antike mushkash dhe kisha të vogla malore mbushin peizazhin.\nShtegu i Majave të Ballkanit, një itinerar ecjeje prej 192 km (120 miljesh) i hapur në 2011, lidh komunitete nëpër tre vende duke përdorur shumë nga këto shtigje tradicionale.';

  @override
  String get albanianAlpsLocationInfo1 =>
      'Alpet Shqiptare shtrihen nëpër rrethet e Shkodrës dhe Kukësit në Shqipërinë veriore, duke formuar kufirin e vendit me Malin e Zi dhe Kosovën. Vargu shtrihet rreth 65 km (40 milje) nga rajoni i Kelmendit në veriperëndim deri te zona e Valbonës në lindje. Luginat kryesore përfshijnë Thethin, Valbonën dhe Kelmendin.';

  @override
  String get albanianAlpsLocationInfo2 =>
      'Parku Kombëtar i Luginës së Valbonës dhe Parku Kombëtar i Thethit mbrojnë shumicën e pjesës shqiptare të vargut. Liqeni i Komanit, i aksesueshëm me traget nëpër një kanjon dramatik shpesh të krahasuar me fjordet skandinave, ofron një qasje mahnitëse në male nga jugu. Rajoni merr disa nga reshjet më të larta në Evropë, duke ushqyer lumenj dhe ujëvara të shumta.';

  @override
  String get albanianAlps1909ce =>
      'Edith Durham boton \"High Albania\", rrëfimin klasik për jetën mes fiseve të malësisë.';

  @override
  String get albanianAlps1929ce =>
      'Alpinistë britanikë bëjnë ngjitjen e parë të regjistruar në Majën e Jezercës (2 694 m), majën më të lartë të vargmalit.';

  @override
  String get albanianAlps1996ce => 'Krijohet Parku Kombëtar i Luginës së Valbonës.';

  @override
  String get albanianAlps2009ce => 'Zbulohet një akullnajë në pjesën shqiptare të vargmalit.';

  @override
  String get albanianAlps2011ce => 'Hapet shtegu \"Majat e Ballkanit\" përmes Shqipërisë, Kosovës dhe Malit të Zi.';

  @override
  String get albanianAlps2022ce =>
      'Thethi, Valbona dhe rezervatet përreth bashkohen në Parkun Kombëtar \"Alpet e Shqipërisë\".';

  @override
  String get korcaTitle => 'Korça';

  @override
  String get korcaRegionTitle => 'Korçë, Shqipëri';

  @override
  String get korcaArtifactCulture => 'Ortodokse Shqiptare';

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
  String get korcaVideoCaption => '“Korçë, Dardhë | Dardhe Korce Albania.” Visit Albania, YouTube.';

  @override
  String get korcaMapCaption => 'Harta që tregon vendndodhjen e Korçës në Shqipërinë juglindore.';

  @override
  String get korcaHistoryInfo1 =>
      'Korça është një qytet në Shqipërinë juglindore, i vendosur në një platformë të lartë në rreth 850 m (2,800 këmbë) mbi nivelin e detit. Qyteti ka qenë një qendër e kulturës, arsimit dhe artit shqiptar që nga shekulli i 19-të, duke fituar titullin \"djepi i kulturës shqiptare.\"\nShkolla e parë në gjuhën shqipe u hap këtu më 7 mars 1887, nga Pandeli Sotiri, duke shënuar një moment vendimtar në zgjimin kombëtar shqiptar. Korça gjithashtu priti shtypshkronjën e parë shqiptare dhe shoqëri të shumta letrare.';

  @override
  String get korcaHistoryInfo2 =>
      'Katedralja origjinale ortodokse u shkatërrua gjatë periudhës komuniste kur Shqipëria u shpall shteti i parë ateist në botë në 1967, duke shembur pothuajse të gjitha ndërtesat fetare. Katedralja e re e Ringjalljes (Katedralja Ngjallja e Krishtit) u ndërtua midis 1994 dhe 2002 mbi themelet e katedrales së vjetër, duke simbolizuar si ringjalljen fetare ashtu edhe ripërtëritjen kulturore kombëtare.\nKorça është gjithashtu e njohur për kontributin e saj në muzikën, artin shqiptar dhe Festivalin e famshëm vjetor të Birrës së Korçës, një nga më të mëdhenjtë në Ballkan.';

  @override
  String get korcaConstructionInfo1 =>
      'Katedralja e Ringjalljes u dizajnua në stil neo-bizantin, duke marrë frymëzim nga arkitektura tradicionale e kishave ortodokse ndërsa inkorporon teknika moderne ndërtimi. Katedralja ka një plan kryqëzor me një kupolë qendrore të madhe që arrin rreth 30 m (100 këmbë) në lartësi, të shoqëruar nga kupola më të vogla.\nJashtësia është e veshur me gur me ngjyrë të çelët me dritare dekorative me harqe, ndërsa brendësia është e zbukuruar me afreske dhe ikonografi të pikturuara nga artistë shqiptarë dhe grekë.';

  @override
  String get korcaConstructionInfo2 =>
      'Katedralja u ndërtua midis viteve 1994 dhe 2002. Ndërtimi modern me beton të armuar dhe skelet çeliku u përdor për integritetin strukturor, ndërsa elementet tradicionale prej guri dhe dekorative ruajnë estetikën bizantine.\nKambanorja, që ngrihet pranë katedrales, strehon një set kambanash që biën nëpër qytet. Sheshi dhe parku përreth krijojnë një qendër kulturore për qytetin, duke u lidhur me Muzeun Kombëtar të Artit Mesjetar, i cili strehon një nga koleksionet më të mira të ikonave bizantine në botë.';

  @override
  String get korcaLocationInfo1 =>
      'Korça ndodhet në Pellgun e Korçës, një platformë pjellore e rrethuar nga male në Shqipërinë juglindore. Qyteti ndodhet rreth 180 km (112 milje) në juglindje të Tiranës, pranë kufinjve me Greqinë dhe Maqedoninë e Veriut. Vargu malor i Moravës ngrihet në lindje, ndërsa Liqeni i Ohrit ndodhet në verilindje.';

  @override
  String get korcaLocationInfo2 =>
      'Platforma e Korçës ka qenë e banuar që nga kohërat parahistorike për shkak të tokës së pjellore dhe pozicionit strategjik përgjatë rrugëve antike tregtare që lidhnin Detin Adriatik me Detin Egje. Vendi arkeologjik i afërt i Maliqit, në brigjet e një liqeni të dikurshëm, ka dhënë dëshmi të banimit të vazhdueshëm që daton nga periudha neolitike, rreth 6000 p.e.s.';

  @override
  String get korca1769ce => 'Pas shkatërrimit të Voskopojës fqinje, një pjesë e tregtisë së saj kalon në Korçë.';

  @override
  String get korca1887ce => 'Më 7 mars hapet Mësonjëtorja, shkolla e parë në gjuhën shqipe.';

  @override
  String get korca1891ce => 'Sevasti Qiriazi themelon shkollën e parë shqipe për vajza.';

  @override
  String get korca1916ce => 'Nën mbrojtjen franceze shpallet Republika Autonome Shqiptare e Korçës.';

  @override
  String get korca1968ce => 'Regjimi komunist rrëzon katedralen ortodokse të Shën Gjergjit.';

  @override
  String get korca1994ce => 'Nis ndërtimi i Katedrales së Ngjalljes së Krishtit; ajo shenjtërohet në vitin 2002.';

  @override
  String get timelineEventIllyrianTribes =>
      'Popuj ilirë si taulantët, ardianët, dardanët dhe enkelejtë formohen në të gjithë Ballkanin Perëndimor.';

  @override
  String get timelineEventEpidamnos =>
      'Kolonë nga Korkyra dhe Korinti themelojnë Epidamnin në tokën e taulantëve. Si Dyrrah, Durrësi i sotëm, ai bëhet porti i madh i bregdetit të Adriatikut.';

  @override
  String get timelineEventBardylisDefeatsMacedon =>
      'Mbreti ilir Bardhyli mund dhe vret mbretin Perdika III të Maqedonisë. Një vit më vonë vëllai i Perdikës, Filipi II, kundërsulmon dhe e mund.';

  @override
  String get timelineEventAlexanderAtPelion =>
      'Aleksandri i Madh, ende i ri, shpartallon në Pelion, në juglindje të Shqipërisë së sotme, aleancën e mbretërve ilirë, Klitit dhe Glaukias.';

  @override
  String get timelineEventGlaukiasShieldsPyrrhus =>
      'Mbreti Glaukia i taulantëve strehon foshnjën Pirro të Epirit dhe refuzon t\'ua dorëzojë armiqve të tij. Vite më vonë e ndihmon të rikthehet në fronin e Epirit.';

  @override
  String get timelineEventTeutaTakesTheHelm =>
      'Pas vdekjes së papritur të mbretit Agron, e veja e tij Teuta sundon mbretërinë e ardianëve në emër të djalit të vogël të Agronit. Flotat e saj sulmojnë brigjet e Adriatikut dhe të Jonit dhe plaçkitin Foinikën (Finiqin e sotëm), qytetin më të pasur të Epirit.';

  @override
  String get timelineEventTeutaDefiesRome =>
      'Roma dërgon 200 anije kundër mbretëreshës Teuta. Lufta e Parë Ilire mbaron më 228 p.e.s. me Korkyrën, Epidamnin dhe Apoloninë nën mbrojtjen romake.';

  @override
  String get timelineEventGentiusFalls =>
      'Në Luftën e Tretë Ilire, Roma e mund mbretin Genti brenda pak javësh dhe e zë rob në Shkodër. Mbretëria e tij copëtohet në krahina nën kontrollin romak.';

  @override
  String get timelineEventEpirusSacked =>
      'Për ta ndëshkuar Epirin që kishte mbajtur anën e Maqedonisë, Roma plaçkit 70 qytete të tij dhe shet si skllevër 150 000 njerëz. Edhe jugu i Shqipërisë së sotme është ndër trojet e goditura.';

  @override
  String get timelineEventViaEgnatia =>
      'Roma ndërton Rrugën Egnatia, që nis nga Dyrrahu dhe Apolonia, kapërcen malet deri në Selanik dhe më vonë zgjatet deri në Bizant.';

  @override
  String get timelineEventCaesarAndPompey =>
      'Në luftën civile romake, Jul Cezari rrethon Pompeun në Dyrrah (Durrës), por zmbrapset. Disa javë më vonë ai e fiton luftën në Farsal të Greqisë.';

  @override
  String get timelineEventPaulInIllyricum =>
      'Në letrën drejtuar romakëve, apostulli Pal shkruan se e ka predikuar ungjillin \'deri në Ilirik\'.';

  @override
  String get timelineEventEmpireSplits =>
      'Me vdekjen e perandorit Theodosi I, Perandoria Romake ndahet përfundimisht. Trojet shqiptare i bien gjysmës lindore, që sundohet nga Kostandinopoja.';

  @override
  String get timelineEventAnastasiusEmperor =>
      'Anastasi I, i lindur në Dyrrah (Durrës), bëhet perandor bizantin dhe më vonë forcon muret e qytetit të tij të lindjes.';

  @override
  String get timelineEventButrintBaptistery =>
      'Butrinti ndërton një pagëzimore të madhe, dyshemeja e së cilës me mozaikë zogjsh, kafshësh dhe hardhish është ndër mozaikët më të bukur paleokristianë të Ballkanit.';

  @override
  String get timelineEventCodexBeratinus =>
      'Kopistë shkruajnë Ungjijtë e Mateut dhe të Markut me bojë argjendi mbi pergamenë të purpurt. I ruajtur në Berat të paktën që nga viti 1356, Kodiku i Beratit është ndër librat më të vjetër të Ungjillit në botë.';

  @override
  String get timelineEventBasilReconquers =>
      'Perandori Vasili II shkatërron shtetin bullgar, që kishte sunduar pjesën më të madhe të rajonit, dhe rivendos sundimin bizantin përmes Temës së Dyrrahut.';

  @override
  String get timelineEventAlbanoiNamed =>
      'Një kronikë bizantine përmend \'albanoi\' mes trupave të gjeneralit rebel Gjergj Maniaku, një nga dëshmitë e para të shkruara për shqiptarët.';

  @override
  String get timelineEventGreatSchism =>
      'Kishat e Romës dhe të Kostandinopojës ndahen. Me kalimin e kohës edhe të krishterët shqiptarë ndahen sipas së njëjtës vijë: katolikë në veri, ortodoksë në jug.';

  @override
  String get timelineEventNormansAtDyrrachium =>
      'Normanët e Robert Guiskardit mundin perandorin Aleks I në Dyrrah dhe hapin një luftë të gjatë mes normanëve, venedikasve dhe bizantinëve për bregdetin.';

  @override
  String get timelineEventArbanon =>
      'Progoni, zot i Krujës, themelon Arbrin, shtetin e parë shqiptar të Mesjetës. Pas tij sundojnë bijtë e tij, Gjini dhe Dhimitri.';

  @override
  String get timelineEventRegnumAlbaniae =>
      'Karli i Anzhuit, mbret i Sicilisë, shpallet mbret i Arbërisë (Regnum Albaniae), një shtet i kohës së kryqëzatave në bregdetin përreth Durrësit.';

  @override
  String get timelineEventSiegeOfBerat =>
      'Një ushtri anzhuine rrethon Beratin, por forcat bizantine që vijnë në ndihmë zënë rob komandantin e saj, Hygo de Sylinë, dhe rrethuesit ikin drejt Vlorës.';

  @override
  String get timelineEventVoiceInTheMountains =>
      'Një dokument gjyqësor në Raguzë (Dubrovnik) shënon: \'Dëgjova një zë që thërriste në mal në gjuhën shqipe.\' Është përmendja më e hershme e njohur e shqipes së folur.';

  @override
  String get timelineEventALanguageOfTheirOwn =>
      'Një raport i një murgu domenikan për mbretin e Francës shënon se shqiptarët kanë një gjuhë krejt të ndryshme nga latinishtja, por në librat e tyre përdorin shkronja latine.';

  @override
  String get timelineEventAlbanianPrincipalities =>
      'Perandoria Serbe e Stefan Dushanit, që kishte pushtuar shumicën e trojeve shqiptare, shpërbëhet pas vdekjes së tij. Familje si Balshajt, Topiajt, Muzakajt, Dukagjinët dhe Kastriotët sundojnë principatat e tyre.';

  @override
  String get timelineEventBattleOfSavra =>
      'Në Betejën e Savrës, një ushtri osmane mund dhe vret Balshën II, zotin e Durrësit. Shumë zotër shqiptarë shpejt bëhen vasalë të osmanëve.';

  @override
  String get timelineEventBattleOfKosovo =>
      'Zotër shqiptarë luftojnë krah ushtrisë serbe të princit Lazar kundër osmanëve në Fushë-Kosovë. Vriten si Lazari, ashtu edhe sulltan Murati I.';

  @override
  String get timelineEventOttomansTakeTheSouth =>
      'Forcat osmane pushtojnë Vlorën, Kaninën dhe Beratin. Një vit më vonë bie edhe Gjirokastra.';

  @override
  String get timelineEventRevoltOf1432 =>
      'Zotër shqiptarë të prirë nga Gjergj Arianiti ngrihen kundër sundimit osman dhe fitojnë disa beteja, para se kryengritja të shtypet më 1436.';

  @override
  String get timelineEventSkanderbegReturns =>
      'Gjergj Kastrioti, komandant osman i njohur si Skënderbe, braktis ushtrinë në Betejën e Nishit, merr Krujën më 28 nëntor dhe ngre flamurin e tij të kuq me shqiponjën e zezë dykrenare.';

  @override
  String get timelineEventLeagueOfLezhe =>
      'Princat shqiptarë bashkohen nën Skënderbeun në Besëlidhjen e Lezhës. Pas disa muajsh ata korrin fitoren e parë të madhe, në Torvioll.';

  @override
  String get timelineEventFirstSiegeOfKruja =>
      'Sulltan Murati II e rrethon Krujën për muaj të tërë me një ushtri të madhe, por garnizoni qëndron dhe ai tërhiqet.';

  @override
  String get timelineEventBattleOfAlbulena =>
      'Skënderbeu shpartallon një ushtri të madhe osmane në Albulenë (Ujëbardhë), një nga fitoret e tij më të famshme.';

  @override
  String get timelineEventBaptismalFormula =>
      'Kryepeshkopi Pal Engjëlli shkruan në një letër latinisht një formulë pagëzimi në shqip: \'Un\'te paghesont\' pr\'emenit t\'Atit e t\'Birit e t\'Spertit Senit.\' Është fjalia më e vjetër e njohur e shkruar shqip.';

  @override
  String get timelineEventMehmedsSieges =>
      'Sulltan Mehmeti II, pushtuesi i Kostandinopojës, e rrethon Krujën dy herë dhe ndërton kalanë e Elbasanit për t\'i ndarë më dysh trojet e Skënderbeut. Kruja sërish qëndron.';

  @override
  String get timelineEventSkanderbegDies =>
      'Skënderbeu vdes nga ethet në Lezhë më 17 janar. Pa të, qëndresa gradualisht shuhet.';

  @override
  String get timelineEventArbereshMigration =>
      'Ndërsa osmanët përparojnë, mijëra shqiptarë kalojnë në Italinë e Jugut dhe në Sicili. Pasardhësit e tyre, arbëreshët, flasin ende shqip sot në dhjetëra fshatra.';

  @override
  String get timelineEventShkoderFalls =>
      'Pas një rrethimi të gjatë, Venediku ua dorëzon Shkodrën osmanëve. Pothuajse e gjithë Shqipëria tani është nën sundimin osman; Durrësi bie më 1501.';

  @override
  String get timelineEventMeshari =>
      'Gjon Buzuku, prift katolik, përfundon \'Mesharin\', librin më të vjetër të ruajtur në gjuhën shqipe. Ruhet vetëm një kopje, në Bibliotekën e Vatikanit.';

  @override
  String get timelineEventBardhiDictionary =>
      'Frang Bardhi boton në Romë një fjalor latinisht–shqip, fjalorin e parë të gjuhës shqipe.';

  @override
  String get timelineEventIslamization =>
      'Gjatë shekullit XVII shumica e shqiptarëve kalojnë në Islam, shpesh për t\'u shpëtuar taksave të rënda dhe për t\'u ngritur në shërbimin osman. Bashkësitë katolike dhe ortodokse mbijetojnë.';

  @override
  String get timelineEventCuneusProphetarum =>
      'Kryepeshkopi Pjetër Bogdani boton në Padovë \'Cuneus Prophetarum\' (\'Çeta e profetëve\'), veprën e parë të madhe origjinale të prozës shqipe.';

  @override
  String get timelineEventVoskopojePress =>
      'Voskopoja, një qytet i pasur tregtar pranë Korçës, hap një nga shtypshkronjat e para në Ballkanin osman. Më 1744 ajo themelon Akademinë e Re.';

  @override
  String get timelineEventBushatiPashalik =>
      'Mehmet Pashë Bushati e bën Shkodrën qendrën e një pashallëku pothuajse të pavarur, të cilin familja e tij e sundon deri më 1831.';

  @override
  String get timelineEventAliPashaRises =>
      'Ali Pasha bëhet sundimtar i Janinës dhe ngre një shtet pothuajse të pavarur, që shtrihet në Shqipërinë e Jugut dhe në Greqinë kontinentale.';

  @override
  String get timelineEventAliPashaFalls =>
      'Pas një rrethimi të gjatë në Janinë, njerëzit e Sulltanit vrasin Ali Pashën e moshuar dhe ia dërgojnë kokën në Stamboll.';

  @override
  String get timelineEventMassacreOfTheBeys =>
      'Veziri i madh osman fton bejlerët shqiptarë në Manastir me premtimin e faljes dhe vret rreth 500 prej tyre, duke thyer pushtetin e zotërve të vjetër.';

  @override
  String get timelineEventVeqilharxhiPrimer =>
      'Naum Veqilharxhi boton një abetare shqip me një alfabet të shpikur prej tij, një nga veprat e para të Rilindjes Kombëtare.';

  @override
  String get timelineEventLeagueOfPrizren =>
      'Ndërsa Fuqitë e Mëdha përgatiten t\'u japin Serbisë dhe Malit të Zi troje të banuara nga shqiptarë, krerët shqiptarë mblidhen në Prizren për t\'i mbrojtur. Është lëvizja e parë kombëtare e organizuar; trupat osmane e shtypin më 1881.';

  @override
  String get timelineEventIstanbulAlphabet =>
      'Sami Frashëri dhe bashkatdhetarë të tij themelojnë në Stamboll një shoqëri për botimin e librave shqip dhe nxjerrin një alfabet për gjuhën shqipe.';

  @override
  String get timelineEventHerdsAndFields =>
      'Naim Frashëri boton \'Bagëti e Bujqësi\', një himn për fshatin shqiptar që bëhet poema më e dashur e Rilindjes.';

  @override
  String get timelineEventFirstAlbanianSchool =>
      'Më 7 mars hapet në Korçë Mësonjëtorja, shkolla e parë që mëson në gjuhën shqipe.';

  @override
  String get timelineEventSchoolForGirls =>
      'Sevasti Qiriazi themelon në Korçë shkollën e parë shqipe për vajza, ku vajzat mësojnë të lexojnë e të shkruajnë në gjuhën e tyre.';

  @override
  String get timelineEventSamiManifesto =>
      'Sami Frashëri boton \'Shqipëria ç\'ka qenë, ç\'është e ç\'do të bëhet?\', një projekt për një shtet shqiptar të lirë.';

  @override
  String get timelineEventFirstAlbanianLiturgy =>
      'Në Boston, Fan Noli kremton liturgjinë e parë ortodokse në gjuhën shqipe, fillimi i një kishe ortodokse shqiptare.';

  @override
  String get timelineEventCongressOfManastir =>
      'Kongresi i Manastirit miraton alfabetin e shqipes me bazë latine që përdoret ende sot.';

  @override
  String get timelineEventFlagAtDeciq =>
      'Gjatë kryengritjes së malësorëve më 1911, luftëtarët e Ded Gjo Lulit fitojnë në Deçiq dhe ngrenë flamurin shqiptar për herë të parë që nga shekulli XV.';

  @override
  String get timelineEventIndependence =>
      'Më 28 nëntor, Ismail Qemali ngre flamurin në Vlorë dhe shpall Shqipërinë të pavarur nga Perandoria Osmane.';

  @override
  String get timelineEventLondonBorders =>
      'Fuqitë e Mëdha e njohin Shqipërinë të pavarur, por e lënë Kosovën dhe troje të tjera me shqiptarë jashtë kufijve të saj.';

  @override
  String get timelineEventPrinceWied =>
      'Princ Vilhelm Vidi mbërrin për të sunduar Principatën e re të Shqipërisë. Brenda gjashtë muajve, kryengritjet dhe Lufta e Parë Botërore e detyrojnë të largohet.';

  @override
  String get timelineEventRepublicOfKorca =>
      'Nën mbrojtjen ushtarake franceze, Korça bëhet republikë autonome shqiptare, me shkollat, pullat dhe flamurin e saj.';

  @override
  String get timelineEventCongressOfLushnje =>
      'Kongresi i Lushnjës hedh poshtë planet për ndarjen e Shqipërisë mes fqinjëve dhe e bën Tiranën kryeqytet.';

  @override
  String get timelineEventVloraWar =>
      'Vullnetarë shqiptarë rrethojnë ushtrinë italiane në Vlorë dhe në shtator Italia tërhiqet nga Shqipëria kontinentale. Në dhjetor Shqipëria pranohet në Lidhjen e Kombeve.';

  @override
  String get timelineEventOrthodoxAutocephaly =>
      'Kongresi i Beratit shpall autoqefalinë e Kishës Ortodokse Shqiptare, të pavarur nga Patriarkana e Kostandinopojës.';

  @override
  String get timelineEventJuneRevolution =>
      'Një kryengritje e sjell në pushtet peshkopin Fan Noli me një program reformash. Gjashtë muaj më vonë Ahmet Zogu rikthehet me mbështetje të huaj dhe Noli largohet.';

  @override
  String get timelineEventKingZog => 'Presidenti Ahmet Zogu shpallet Zogu I, Mbret i Shqiptarëve.';

  @override
  String get timelineEventBektashiCentre =>
      'I ndaluar në Turqi, urdhri sufi bektashi vendos në një kongres në Korçë të zhvendosë qendrën e tij botërore në Tiranë, ku ndodhet edhe sot.';

  @override
  String get timelineEventKanunPublished =>
      'Botohet e plotë përmbledhja e Shtjefën Gjeçovit e \'Kanunit të Lekë Dukagjinit\', e drejta zakonore e malësive të veriut.';

  @override
  String get timelineEventItalianInvasion =>
      'Më 7 prill, trupat e Musolinit zbarkojnë në Durrës dhe në porte të tjera. Mbreti Zog largohet dhe Shqipëria i bashkohet kurorës italiane.';

  @override
  String get timelineEventKokalariBook =>
      'Musine Kokalari boton \'Siç më thotë nënua plakë\', tregime në të folmen e Gjirokastrës. Ajo është gruaja e parë shqiptare që boton prozë.';

  @override
  String get timelineEventWarWithGreece =>
      'Italia sulmon Greqinë nga toka shqiptare. Kundërsulmi grek depërton thellë në jug dhe merr Korçën në nëntor dhe Gjirokastrën në dhjetor.';

  @override
  String get timelineEventResistanceOrganises =>
      'Në Konferencën e Pezës, komunistë dhe nacionalistë formojnë Lëvizjen Nacionalçlirimtare. Më vonë po atë vit themelohet Balli Kombëtar, një organizatë nacionaliste rivale.';

  @override
  String get timelineEventGermanOccupation =>
      'Italia kapitullon në shtator dhe trupat gjermane pushtojnë Shqipërinë. Grupet rivale të rezistencës tani luftojnë edhe njëra-tjetrën, krahas pushtuesve.';

  @override
  String get timelineEventBesaJews =>
      'Familje shqiptare, myslimane e të krishtera, fshehin refugjatë hebrenj nga pushtuesit, duke mbajtur besën, një premtim të shenjtë. Shqipëria e mbyll luftën me më shumë hebrenj se sa kishte para saj.';

  @override
  String get timelineEventGovernmentAtBerat =>
      'I mbledhur në Berat në tetor, këshilli i rezistencës i udhëhequr nga komunistët formon një qeveri të përkohshme me Enver Hoxhën kryeministër.';

  @override
  String get timelineEventLiberation =>
      'Më 29 nëntor largohen trupat e fundit gjermane. Partizanët e udhëhequr nga komunistët marrin pushtetin dhe Enver Hoxha nis katër dekada sundimi njëpartiak.';

  @override
  String get timelineEventPeoplesRepublic =>
      'Shqipëria shpallet Republikë Popullore. Kundërshtarët gjykohen dhe burgosen, ndër ta shkrimtarja Musine Kokalari.';

  @override
  String get timelineEventCorfuChannel =>
      'Minat në Kanalin e Korfuzit dëmtojnë rëndë dy luftanije britanike dhe vrasin 44 marinarë. Mosmarrëveshja bëhet çështja e parë e gjykuar nga Gjykata Ndërkombëtare e Drejtësisë.';

  @override
  String get timelineEventBreakWithYugoslavia =>
      'Kur Titoja prishet me Stalinin, Hoxha i ndërpret lidhjet me Jugosllavinë dhe kthehet nga Bashkimi Sovjetik.';

  @override
  String get timelineEventBreakWithMoscow =>
      'Shqipëria mban anën e Kinës kundër Hrushovit. Bashkimi Sovjetik ndërpret marrëdhëniet dhe tërheq forcat e veta nga baza detare e Vlorës.';

  @override
  String get timelineEventAtheistState =>
      'Regjimi mbyll ose shkatërron xhamitë dhe kishat dhe e shpall Shqipërinë shtetin e parë ateist në botë.';

  @override
  String get timelineEventBunkers =>
      'Nga frika e një pushtimi, regjimi e mbush vendin me bunkerë betoni, rreth 170 000 të tillë, të ndërtuar nga fundi i viteve 1960 deri në mesin e viteve 1980.';

  @override
  String get timelineEventChronicleInStone =>
      'Ismail Kadare boton \'Kronikë në gur\', ku Gjirokastra e tij e lindjes gjatë Luftës së Dytë Botërore shihet me sytë e një fëmije.';

  @override
  String get timelineEventOrthographicCongress =>
      'Kongresi i Drejtshkrimit përcakton një normë të vetme për shqipen e shkruar, të mbështetur kryesisht në dialektin toskë të jugut.';

  @override
  String get timelineEventBreakWithChina =>
      'Kina ndërpret ndihmat dhe Shqipëria prishet me aleatin e saj të fundit, duke u mbështetur vetëm te forcat e veta.';

  @override
  String get timelineEventMotherTeresaNobel =>
      'Nënë Tereza, e lindur si Anjezë Gonxhe Bojaxhiu në një familje shqiptare në Shkup, merr Çmimin Nobel për Paqe për punën e saj mes të varfërve të Kalkutës.';

  @override
  String get timelineEventHoxhaDies =>
      'Enver Hoxha vdes më 11 prill. Pasardhësi i tij, Ramiz Alia, i lehtëson kontrollet vetëm ngadalë.';

  @override
  String get timelineEventRegimeCracks =>
      'Në korrik, mijëra shqiptarë futen në ambasadat e huaja për t\'u larguar nga vendi. Në dhjetor, protestat e studentëve në Tiranë e detyrojnë regjimin të lejojë partitë opozitare.';

  @override
  String get timelineEventFaithReturns =>
      'Më 4 nëntor, dom Simon Jubani thotë meshën e parë publike pas dekadash, në një varrezë në Shkodër. Brenda pak muajsh, xhamitë dhe kishat rihapen në të gjithë vendin.';

  @override
  String get timelineEventFirstFreeElections =>
      'Në mars, Shqipëria mban zgjedhjet e para shumëpartiake pas dekadash. Fitojnë ish-komunistët, por një vit më vonë pushtetin e merr Partia Demokratike.';

  @override
  String get timelineEventVloraShip =>
      'Më 8 gusht anija e mallrave \'Vlora\' mbërrin në Bari me rreth 20 000 shqiptarë në bord, pamja që shënjoi një eksod masiv.';

  @override
  String get timelineEventPyramidCrisis =>
      'Rënia e skemave piramidale fshin kursimet e një pjese të madhe të vendit dhe shkakton trazira të armatosura, ku humbin jetën më shumë se 2 000 njerëz.';

  @override
  String get timelineEventKosovoRefugees =>
      'Gjatë luftës në Kosovë, Shqipëria pret rreth 450 000 refugjatë, shumicën prej tyre në shtëpi private.';

  @override
  String get timelineEventIsoPolyphony =>
      'UNESCO e shpall isopolifoninë popullore shqiptare, këngën me shumë zëra të jugut, kryevepër të trashëgimisë gojore dhe shpirtërore të njerëzimit.';

  @override
  String get timelineEventKadareBooker =>
      'Ismail Kadare fiton çmimin e parë \'Man Booker International\' për krijimtarinë e tij.';

  @override
  String get timelineEventNatoMembership =>
      'Shqipëria anëtarësohet në NATO më 1 prill dhe pak javë më vonë aplikon për t\'u bërë pjesë e Bashkimit Evropian.';

  @override
  String get timelineEventEuCandidate =>
      'Shqipëria merr statusin zyrtar të vendit kandidat për anëtarësim në Bashkimin Evropian.';

  @override
  String get timelineEventDurresEarthquake =>
      'Një tërmet me magnitudë 6,4 godet pranë Durrësit më 26 nëntor, duke vrarë 51 njerëz dhe duke lënë mijëra të pastrehë.';

  @override
  String get timelineEventEuTalks =>
      'Shqipëria hap zyrtarisht negociatat e anëtarësimit me Bashkimin Evropian më 19 korrik.';

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
  String get buddyHeaderTitle => 'Pathfinder';

  @override
  String get buddyHeaderSubtitle => 'Udhërrëfyesi juaj AI për Shqipërinë';

  @override
  String get buddyEmptyTitle => 'Si mund të ju ndihmoj me udhëtimin?';

  @override
  String get buddyEmptySubtitle => 'Më pyesni për vende, ushqim, buxhet ose itinerare në Shqipëri.';

  @override
  String get buddyComposerHint => 'Shkruaji Pathfinder-it…';

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
  String get refineWithBuddyButton => 'Përsosni me Pathfinder';

  @override
  String get refineComposerHint => 'Kërkoji Pathfinder-it të përmirësojë këtë udhëtim…';

  @override
  String get refineEmptyTitle => 'Çfarë duhet të ndryshojmë?';

  @override
  String get refineEmptySubtitle =>
      'Kërkoji Pathfinder-it ta përshtasë këtë udhëtim — shkurto një ditë, ndrysho një ndalesë, shto diçka të re.';

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
  String get buddyAttachFormatError => 'Foto e papërkrahur — përdor JPG, PNG, GIF ose WebP';

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
      'Zgjidh profilin që të ngjan më shumë tani. Është vetëm pikënisja — sa më shumë të bisedosh me Pathfinder, aq më mirë do ta kuptojë se si udhëton në të vërtetë. Buxhetin tënd, ritmin tënd, çfarë anashkalon, çfarë nuk e humb kurrë. Me kohën, rekomandimet nuk do të duken më të përgjithshme, por sikur janë krijuar enkas për ty.';

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
  String get myTripsEmptySubtitle => 'Planifiko një me Pathfinder dhe prek Ruaj itinerarin.';

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
      'Pathfinder Albania mund t\'i shënojë automatikisht ndalesat kur je afër tyre brenda orarit. Vendndodhja qëndron në pajisjen tënde.';

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
      'Qasja në vendndodhje është bllokuar. Hap Cilësimet për ta lejuar Pathfinder Albania.';

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
  String get tripDetailDayActionAddStop => 'Shto ndalesë këtu';

  @override
  String get tripDetailDayActionDelete => 'Fshi ditën';

  @override
  String get tripDetailRenameDayDialogTitle => 'Riemërto ditën';

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

  @override
  String get placeCardOpenInMaps => 'Hap në harta';
}
