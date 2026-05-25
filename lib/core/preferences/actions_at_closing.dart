import 'package:hiddify/gen/translations.g.dart';

enum ActionsAtClosing {
  ask,
  hide,
  exit;

  String present(TranslationsRu t) => switch (this) {
    ask => t.dialogs.windowClosing.askEachTime,
    hide => t.common.hide,
    exit => t.common.exit,
  };
}
