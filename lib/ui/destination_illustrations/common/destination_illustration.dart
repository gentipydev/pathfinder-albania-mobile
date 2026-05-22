import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/ui/destination_illustrations/albanian_alps_illustration.dart';
import 'package:travel_buddy/ui/destination_illustrations/apollonia_illustration.dart';
import 'package:travel_buddy/ui/destination_illustrations/berat_illustration.dart';
import 'package:travel_buddy/ui/destination_illustrations/butrint_illustration.dart';
import 'package:travel_buddy/ui/destination_illustrations/common/destination_illustration_config.dart';
import 'package:travel_buddy/ui/destination_illustrations/gjirokaster_illustration.dart';
import 'package:travel_buddy/ui/destination_illustrations/korca_illustration.dart';
import 'package:travel_buddy/ui/destination_illustrations/kruja_illustration.dart';
import 'package:travel_buddy/ui/destination_illustrations/theth_illustration.dart';

/// Convenience class for showing an illustration when all you have is the type.
class DestinationIllustration extends StatelessWidget {
  const DestinationIllustration(this.type, {super.key, required this.config});
  final DestinationIllustrationConfig config;
  final DestinationType type;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      DestinationType.albanianAlps => AlbanianAlpsIllustration(config: config),
      DestinationType.apollonia => ApolloniaIllustration(config: config),
      DestinationType.berat => BeratIllustration(config: config),
      DestinationType.butrint => ButrintIllustration(config: config),
      DestinationType.gjirokaster => GjirokasterIllustration(config: config),
      DestinationType.korca => KorcaIllustration(config: config),
      DestinationType.kruja => KrujaIllustration(config: config),
      DestinationType.theth => ThethIllustration(config: config),
    };
  }
}
