import 'package:flutter/cupertino.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_translate/flutter_translate.dart';

String? value = "es";

void showDemoActionSheet(
    {required BuildContext context, required Widget child}) {
  showCupertinoModalPopup<String>(
      context: context, builder: (BuildContext context) => child);
}

void onActionSheetPress(BuildContext context) {
  showDemoActionSheet(
    context: context,
    child: CupertinoActionSheet(
      title: Text(translate('language.selection.title'),
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 20.0,
            color: Color.fromARGB(255, 90, 90, 90),
          )),
      message: Text(translate('language.selection.message'),
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16.0,
            color: Color.fromARGB(255, 90, 90, 90),
          )),
      actions: <Widget>[
        CupertinoActionSheetAction(
            child: Text(translate('language.name.en') + " 🇺🇸",
                style: TextStyle(fontWeight: FontWeight.normal)),
            onPressed: () {
              changeLocale(context, "en");
              Navigator.of(context, rootNavigator: true).pop("en");
            }),
        CupertinoActionSheetAction(
            child: Text(translate('language.name.es') + " 🇪🇸",
                style: TextStyle(fontWeight: FontWeight.normal)),
            onPressed: () {
              changeLocale(context, "es");
              Navigator.of(context, rootNavigator: true).pop("es");
            }),
        CupertinoActionSheetAction(
            child: Text(translate('language.name.hi') + " 🇮🇳",
                style: TextStyle(fontWeight: FontWeight.normal)),
            onPressed: () {
              changeLocale(context, "hi");
              Navigator.of(context, rootNavigator: true).pop("hi");
            }),
        CupertinoActionSheetAction(
            child: Text(translate('language.name.sq') + " 🇦🇱",
                style: TextStyle(fontWeight: FontWeight.normal)),
            onPressed: () {
              changeLocale(context, "sq");
              Navigator.of(context, rootNavigator: true).pop("sq");
            })
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(translate('button.cancel'),
            style: TextStyle(fontWeight: FontWeight.normal)),
        isDefaultAction: true,
        onPressed: () =>
            Navigator.of(context, rootNavigator: true).pop("Cancel"),
      ),
    ),
  );
}
