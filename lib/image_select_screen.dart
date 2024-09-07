import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_edit_snap/image_edit_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image_lib;

class ImageSelectScreen extends StatefulWidget {
  const ImageSelectScreen({Key? key});

  @override
  State<ImageSelectScreen> createState() => _ImageSelectScreenState();
}

class _ImageSelectScreenState extends State<ImageSelectScreen> {
  /* ImagePicker
  image picker パッケージが提供するクラス
  画像ライブラリやカメラにアクセスする機能を持つ */
  final ImagePicker _picker = ImagePicker();

  /* Uint 8 List
  8 bit 符号なし整数のリスト */
  Uint8List? _imageBitmap;

  Future<void> _selectImage() async {
    /* XFile
    ファイルの抽象化クラス */
    // 画像を選択する
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.gallery);

    // ファイルオブジェクトから画像データを取得する
    final imageBitmap = await imageFile?.readAsBytes();
    assert(imageBitmap != null);
    if (imageBitmap == null) return;

    // 画像データをデコードする
    final image = image_lib.decodeImage(imageBitmap);
    assert(image != null);
    if (image == null) return;

    /* Image
    画像データとメタデータを内包したクラス */
    final image_lib.Image resizedImage;
    if (image.width > image.height) {
      // 横長の画像なら横幅を 500 px にリサイズする
      resizedImage = image_lib.copyResize(image, width: 500);
    } else {
      // 縦長の画像なら縦幅を 500 px にリサイズする
      resizedImage = image_lib.copyResize(image, height: 500);
    }

    // 画像をエンコードして状態を更新する
    setState(() {
      _imageBitmap = image_lib.encodeBmp(resizedImage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final imageBitmap = _imageBitmap;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.imageSelectScreenTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageBitmap != null) Image.memory(imageBitmap),
            ElevatedButton(
                child: Text(l10n.imageSelect), onPressed: () => _selectImage()),
            if (imageBitmap != null)
              ElevatedButton(
                  child: Text(l10n.imageEdit),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ImageEditScreen(imageBitmap: imageBitmap)))),
          ],
        ),
      ),
    );
  }
}
