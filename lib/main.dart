import 'dart:async';

import 'package:secmtp_sdk/at_platformview/at_native_platform_widget.dart';
import 'package:topon.flutter.demo/Button/button_with_label.dart';
import 'package:topon.flutter.demo/configuration_sdk.dart';
import 'package:topon.flutter.demo/manager/banner_sdk.dart';
import 'package:topon.flutter.demo/manager/listenerManager.dart';
import 'package:topon.flutter.demo/manager/native_sdk.dart';
import 'package:topon.flutter.demo/manager/splash_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'manager/automatic_sdk.dart';
import 'manager/init_sdk.dart';
import 'manager/interstitial_sdk.dart';
import 'manager/rewarder_sdk.dart';
import 'routers/Routers.dart';

class EventBusUtil {
  static final EventBus eventBus = EventBus();
}

// 定义枚举类型
enum AdEventType {
  loading,
  ready,
  failed,
  not_ready,
  close,
}

// 事件类
class AdEvent {
  final String placementId;
  final AdEventType type;
  AdEvent({
    required this.placementId,
    required this.type,
  });
}

class NativeAdWidgetEvent {
  final PlatformNativeWidget nativeWidget;
  NativeAdWidgetEvent({
    required this.nativeWidget,
  });
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    _setListen();
    //添加网络环境监听(可选)
    _setSDK();
  }

  _setSDK() {
    InitManager.setLogEnabled();

    // InitManager.setExludeBundleIDArray();
    // InitManager.deniedUploadDeviceInfo();

    // 直接初始化SDK
    //InitManager.initTopon();

    //展示GDPR+UMP弹窗，接收到关闭事件回调后在初始化SDK，应用在欧盟地区有发布需要使用
    InitManager.showGDPRConsentDialog();

    // 手动设置数据同意，不通过用户选择
    // InitManager.setDataConsentSet();

    InitManager.setChannelStr();
    InitManager.setSubchannelStr();
    InitManager.setCustomDataDic();
    InitManager.setPlacementCustomData();
    InitManager.getGDPRLevel();
  }

  _setListen() {
    //注册事件回调
    InitManager.initListen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: MyHome(),
      routes: anyThinkRouters,
      initialRoute: "/",
    );
  }
}

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TopOn Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TopOnDemoPage(),
    );
  }
}

class TopOnDemoPage extends StatefulWidget {
  const TopOnDemoPage({Key? key}) : super(key: key);

  @override
  State<TopOnDemoPage> createState() => TopOnDemoPageState();
}

class TopOnDemoPageState extends State<TopOnDemoPage> {
  // 添加状态变量存储 Native 广告视图
  PlatformNativeWidget? nativeAdWidget;

  @override
  void initState() {
    super.initState();

    // 添加事件监听
    EventBusUtil.eventBus.on<NativeAdWidgetEvent>().listen((event) {
      setState(() {
        print('NativeAdWidgetEvent');
        nativeAdWidget = event.nativeWidget;
      });
    });

    // 添加事件监听
    EventBusUtil.eventBus.on<AdEvent>().listen((event) {
      if (event.placementId == Configuration.nativePlacementID) {
        setState(() {
          switch (event.type) {
            case AdEventType.close:
              setState(() {
                nativeAdWidget = null;
              });
              break;
            default:
          }
        });
      }
    });
  }

  // 添加移除广告的方法
  void removeNativeAd() {
    // 更新状态，移除广告视图
    if (nativeAdWidget != null) {
      setState(() {
        nativeAdWidget = null;
      });
    }
  }

  @override
  void dispose() {
    // 在页面销毁时确保清理资源
    removeNativeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color.fromRGBO(60, 104, 243, 1),
            child: Container(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'TopOn Flutter Demo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ButtonWithLabel(
                      text: 'Show Interstitial',
                      placementID: Configuration.interstitialPlacementID,
                      onPressed: () =>
                          InterstitialManager.startShowInterstitialAd(),
                    ),
                    const SizedBox(height: 20),
                    ButtonWithLabel(
                      text: 'Show Reward',
                      placementID: Configuration.rewarderPlacementID,
                      onPressed: () =>
                          RewarderManager.startShowRewardedVideoAd(),
                    ),
                    const SizedBox(height: 20),
                    ButtonWithLabel(
                      text: 'Show Splash',
                      placementID: Configuration.splashPlacementID,
                      onPressed: () => SplashManager.startShowSplashAd(),
                    ),
                    const SizedBox(height: 20),
                    ButtonWithLabel(
                      text: 'Show Banner',
                      placementID: Configuration.bannerPlacementID,
                      onPressed: () => BannerManager.startShowBannerAd(),
                    ),
                    const SizedBox(height: 20),
                    ButtonWithLabel(
                        text: 'Show Native',
                        placementID: Configuration.nativePlacementID,
                        onPressed: () => NativeManager.startShowNativeAd(),
                    ),
                    const SizedBox(height: 20),
                    ButtonWithLabel(
                      text: 'Mediation Debugger',
                      placementID: '',
                      onPressed: () => InitManager.showDebugUI(),
                    ),
                    const SizedBox(height: 20),
                    ButtonWithLabel(
                      text: 'Automatic Load Ad',
                      placementID: '',
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AutomaticPage())),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (nativeAdWidget != null)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 340,
                      child: nativeAdWidget,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
