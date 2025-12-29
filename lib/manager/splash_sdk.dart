import 'dart:developer';

import 'package:secmtp_sdk/at_index.dart';
import '../configuration_sdk.dart';
import '../main.dart';

final SplashManager = SplashTool();

class SplashTool {

  SplashTool() {
    //设置监听
    splashAdListener();
  }

  //加载广告
  startLoadSplashAd() async {
    loadSplashAd();
    EventBusUtil.eventBus.fire(AdEvent(
        placementId: Configuration.splashPlacementID,
        type: AdEventType.loading));
  }

  //展示广告
  startShowSplashAd() async {
    //到达展示场景，展示前检查是否准备就绪
    ATSplashManager.splashReady(
      placementID: Configuration.splashPlacementID,
    ).then((value) async {
      print('flutter splashReady: $value');
      if (value == true) {
        //场景统计(可选)
        entrySplashScenario();
        //查看有效广告缓存(可选)
        getSplashAdValidAds();
        //已经准备就绪，开始展示
        showSplashAdWithShowConfig();
      } else {
        //没有准备就绪，可能是还在加载中或者加载失败，下方有检查加载状态API。
        //若加载失败，可在加载失败监听中重新发起加载。
        //若加载中，重复发起加载是无效的。
        //您可以根据实际逻辑来调整具体代码
        int isLoading = await checkSplashAdLoadStatus();
        if (isLoading == 1) {
          print('广告正在加载中... + ${Configuration.splashPlacementID}');
        } else {
          print('广告还没加载，发起加载 + ${Configuration.splashPlacementID}');
          startLoadSplashAd();
        }
      }
    });
  }

  splashAdListener() {
    ATListenerManager.splashEventHandler.listen((value) {
      switch (value.splashStatus) {
        case SplashStatus.splashDidFailToLoad:
          log(
              "flutter splash--splashDidFailToLoad ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}");
          EventBusUtil.eventBus.fire(AdEvent(
              placementId: value.placementID, type: AdEventType.failed));
          break;
        case SplashStatus.splashDidFinishLoading:
          log(
              "flutter splash--splashDidFinishLoading ---- placementID: ${value.placementID} ---- isTimeout：${value.isTimeout}");
          //到达展示场景，展示前检查是否准备就绪
          ATSplashManager.splashReady(
            placementID: value.placementID,
          ).then((isReady) {
            log('flutter splashReady: $isReady');
            if (isReady == true) {
              EventBusUtil.eventBus.fire(AdEvent(
                  placementId: value.placementID, type: AdEventType.ready));
            } else {}
          });
          break;
        case SplashStatus.splashDidTimeout:
          log(
              "flutter splash--splashDidTimeout ---- placementID: ${value.placementID}");
          break;
        case SplashStatus.splashDidShowSuccess:
          log(
              "flutter splash--splashDidShowSuccess ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case SplashStatus.splashDidShowFailed:
          log(
              "flutter splash--splashDidShowFailed ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}");
          break;
        case SplashStatus.splashDidClick:
          log(
              "flutter splash--splashDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case SplashStatus.splashDidDeepLink:
          log(
              "flutter splash--splashDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}");
          break;
        case SplashStatus.splashDidClose:
          log(
              "flutter splash--splashDidClose ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          ATSplashManager.splashReady(
            placementID: value.placementID,
          ).then((isReady) {
            print('flutter splashReady: $isReady');
            if (isReady == true) {
              EventBusUtil.eventBus.fire(AdEvent(
                  placementId: value.placementID, type: AdEventType.ready));
            } else {
              EventBusUtil.eventBus.fire(AdEvent(
                  placementId: value.placementID, type: AdEventType.not_ready));
            }
          });
          break;
        case SplashStatus.splashWillClose:
          log(
              "flutter splash--splashWillClose ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case SplashStatus.splashUnknown:
          log("flutter splash--splashUnknown");
          break;
      }
    });
  }

  //======================== API 列表 ========================
  //======================== API List ========================

  //加载广告
  loadSplashAd() async {
    await ATSplashManager.loadSplash(
        placementID: Configuration.splashPlacementID,
        extraMap: {ATSplashManager.tolerateTimeout(): 5000});
  }

  //检查是否准备就绪
  hasSplashAdReady() async {
    await ATSplashManager.splashReady(
      placementID: Configuration.splashPlacementID,
    ).then((value) {
      print('flutter splash--Ready: $value');
      if (value == true) {
        SplashManager.showSplashAdWithShowConfig();
      }
    });
  }

  //检查加载状态
  Future<int> checkSplashAdLoadStatus() async {
    try {
      final value = await ATSplashManager.checkSplashLoadStatus(
        placementID: Configuration.splashPlacementID,
      );
      final isLoading = value['isLoading'] ?? 0;
      return isLoading;
    } catch (error) {
      return -1; // 出现错误时，返回-1
    }
  }

  //查看缓存中已加载的广告列表，第一条为即将展示的广告
  getSplashAdValidAds() async {
    await ATSplashManager.getSplashValidAds(
      placementID: Configuration.splashPlacementID,
    ).then((value) {
      print('flutter splash--getSplashValidAds: $value');
    });
  }

  //展示广告
  showSplashAd() async {
    await ATSplashManager.showSplash(
      placementID: Configuration.splashPlacementID,
    );
  }

  //展示广告，带sceneID：TopOn/Taku 后台的场景ID
  showSceneSplashAd() async {
    await ATSplashManager.showSceneSplash(
      sceneID: Configuration.splashSceneID,
      placementID: Configuration.splashPlacementID,
    );
  }

  //展示广告，带sceneID：TopOn/Taku 后台的场景ID，showCustomExt展示时的透传参数
  showSplashAdWithShowConfig() async {
    await ATSplashManager.showSplashAdWithShowConfig(
      placementID: Configuration.splashPlacementID,
      sceneID: Configuration.splashSceneID,
      showCustomExt: Configuration.splashShowCustomExt,
    );
  }

  //场景统计，带sceneID：TopOn/Taku 后台的场景ID
  entrySplashScenario() async {
    await ATSplashManager.entrySplashScenario(
        placementID: Configuration.splashPlacementID,
        sceneID: Configuration.splashSceneID);
  }
}
