import 'dart:developer';

import 'package:secmtp_sdk/at_index.dart';
import 'package:event_bus/event_bus.dart';
import '../main.dart';
import '../topsize.dart';
import '../configuration_sdk.dart';

final NativeManager = NativeTool();

class NativeTool {
  NativeTool() {
    // 设置监听
    nativeAdListener();
  }

  //加载广告
  startLoadNativeAd() async {
    loadNativeAd();
    EventBusUtil.eventBus.fire(AdEvent(
        placementId: Configuration.nativePlacementID,
        type: AdEventType.loading));
  }

  //展示广告
  startShowNativeAd() async {
    //到达展示场景，展示前检查是否准备就绪
    ATNativeManager.nativeAdReady(
      placementID: Configuration.nativePlacementID,
    ).then((value) async {
      print('flutter nativeAdReady: $value');
      if (value == true) {
        //场景统计(可选)
        entryNativeScenario();
        //查看有效广告缓存(可选)
        getNativeAdValidAds();
        //已经准备就绪，拿到NativeView显示即可
        EventBusUtil.eventBus
            .fire(NativeAdWidgetEvent(nativeWidget: getNativeView()));
      } else {
        //没有准备就绪，可能是还在加载中或者加载失败，下方有检查加载状态API。
        //若加载失败，可在加载失败监听中重新发起加载。
        //若加载中，重复发起加载是无效的。
        //您可以根据实际逻辑来调整具体代码
        int isLoading = await checkNativeAdLoadStatus();
        if (isLoading == 1) {
          print('广告正在加载中... + ${Configuration.nativePlacementID}');
        } else {
          print('广告还没加载，发起加载 + ${Configuration.nativePlacementID}');
          startLoadNativeAd();
        }
      }
    });
  }

  //添加监听
  nativeAdListener() {
    ATListenerManager.nativeEventHandler.listen((value) {
      switch (value.nativeStatus) {
        case NativeStatus.nativeAdFailToLoadAD:
          log(
              "flutter nativeAdFailToLoadAD ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}");
          EventBusUtil.eventBus.fire(AdEvent(
              placementId: value.placementID, type: AdEventType.failed));
          break;
        case NativeStatus.nativeAdDidFinishLoading:
          log(
              "flutter nativeAdDidFinishLoading ---- placementID: ${value.placementID}");
          //到达展示场景，展示前检查是否准备就绪
          ATNativeManager.nativeAdReady(
            placementID: value.placementID,
          ).then((isReady) {
            log('flutter nativeAdReady: $isReady');
            if (isReady == true) {
              EventBusUtil.eventBus.fire(AdEvent(
                  placementId: value.placementID, type: AdEventType.ready));
            } else {
              //else
            }
          });
          break;
        case NativeStatus.nativeAdDidClick:
          log(
              "flutter nativeAdDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case NativeStatus.nativeAdDidDeepLink:
          log(
              "flutter nativeAdDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}");
          break;
        case NativeStatus.nativeAdDidEndPlayingVideo:
          log(
              "flutter nativeAdDidEndPlayingVideo ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case NativeStatus.nativeAdEnterFullScreenVideo:
          log(
              "flutter nativeAdEnterFullScreenVideo ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case NativeStatus.nativeAdExitFullScreenVideoInAd:
          log(
              "flutter nativeAdExitFullScreenVideoInAd ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case NativeStatus.nativeAdDidShowNativeAd:
          log(
              "flutter nativeAdDidShowNativeAd ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case NativeStatus.nativeAdDidStartPlayingVideo:
          log(
              "flutter nativeAdDidStartPlayingVideo ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case NativeStatus.nativeAdDidTapCloseButton:
          log(
              "flutter nativeAdDidTapCloseButton ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          EventBusUtil.eventBus.fire(
              AdEvent(placementId: value.placementID, type: AdEventType.close));
          //移除广告
          removeNativeAd();

          ATNativeManager.nativeAdReady(
            placementID: value.placementID,
          ).then((isReady) {
            log('flutter nativeAdReady: $isReady');
            if (isReady == true) {
              EventBusUtil.eventBus.fire(AdEvent(
                  placementId: value.placementID, type: AdEventType.ready));
            } else {
              EventBusUtil.eventBus.fire(AdEvent(
                  placementId: value.placementID, type: AdEventType.not_ready));
            }
          });

          break;
        case NativeStatus.nativeAdDidCloseDetailInAdView:
          log(
              "flutter nativeAdDidCloseDetailInAdView ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case NativeStatus.nativeAdDidLoadSuccessDraw:
          log(
              "flutter nativeAdDidLoadSuccessDraw ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case NativeStatus.nativeAdUnknown:
          log("flutter downloadUnknown");
          break;
      }
    });
  }

  //获取原生Widget
  getNativeView() {
    return PlatformNativeWidget(
        Configuration.nativePlacementID,
        {
          ATNativeManager.parent():
              ATNativeManager.createNativeSubViewAttribute(
                  topSizeTool.getWidth(), 340,
                  backgroundColorStr: '#FFFFFF'),
          ATNativeManager.appIcon():
              ATNativeManager.createNativeSubViewAttribute(50, 50,
                  x: 10,
                  y: 40,
                  backgroundColorStr: 'clearColor',
                  cornerRadius: 10),
          ATNativeManager.mainTitle():
              ATNativeManager.createNativeSubViewAttribute(
                  topSizeTool.getWidth() - 190, 20,
                  x: 70,
                  y: 40,
                  backgroundColorStr: '#2095F1',
                  textSize: 15,
                  cornerRadius: 10),
          ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
              topSizeTool.getWidth() - 190, 20,
              x: 70,
              y: 70,
              backgroundColorStr: '#2095F1',
              textSize: 15,
              cornerRadius: 10),
          ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
            100,
            50,
            x: topSizeTool.getWidth() - 110,
            y: 40,
            textSize: 15,
            textColorStr: "#FFFFFF",
            backgroundColorStr: "#2095F1",
            textAlignmentStr: "center",
          ),
          // ATNativeManager.customView(): [ATNativeManager.createNativeSubCustomViewAttribute(
          //   88,
          //   30,
          //   x: 0,
          //   y: 0,
          //   textSize: 15,
          //   textColorStr: "#FFFFFF",
          //   backgroundColorStr: "#2095F1",
          //   textAlignmentStr: "center",
          //   cornerRadius: 5,
          //   customViewNative:ATCustomViewNative.label,
          //   title: '测试',
          // )],
          ATNativeManager.mainImage():
              ATNativeManager.createNativeSubViewAttribute(
                  topSizeTool.getWidth() - 20, topSizeTool.getWidth() * 0.6,
                  x: 10,
                  y: 100,
                  backgroundColorStr: '#00000000',
                  cornerRadius: 5),
          // ATNativeManager.adLogo(): ATNativeManager.createNativeSubViewAttribute(
          //     45, 20,
          //     x: 10,
          //     y: 10,
          //     backgroundColorStr: '#00000000'),
          ATNativeManager.dislike():
              ATNativeManager.createNativeSubViewAttribute(
            20,
            20,
            x: topSizeTool.getWidth() - 30,
            y: 10,
          ),
          ATNativeManager.elementsView():
              ATNativeManager.createNativeSubViewAttribute(
                  topSizeTool.getWidth(), 25,
                  x: 0,
                  y: 315,
                  textSize: 12,
                  textColorStr: "#FFFFFF",
                  backgroundColorStr: "#7F000000"),
          "showCustomExt": Configuration.nativeShowCustomExt
        },
        sceneID: Configuration.nativeSceneID);
  }

  //======================== API 列表 ========================
  //======================== API List ========================

  //加载广告
  loadNativeAd() async {
    await ATNativeManager.loadNativeAd(
        placementID: Configuration.nativePlacementID,
        extraMap: {
          ATCommon.isNativeShow(): false,
          ATCommon.getAdSizeKey(): ATNativeManager.createNativeSubViewAttribute(
            topSizeTool.getWidth() - 100,
            (topSizeTool.getWidth() - 100) / 2,
          ),
          ATNativeManager.isAdaptiveHeight(): false
        });
  }

  //检查是否就绪
  hasNativeAdReady() async {
    await ATNativeManager.nativeAdReady(
      placementID: Configuration.nativePlacementID,
    ).then((value) {
      print('flutter nativeAdReady: $value');
    });
  }

  //获取可展示的广告，第一条为即将展示的
  getNativeAdValidAds() async {
    await ATNativeManager.getNativeValidAds(
      placementID: Configuration.nativePlacementID,
    ).then((value) {
      print('flutter getNativeValidAds: $value');
    });
  }

  //检查加载状态
  Future<int> checkNativeAdLoadStatus() async {
    try {
      final value = await ATNativeManager.checkNativeAdLoadStatus(
        placementID: Configuration.nativePlacementID,
      );
      final isLoading = value['isLoading'] ?? 0;
      return isLoading;
    } catch (error) {
      return -1; // 出现错误时，返回-1
    }
  }

  //展示原生广告
  showNative() async {
    await ATNativeManager
        .showNativeAd(placementID: Configuration.nativePlacementID, extraMap: {
      ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
        topSizeTool.getWidth(),
        topSizeTool.getHeight(),
        x: 0,
        y: 100,
      ),
      ATNativeManager.appIcon(): ATNativeManager.createNativeSubViewAttribute(
          50, 50,
          x: 20, y: 70, backgroundColorStr: 'clearColor'),
      ATNativeManager.mainTitle(): ATNativeManager.createNativeSubViewAttribute(
        topSizeTool.getWidth() - 100,
        40,
        x: 90,
        y: 70,
        textSize: 15,
      ),
      ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
        topSizeTool.getWidth() - 100,
        40,
        x: 90,
        y: 120,
        textSize: 15,
      ),
      ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
        50,
        50,
        x: 90,
        y: 170,
        textSize: 15,
      ),
      ATNativeManager.mainImage(): ATNativeManager.createNativeSubViewAttribute(
        topSizeTool.getWidth() - 40,
        topSizeTool.getHeight() - 200,
        x: 20,
        y: 220,
      ),
      ATNativeManager.adLogo(): ATNativeManager.createNativeSubViewAttribute(
        100,
        50,
        x: topSizeTool.getWidth() - 100,
        y: topSizeTool.getHeight() - 70,
      ),
      ATNativeManager.dislike(): ATNativeManager.createNativeSubViewAttribute(
        80,
        80,
        x: 20,
        y: 0,
      ),
    }).then((value) {
      print('flutter showNativeAd: $value');
    });
  }

  //展示原生广告，带sceneID：TopOn/Taku 后台的场景ID
  showSceneNativeAd() async {
    await ATNativeManager.showSceneNativeAd(
        placementID: Configuration.nativePlacementID,
        sceneID: Configuration.nativeSceneID,
        extraMap: {
          ATNativeManager.parent():
              ATNativeManager.createNativeSubViewAttribute(
            topSizeTool.getWidth(),
            topSizeTool.getHeight(),
            x: 0,
            y: 100,
          ),
          ATNativeManager.appIcon():
              ATNativeManager.createNativeSubViewAttribute(50, 50,
                  x: 20, y: 70, backgroundColorStr: 'clearColor'),
          ATNativeManager.mainTitle():
              ATNativeManager.createNativeSubViewAttribute(
            topSizeTool.getWidth() - 100,
            40,
            x: 90,
            y: 70,
            textSize: 15,
          ),
          ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
            100,
            40,
            x: 90,
            y: 120,
            textSize: 15,
          ),
          ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
            50,
            50,
            x: 90,
            y: 170,
            textSize: 15,
          ),
          ATNativeManager.mainImage():
              ATNativeManager.createNativeSubViewAttribute(
            topSizeTool.getWidth() - 40,
            topSizeTool.getHeight() - 200,
            x: 20,
            y: 220,
          ),
          ATNativeManager.adLogo():
              ATNativeManager.createNativeSubViewAttribute(
            100,
            50,
            x: topSizeTool.getWidth() - 100,
            y: topSizeTool.getHeight() - 70,
          ),
          ATNativeManager.dislike():
              ATNativeManager.createNativeSubViewAttribute(
            80,
            80,
            x: 20,
            y: 0,
          ),
        });
  }

  //展示原生广告，带sceneID：TopOn/Taku 后台的场景ID，showCustomExt展示时的透传参数
  showSceneNativeAdWithCustomExt() async {
    await ATNativeManager.showSceneNativeAdWithCustomExt(
        placementID: Configuration.nativePlacementID,
        sceneID: Configuration.nativeSceneID,
        showCustomExt: Configuration.nativeShowCustomExt,
        extraMap: {
          ATNativeManager.parent():
              ATNativeManager.createNativeSubViewAttribute(
            topSizeTool.getWidth(),
            topSizeTool.getHeight(),
            x: 0,
            y: 100,
          ),
          ATNativeManager.appIcon():
              ATNativeManager.createNativeSubViewAttribute(50, 50,
                  x: 20, y: 70, backgroundColorStr: 'clearColor'),
          ATNativeManager.mainTitle():
              ATNativeManager.createNativeSubViewAttribute(
            topSizeTool.getWidth() - 100,
            40,
            x: 90,
            y: 70,
            textSize: 15,
          ),
          ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
            100,
            40,
            x: 90,
            y: 120,
            textSize: 15,
          ),
          ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
            50,
            50,
            x: 90,
            y: 170,
            textSize: 15,
          ),
          ATNativeManager.mainImage():
              ATNativeManager.createNativeSubViewAttribute(
            topSizeTool.getWidth() - 40,
            topSizeTool.getHeight() - 200,
            x: 20,
            y: 220,
          ),
          ATNativeManager.adLogo():
              ATNativeManager.createNativeSubViewAttribute(
            100,
            50,
            x: topSizeTool.getWidth() - 100,
            y: topSizeTool.getHeight() - 70,
          ),
          ATNativeManager.dislike():
              ATNativeManager.createNativeSubViewAttribute(
            80,
            80,
            x: 20,
            y: 0,
          ),
        });
  }

  //销毁广告
  removeNativeAd() async {
    await ATNativeManager.removeNativeAd(
        placementID: Configuration.nativePlacementID);
  }

  //场景统计
  entryNativeScenario() async {
    await ATNativeManager.entryNativeScenario(
        placementID: Configuration.nativePlacementID,
        sceneID: Configuration.nativeSceneID);
  }
}
