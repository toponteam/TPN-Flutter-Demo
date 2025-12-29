import 'dart:io';

import 'package:topon.flutter.demo/manager/splash_sdk.dart';
import 'package:secmtp_sdk/at_init.dart';
import 'package:secmtp_sdk/at_init_response.dart';
import 'package:secmtp_sdk/at_listener.dart';
import '../configuration_sdk.dart';
import 'banner_sdk.dart';
import 'interstitial_sdk.dart';
import 'native_sdk.dart';
import 'rewarder_sdk.dart';

final InitManager = InitTool();

class InitTool {
  // 打开SDK的Debug log，强烈建议在测试阶段打开，方便排查问题。
  setLogEnabled() async {
    await ATInitManger.setLogEnabled(
      logEnabled: true,
    ).then((value) {
      print('Set log switch $value');
    });
  }

  // 设置渠道，可用于统计数据和进行流量分组
  setChannelStr() async {
    await ATInitManger.setChannelStr(
      channelStr: "test_setChannel",
    ).then((value) {
      print('Set up channels $value');
    });
  }

  // 设置子渠道，可用于统计数据和进行流量分组
  setSubchannelStr() async {
    await ATInitManger.setSubChannelStr(
      subchannelStr: "test_setSubchannelStr",
    ).then((value) {
      print('Set up sub-channels');
    });
  }

  // 设置自定义的Map信息，可匹配后台配置的对应流量分组（App纬度）,也可以用设置用户信息（可选配置）
  setCustomDataDic() async {
    await ATInitManger.setCustomDataMap(
      customDataMap: {
        'setCustomDataDic': 'myCustomDataDic',
      },
    ).then((value) {
      print('Set up custom rules');
    });
  }

  // 设置自定义的Map信息，可匹配后台配置的对应的流量分组（Placement纬度）,也可以用设置用户信息（可选配置）
  setPlacementCustomData() async {
    await ATInitManger.setPlacementCustomData(
      placementIDStr: 'b5b72b21184aa8',
      placementCustomDataMap: {
        'setPlacementCustomData': 'test_setPlacementCustomData'
      },
    ).then((value) {
      print('Set pl rules');
    });
  }

  // 设置排除交叉推广App列表
  setExludeBundleIDArray() async {
    await ATInitManger.setExludeBundleIDArray(
      exludeBundleIDList: ['test_setExludeBundleIDArray'],
    ).then((value) {
      print('Set up exclusion of cross-promotion');
    });
  }

  // 通过ip判断是否用户所在地区
  getUserLocation() async {
    await ATInitManger.getUserLocation().then((value) {
      print('flutter: Get user location -- ${value.toString()}');
    });
  }

  // 获取GDPR的授权级别
  getGDPRLevel() async {
    await ATInitManger.getGDPRLevel().then((value) {
      print('flutter:Get GDPR --${value.toString()}');
    });
  }

  // 设置数据同意级别
  setDataConsentSet() async {
    await ATInitManger.setDataConsentSet(
            gdprLevel: ATInitManger.dataConsentSetPersonalized())
        .then((value) {
      print('flutter: Set up GDPR${value.toString()}');
    });
  }

  //设置禁止SDK收集的数据
  deniedUploadDeviceInfo() async {
    await ATInitManger.deniedUploadDeviceInfo(
        deniedUploadDeviceInfoList: [ATInitManger.aOAID()]).then((value) {
      print('flutter: End of initialization');
    });
  }

  // 初始化SDK
  Future<void> initTopon() async {
    await ATInitManger.initAnyThinkSDK(
      appidStr: Configuration.appidStr,
      appidkeyStr: Configuration.appidkeyStr,
    );
  }

  // 设置预置策略的放置路径
  setPresetPlacementConfigPath() async {
    print("flutter: flutter setPresetPlacementConfigPath");
    await ATInitManger.setPresetPlacementConfigPath(pathStr: "localStrategy");
  }

  // 展示GDPR的界面，建议使用showGDPRConsentDialog()
  showGDPRAuth() async {
    await ATInitManger.showGDPRAuth();
  }

  // 展示GDPR+UMP流程弹窗
  showGDPRConsentDialog() async {
    await ATInitManger.showGDPRConsentDialog();
  }

  //展示DebugUI
  showDebugUI() async {
    print('flutter:showDebugUI');
    await ATInitManger.showDebuggerUI(debugKey: Configuration.debugKey);
  }

  startPreLoadAd() {
    print("flutter: flutter startPreLoadAd");
    //预加载广告
    InterstitialManager.startLoadInterstitialAd();
    RewarderManager.startShowRewardedVideoAd();
    BannerManager.startShowBannerAd();
    SplashManager.startShowSplashAd();
    NativeManager.startShowNativeAd();
  }

  // GDPR+UMP弹窗流程关闭的监听事件回调，用户选择数据同意回调
  initListen() {
    ATListenerManager.initEventHandler.listen((value) async {
      //GDPR+UMP弹窗流程关闭
      if (value.consentDismiss != null) {
        //初始化SDK
        await initTopon();
        //设置预置策略(可选)
        setPresetPlacementConfigPath();
        //开始预加载广告((可选)仅demo场景示例)
        startPreLoadAd();
      }

      //获取Consent等级(可选)
      if (value.consentSet != null) {
        switch (value.consentSet) {
          case InitConsentSet.initConsentSetPersonalized:
            print("flutter: flutter initConsentSetPersonalized");
            break;
          case InitConsentSet.initConsentSetNonpersonalized:
            print("flutter: flutter initConsentSetNonpersonalized");
            break;
          case InitConsentSet.initConsentSetUnknown:
            print("flutter: flutter initConsentSetUnknown");
            break;
        }
      }
    });
  }
}
