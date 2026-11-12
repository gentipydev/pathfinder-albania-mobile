import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/common/string_utils.dart';
import 'package:pathfinder_albania/logic/data/destination_data.dart';

/// To match designs:
/// - need a line-break after the first line
/// - of/the should be down-sized
/// Accomplished using a set of TextSpans, and a white list of 'small words'
class DestinationTitleText extends StatelessWidget {
  const DestinationTitleText(this.data, {super.key, this.enableShadows = false, this.enableHero = true});
  final DestinationData data;
  final bool enableShadows;
  final bool enableHero;
  @override
  Widget build(BuildContext context) {
    var textStyle = $styles.text.destinationTitle.copyWith(
      color: $styles.colors.offWhite,
    );
    // Only titles too wide for a 375pt screen at full size step down to 56px:
    // "Gjirokastër" / "Gjirokastra" are ~367px wide at 64px, the next widest word is ~317px.
    bool smallText = [DestinationType.gjirokaster].contains(data.type);
    if (smallText) {
      textStyle = textStyle.copyWith(fontSize: 56 * $styles.scale);
    }

    // First, get a list like: ['the\n', 'destination', 'name']
    final title = data.title.toLowerCase();
    // Split on spaces, later, add either a linebreak or a space back in.
    List<String> pieces = title.split(' ');
    // TextSpan builder, figures out whether to use small text, and adds linebreak or space (or nothing).
    TextSpan buildTextSpan(String text) {
      final smallWords = ['of', 'the'];
      bool useSmallText = smallWords.contains(text.trim());
      int i = pieces.indexOf(text);
      bool addLinebreak = i == 0 && pieces.length > 1;
      bool addSpace = !addLinebreak && i < pieces.length - 1;
      if (useSmallText == false) {
        text = StringUtils.capitalize(text);
      }
      return TextSpan(
        text:
            '$text${addLinebreak
                ? '\n'
                : addSpace
                ? ' '
                : ''}',
        style: useSmallText ? textStyle.copyWith(fontSize: 20 * $styles.scale) : textStyle,
      );
    }

    List<Shadow> shadows = enableShadows ? $styles.shadows.textSoft : [];
    var content = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: textStyle.copyWith(shadows: shadows),
        children: pieces.map(buildTextSpan).toList(),
      ),
    );
    // Respect reduce-motion like the illustration heroes do (see IllustrationPiece).
    return enableHero && !$styles.disableAnimations
        ? Hero(
            tag: 'destinationTitle-$title',
            child: content,
          )
        : content;
  }
}
