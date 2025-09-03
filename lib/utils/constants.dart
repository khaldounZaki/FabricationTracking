import 'package:flutter/material.dart';

class AppStrings {
  static const String appTitle = 'Fabrication Admin';
}

class AppColors {
  static const primary = Colors.blue;
}

class Routes {
  static const adminHome = '/';
  static const addJobOrder = '/addJobOrder';
  static const addItems = '/addItems';
  static const importItemsExcel = '/importItemsExcel';
  static const jobOrdersList = '/jobOrdersList';
  static const jobOrderDetail = '/jobOrderDetail';
  static const addParts = '/addParts';
  static const printSticker = '/printSticker';
  static const usersList = '/usersList';
  static const reports = '/reports';
}

class Roles {
  static const admin = 'admin';
  static const solidDesigner = 'solid designer';
  static const welder = 'welder';
  static const polisher = 'polisher';
  static const cleaner = 'cleaner';
  static const qualityChecker = 'quality checker';
  static const installer = 'installer';
}
