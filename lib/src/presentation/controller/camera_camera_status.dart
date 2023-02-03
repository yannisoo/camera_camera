import 'package:camera/camera.dart';
import 'package:camera_camera_overlay/src/shared/entities/camera.dart';

abstract class CameraCameraStatus {}

class CameraCameraEmpty extends CameraCameraStatus {
  CameraCameraEmpty();
}

class CameraCameraLoading extends CameraCameraStatus {
  CameraCameraLoading();
}

class CameraCameraFailure extends CameraCameraStatus {
  String message;
  CameraException? exception;
  CameraCameraFailure({
    required this.message,
    this.exception,
  });
}

class CameraCameraSuccess extends CameraCameraStatus {
  Camera camera;
  CameraCameraSuccess({
    required this.camera,
  });
}

extension CameraCameraStatusExt on CameraCameraStatus {
  Camera get camera => (this as CameraCameraSuccess).camera;
  CameraCameraFailure get failure => this as CameraCameraFailure;
  CameraCameraLoading get loading => this as CameraCameraLoading;
  CameraCameraSuccess get success => this as CameraCameraSuccess;
  dynamic when({
    Function(String message, dynamic exception)? failure,
    Function()? loading,
    required Function() orElse,
    Function(Camera camera)? success,
  }) {
    switch (this.runtimeType) {
      case CameraCameraFailure:
        {
          if (failure != null) {
            return failure(this.failure.message, this.failure.exception);
          } else {
            return orElse();
          }
        }

      case CameraCameraLoading:
        {
          if (loading != null) {
            return loading();
          } else {
            return orElse();
          }
        }

      case CameraCameraSuccess:
        {
          if (success != null) {
            return success(this.success.camera);
          } else {
            return orElse();
          }
        }

      default:
        throw "CAMERA CAMERA (UI) INVALID STATUS";
    }
  }
}
