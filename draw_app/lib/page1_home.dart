import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//
// 画面 A
//
class PageA extends StatefulWidget {
  const PageA({super.key});

  @override
  State<PageA> createState() => _PageAState();
}

class _PageAState extends State<PageA> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // 1秒ごとに_nowを更新して再描画
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // 画面を離れるときにタイマーを止める
    super.dispose();
  }

  // 日付と時間をフォーマット
  String get formattedDateTime {
    final date =
        "${_now.year}/${_now.month.toString().padLeft(2, '0')}/${_now.day.toString().padLeft(2, '0')}";
    final time =
        "${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}";
    return "$date $time";
  }

  // ボタンを押したとき画面Bへ進む
  void push(BuildContext context) {
    context.push('/b');
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: Colors.red,
      title: const Text('Home'),
    );

    final pushButton = ElevatedButton.icon(
      onPressed: () => push(context),
      icon: const Icon(Icons.photo_camera),
      label: const Text('撮る'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        fixedSize: const Size(130, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          // 左上：リアルタイム時計
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                formattedDateTime,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),

          // 右下：「撮る」ボタン
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: pushButton,
            ),
          ),
        ],
      ),
    );
  }
}
