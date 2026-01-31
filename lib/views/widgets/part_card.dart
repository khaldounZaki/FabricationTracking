import 'package:flutter/material.dart';
import '../../models/part.dart';

class PartCard extends StatelessWidget {
  final Part part;
  final VoidCallback onOpen;
  final VoidCallback? onPrint;
  final String? subtitleRight;

  const PartCard({
    super.key,
    required this.part,
    required this.onOpen,
    this.onPrint,
    this.subtitleRight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      child: ListTile(
        leading: const Icon(Icons.build),
        title: Text(part.description),
        subtitle: subtitleRight == null ? null : Text(subtitleRight!),
        trailing: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // if (onPrint != null)
            //   IconButton(
            //     icon: const Icon(Icons.print),
            //     onPressed: onPrint,
            //     tooltip: 'Print Sticker',
            //   ),
            Icon(Icons.chevron_right),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}
