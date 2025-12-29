import 'dart:developer';

import 'package:secmtp_sdk/at_index.dart';
import '../main.dart';
import '../topsize.dart';
import '../configuration_sdk.dart';

final BannerManager = BannerTool();

class BannerTool {
  BannerTool() {
    //设置监听
    bannerListen();
  }

  startLoadBannerAd() async {
    loadBannerAd();
    EventBusUtil.eventBus.fire(AdEvent(
        placementId: Configuration.bannerPlacementID,
        type: AdEventType.loading));
  }

  startShowBannerAd() async {
    //到达展示场景，展示前检查是否准备就绪
    ATBannerManager.bannerAdReady(
      placementID: Configuration.bannerPlacementID,
    ).then((value) async {
      print('flutter bannerAdReady: $value');
      if (value == true) {
        //场景统计(可选)
        entryBannerScenario();
        //查看有效广告缓存(可选)
        getBannerAdValidAds();
        //开始展示banner
        showSceneBannerAdInRectangle();
      } else {
        //没有准备就绪，可能是还在加载中或者加载失败，下方有检查加载状态API。
        //若加载失败，可在加载失败监听中重新发起加载。
        //若加载中，重复发起加载是无效的。
        //您可以根据实际逻辑来调整具体代码
        int isLoading = await checkBannerAdLoadStatus();
        if (isLoading == 1) {
          print('广告正在加载中... + ${Configuration.bannerPlacementID}');
        } else {
          print('广告还没加载，发起加载 + ${Configuration.bannerPlacementID}');
          startLoadBannerAd();
        }
      }
    });
  }

  bannerListen() {
    ATListenerManager.bannerEventHandler.listen((value) {
      switch (value.bannerStatus) {
        case BannerStatus.bannerAdFailToLoadAD:
          log(
              "flutter bannerAdFailToLoadAD ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}");
          EventBusUtil.eventBus.fire(AdEvent(
              placementId: value.placementID, type: AdEventType.failed));
          break;
        case BannerStatus.bannerAdDidFinishLoading:
          log(
              "flutter bannerAdDidFinishLoading ---- placementID: ${value.placementID}");
          //到达展示场景，展示前检查是否准备就绪
          ATBannerManager.bannerAdReady(
            placementID: value.placementID,
          ).then((isReady) {
            log('flutter bannerAdReady: $isReady');
            if (isReady == true) {
              EventBusUtil.eventBus.fire(AdEvent(
                  placementId: value.placementID,
                  type: AdEventType.ready));
            } else {}
          });
          break;
        case BannerStatus.bannerAdAutoRefreshSucceed:
          log(
              "flutter bannerAdAutoRefreshSucceed ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case BannerStatus.bannerAdDidClick:
          log(
              "flutter bannerAdDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case BannerStatus.bannerAdDidDeepLink:
          log(
              "flutter bannerAdDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}");
          break;
        case BannerStatus.bannerAdDidShowSucceed:
          log(
              "flutter bannerAdDidShowSucceed ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case BannerStatus.bannerAdTapCloseButton:
          log(
              "flutter bannerAdTapCloseButton ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          //移除banner
          removeBannerAd();

          ATBannerManager.bannerAdReady(
            placementID: value.placementID,
          ).then((isReady) {
            log('flutter bannerPlacementID: $isReady');
            if (isReady == true) {
              EventBusUtil.eventBus.fire(AdEvent(
                  placementId: value.placementID,
                  type: AdEventType.ready));
            } else {
              EventBusUtil.eventBus.fire(AdEvent(
                  placementId: value.placementID,
                  type: AdEventType.not_ready));
            }
          });
          break;
        case BannerStatus.bannerAdAutoRefreshFail:
          log(
              "flutter bannerAdAutoRefreshFail ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}");
          break;
        case BannerStatus.bannerAdUnknown:
          log("flutter bannerAdUnknown");
          break;
      }
    });
  }

  //======================== API 列表 ========================
  //======================== API List ========================

  //加载banner ad
  loadBannerAd() async {
    await ATBannerManager.loadBannerAd(
        placementID: Configuration.bannerPlacementID,
        extraMap: {
          ATCommon.isNativeShow(): true,//是否加载Flutter原生的banner
          ATCommon.getAdSizeKey(): ATBannerManager.createLoadBannerAdSize(
              TopSize().getWidth(), TopSize().getWidth() * (50 / 320)),//设置banner尺寸
          ATBannerManager.getAdaptiveWidthKey(): TopSize().getWidth(),//设置自适应尺寸，根据宽度来，部分平台有效
          ATBannerManager.getAdaptiveOrientationKey():ATBannerManager.adaptiveOrientationCurrent(),//自适应横竖屏，部分平台有效
        });
  }

  //banner是否准备好展示
  hasBannerAdReady() async {
    await ATBannerManager.bannerAdReady(
      placementID: Configuration.bannerPlacementID,
    ).then((value) {
      print('flutter bannerAdReady: $value');
    });
  }

  //获取已经加载的banner，第一条为即将展示的
  getBannerAdValidAds() async {
    await ATBannerManager.getBannerValidAds(
      placementID: Configuration.bannerPlacementID,
    ).then((value) {
      print('flutter getBannerValidAds: $value');
    });
  }

  //检查加载状态
  Future<int> checkBannerAdLoadStatus() async {
    try {
      final value = await ATBannerManager.checkBannerLoadStatus(
        placementID: Configuration.bannerPlacementID,
      );
      final isLoading = value['isLoading'] ?? 0;
      return isLoading;
    } catch (error) {
      return -1; // 出现错误时，返回-1
    }
  }

  //根据一片区域展示banner ad,getAdSizeKey请跟load广告时传入的size的宽和高一致，按需求设置x、y轴坐标。
  showBannerAdInRectangle() async {
    await ATBannerManager.showBannerInRectangle(
        placementID: Configuration.bannerPlacementID,
        extraMap: {
          ATCommon.getAdSizeKey():
              ATBannerManager.createLoadBannerAdSize(400, 500, x: 0, y: 200),
        });
  }

  //根据一片区域展示banner ad，带sceneID：TopOn/Taku 后台的场景ID
  showSceneBannerAdInRectangle() async {
    await ATBannerManager.showSceneBannerInRectangle(
        placementID: Configuration.bannerPlacementID,
        sceneID: Configuration.bannerSceneID,
        extraMap: {
          ATCommon.getAdSizeKey():
              ATBannerManager.createLoadBannerAdSize(400, 500, x: 0, y: 200),
          ATCommon.getShowCustomExtKey(): Configuration.bannerShowCustomExt,
        });
  }

  //根据位置展示banner ad
  showAdInPosition() async {
    await ATBannerManager.showAdInPosition(
        placementID: Configuration.bannerPlacementID,
        position: ATCommon.getAdATBannerAdShowingPositionBottom());
  }

  //根据位置展示banner ad，带sceneID：TopOn/Taku 后台的场景ID
  showSceneBannerAdInPosition() async {
    await ATBannerManager.showSceneBannerAdInPosition(
        placementID: Configuration.bannerPlacementID,
        sceneID: Configuration.bannerSceneID,
        position: ATCommon.getAdATBannerAdShowingPositionBottom(),
        showCustomExt:Configuration.bannerShowCustomExt,
    );
  }

  removeBannerAd() async {
    await ATBannerManager.removeBannerAd(
      placementID: Configuration.bannerPlacementID,
    );
  }

  //隐藏banner AD
  hideBannerAd() async {
    await ATBannerManager.hideBannerAd(
      placementID: Configuration.bannerPlacementID,
    );
  }

  //在展示banner AD
  afreshShowBannerAd() async {
    await ATBannerManager.afreshShowBannerAd(
      placementID: Configuration.bannerPlacementID,
    );
  }

  //场景统计，sceneID：TopOn/Taku 后台的场景ID
  entryBannerScenario() async {
    await ATBannerManager.entryBannerScenario(
        placementID: Configuration.bannerPlacementID,
        sceneID: Configuration.bannerSceneID);
  }
}
