import 'package:flutter/material.dart';

 class AppCustomDecoration {

   InputDecoration appDefualtDecoration() {
     return const InputDecoration(
       fillColor: Colors.white70,
       filled: true,
       hintStyle: TextStyle(
         color: Color(0xFFC6C8CA)
       ),
       enabledBorder: OutlineInputBorder(
         borderSide: BorderSide(color: Colors.black12),
       ),
       focusedBorder: OutlineInputBorder(
         borderSide: BorderSide(color: Colors.black26),
       ),
     );
   }
}
