import 'dart:io';

class Configuration {
  static String appidStr = Platform.isIOS ? 'a5b0e8491845b3' : 'a62b013be01931';

  static String appidkeyStr = Platform.isIOS
      ? '7eae0567827cfe2b22874061763f30c9'
      : 'c3d0d2a9a9d451b07e62b509659f7c97';

  static String rewarderPlacementID = Platform.isIOS ? 'b5b72b21184aa8' : 'b62ecb800e1f84';
  static String autoRewarderPlacementID = Platform.isIOS ? 'b62fe22b92bb41' : 'b62ecb800e1f84';

  static String interstitialPlacementID = Platform.isIOS ? 'b5bacad26a752a' : 'b62b028b61c800';
  static String autoInterstitialPlacementID = Platform.isIOS ? 'b62fe22e06dd64' : 'b62b028b61c800';

  static String bannerPlacementID = Platform.isIOS ? 'b5bacaccb61c29' : 'b62b01a36e4572';
  static String nativePlacementID = Platform.isIOS ? 'b5bacac5f73476' : 'b6305efb12d408';
  static String splashPlacementID = Platform.isIOS ? 'b5c22f0e5cc7a0' : 'b62b0272f8762f';

  static String rewardedShowCustomExt = 'RewardedShowCustomExt';
  static String interstitialShowCustomExt = 'InterstitialShowCustomExt';
  static String splashShowCustomExt = 'SplashShowCustomExt';
  static String bannerShowCustomExt = 'BannerShowCustomExt';
  static String nativeShowCustomExt = 'NativeShowCustomExt';

  static String rewarderSceneID = Platform.isIOS ? 'f5e54970dc84e6' : '';
  static String autoRewarderSceneID = Platform.isIOS ? 'f5e54970dc84e6' : '';

  static String interstitialSceneID = Platform.isIOS ? 'f5e549727efc49' : '';
  static String autoInterstitialSceneID = Platform.isIOS ? 'f5e549727efc49' : '';

  static String nativeSceneID = Platform.isIOS ? 'f600938967feb5' : '';

  static String bannerSceneID = Platform.isIOS ? 'f600938d045dd3' : '';

  static String splashSceneID = Platform.isIOS ? 'f5e549727efc49' : '';

  static String debugKey = Platform.isIOS ? '99117a5bf26ca7a1923b3fed8e5371d3ab68c25c' : '';
}
