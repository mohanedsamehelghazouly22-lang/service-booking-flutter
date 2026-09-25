import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../models/category.dart';
import '../../models/service.dart';
import '../../widgets/service_tile.dart';
import '../service/service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Category>> _categoriesFuture;
  late Future<List<ServiceModel>> _servicesFuture;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final repo = context.read<CatalogRepository>();
    _categoriesFuture = repo.fetchCategories();
    _servicesFuture = repo.fetchServices();
  }

  void _selectCategory(String? id) {
    setState(() {
      _selectedCategoryId = id;
      _servicesFuture = context.read<CatalogRepository>().fetchServices(categoryId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _categoriesFuture = context.read<CatalogRepository>().fetchCategories();
              _servicesFuture =
                  context.read<CatalogRepository>().fetchServices(categoryId: _selectedCategoryId);
            });
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              const Text('Book a service', style: TextStyle(fontSize: 15, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              const Text('What do you need today?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 20),
              _CategoryChips(
                future: _categoriesFuture,
                selectedId: _selectedCategoryId,
                onSelect: _selectCategory,
              ),
              const SizedBox(height: 24),
              FutureBuilder<List<ServiceModel>>(
                future: _servicesFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }
                  if (snap.hasError) {
                    return _ErrorState(message: '${snap.error}');
                  }
                  final services = snap.data ?? [];
                  if (services.isEmpty) {
                    return const _EmptyState(message: 'No services available right now.');
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: services.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (context, i) {
                      final s = services[i];
                      return ServiceTile(
                        service: s,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: s)),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final Future<List<Category>> future;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  const _CategoryChips({required this.future, required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: future,
      builder: (context, snap) {
        final categories = snap.data ?? [];
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chip(context, label: 'All', selected: selectedId == null, onTap: () => onSelect(null)),
              const SizedBox(width: 8),
              ...categories.expand((c) => [
                    _chip(context, label: c.name, selected: selectedId == c.id, onTap: () => onSelect(c.id)),
                    const SizedBox(width: 8),
                  ]),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(BuildContext context, {required String label, required bool selected, required VoidCallback onTap}) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.chipBg,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.chip)),
      side: BorderSide.none,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.danger),
          const SizedBox(height: 12),
          Text('Could not load services', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
