class DashboardSummary {
  final DashboardCounts counts;
  final List<LowStockItem> lowStockPreview;
  final List<StockMovementItem> recentMovements;

  DashboardSummary({
    required this.counts,
    required this.lowStockPreview,
    required this.recentMovements,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      counts: DashboardCounts.fromJson(json['counts'] as Map<String, dynamic>? ?? {}),
      lowStockPreview: (json['low_stock_preview'] as List<dynamic>? ?? [])
          .map((e) => LowStockItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentMovements: (json['recent_movements'] as List<dynamic>? ?? [])
          .map((e) => StockMovementItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardCounts {
  final int products;
  final int categories;
  final int lowStock;
  final int outOfStock;

  DashboardCounts({
    required this.products,
    required this.categories,
    required this.lowStock,
    required this.outOfStock,
  });

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      products: json['products'] ?? 0,
      categories: json['categories'] ?? 0,
      lowStock: json['low_stock'] ?? 0,
      outOfStock: json['out_of_stock'] ?? 0,
    );
  }
}

class LowStockItem {
  final int id;
  final String name;
  final String category;
  final int stockQuantity;
  final int reorderLevel;

  LowStockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.stockQuantity,
    required this.reorderLevel,
  });

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Uncategorized',
      stockQuantity: json['stock_quantity'] ?? 0,
      reorderLevel: json['reorder_level'] ?? 0,
    );
  }
}

class StockMovementItem {
  final int? id;
  final String type;
  final String item;
  final int qty;
  final String by;

  StockMovementItem({
    this.id,
    required this.type,
    required this.item,
    required this.qty,
    required this.by,
  });

  factory StockMovementItem.fromJson(Map<String, dynamic> json) {
    return StockMovementItem(
      id: json['id'],
      type: json['type']?.toString() ?? 'adjustment',
      item: json['item']?.toString() ?? 'Unknown',
      qty: json['qty'] ?? 0,
      by: json['by']?.toString() ?? 'System',
    );
  }
}
