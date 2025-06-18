import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

//
// 画面 B
//
class PageB extends StatelessWidget {
  const PageB({super.key});

  // 進むボタンを押したとき
  push(BuildContext context) {
    // 画面 C へ進む
    context.push('/c');
  }

  // 戻るボタンを押したとき
  back(BuildContext context) {
    // 前の画面 へ戻る
    context.pop();
  }

  @override
  Widget build(BuildContext context) {

    //画面のサイズ取得
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // 画面の上に表示するバー
    final appBar = AppBar(
      backgroundColor: const Color.fromARGB(255, 128, 229, 128),
      title:  Text('Draw',
        style:GoogleFonts.yuseiMagic(
        fontSize:20,
        color:Colors.brown),)
    );

    // 画像領域
    final image = Container(
      color: Colors.grey,
      width: screenWidth * 0.8,
      height: screenHeight * 0.5,
      //child: const Text("画像"),
    );

    // 進むボタン
    final goButton = ElevatedButton(
      onPressed: () => push(context),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          fixedSize: const Size(130, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      child: Text('完了',
        style:GoogleFonts.yuseiMagic(
            fontSize:20,
            color:Colors.brown),
      ),
    );

    // 戻るボタン
    final backButton = ElevatedButton(
      onPressed: () => back(context),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          fixedSize: const Size(130, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      child: Text('< 戻る',
      style:GoogleFonts.yuseiMagic(
          fontSize:20,
          color:Colors.brown),
      )
    );

    // 画面全体
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("画像を編集してください",
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: image,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  backButton,
                  const SizedBox(width: 70), // ボタンの間のスペース
                  goButton,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
