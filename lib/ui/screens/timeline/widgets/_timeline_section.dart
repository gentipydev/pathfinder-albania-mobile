part of '../timeline_screen.dart';

class TimelineSection extends StatelessWidget {
  const TimelineSection(this.data, this.selectedYr, {super.key, required this.selectedDestination});
  final DestinationData data;
  final int selectedYr;
  final DestinationType? selectedDestination;

  /// Strength of the tinted (luminosity) image over the lane colour.
  static const double _imageOpacity = .85;

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedDestination == data.type;
    // get a fraction from 0 - 1 based on selected yr and start/end yr of the destination
    // 500, 250, 750
    int startYr = data.startYr, endYr = data.endYrOrNow;
    double fraction = (selectedYr - startYr) / (endYr - startYr);
    fraction = fraction.clamp(0, 1);

    return Semantics(
      label:
          '${data.title}, ${$strings.timelineSemanticDate(
            StringUtils.formatYr(data.startYr),
            StringUtils.formatEndYr(data.endYr),
          )}',
      child: IgnorePointerKeepSemantics(
        child: Container(
          alignment: Alignment(0, -1 + fraction * 2),
          padding: EdgeInsets.all($styles.insets.xs),
          decoration: BoxDecoration(color: data.type.fgColor),
          // The pill clip sits INSIDE the blend layer so the layer's content is
          // already rounded. A clip placed outside the luminosity layer is not
          // applied when that layer is composited (Impeller), which let the
          // image's square corners spill past the bar's rounded ends.
          child: BlendMask(
            blendModes: isSelected ? const [] : const [BlendMode.luminosity],
            opacity: _imageOpacity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: _buildDestinationImage(),
            ),
          ),
        ),
      ),
    );
  }

  Container _buildDestinationImage() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: data.type.bgColor,
        image: DecorationImage(
          fit: BoxFit.cover,
          alignment: Alignment(0, -.5),
          image: AssetImage(data.type.flattened),
        ),
      ),
    );
  }
}
