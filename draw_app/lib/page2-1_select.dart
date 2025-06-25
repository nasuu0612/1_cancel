import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:typed_data';
//
// 画面 b1
//

class Page2Select extends StatelessWidget {
  const Page2Select({super.key});

  @override
  Widget build(BuildContext context) {
    // extraで渡されたデータを受け取る
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final File? _imageFile = extra?['underImageFile'];
    final Uint8List? _upperImageBytes = extra?['upperImageBytes'];

    // 完了ボタンを押したときの処理
    void _completeAndProceed() {
      if (_imageFile != null && _upperImageBytes != null) {
        context.push(
          '/b2',
          extra: {
            'underImageFile': _imageFile,
            'upperImageBytes': _upperImageBytes,
          },
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('写真またはマスク画像がありません')));
      }
    }

    final appBar = AppBar(
      backgroundColor: Colors.green,
      title: const Text('Select'),
    );

    final completeButton = ElevatedButton(
      onPressed: _completeAndProceed,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      child: const Text('完了'),
    );

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          if (_upperImageBytes != null)
            Center(child: Image.memory(_upperImageBytes, fit: BoxFit.contain))
          else
            const Center(child: Text('マスク画像がありません')),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [completeButton],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
