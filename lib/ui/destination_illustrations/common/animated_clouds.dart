import 'dart:async';

import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/ui/common/utils/context_utils.dart';
import 'package:pathfinder_albania/ui/common/utils/duration_utils.dart';

// Shows a set of clouds that animated onto stage.
// When value-key is changed, a new set of clouds will animate into place and the old ones will animate out.
// Uses a random seed system, to make sure we get the same set of clouds for each destination, without actually having to hand-position them.
class AnimatedClouds extends StatefulWidget {
  const AnimatedClouds({
    super.key,
    required this.destinationType,
    required this.opacity,
  });
  final DestinationType destinationType;
  final double opacity;
  @override
  State<AnimatedClouds> createState() => _AnimatedCloudsState();
}

class _AnimatedCloudsState extends State<AnimatedClouds> with SingleTickerProviderStateMixin {
  late List<_Cloud> _clouds = [];
  List<_Cloud> _oldClouds = [];
  late final AnimationController _anim = AnimationController(vsync: this, duration: 1500.animateMs);

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      setState(() => _clouds = _getClouds());
    });
    _showClouds();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedClouds oldWidget) {
    if (oldWidget.destinationType != widget.destinationType) {
      _oldClouds = _clouds;
      _clouds = _getClouds();
      _showClouds();
    }
    super.didUpdateWidget(oldWidget);
  }

  int _getCloudSeed(DestinationType type) {
    return switch (type) {
      DestinationType.butrint => 2,
      DestinationType.berat => 78,
      DestinationType.gjirokaster => 1,
      DestinationType.apollonia => 500,
      DestinationType.theth => 37,
      DestinationType.kruja => 111,
      DestinationType.albanianAlps => 15,
      DestinationType.korca => 2,
    };
  }

  /// Starts playing the clouds animation.
  void _showClouds() => _anim.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    // Old clouds animate from 0 to startOffset, new clouds do the opposite.
    Widget buildCloud(_Cloud c, {required bool isOld, required int startOffset}) {
      // Use a positive, or negative start offset, based on index (within the cloud's own set, so
      // outgoing clouds alternate sides too and each lane keeps drifting the same way)
      final index = (isOld ? _oldClouds : _clouds).indexOf(c);
      final stOffset = index % 2 == 0 ? -startOffset : startOffset;
      // If old, we will end at the stOffset and start at 0, if new, start at stOffset, and end at 0
      double curvedValue = Curves.easeOut.transform(_anim.value);
      return Positioned(
        top: c.pos.dy,
        left: isOld ? c.pos.dx - stOffset * curvedValue : c.pos.dx + stOffset * (1 - curvedValue),
        child: Opacity(opacity: isOld ? 1 - _anim.value : _anim.value, child: c),
      );
    }

    return RepaintBoundary(
      child: ClipRect(
        child: OverflowBox(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, _) {
              // A stack with 2 sets of clouds, one set is moving out of view while the other moves in.
              return Stack(
                clipBehavior: Clip.hardEdge,
                key: ValueKey(widget.destinationType),
                children: [
                  if (_anim.value != 1) ...[
                    ..._oldClouds.map((c) => buildCloud(c, isOld: true, startOffset: 1000)),
                  ],
                  ..._clouds.map((c) => buildCloud(c, isOld: false, startOffset: 1000)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<_Cloud> _getClouds() {
    Size size = ContextUtils.getSize(context) ?? Size(context.widthPx, 400);
    rndSeed = _getCloudSeed(widget.destinationType);
    return List<_Cloud>.generate(3, (index) {
      return _Cloud(
        Offset(rnd.getDouble(-200, size.width - 100), rnd.getDouble(50, size.height - 50)),
        scale: rnd.getDouble(.7, 1),
        flipX: rnd.getBool(),
        flipY: rnd.getBool(),
        opacity: widget.opacity,
        size: 500,
      );
    }).toList();
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud(
    this.pos, {
    this.scale = 1,
    this.flipX = false,
    this.flipY = false,
    required this.opacity,
    required this.size,
  });

  final Offset pos;
  final double scale;
  final bool flipX;
  final bool flipY;
  final double opacity;
  final double size;

  @override
  Widget build(BuildContext context) => Transform.scale(
    scaleX: scale * (flipX ? -1 : 1),
    scaleY: scale * (flipY ? -1 : 1),
    child: Image.asset(
      ImagePaths.cloud,
      excludeFromSemantics: true,
      opacity: AlwaysStoppedAnimation(.4 * opacity),
      width: size * scale,
      fit: BoxFit.fitWidth,
    ),
  );
}
