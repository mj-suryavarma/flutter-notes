

import 'package:flutter/material.dart';
import 'package:my_notes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context){
    
    return showGenericDialog(
        context: context,
        title: "Log out",
        content: "Are you sure you want to log out ?", optionBuilder: () => {
          'Cancel' : false,
           'log out' : true
    }).then((value) => value ?? false);
}