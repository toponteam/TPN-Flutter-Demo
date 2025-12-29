import 'package:topon.flutter.demo/Button/button_with_label.dart';
import 'package:topon.flutter.demo/main.dart';
import 'package:flutter/material.dart';
import 'package:topon.flutter.demo/configuration_sdk.dart';
import 'package:topon.flutter.demo/manager/rewarder_sdk.dart';
import 'package:topon.flutter.demo/manager/interstitial_sdk.dart';

class AutomaticPage extends StatefulWidget {
  const AutomaticPage({Key? key}) : super(key: key);

  @override
  _AutomaticPageState createState() => _AutomaticPageState();
}

class _AutomaticPageState extends State<AutomaticPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onEnter(); // // 布局完成后调用的方法
    });
  }

  @override
  void dispose() {
    onLeave(); // 离开页面时调用的方法
    super.dispose();
  }

  void onEnter() {
    print('Entered AutomaticPage');
    //开始自动加载
    RewarderManager.startLoadAutoRewardedVideoAd();
    InterstitialManager.startLoadAutoInterstitialAd();

    //检查是否已经准备就绪
    RewarderManager.checkReadyAndSendStatus(Configuration.autoRewarderPlacementID);
    InterstitialManager.checkReadyAndSendStatus(Configuration.autoInterstitialPlacementID);
  }

  void onLeave() {
    print('Leaving AutomaticPage');

    //取消自动加载
    RewarderManager.cancelAutoLoadRewardedVideo();
    InterstitialManager.cancelAutoLoadInterstitialAD();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color.fromRGBO(60, 104, 243, 1),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: Container(
        color: Color.fromRGBO(60, 104, 243, 1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Automatic Ads Demo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ButtonWithLabel(
                text: 'Automatic Reward',
                placementID: Configuration.autoRewarderPlacementID,
                onPressed: () =>
                    RewarderManager.startShowAutoLoadRewardedVideoAd(),
              ),
              const SizedBox(height: 20),
              ButtonWithLabel(
                text: 'Automatic Interstitial',
                placementID: Configuration.autoInterstitialPlacementID,
                onPressed: () =>
                    InterstitialManager.startShowAutoLoadInterstitialAd(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
