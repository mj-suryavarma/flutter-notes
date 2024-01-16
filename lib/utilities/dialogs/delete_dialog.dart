

import 'package:flutter/material.dart';
import 'package:my_notes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context){

  return showGenericDialog(
      context: context,
      title: "Delete",
      content: "Are you sure you want to delete note?", optionBuilder: () => {
    'Cancel' : false,
    'yes' : true
  }).then((value) => value ?? false);
}