import 'package:flutter/material.dart';

/// Generic apparel measurements (inches / cm). Not product-specific —
/// aura-fashion-backend has no per-product size-chart data, so this is a
/// static reference shown the same way across all products with sizes.
const _rows = [
  ['XS', '31–32 / 79–81', '24–25 / 61–64', '34–35 / 86–89'],
  ['S', '33–34 / 84–86', '26–27 / 66–69', '36–37 / 91–94'],
  ['M', '35–36 / 89–91', '28–29 / 71–74', '38–39 / 97–99'],
  ['L', '37–39 / 94–99', '30–32 / 76–81', '40–42 / 102–107'],
  ['XL', '40–42 / 102–107', '33–35 / 84–89', '43–45 / 109–114'],
];

Future<void> showSizeGuide(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _SizeGuideSheet(),
  );
}

class _SizeGuideSheet extends StatelessWidget {
  const _SizeGuideSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Size Guide', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Measurements in inches / cm',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Size')),
                DataColumn(label: Text('Chest')),
                DataColumn(label: Text('Waist')),
                DataColumn(label: Text('Hips')),
              ],
              rows: [
                for (final row in _rows)
                  DataRow(cells: [for (final cell in row) DataCell(Text(cell))]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Measurements are body measurements, not garment measurements. '
            'If you\'re between sizes, we recommend sizing up.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
