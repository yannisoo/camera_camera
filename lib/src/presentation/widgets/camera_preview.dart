import 'package:camera_camera_overlay/src/presentation/controller/camera_camera_controller.dart';
import 'package:camera_camera_overlay/src/presentation/controller/camera_camera_status.dart';
import 'package:camera_camera_overlay/src/shared/entities/camera_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraCameraPreview extends StatefulWidget {
  final void Function(String value)? onFile;
  final CameraCameraController controller;
  final Widget? overlay;
  final bool enableZoom;
  CameraCameraPreview({
    Key? key,
    this.onFile,
    this.overlay,
    required this.controller,
    required this.enableZoom,
  }) : super(key: key);

  @override
  _CameraCameraPreviewState createState() => _CameraCameraPreviewState();
}

class _CameraCameraPreviewState extends State<CameraCameraPreview> {
  @override
  void initState() {
    widget.controller.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ValueListenableBuilder<CameraCameraStatus>(
      valueListenable: widget.controller.statusNotifier,
      builder: (_, status, __) => status.when(
          success: (camera) => GestureDetector(
                onScaleUpdate: (details) {
                  widget.controller.setZoomLevel(details.scale);
                },
                child: Stack(
                  children: [
                    if (widget.controller.cameraMode ==
                        CameraMode.ratioFull) ...[
                      OverflowBox(
                          maxHeight: size.height,
                          maxWidth:
                              size.width * (widget.controller.aspectRatio),
                          child: widget.controller.buildPreview()),
                    ] else ...[
                      Center(
                        child: AspectRatio(
                          aspectRatio: widget.controller.cameraMode.value,
                          child: widget.controller.buildPreview(),
                        ),
                      ),
                    ],
                    if (widget.overlay != null) widget.overlay!,
                    if (camera.zoom != null && widget.enableZoom)
                      Positioned(
                        bottom: 116,
                        left: 0.0,
                        right: 0.0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black.withOpacity(0.6),
                          child: IconButton(
                            icon: Center(
                              child: Text(
                                "${camera.zoom?.toStringAsFixed(1)}x",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            onPressed: () {
                              widget.controller.zoomChange();
                            },
                          ),
                        ),
                      ),
                    if (widget.controller.flashModes.length > 1)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32, left: 64),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black.withOpacity(0.6),
                            child: IconButton(
                              onPressed: () {
                                widget.controller.changeFlashMode();
                              },
                              icon: Icon(
                                camera.flashModeIcon,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: InkWell(
                          onTap: () {
                            widget.controller.takePhoto();
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          failure: (message, _) => Container(
                color: Colors.black,
                child: Text(message),
              ),
          orElse: () => Container(
                color: Colors.black,
              )),
    );
  }

  Widget _wrapInRotatedBox(
      {required Widget child, required DeviceOrientation orentation}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return RotatedBox(
      quarterTurns: _getQuarterTurns(orentation),
      child: child,
    );
  }

  int _getQuarterTurns(DeviceOrientation orentation) {
    return turns[orentation]!;
  }

  Map<DeviceOrientation, int> turns = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeRight: 1,
    DeviceOrientation.portraitDown: 2,
    DeviceOrientation.landscapeLeft: 3,
  };
}
