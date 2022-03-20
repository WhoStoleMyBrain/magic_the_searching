import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as sys_paths;
import 'package:http/http.dart' as http;

class CameraHelper {
  static Future<bool> doesLocalFileExist(String url) async {
    final appDir = await sys_paths.getApplicationDocumentsDirectory();
    final fileName = path.basename(url);
    final fullPath = '${appDir.path}/$fileName';
    // final savedImage =
    //     await File(url).copy('${appDir.path}/$fileName');
    bool file = await File(fullPath).exists();
    return file;
  }

  static Future<File> getLocalFile(String name) async {
    final appDir = await sys_paths.getApplicationDocumentsDirectory();
    final fileName = path.basename(name);
    final fullPath = '${appDir.path}/$fileName';
    return File(fullPath);
  }

  static Future<File> saveFileLocally(String name) async {
    final appDir = await sys_paths.getApplicationDocumentsDirectory();
    final fileName = path.basename(name);
    var url = Uri.parse(name);
    var response = await http.get(url);
    File savedImage = File('${appDir.path}/$fileName');
    savedImage.writeAsBytesSync(response.bodyBytes);
    // final savedImage = await File(name).copy('${appDir.path}/${fileName}');
    return savedImage;
  }
}
