
import 'package:flutter/material.dart';
import 'package:my_notes/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
     return showGenericDialog(
       context: context,
       title: "Sharing",
       content: "Cannot Share Empty Note",
       optionBuilder: () => {
       "Okay": null
     },);
}