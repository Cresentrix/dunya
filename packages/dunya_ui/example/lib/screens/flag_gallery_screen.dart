import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

class FlagGalleryScreen extends StatelessWidget {
  const FlagGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flag Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Size variations
          const _Header(
            title: 'Size Variations',
            description: 'FlagWidget at 16, 24, 28, 36, 48, and 64dp width. '
                'Height is always width × 0.67.',
          ),
          const SizedBox(height: 12),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _FlagWithLabel(alpha2: 'AE', size: 16, label: '16'),
              SizedBox(width: 16),
              _FlagWithLabel(alpha2: 'AE', size: 24, label: '24'),
              SizedBox(width: 16),
              _FlagWithLabel(alpha2: 'AE', size: 28, label: '28'),
              SizedBox(width: 16),
              _FlagWithLabel(alpha2: 'AE', size: 36, label: '36'),
              SizedBox(width: 16),
              _FlagWithLabel(alpha2: 'AE', size: 48, label: '48'),
              SizedBox(width: 16),
              _FlagWithLabel(alpha2: 'AE', size: 64, label: '64'),
            ],
          ),
          const SizedBox(height: 28),

          // Radius variations
          const _Header(
            title: 'Radius Variations',
            description: 'Same flag at 0, 2, 4, 8, and fully rounded radius.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const _FlagWithLabel(
                alpha2: 'JP',
                size: 48,
                label: 'r=0',
                radius: BorderRadius.zero,
              ),
              const SizedBox(width: 16),
              _FlagWithLabel(
                alpha2: 'JP',
                size: 48,
                label: 'r=2',
                radius: BorderRadius.circular(2),
              ),
              const SizedBox(width: 16),
              const _FlagWithLabel(alpha2: 'JP', size: 48, label: 'r=4 (default)'),
              const SizedBox(width: 16),
              _FlagWithLabel(
                alpha2: 'JP',
                size: 48,
                label: 'r=8',
                radius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 16),
              _FlagWithLabel(
                alpha2: 'JP',
                size: 48,
                label: 'pill',
                radius: BorderRadius.circular(24),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Placeholder fallback
          const _Header(
            title: 'Placeholder Fallback',
            description:
                'Unknown alpha2 codes show a grey rounded rect placeholder.',
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _FlagWithLabel(alpha2: 'XX', size: 48, label: 'XX'),
              SizedBox(width: 16),
              _FlagWithLabel(alpha2: 'ZZ', size: 48, label: 'ZZ'),
              SizedBox(width: 16),
              _FlagWithLabel(alpha2: '??', size: 48, label: '??'),
              SizedBox(width: 16),
              _FlagWithLabel(alpha2: 'US', size: 48, label: 'US (valid)'),
            ],
          ),
          const SizedBox(height: 28),

          // Context comparison
          const _Header(
            title: 'List vs Dial Field Size',
            description:
                'List context uses 28dp (default). Dial field context uses 24dp.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                children: [
                  const FlagWidget(alpha2: 'EG', size: 28),
                  const SizedBox(height: 4),
                  Text('28dp list',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  const FlagWidget(alpha2: 'EG', size: 24),
                  const SizedBox(height: 4),
                  Text('24dp dial',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // All 250 flags grid
          const _Header(
            title: 'All Flags',
            description: '250 countries — tap for details.',
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: CountryRepository.all.length,
            itemBuilder: (context, i) {
              final c = CountryRepository.all[i];
              return GestureDetector(
                onTap: () => _showDetail(context, c),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlagWidget(alpha2: c.alpha2, size: 36),
                    const SizedBox(height: 2),
                    Text(c.alpha2,
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Country country) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlagWidget(alpha2: country.alpha2, size: 64),
            const SizedBox(height: 12),
            Text(country.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(country.nativeName,
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              '${country.alpha2}  •  ${country.alpha3}  •  ${country.dialCode}',
              style: const TextStyle(fontSize: 14),
            ),
            Text('${country.region} — ${country.subregion}',
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String description;
  const _Header({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(description,
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }
}

class _FlagWithLabel extends StatelessWidget {
  final String alpha2;
  final double size;
  final String label;
  final BorderRadius? radius;

  const _FlagWithLabel({
    required this.alpha2,
    required this.size,
    required this.label,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlagWidget(alpha2: alpha2, size: size, radius: radius),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
