import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/part.dart';
import '../widgets/part_card.dart';
import 'add_part.dart';
import 'part_detail.dart';

class ItemDetailPage extends StatelessWidget {
  final String jobOrderId;
  final String orderNumber;
  final String clientName;
  final String itemId;
  final String itemCode;
  final String itemDescription;
  final int quantity;

  const ItemDetailPage({
    super.key,
    required this.jobOrderId,
    required this.orderNumber,
    required this.clientName,
    required this.itemId,
    required this.itemCode,
    required this.itemDescription,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),

      // ✅ Different from JobOrder page: bottom bar action
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
            ),
          ),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Part'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPartPage(
                      jobOrderId: jobOrderId,
                      orderNumber: orderNumber,
                      itemId: itemId,
                      itemCode: itemCode,
                      clientName: clientName,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),

      body: StreamBuilder<List<Part>>(
        stream: db.getParts(jobOrderId, itemId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final parts = snap.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: _ItemHeaderCard(
                    clientName: clientName,
                    orderNumber: orderNumber,
                    itemCode: itemCode,
                    itemDescription: itemDescription,
                    quantity: quantity,
                    partsCount: parts.length,
                  ),
                ),
              ),
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     child: _SectionTitle(
              //       title: 'Parts',
              //       subtitle: parts.isEmpty
              //           ? 'No parts yet'
              //           : '${parts.length} part(s)',
              //     ),
              //   ),
              // ),
              if (parts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('No parts added yet.\nTap "Add Part" below.'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  sliver: SliverList.separated(
                    itemCount: parts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = parts[i];

                      return DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.45),
                          ),
                          // subtle card tint
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: PartCard(
                            part: p,
                            subtitleRight: 'SN: ${p.sn} • Qty: ${p.qty}',
                            onOpen: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PartDetailPage(
                                    jobOrderId: jobOrderId,
                                    itemId: itemId,
                                    part: p,
                                    clientName: clientName,
                                    orderNumber: orderNumber,
                                    itemCode: itemCode,
                                  ),
                                ),
                              );
                            },
                            // keep your behavior: print button opens detail page (since detail prints)
                            onPrint: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PartDetailPage(
                                    jobOrderId: jobOrderId,
                                    itemId: itemId,
                                    part: p,
                                    clientName: clientName,
                                    orderNumber: orderNumber,
                                    itemCode: itemCode,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemHeaderCard extends StatelessWidget {
  final String clientName;
  final String orderNumber;
  final String itemCode;
  final String itemDescription;
  final int quantity;
  final int partsCount;

  const _ItemHeaderCard({
    required this.clientName,
    required this.orderNumber,
    required this.itemCode,
    required this.itemDescription,
    required this.quantity,
    required this.partsCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Use theme colors (so it follows dark/light mode)
    final bg = cs.primaryContainer;
    final fg = cs.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top line
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  itemCode,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: fg.withOpacity(0.25),
                  ),
                ),
                child: Text(
                  'Qty: $quantity',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: fg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            itemDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetaChip(label: 'Client', value: clientName, fg: fg),
              _MetaChip(label: 'Order', value: orderNumber, fg: fg),
              //_MetaChip(label: 'Parts', value: partsCount.toString(), fg: fg),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  final Color fg;

  const _MetaChip({
    required this.label,
    required this.value,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: fg.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: fg.withOpacity(0.9)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.45),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
