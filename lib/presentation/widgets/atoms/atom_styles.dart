import 'package:flutter/material.dart';

class AtomStyles {
  // 🎨 Label por defecto
  static const double labelHeight = 20;
  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
    height: labelHeight / 14,
  );

  // 🎨 Título por defecto
  static const double titleHeight = 28;
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 20,
    color: Colors.black,
    fontWeight: FontWeight.bold,
    height: titleHeight / 20,
  );

  // 🎨 Input Text
  static const double inputHeight = 48;
  static const TextStyle inputTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black,
    height: inputHeight / 16,
  );

  static const OutlineInputBorder inputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green),
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  // 🎨 Dropdown
  static const double dropdownHeight = 56;
  static const TextStyle dropdownItemStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
    height: dropdownHeight / 16,
  );

  // 🎨 Date Picker
  static const double datePickerHeight = 64;
  static const TextStyle datePickerLabelStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
    height: datePickerHeight / 14,
  );

  static const TextStyle datePickerTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.blueGrey,
    height: datePickerHeight / 16,
  );

  // 🎨 Switch / Checkbox
  static const double switchHeight = 40;
  static const double checkboxHeight = 48;
  static const Color activeColor = Colors.green;
  static const Color inactiveColor = Colors.grey;
}
