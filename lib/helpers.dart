import 'package:ansicolor/ansicolor.dart';

class Logger { 
  AnsiPen pen = AnsiPen();
  
  void error(String message) {
    pen..red();
    print(pen(message));
  }

  void success(String message) {
    pen..green();
    print(pen(message));
  }
  
  void warning(String message) {
    pen..yellow();
    print(pen(message));
  }

  void info(String message) => print(message);
}

String getFileNameFromPath(String path) =>
  path.split('/').last;

String getLangFromFileName(String fileName) =>
  fileName.substring(5, fileName.length - 4);