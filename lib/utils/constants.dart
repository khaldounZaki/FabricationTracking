import 'package:flutter/material.dart';

class AppColors {
  static const primary = Colors.blue;
  static const success = Colors.green;
  static const danger = Colors.red;
}

class Roles {
  static const admin = 'admin';
  static const solidDesigner = 'solid_designer';
  static const assembler = 'assembler';
  static const welder = 'welder';
  static const polisher = 'polisher';
  static const cleaner = 'cleaner';
  static const qualityChecker = 'quality_checker';
  static const installer = 'installer';

  static const all = <String>[
    admin,
    solidDesigner,
    assembler,
    welder,
    polisher,
    cleaner,
    qualityChecker,
    installer,
  ];
}

class Routes {
  static const String jobOrdersList = '/jobOrdersList';
  static const String addJobOrder = '/addJobOrder';
  static const String addItems = '/addItems';
  static const String importItemsExcel = '/importItemsExcel';
  static const String addParts = '/addParts';
  static const String printSticker = '/printSticker';
  static const String usersList = '/usersList';
  static const String reports = '/reports';
}
