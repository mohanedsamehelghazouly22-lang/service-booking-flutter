import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../models/service.dart';
import '../../models/location.dart';
import '../../state/booking_flow_provider.dart';
import '../booking/date_select_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late Future<List<LocationModel>> _locationsFuture;

  @override
  void initState() {
    super.initState();
    _locationsFuture = context.read<CatalogRepository>().fetchLocationsForService(widget.service.id);
    context.read<BookingFlowProvider>().selectService(widget.service);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            backgroundColor: AppColors.background,
            pinned: true,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: s.imageUrl != null
                  ? CachedNetworkImage(imageUrl: s.imageUrl!, fit: BoxFit.cover)
                  : Container(color: AppColors.cardAlt),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text('${s.durationMinutes} min', style: const TextStyle(color: AppColors.textMuted)),
                      if (s.price != null) ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.payments_outlined, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text('\$${s.price!.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMuted)),
                      ],
                    ],
                  ),
                  if (s.description != null) ...[
                    const SizedBox(height: 16),
                    Text(s.description!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 28),
                  const Text('Choose a location', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 14),
                  FutureBuilder<List<LocationModel>>(
                    future: _locationsFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        );
                      }
                      if (snap.hasError) {
                        return Text('Could not load locations: ${snap.error}',
                            style: const TextStyle(color: AppColors.danger));
                      }
                      final locations = snap.data ?? [];
                      if (locations.isEmpty) {
                        return const Text('No locations currently offer this service.',
                            style: TextStyle(color: AppColors.textMuted));
                      }
                      return Column(
                        children: locations.map((l) => _LocationCard(location: l, service: s)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final LocationModel location;
  final ServiceModel service;
  const _LocationCard({required this.location, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.cardAlt,
          child: Icon(Icons.location_on_outlined,
              color: location.isInstant ? AppColors.primary : AppColors.textMutedOnCard),
        ),
        title: Text(location.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            if (location.address != null) location.address!,
            location.isInstant ? 'Instant confirmation' : 'Confirmed within 4 hours',
          ].join(' · '),
          style: const TextStyle(color: AppColors.textMutedOnCard, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
        onTap: () {
          context.read<BookingFlowProvider>().selectLocation(location);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DateSelectScreen()),
          );
        },
      ),
    );
  }
}
