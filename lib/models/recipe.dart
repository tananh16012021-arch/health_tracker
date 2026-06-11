class Recipe {
  const Recipe({
    required this.title,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.goal,
    required this.steps,
  });

  final String title;
  final String description;
  final int calories;
  final String protein;
  final String carbs;
  final String fat;
  final String goal;
  final List<String> steps;
}

const sampleRecipes = <Recipe>[
  Recipe(
    title: 'Ức gà áp chảo + salad',
    description: 'Bữa ăn giàu đạm, ít dầu mỡ, phù hợp mục tiêu giảm mỡ.',
    calories: 430,
    protein: '38g',
    carbs: '32g',
    fat: '14g',
    goal: 'Giảm mỡ',
    steps: [
      'Ướp ức gà với muối, tiêu, tỏi trong 10 phút.',
      'Áp chảo mỗi mặt 4-5 phút đến khi chín.',
      'Ăn kèm xà lách, cà chua, dưa leo và sốt ít béo.',
    ],
  ),
  Recipe(
    title: 'Yến mạch chuối sữa chua',
    description: 'Bữa sáng nhanh, dễ chuẩn bị, nhiều chất xơ.',
    calories: 360,
    protein: '18g',
    carbs: '58g',
    fat: '7g',
    goal: 'Giữ dáng',
    steps: [
      'Trộn yến mạch với sữa chua không đường.',
      'Thêm chuối cắt lát và hạt chia.',
      'Để lạnh 15 phút rồi dùng.',
    ],
  ),
  Recipe(
    title: 'Cá hồi nướng rau củ',
    description: 'Bổ sung omega-3, phù hợp bữa tối lành mạnh.',
    calories: 520,
    protein: '42g',
    carbs: '35g',
    fat: '24g',
    goal: 'Tăng cơ',
    steps: [
      'Ướp cá hồi với chanh, tiêu, muối.',
      'Nướng cùng bông cải, cà rốt, khoai tây trong 15-20 phút.',
      'Dùng khi còn nóng.',
    ],
  ),
  Recipe(
    title: 'Cơm gạo lứt bò xào nấm',
    description: 'Nhiều năng lượng sạch cho ngày tập nặng.',
    calories: 610,
    protein: '45g',
    carbs: '68g',
    fat: '18g',
    goal: 'Tăng cơ',
    steps: [
      'Xào bò nạc cùng nấm, hành tây và ít dầu olive.',
      'Ăn kèm cơm gạo lứt và rau luộc.',
      'Có thể chia thành hộp meal prep cho 2 bữa.',
    ],
  ),
];
