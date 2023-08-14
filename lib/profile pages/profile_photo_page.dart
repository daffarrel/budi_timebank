import 'package:flutter/material.dart';

/// View profile photo in full page
///
/// Credit to https://stackoverflow.com/a/64689813/13617136
class ProfilePhotoPage extends StatefulWidget {
  const ProfilePhotoPage({super.key, required this.name, required this.image});

  final String name;
  final ImageProvider image;

  @override
  State<ProfilePhotoPage> createState() => _ProfilePhotoPageState();
}

class _ProfilePhotoPageState extends State<ProfilePhotoPage>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late Animation<Matrix4>? _animationReset;
  late AnimationController _controllerReset;

  void _onAnimateReset() {
    _transformationController.value = _animationReset!.value;
    if (!_controllerReset.isAnimating) {
      _animationReset?.removeListener(_onAnimateReset);
      _animationReset = null;
      _controllerReset.reset();
    }
  }

  void _animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(_controllerReset);
    _animationReset?.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

// Stop a running reset to home transform animation.
  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset?.removeListener(_onAnimateReset);
    _animationReset = null;
    _controllerReset.reset();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_controllerReset.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) async {
    _animateResetInitialize();
  }

  @override
  void initState() {
    super.initState();
    _controllerReset = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controllerReset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Center(
        child: Hero(
          tag: 'profile-photo',
          child: InteractiveViewer(
            onInteractionStart: _onInteractionStart,
            onInteractionEnd: _onInteractionEnd,
            transformationController: _transformationController,
            // minScale: 1.0,
            clipBehavior: Clip.none,
            child: Image(
              image: widget.image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
