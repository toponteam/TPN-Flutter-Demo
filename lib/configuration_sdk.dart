import 'dart:io';

class Configuration {
  static String appidStr = Platform.isIOS ? 'a5b0e8491845b3' : 'a5aa1f9deda26d';

  static String appidkeyStr = Platform.isIOS
      ? '7eae0567827cfe2b22874061763f30c9'
      : '4f7b9ac17decb9babec83aac078742c7';

  static String rewarderPlacementID = Platform.isIOS ? 'b5b72b21184aa8' : 'b5b449fb3d89d7';
  static String autoRewarderPlacementID = Platform.isIOS ? 'b62fe22b92bb41' : 'b64e41ccbf095c';

  static String interstitialPlacementID = Platform.isIOS ? 'b5bacad26a752a' : 'b5baca53984692';
  static String autoInterstitialPlacementID = Platform.isIOS ? 'b62fe22e06dd64' : 'b64e44f9456121';

  static String bannerPlacementID = Platform.isIOS ? 'b5bacaccb61c29' : 'b5baca4f74c3d8';
  static String nativePlacementID = Platform.isIOS ? 'b5bacac5f73476' : 'b5aa1fa2cae775';
  static String splashPlacementID = Platform.isIOS ? 'b5c22f0e5cc7a0' : 'b5bea7cc9a4497';

  static String rewardedShowCustomExt = 'RewardedShowCustomExt';
  static String interstitialShowCustomExt = 'InterstitialShowCustomExt';
  static String splashShowCustomExt = 'SplashShowCustomExt';
  static String bannerShowCustomExt = 'BannerShowCustomExt';
  static String nativeShowCustomExt = 'NativeShowCustomExt';

  static String rewarderSceneID = Platform.isIOS ? 'f5e54970dc84e6' : 'f5e5492eca9668';
  static String autoRewarderSceneID = Platform.isIOS ? 'f5e54970dc84e6' : 'f5e5492eca9668';

  static String interstitialSceneID = Platform.isIOS ? 'f5e549727efc49' : 'f5e54937b0483d';
  static String autoInterstitialSceneID = Platform.isIOS ? 'f5e549727efc49' : 'f5e54937b0483d';

  static String nativeSceneID = Platform.isIOS ? 'f600938967feb5' : 'f600e5f8b80c14';

  static String bannerSceneID = Platform.isIOS ? 'f600938d045dd3' : 'f600e6039e152c';

  static String splashSceneID = Platform.isIOS ? 'f5e549727efc49' : 'f628c7999265cd';

  static String debugKey = Platform.isIOS ? '99117a5bf26ca7a1923b3fed8e5371d3ab68c25c' : 'aa3d1b3dffe65c68551105fd1abd666781bbc3e6';
}
