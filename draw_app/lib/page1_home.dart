import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'page4_condition.dart';

// 時刻を定期的に流すプロバイダー（1秒ごと）
final timeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});

class PageA extends ConsumerWidget {
  const PageA({super.key});

  // 2桁に整える
  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTime = ref.watch(timeProvider);
    //画面のサイズ取得
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // 時計表示
    final timeWidget = asyncTime.when(
      data: (now) {
        final date = "${now.year}/${_two(now.month)}/${_two(now.day)}";
        final time = "${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}";
        return Text(
          "$date $time",
          style:GoogleFonts.yuseiMagic(
          fontSize:20,
          color:Colors.brown
        ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("エラー: $e"),
    );

    // 画像領域
    final image = Container(
      color: Colors.grey,
      width: screenWidth * 0.8,
      height: screenHeight * 0.5,
      //child: const Text("画像"),
    );

    final GetUpTime=ref.read(GetUpTimeProvider);
    // 条件ボタン
    
    final conditionButton = ElevatedButton.icon(  
      onPressed: () => context.go("/d"),
      icon: const Icon(Icons.check_box),
      label: Text('条件',
        style:GoogleFonts.yuseiMagic(
          fontSize:20,
          color:Colors.brown
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        fixedSize: const Size(130, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    // 撮るボタン
    late final Widget pushButton;
    final now = DateTime.now(); // 現在の時刻をその場で取得
    //if (GetUpTime ==0) {//テスト用
    if (GetUpTime <  now.hour || now.hour < 4) {//最低でも4時までは就寝時間だと判定
      pushButton = ElevatedButton.icon(
        onPressed: null, // 無効ボタン
        icon: const Icon(Icons.photo_camera),
        label:Text('撮る',
        style:GoogleFonts.yuseiMagic(
          fontSize:20,
          color:Colors.brown
        ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          fixedSize: const Size(130, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } 
    else {
      pushButton = ElevatedButton.icon(
        onPressed: () => context.push('/b'),
        icon: const Icon(Icons.photo_camera),
        label: Text('撮る',
          style:GoogleFonts.yuseiMagic(
          fontSize:20,
          color:Colors.brown
        ),),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          fixedSize: const Size(130, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
    

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 128, 229, 128),
        title:Text('Home',
        style:GoogleFonts.yuseiMagic(
          fontSize:20,
          color:Colors.brown
        ),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
          decoration: BoxDecoration(color: Color.fromARGB(255, 128, 229, 128)),
          child: Text('メニュー', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
          leading: const Icon(Icons.smartphone),
          title: const Text('このアプリについて'),//フォントを借りたので権利表記したい
          onTap: () => Navigator.pop(context),
      ),
        ]
      )
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: image,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: timeWidget,
            ),
          ),


          Align(
            alignment: Alignment(1.0,-1.0),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Image.asset(
              "assets/images/DrawingArtist.PNG",
              width: 100, // サイズを明示
            ),
            ),
          ),
          
          
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: conditionButton,
            ),
          ),
          
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
