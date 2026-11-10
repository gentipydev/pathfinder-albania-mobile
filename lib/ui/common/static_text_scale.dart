import 'package:travel_buddy/common_libs.dart';

class StaticTextScale extends StatelessWidget {
  const StaticTextScale({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling,
      ),
      child: child,
    );
  }
}
