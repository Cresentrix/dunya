import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Country> _results = CountryRepository.all;
  String? _regionFilter;

  static const _examples = [
    _SearchExample(query: 'AE', label: 'Alpha-2 code', score: '0 — exact'),
    _SearchExample(query: '+971', label: 'Dial code', score: '1 — exact'),
    _SearchExample(query: 'Uni', label: 'Name starts with', score: '2 — prefix'),
    _SearchExample(query: 'land', label: 'Name contains', score: '3 — contains'),
    _SearchExample(query: 'مصر', label: 'Native name', score: '4 — native'),
    _SearchExample(query: 'ARE', label: 'Alpha-3 code', score: '5 — alpha3'),
  ];

  static final _regions = [
    null,
    ...{...CountryRepository.all.map((c) => c.region)}..remove(''),
  ];

  List<Country> get _sourceList {
    if (_regionFilter == null) return CountryRepository.all;
    return CountryRepository.all
        .where((c) => c.region == _regionFilter)
        .toList();
  }

  void _search(String query) {
    setState(() {
      _results = CountrySearch.search(_sourceList, query);
    });
  }

  void _setRegion(String? region) {
    setState(() {
      _regionFilter = region;
      _results = CountrySearch.search(_sourceList, _controller.text);
    });
  }

  void _applyExample(String query) {
    _controller.text = query;
    _search(query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          // Search input + region filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _controller,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Type name, code, dial code, native name...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Region filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Region:', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _regions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final region = _regions[i];
                        final isActive = region == _regionFilter;
                        return FilterChip(
                          label: Text(region ?? 'All',
                              style: const TextStyle(fontSize: 12)),
                          selected: isActive,
                          onSelected: (_) => _setRegion(isActive ? null : region),
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Quick examples
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _examples.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final ex = _examples[i];
                  return ActionChip(
                    label: Text('"${ex.query}"',
                        style: const TextStyle(fontSize: 11)),
                    onPressed: () => _applyExample(ex.query),
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Result count + score legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('${_results.length} results',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const Spacer(),
                if (_regionFilter != null)
                  Text('Filtered: $_regionFilter',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),

          const Divider(height: 1),

          // Results list
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        const Text('No matching countries'),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _results.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (_, i) {
                      final c = _results[i];
                      return ListTile(
                        leading: FlagWidget(alpha2: c.alpha2),
                        title: Text(c.name),
                        subtitle: Text(
                          '${c.nativeName}  •  ${c.alpha2}  •  ${c.dialCode}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(c.region,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500])),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchExample {
  final String query;
  final String label;
  final String score;
  const _SearchExample({
    required this.query,
    required this.label,
    required this.score,
  });
}
