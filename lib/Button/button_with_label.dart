import 'dart:async';

import 'package:flutter/material.dart';

import 'package:topon.flutter.demo/main.dart'; // Assumed path for AdEvent and EventBusUtil.
import 'package:flutter/material.dart';
import 'dart:async'; // Required for using StreamSubscription.

class ButtonWithLabel extends StatefulWidget {
  final String text;
  final String placementID;
  final Future<void> Function() onPressed;

  const ButtonWithLabel({
    required this.text,
    required this.placementID,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  _ButtonWithLabelState createState() => _ButtonWithLabelState();
}

class _ButtonWithLabelState extends State<ButtonWithLabel> {
  static final Map<String, String> _labels = {};
  StreamSubscription<AdEvent>? _eventSubscription; // Subscription to manage the event listener.

  @override
  void initState() {
    super.initState();

    _labels.putIfAbsent(widget.placementID, () => '');

    // 添加路由变化监听器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ModalRoute.of(context)?.addLocalHistoryEntry(LocalHistoryEntry(
        onRemove: _unsubscribeEventBus,
      ));
    });

    // Subscribe to the event bus and keep the subscription so it can be canceled.
    _eventSubscription = EventBusUtil.eventBus.on<AdEvent>().listen((event) {
      if (event.placementId == widget.placementID && mounted) { // Check that the widget is mounted before calling setState
        setState(() {
          switch (event.type) {
            case AdEventType.close:
              _labels[widget.placementID] = "closed";
              break;
            case AdEventType.loading:
              _labels[widget.placementID] = "loading";
              break;
            case AdEventType.ready:
              _labels[widget.placementID] = "ready";
              break;
            case AdEventType.failed:
              _labels[widget.placementID] = "failed";
              break;
            case AdEventType.not_ready:
              _labels[widget.placementID] = "not ready";
              break;
            default:
              _labels[widget.placementID] = "unknown";
          }
        });
      }
    });
  }

  void _unsubscribeEventBus() {
    // 取消事件订阅
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  @override
  void dispose() {
    // 如果未通过_localHistoryEntry取消订阅，则在这里取消
    _unsubscribeEventBus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = _labels[widget.placementID] ?? '';

    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.onPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(widget.text),
                ),
              )),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 + 100 + 10,
            top: 15,
            height: 20,
            child: Text(
              label,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
