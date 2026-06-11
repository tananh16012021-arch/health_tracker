import 'package:flutter/material.dart';

import '../models/food_product.dart';
import '../models/recipe.dart';
import '../widgets/section_title.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _barcodeController = TextEditingController(text: '893000000001');
  FoodProduct? _product = sampleFoodProducts.first;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _lookup() {
    final code = _barcodeController.text.trim();
    FoodProduct? found;
    for (final item in sampleFoodProducts) {
      if (item.barcode == code) {
        found = item;
        break;
      }
    }
    setState(() => _product = found);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(
            title: 'Barcode lookup demo',
            subtitle: 'Bản này dùng dữ liệu mẫu offline. Sau này có thể nối Open Food Facts hoặc camera scanner.',
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _barcodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nhập barcode demo',
                      prefixIcon: Icon(Icons.qr_code_scanner),
                      helperText: 'Thử: 893000000001, 893000000002, 893000000003',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _lookup,
                    icon: const Icon(Icons.search),
                    label: const Text('Tra cứu'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_product == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('Không tìm thấy barcode trong dữ liệu demo.'),
              ),
            )
          else
            _ProductCard(product: _product!),
          const SizedBox(height: 20),
          const SectionTitle(title: 'Healthy recipes'),
          for (final recipe in sampleRecipes) _RecipeCard(recipe: recipe),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final FoodProduct product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('${product.brand} • ${product.barcode}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('${product.calories} kcal')),
                Chip(label: Text('${product.protein.toStringAsFixed(1)}g protein')),
                Chip(label: Text('${product.sugar.toStringAsFixed(1)}g sugar')),
              ],
            ),
            const SizedBox(height: 8),
            Text(product.note),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(child: Text('${recipe.calories}')),
        title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${recipe.goal} • P ${recipe.protein} • C ${recipe.carbs} • F ${recipe.fat}'),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(recipe.description)),
          const SizedBox(height: 8),
          for (var i = 0; i < recipe.steps.length; i++)
            ListTile(
              dense: true,
              leading: CircleAvatar(radius: 13, child: Text('${i + 1}')),
              title: Text(recipe.steps[i]),
            ),
        ],
      ),
    );
  }
}
