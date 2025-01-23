import 'package:anythink_sdk_example/main.dart';
import 'package:anythink_sdk_example/manager/automatic_sdk.dart';

final anyThinkRouters = {
  "/": (context) => MyHome(),
  '/automatic_sdk': (context) => AutomaticPage(),

};