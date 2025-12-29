import 'package:secmtp_sdk/at_index.dart';
import 'package:topon.flutter.demo/main.dart';
import 'package:topon.flutter.demo/manager/splash_sdk.dart';

final ListenerManager = ListenerTool();

class ListenerTool {
  downLoadListen() {
    ATListenerManager.downloadEventHandler.listen((value) {
      switch (value.downloadStatus) {
        case DownloadStatus.downloadStart:
          print(
              "flutter downloadStart ---- placementID: ${value.placementID}, totalBytes: ${value.totalBytes}, currBytes: ${value.currBytes}, "
              "fileName: ${value.fileName}, appName: ${value.appName}, extra: ${value.extraMap}");
          break;
        case DownloadStatus.downloadUpdate:
          print(
              "flutter downloadUpdate ---- placementID: ${value.placementID}, totalBytes: ${value.totalBytes}, currBytes: ${value.currBytes}, "
              "fileName: ${value.fileName}, appName: ${value.appName}, extra: ${value.extraMap}");
          break;
        case DownloadStatus.downloadPause:
          print(
              "flutter downloadPause ---- placementID: ${value.placementID}, totalBytes: ${value.totalBytes}, currBytes: ${value.currBytes}, "
              "fileName: ${value.fileName}, appName: ${value.appName}, extra: ${value.extraMap}");
          break;
        case DownloadStatus.downloadFinished:
          print(
              "flutter downloadFinished ---- placementID: ${value.placementID}, totalBytes: ${value.totalBytes}, "
              "fileName: ${value.fileName}, appName: ${value.appName}, extra: ${value.extraMap}");
          break;
        case DownloadStatus.downloadFailed:
          print(
              "flutter downloadFailed ---- placementID: ${value.placementID}, totalBytes: ${value.totalBytes}, currBytes: ${value.currBytes}, "
              "fileName: ${value.fileName}, appName: ${value.appName}, extra: ${value.extraMap}");
          break;
        case DownloadStatus.downloadInstalled:
          print(
              "flutter downloadInstalled ---- placementID: ${value.placementID}, "
              "fileName: ${value.fileName}, appName: ${value.appName}, extra: ${value.extraMap}");
          break;
        case DownloadStatus.downloadUnknown:
          print("flutter downloadUnknow");
          break;
      }
    });
  }
}
