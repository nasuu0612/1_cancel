import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';


//
// 画面 D
//
final GetUpTimeProvider = StateProvider((ref){
  return 8;
  //変化させたいデータをプロバイダーで囲む
}
);
class PageD extends ConsumerWidget {
   final items = [
      DropdownMenuItem(
        value: 5,
        child: Text('5時'),
      ),
      DropdownMenuItem(
        value: 6,
        child: Text('6時'),
      ),
      DropdownMenuItem(
        value: 7,
        child: Text('7時'),
      ),
      DropdownMenuItem(
        value: 8,
        child: Text('8時'),
      ),
      DropdownMenuItem(
        value: 9,
        child: Text('9時'),
      ),
      DropdownMenuItem(
        value: 10,
        child: Text('10時'),
      ),
      DropdownMenuItem(
        value: 11,
        child: Text('11時'),
      ),
    ];
  push(BuildContext context) {
    // 画面 a へ進む
    context.push('/a');
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final GetUpTime=ref.watch(GetUpTimeProvider);
    // 画面の上に表示するバー
    final appBar = AppBar(
      backgroundColor: const Color.fromARGB(255, 128, 229, 128),
      title: Text('目標',
      style:GoogleFonts.yuseiMagic(
        fontSize:20,
        color:Colors.brown),),
    );

    
    // 戻るボタン
    final homeButton = ElevatedButton(
      onPressed: () => context.go("/a"),
      // MEMO: primary は古くなったので backgroundColor へ変更しました
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      child: const Text('ホームへ'),
    );

    // 画面全体
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  const Text("・朝何時までに起きる？"),
                  const SizedBox(height: 10),
                  DropdownButton(
                    value: GetUpTime,
                    onChanged: (newvalue) {
                      if(newvalue==null){return;}
                      ref.read(GetUpTimeProvider.notifier).state = newvalue;
                    },
                    items: items
                  ),
                  
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment(-1.0,-0.7),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("※この時間を過ぎると撮影できません！"),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  homeButton,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
