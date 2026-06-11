class FoodProduct {
  const FoodProduct({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.calories,
    required this.protein,
    required this.sugar,
    required this.note,
  });

  final String barcode;
  final String name;
  final String brand;
  final int calories;
  final double protein;
  final double sugar;
  final String note;
}

const sampleFoodProducts = <FoodProduct>[
  FoodProduct(
    barcode: '893000000001',
    name: 'Sữa chua Hy Lạp không đường',
    brand: 'Demo Fit',
    calories: 95,
    protein: 10,
    sugar: 3.5,
    note: 'Tốt cho bữa phụ, giàu protein và ít đường.',
  ),
  FoodProduct(
    barcode: '893000000002',
    name: 'Thanh protein vị cacao',
    brand: 'Demo Bar',
    calories: 210,
    protein: 20,
    sugar: 7,
    note: 'Phù hợp sau tập, nên kiểm soát tổng calories trong ngày.',
  ),
  FoodProduct(
    barcode: '893000000003',
    name: 'Nước uống điện giải ít đường',
    brand: 'Hydro Demo',
    calories: 35,
    protein: 0,
    sugar: 4,
    note: 'Dùng khi vận động nhiều, không thay thế nước lọc hằng ngày.',
  ),
];
