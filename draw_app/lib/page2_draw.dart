import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io'; //モバイルのファイル用
import 'package:camera/camera.dart'; //XFile用
import 'camera_utils/camera_handler.dart'; //CameraHandlerをインポート

//
// 画面 B
//

//元のPageBクラスをPage2Drawに変更してStatefulWidgetに変更
//カメラを使うためにはStatefulWidgetが必要になる
class Page2Draw extends StatefulWidget {
  const Page2Draw({Key? key}) : super(key: key);

  @override
  State<Page2Draw> createState() => _Page2DrawState();
}

class _Page2DrawState extends State<Page2Draw> {
  final CameraHandler _cameraHandler = CameraHandler();
  XFile? _imageFile; //キャプチャした画像を保存する変数
  bool _showCameraPreview = false;

  @override
  void initState() {
    super.initState();
    //必要があればカメラの初期化を行う
    //_cameraHandler.initializeCamera().then((_) {
    //  if (mounted && _cameraHandler.isCameraInitialized) {
    //    setState(() {});
    //  }
    //});
  }

  @override
  void dispose() {
    _cameraHandler.dispose(); //カメラのリソースを解放
    super.dispose();
  }

  //完了ボタンのアクション(元のファイルのpushメソッドの部分)
  void _completeAndProceed() {
    if (_imageFile != null) {
      //ここで_imageFileを使った編集処理を挟める
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('編集処理に入ったところです'))
      );
      context.push('/c'); //PageCに進む
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('写真が撮影・選択されていない状態です'))
      );
    }
  }

  //戻るボタンのアクション(元のBackメソッドの部分)
  void _goBack() {
    if (_showCameraPreview) {
      //カメラプレビュー表示中の場合はプレビューを閉じる
      setState(() {
        _showCameraPreview = false;
        //_imageFileはクリアせずに保持している状態
        //プレビューキャンセルで画像は破棄する場合は
        //_imageFile = null;
      });
    } else {
      //それ以外の場合は前の画面に戻る
      context.pop();
    }
  }

  Future<void> _startCamera() async {
    if (!_cameraHandler.isCameraInitialized) {
      await _cameraHandler.initializeCamera();
    }

    if (_cameraHandler.isCameraInitialized && mounted) {
      setState(() {
        _showCameraPreview = true; //カメラプレビューを表示する状態
        _imageFile = null; //以前の画像はクリア
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カメラを起動できない状態です')),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (!_cameraHandler.isCameraInitialized || _cameraHandler.controller == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カメラが準備できていません')),
        );
      }
      return;
    }

    final XFile? picture = await _cameraHandler.takePicture();

    if (picture != null) {
      if (!mounted) return; //非同期処理後にウィジェットが破棄されている可能性をチェック

      bool? retake = await showDialog<bool>(
        context: context,
        barrierDismissible: false, //ダイアログ以外の領域をタップしても閉じない
        builder: (BuildContext context) {
          return AlertDialog( //アラートダイアログで写真の確認をする
            title: const Text('写真を確認(title)'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(File(picture.path), height: 200, fit: BoxFit.contain), //撮影した写真を表示
                const SizedBox(height: 10), //写真とボタンの間のスペース
                const Text('この写真を使用しますか?'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('再撮影'),
                onPressed: () {
                  Navigator.of(context).pop(true); //再撮影を選択したとき
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(false); //OKを選択したとき
                },
              ),
            ],
          );
        },
      );

      if (retake == true) {
        //再撮影する場合は状態はカメラプレビューのまま
        setState(() {
          _imageFile = null; //以前の画像はクリア
        });
      } else {
        //この写真を利用する場合
        setState(() {
          _imageFile = picture; //撮影した写真を保存
          _showCameraPreview = false; //カメラプレビューを非表示にする
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('写真の撮影に失敗しました')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: Colors.green, //アプリバーの背景色
      title: const Text('Draw'), //アプリバーのタイトル
    );

    Widget mainContent;
    if (_showCameraPreview) {
      if (_cameraHandler.isCameraInitialized && _cameraHandler.controller != null) {
        mainContent = AspectRatio(
          aspectRatio: _cameraHandler.controller!.value.aspectRatio,
          child: CameraPreviewWidget(cameraHandler: _cameraHandler),
        );
      } else {
        //カメラ初期化中or失敗
        mainContent = const Center(child: CircularProgressIndicator());
      }
    } else if (_imageFile != null) {
      mainContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.file(File(_imageFile!.path)), //撮影した画像を表示
        ),
      );
    } else {
      mainContent = const Center(
        child: Text('「カメラ起動」ボタンを押して撮影してください'),
      );
    }

    List<Widget> actionButtons = [];
    if (_showCameraPreview) {
      actionButtons = [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showCameraPreview = false; //カメラプレビューを閉じる
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('キャンセル'),
         ),
         const SizedBox(width: 20), //ボタン間のスペース

         ElevatedButton(
          onPressed: _takePicture,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('撮影'),
         ),
      ];
    } else if (_imageFile != null) {
      actionButtons = [
        ElevatedButton(
          onPressed: _goBack, //通常の戻る動作
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('< 戻る'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _startCamera, //再撮影
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('再撮影'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _completeAndProceed, //完了ボタン
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('完了'),
        ),
      ];
    } else {
      //初期状態
      actionButtons = [
        ElevatedButton(
          onPressed: _goBack,//通常の戻る動作
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('< 戻る'),
        ),
        const SizedBox(width: 70), //元のレイアウトに合わせる

        ElevatedButton(
          onPressed: _startCamera, //カメラ起動
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('カメラ起動'),
        ),
      ];
    }

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          mainContent, //カメラプレビューor画像or初期メッセージ
          Align(
            alignment: Alignment.bottomRight, //画面右下に配置
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisSize: MainAxisSize.min, //ボタンを最小限の幅にする
                children: actionButtons, //アクションボタン類を配置
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//元の部分(確認後削除する部分)
/*class PageB extends StatelessWidget {
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
    // 画面の上に表示するバー
    final appBar = AppBar(
      backgroundColor: Colors.green,
      title: const Text('Draw'),
    );

    // 進むボタン
    final goButton = ElevatedButton(
      onPressed: () => push(context),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      child: const Text('完了'),
    );

    // 戻るボタン
    final backButton = ElevatedButton(
      onPressed: () => back(context),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('< 戻る'),
    );

    // 画面全体
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
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
*/
