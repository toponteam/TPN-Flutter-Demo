import 'dart:developer';

import 'package:secmtp_sdk/at_index.dart';
import '../configuration_sdk.dart';
import '../main.dart';

final InterstitialManager = InterstitialTool();

class InterstitialTool {
  InterstitialTool() {
    //设置监听
    interListen();
  }

  startLoadInterstitialAd() async {
    loadInterstitialAd();
    EventBusUtil.eventBus.fire(AdEvent(
        placementId: Configuration.interstitialPlacementID,
        type: AdEventType.loading));
  }

  startShowInterstitialAd() async {
    //到达展示场景，展示前检查是否准备就绪
    ATInterstitialManager.hasInterstitialAdReady(
      placementID: Configuration.interstitialPlacementID,
    ).then((value) async {
      print('flutter hasInterstitialAdReady: $value');
      if (value == true) {
        //场景统计(可选)
        entryInterstitialScenario(Configuration.interstitialPlacementID,Configuration.interstitialSceneID);
        //查看有效广告缓存(可选)
        getInterstitialValidAds(Configuration.interstitialPlacementID);
        //展示广告
        showInterstitialAdWithShowConfig();
      } else {
        //没有准备就绪，可能是还在加载中或者加载失败，下方有检查加载状态API。
        //若加载失败，可在加载失败监听中重新发起加载。
        //若加载中，重复发起加载是无效的。
        //您可以根据实际逻辑来调整具体代码
        int isLoading = await checkInterstitialLoadStatus(Configuration.interstitialPlacementID);
        if (isLoading == 1) {
          print('广告正在加载中... + ${Configuration.interstitialPlacementID}');
        } else {
          print('广告还没加载，发起加载 + ${Configuration.interstitialPlacementID}');
          startLoadInterstitialAd();
        }
      }
    });
  }

  //全自动加载
  startLoadAutoInterstitialAd() async {
    //开启全自动加载
    autoLoadInterstitialAD();
    EventBusUtil.eventBus.fire(AdEvent(
        placementId: Configuration.autoInterstitialPlacementID,
        type: AdEventType.loading));
  }

  startShowAutoLoadInterstitialAd() async {
    //到达展示场景，展示前检查是否准备就绪
    ATInterstitialManager.hasInterstitialAdReady(
      placementID: Configuration.autoInterstitialPlacementID,
    ).then((value) async {
      print('flutter hasInterstitialAdReady: $value');
      if (value == true) {
        //场景统计（可选）
        entryInterstitialScenario(Configuration.autoInterstitialPlacementID,Configuration.autoInterstitialSceneID);
        //全自动加载插屏设置展示时透传参数(可选)
        autoLoadInterstitialADSetLocalExtra();
        //检查状态(可选)
        int isLoading = await checkInterstitialLoadStatus(Configuration.autoInterstitialPlacementID);
        print('全自动插屏广告加载状态 + $isLoading + "placementID :" + ${Configuration.autoInterstitialPlacementID}');
        //查看缓存(可选)
        getInterstitialValidAds(Configuration.autoInterstitialPlacementID);
        //已经准备就绪，开始展示
        showAutoLoadInterstitialADWithPlacementID();
      } else {
        print('广告正在自动加载中... + ${Configuration.autoInterstitialPlacementID}');
      }
    });
  }

  checkReadyAndSendStatus(String placementID) {
    //到达展示场景，展示前检查是否准备就绪
    ATInterstitialManager.hasInterstitialAdReady(
      placementID: placementID,
    ).then((isReady) {
      log("flutter hasInterstitialAdReady: ${isReady} ---- placementID:${placementID}");
      if (isReady == true) {
        EventBusUtil.eventBus.fire(AdEvent(
            placementId: placementID, type: AdEventType.ready));
      } else {}
    });
  }

  interListen() {
    ATListenerManager.interstitialEventHandler.listen((value) {
      switch (value.interstatus) {
        case InterstitialStatus.interstitialAdFailToLoadAD:
          log(
              "flutter interstitialAdFailToLoadAD ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}");
          EventBusUtil.eventBus.fire(AdEvent(
              placementId: value.placementID, type: AdEventType.failed));
          break;
        case InterstitialStatus.interstitialAdDidFinishLoading:
          log(
              "flutter interstitialAdDidFinishLoading ---- placementID: ${value.placementID}");
          checkReadyAndSendStatus(value.placementID);
          break;
        case InterstitialStatus.interstitialAdDidStartPlaying:
          log(
              "flutter interstitialAdDidStartPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case InterstitialStatus.interstitialAdDidEndPlaying:
          log(
              "flutter interstitialAdDidEndPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case InterstitialStatus.interstitialDidFailToPlayVideo:
          log(
              "flutter interstitialDidFailToPlayVideo ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}");
          break;
        case InterstitialStatus.interstitialDidShowSucceed:
          log(
              "flutter interstitialDidShowSucceed ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case InterstitialStatus.interstitialFailedToShow:
          log(
              "flutter interstitialFailedToShow ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}");
          break;
        case InterstitialStatus.interstitialAdDidClick:
          log(
              "flutter interstitialAdDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case InterstitialStatus.interstitialAdDidDeepLink:
          log(
              "flutter interstitialAdDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case InterstitialStatus.interstitialAdDidClose:
          log(
              "flutter interstitialAdDidClose ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          ATInterstitialManager.hasInterstitialAdReady(
            placementID: value.placementID,
          ).then((isReady) {
            log('flutter hasInterstitialAdReady: $isReady');
            if (isReady == true) {
              EventBusUtil.eventBus.fire(AdEvent(
                  placementId: value.placementID, type: AdEventType.ready));
            } else {
              EventBusUtil.eventBus.fire(AdEvent(
                  placementId: value.placementID, type: AdEventType.not_ready));
            }
          });
          break;
        case InterstitialStatus.interstitialUnknown:
          log("flutter interstitialUnknown");
          break;
      }
    });
  }

//======================== API 列表 ========================
//======================== API List ========================

// 加载插屏广告
// Load interstitial ad
  loadInterstitialAd() async {
    await ATInterstitialManager.loadInterstitialAd(
        placementID: Configuration.interstitialPlacementID,
        extraMap: {
          // Sigmob rewarded video ----> Interstitial ads
          // ATInterstitialManager.useRewardedVideoAsInterstitialKey(): true
        });
  }

// 检查是否有插屏广告准备就绪
// Check if the interstitial ad is ready
  hasInterstitialAdReady(String placementID) async {
    await ATInterstitialManager.hasInterstitialAdReady(
      placementID: placementID,
    ).then((value) {
      print('flutter hasInterstitialAdReady: $value');
    });
  }

// 获取有效的插屏广告列表，第一条为即将展示的
// Get list of valid interstitial ads
  getInterstitialValidAds(String placementID) async {
    await ATInterstitialManager.getInterstitialValidAds(
      placementID: placementID,
    ).then((value) {
      print('flutter getInterstitialValidAds: $value + placementID: + ${Configuration.autoInterstitialPlacementID}');
    });
  }

// 检查插屏广告加载状态
// Check interstitial ad load status
  Future<int> checkInterstitialLoadStatus(String placementID) async {
    try {
      final value = await ATInterstitialManager.checkInterstitialLoadStatus(
        placementID: placementID,
      );
      final isLoading = value['isLoading'] ?? 0;
      return isLoading;
    } catch (error) {
      return -1; // 出现错误时，返回-1
    }
  }

// 展示插屏广告
// Show interstitial ad
  showInterstitialAd() async {
    await ATInterstitialManager.showInterstitialAd(
      placementID: Configuration.interstitialPlacementID,
    );
  }

// 展示指定场景的插屏广告，带sceneID：TopOn/Taku 后台的场景ID
// Show interstitial ad for a specific scene
  showSceneInterstitialAd() async {
    await ATInterstitialManager.showSceneInterstitialAd(
      placementID: Configuration.interstitialPlacementID,
      sceneID: Configuration.interstitialSceneID,
    );
  }

// 使用展示配置展示插屏广告，带sceneID：TopOn/Taku 后台的场景ID，showCustomExt展示时的透传参数
// Show interstitial ad with show configuration
  showInterstitialAdWithShowConfig() async {
    await ATInterstitialManager.showInterstitialAdWithShowConfig(
      placementID: Configuration.interstitialPlacementID,
      sceneID: Configuration.interstitialSceneID,
      showCustomExt: Configuration.interstitialShowCustomExt,
    );
  }

// 进入插屏广告场景，带sceneID：TopOn/Taku 后台的场景ID
// Enter interstitial ad scenario
  entryInterstitialScenario(String placementID, String sceneID) async {
    await ATInterstitialManager.entryInterstitialScenario(
        placementID: placementID,
        sceneID: sceneID);
  }

// 开启全自动加载插屏广告
// Auto-load interstitial ad
  autoLoadInterstitialAD() async {
    await ATInterstitialManager.autoLoadInterstitialAD(
        placementIDs: Configuration.autoInterstitialPlacementID);
  }

// 取消全自动加载插屏广告
// Cancel auto-loading interstitial ad
  cancelAutoLoadInterstitialAD() async {
    await ATInterstitialManager.cancelAutoLoadInterstitialAD(
        placementIDs: Configuration.autoInterstitialPlacementID);
  }

// 使用placementID显示全自动加载的插屏广告，带sceneID：TopOn/Taku 后台的场景ID
// Show auto-loaded interstitial ad using placementID
  showAutoLoadInterstitialADWithPlacementID() async {
    await ATInterstitialManager.showAutoLoadInterstitialAD(
        placementID: Configuration.autoInterstitialPlacementID,
        sceneID: Configuration.autoInterstitialSceneID);
  }

// 设置全自动加载插屏广告的展示透传信息，请用我们的key，value传自定义的字符串
// Set local extra information for auto-loaded interstitial ad
  autoLoadInterstitialADSetLocalExtra() async {
    await ATInterstitialManager.autoLoadInterstitialADSetLocalExtra(
        placementID: Configuration.autoInterstitialPlacementID,
        extraMap: {
          ATInterstitialManager.kATAdShowCustomExtKey():
              '1234 auto show ins extra'
        });
  }
}
