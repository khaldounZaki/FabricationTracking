import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'views/admin/admin_home.dart';
import 'views/admin/add_job_order.dart';
import 'views/admin/add_items.dart';
import 'views/admin/import_items_excel.dart';
import 'views/admin/job_orders_list.dart';
import 'views/admin/job_order_detail.dart';
import 'views/admin/add_parts.dart';
import 'views/admin/print_sticker.dart';
import 'views/admin/users_list.dart';
import 'views/admin/reports.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      initialRoute: Routes.adminHome,
      routes: {
        Routes.adminHome: (_) => const AdminHome(),
        Routes.addJobOrder: (_) => const AddJobOrderPage(),
        Routes.addItems: (_) => const AddItemsPage(),
        Routes.importItemsExcel: (_) => const ImportItemsExcelPage(),
        Routes.jobOrdersList: (_) => const JobOrdersListPage(),
        Routes.jobOrderDetail: (_) => const JobOrderDetailPage(),
        Routes.addParts: (_) => const AddPartsPage(),
        Routes.printSticker: (_) => const PrintStickerPage(),
        Routes.usersList: (_) => const UsersListPage(),
        Routes.reports: (_) => const ReportsPage(),
      },
    );
  }
}
