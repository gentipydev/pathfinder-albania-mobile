import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/data/destination_data.dart';
import 'package:pathfinder_albania/logic/data/destinations_data/butrint_data.dart';
import 'package:pathfinder_albania/logic/data/destinations_data/berat_data.dart';
import 'package:pathfinder_albania/logic/data/destinations_data/gjirokaster_data.dart';
import 'package:pathfinder_albania/logic/data/destinations_data/apollonia_data.dart';
import 'package:pathfinder_albania/logic/data/destinations_data/theth_data.dart';
import 'package:pathfinder_albania/logic/data/destinations_data/kruja_data.dart';
import 'package:pathfinder_albania/logic/data/destinations_data/albanian_alps_data.dart';
import 'package:pathfinder_albania/logic/data/destinations_data/korca_data.dart';

class DestinationsLogic {
  List<DestinationData> all = [];

  final int timelineStartYear = -1500;
  final int timelineEndYear = 2100;

  DestinationData getData(DestinationType value) {
    DestinationData? result = all.firstWhereOrNull((w) => w.type == value);
    if (result == null) throw ('Could not find data for destination type $value');
    return result;
  }

  void init() {
    all = [
      ApolloniaData(),
      KrujaData(),
      GjirokasterData(),
      ButrintData(),
      ThethData(),
      KorcaData(),
      BeratData(),
      AlbanianAlpsData(),
    ];
  }
}
