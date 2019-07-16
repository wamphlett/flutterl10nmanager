import 'package:ansicolor/ansicolor.dart';

/// A very basic loggling class to help put messages into
/// the console.
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

/// Takes an absolute path and finds the file name
String getFileNameFromPath(String path) => path.split('/').last;

/// Takes a file name and extracts the language code
/// from it. Expects file to be named intl_en.arb
String getLangFromFileName(String fileName) =>
    fileName.substring(5, fileName.length - 4);
