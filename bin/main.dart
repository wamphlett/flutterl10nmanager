import 'dart:io';
import 'package:args/command_runner.dart';
// Commands
import 'package:flutterl10nmanager/commands/export.dart';

main(List<String> arguments) {
  CommandRunner runner = CommandRunner('flutterl10nmanager', 'Flutter L10N Manager')
    ..addCommand(ExportCommand())
    ..run(arguments);
}
