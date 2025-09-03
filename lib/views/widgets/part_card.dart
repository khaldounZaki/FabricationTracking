import 'package:flutter/material.dart';

class PartCard extends StatelessWidget {
  final String description;
  final String sn;
  const PartCard({super.key, required this.description, required this.sn});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(description),
        subtitle: Text('SN: $sn'),
      ),
    );
  }
}
