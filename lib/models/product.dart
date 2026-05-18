class Product {
  final int id;
  final int? categoryId;
  final int? supplierId;
  final String? sku;
  final String? barcode;
  final String name;
  final String? description;
  final String? imagePath;
  final double? costPrice;
  final double? sellingPrice;
  final int stockQuantity;
  final int? reorderLevel;
  final DateTime? expiryDate;
  final bool isActive;
  final Category? category;
  final Supplier? supplier;

  Product({
    required this.id,
    this.categoryId,
    this.supplierId,
    this.sku,
    this.barcode,
    required this.name,
    this.description,
    this.imagePath,
    this.costPrice,
    this.sellingPrice,
    required this.stockQuantity,
    this.reorderLevel,
    this.expiryDate,
    required this.isActive,
    this.category,
    this.supplier,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      categoryId: json['category_id'],
      supplierId: json['supplier_id'],
      sku: json['sku'],
      barcode: json['barcode'],
      name: json['name'],
      description: json['description'],
      imagePath: json['image_path'],
      costPrice: json['cost_price'] != null ? double.parse(json['cost_price'].toString()) : null,
      sellingPrice: json['selling_price'] != null ? double.parse(json['selling_price'].toString()) : null,
      stockQuantity: json['stock_quantity'] ?? 0,
      reorderLevel: json['reorder_level'],
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      isActive: json['is_active'] ?? true,
      category: json['category'] != null
          ? (json['category'] is Map<String, dynamic>
              ? Category.fromJson(json['category'])
              : Category(
                  id: json['category_id'] ?? 0,
                  name: json['category'].toString(),
                  description: null,
                ))
          : null,
      supplier: json['supplier'] != null
          ? (json['supplier'] is Map<String, dynamic>
              ? Supplier.fromJson(json['supplier'])
              : Supplier(
                  id: json['supplier_id'] ?? 0,
                  name: json['supplier'].toString(),
                  contactPerson: null,
                  phone: null,
                  email: null,
                  address: null,
                  isActive: true,
                ))
          : null,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class Supplier {
  final int id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final bool isActive;

  Supplier({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    required this.isActive,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      contactPerson: json['contact_person'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      isActive: json['is_active'] ?? true,
    );
  }
}