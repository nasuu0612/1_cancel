import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

//
// タイトル画面
//
class PageTitle extends StatelessWidget {
  const PageTitle({super.key});

  // 進むボタンを押したとき
  push(BuildContext context) {
    // 画面 A へ進む
    context.push('/a');
  }

  @override
  Widget build(BuildContext context) {
    // 進むボタン
    final goButton = ElevatedButton(
      onPressed: () => push(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // 丸みを強調
        ),
        elevation: 6,
        shadowColor: Colors.orange.shade200,
      ),
      child: Text(
        'はじめる',
        style: GoogleFonts.yuseiMagic(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    //タイトルの文字
    final text = Text(
      "あさぬり",
      style: GoogleFonts.yuseiMagic(fontSize: 40, color: Colors.brown),
    );
    //写真
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final img = Image.asset("assets/images/RunningArtist.PNG");
    final con = Container(
      width: screenWidth * 0.7,
      height: screenHeight * 0.7,
      child: img,
    );

    // 画面全体
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [text, con, goButton],
            ),
          ),
        ],
      ),
    );
  }
}
