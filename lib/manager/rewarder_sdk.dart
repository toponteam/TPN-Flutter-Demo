import 'dart:developer';

import 'package:secmtp_sdk/at_index.dart';
import '../configuration_sdk.dart';
import '../main.dart';

final RewarderManager = RewarderTool();

class RewarderTool{

  RewarderTool() {
    //设置监听
    rewardedAdListener();
  }

  startLoadRewardedVideoAd() async {
    loadRewardedVideo();
    EventBusUtil.eventBus.fire(AdEvent(
        placementId: Configuration.rewarderPlacementID,
        type: AdEventType.loading));
  }

  startShowRewardedVideoAd() async {

    //到达展示场景，展示前检查是否准备就绪
    ATRewardedManager.rewardedVideoReady(
      placementID: Configuration.rewarderPlacementID,
    ).then((value) async {
      print('flutter rewardedVideoReady: $value');
      if (value == true) {
        //场景统计（可选）
        entryRewardedVideoScenario(Configuration.rewarderPlacementID,Configuration.rewarderSceneID);
        //查看有效广告缓存(可选)
        getRewardedVideoAdValidAds(Configuration.rewarderPlacementID);
        //开始展示
        showRewardedVideoAdWithShowConfig();
      } else {
        //没有准备就绪，可能是还在加载中或者加载失败，下方有检查加载状态API。
        //若加载失败，可在加载失败监听中重新发起加载。
        //若加载中，重复发起加载是无效的。
        //您可以根据实际逻辑来调整具体代码
        int isLoading = await checkRewardedVideoAdLoadStatus(Configuration.rewarderPlacementID);
        if (isLoading == 1) {
          print('广告正在加载中... + ${Configuration.rewarderPlacementID}');
        } else {
          print('广告还没加载，发起加载 + ${Configuration.rewarderPlacementID}');
          startLoadRewardedVideoAd();
        }
      }
    });
  }

  //开启全自动加载
  startLoadAutoRewardedVideoAd() async {
    //设置激励视频加载时透传参数(可选)
    autoLoadRewardedVideoSetLocalExtra();

    //开始加载
    autoLoadRewardedVideo();
    EventBusUtil.eventBus.fire(AdEvent(
        placementId: Configuration.autoRewarderPlacementID,
        type: AdEventType.loading));
  }

  //全自动加载广告展示
  startShowAutoLoadRewardedVideoAd() async {
    //到达展示场景，展示前检查是否准备就绪
    ATRewardedManager.rewardedVideoReady(
      placementID: Configuration.autoRewarderPlacementID,
    ).then((value) async {
      print('flutter rewardedVideoReady: $value');
      if (value == true) {
        //场景统计（可选）
        entryRewardedVideoScenario(Configuration.autoRewarderPlacementID,Configuration.autoRewarderSceneID);
        //全自动加载激励视频设置展示时透传参数（可选）
        autoLoadRewardedVideoSetLocalExtra();
        //检查状态（可选）
        int isLoading = await checkRewardedVideoAdLoadStatus(Configuration.autoRewarderPlacementID);
        print('全自动激励视频广告加载状态 + $isLoading + "placementID :" + ${Configuration.autoRewarderPlacementID}');
        //查看缓存（可选）
        getRewardedVideoAdValidAds(Configuration.autoRewarderPlacementID);
        //已经准备就绪，开始展示
        showAutoLoadRewardedVideoAD();
      } else {
        print('广告正在全自动加载中... + ${Configuration.autoRewarderPlacementID}');
      }
    });
  }

  checkReadyAndSendStatus(String placementID) {
    //到达展示场景，展示前检查是否准备就绪
    ATRewardedManager.rewardedVideoReady(
      placementID: placementID,
    ).then((isReady) {
      print("flutter rewardedVideoReady: ${isReady} ---- placementID:${placementID}");
      if (isReady == true) {
        EventBusUtil.eventBus.fire(AdEvent(
            placementId: placementID,
            type: AdEventType.ready));
      } else {}
    });
  }

  rewardedAdListener() {
    ATListenerManager.rewardedVideoEventHandler.listen((value) {

      switch (value.rewardStatus) {
        case RewardedStatus.rewardedVideoDidFailToLoad:
          log("flutter rewardedVideoDidFailToLoad ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}");
          EventBusUtil.eventBus.fire(AdEvent(
              placementId: value.placementID, type: AdEventType.failed));
          break;
        case RewardedStatus.rewardedVideoDidFinishLoading:
          log("flutter rewardedVideoDidFinishLoading ---- placementID: ${value.placementID}");
          checkReadyAndSendStatus(value.placementID);
          break;
        case RewardedStatus.rewardedVideoDidStartPlaying:
          log("flutter rewardedVideoDidStartPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidEndPlaying:
          log("flutter rewardedVideoDidEndPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidFailToPlay:
          log("flutter rewardedVideoDidFailToPlay ---- placementID: ${value.placementID} ---- errStr:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidRewardSuccess:
          log("flutter rewardedVideoDidRewardSuccess ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidClick:
          log("flutter rewardedVideoDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidDeepLink:
          log("flutter rewardedVideoDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}");
          break;
        case RewardedStatus.rewardedVideoDidClose:
          log("flutter rewardedVideoDidClose ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          ATRewardedManager.rewardedVideoReady(
            placementID: value.placementID,
          ).then((isReady) {
            log('flutter rewardedVideoReady: $isReady');
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
        case RewardedStatus.rewardedVideoUnknown:
          log("flutter rewardedVideoUnknown");
          break;
        case RewardedStatus.rewardedVideoDidAgainStartPlaying:
          log("flutter rewardedVideoDidAgainStartPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidAgainEndPlaying:
          log("flutter rewardedVideoDidAgainEndPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidAgainFailToPlay:
          log("flutter rewardedVideoDidAgainFailToPlay ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
          log("flutter rewardedVideoDidAgainRewardSuccess ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidAgainClick:
          log("flutter rewardedVideoDidAgainClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}");
          break;
      }
    });
  }

  //======================== API 列表 ========================
  //======================== API List ========================

  //加载广告
  loadRewardedVideo() async {
    await ATRewardedManager.loadRewardedVideo(
        placementID: Configuration.rewarderPlacementID,
        extraMap: {
          //如果需要通过开发者的服务器进行奖励的下发（部分广告平台支持此服务器激励），则需要传递下面两个key
          //您可以自定义value内容，但需要保证是字符串类型。例如json字符串。
          ATRewardedManager.kATAdLoadingExtraUserDataKeywordKey(): '1234',
          ATRewardedManager.kATAdLoadingExtraUserIDKey(): '1234',
        });
  }

  //检查是否准备就绪
  hasRewardedVideoAdReady(String placementID) async {
    await ATRewardedManager
        .rewardedVideoReady(
      placementID: placementID,
    )
        .then((value) {
      print('flutter rewardedVideoReady: $value');
    });
  }

  //检查加载状态
  Future<int> checkRewardedVideoAdLoadStatus(String placementID) async {
    try {
      final value = await ATRewardedManager.checkRewardedVideoLoadStatus(
        placementID: placementID,
      );
      final isLoading = value['isLoading'] ?? 0;
      return isLoading;
    } catch (error) {
      return -1; // 出现错误时，返回-1
    }
  }

  //查看缓存中已加载的广告列表，第一条为即将展示的广告
  getRewardedVideoAdValidAds(String placementID) async {
    await ATRewardedManager.getRewardedVideoValidAds(
      placementID: placementID)
        .then((value) {
      print('flutter getRewardedVideoValidAds: $value + placementID: + $Configuration.autoInterstitialPlacementID');
    });
  }

  //展示广告
  showRewardedVideoAd() async {
    await ATRewardedManager
        .showRewardedVideo(
      placementID: Configuration.rewarderPlacementID,
    );
  }

  //展示广告，带场景ID
  showSceneRewardedAd() async {
    await ATRewardedManager
        .showSceneRewardedVideo(
      sceneID: Configuration.rewarderSceneID,
      placementID: Configuration.rewarderPlacementID,
    );
  }

  //展示广告，带sceneID：TopOn/Taku 后台的场景ID，showCustomExt展示时的透传参数
  showRewardedVideoAdWithShowConfig() async {
    await ATRewardedManager.showRewardedVideoWithShowConfig(
      placementID: Configuration.rewarderPlacementID,
      sceneID: Configuration.rewarderSceneID,
      showCustomExt: Configuration.rewardedShowCustomExt,
    );
  }

  entryRewardedVideoScenario(String placementID, String sceneID) async {
    await ATRewardedManager.entryRewardedVideoScenario(
        placementID: placementID,
        sceneID: sceneID
    );
  }

  autoLoadRewardedVideo() async {
    await ATRewardedManager.autoLoadRewardedVideo(
        placementIDs: Configuration.autoRewarderPlacementID
    );
  }

  cancelAutoLoadRewardedVideo() async {
    await ATRewardedManager.cancelAutoLoadRewardedVideo(
        placementIDs: Configuration.autoRewarderPlacementID
    );
  }

  //展示全自动加载的广告
  showAutoLoadRewardedVideoAD() async {
    await ATRewardedManager.showAutoLoadRewardedVideoAD(
        placementID: Configuration.autoRewarderPlacementID,
        sceneID: Configuration.autoRewarderSceneID
    );
  }

  // 设置全自动加载广告的展示透传信息，请用我们的key，value传自定义的字符串
  // Set local extra information for auto-loaded ad
  autoLoadRewardedVideoSetLocalExtra() async {
    await ATRewardedManager.autoLoadRewardedVideoSetLocalExtra(
        placementID: Configuration.autoRewarderPlacementID,
        extraMap: {
          ATRewardedManager.kATAdLoadingExtraUserDataKeywordKey(): '1234 auto show rv extra',
          ATRewardedManager.kATAdLoadingExtraUserIDKey(): '1234 auto show rv extra',
        });
  }
}