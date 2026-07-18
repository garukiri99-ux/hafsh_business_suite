import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_provider.dart';

class SearchBox extends ConsumerStatefulWidget {
  const SearchBox({super.key});

  @override
  ConsumerState<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends ConsumerState<SearchBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: ref.read(searchProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(searchProvider);

    // Sinkronkan jika state berubah dari luar
    if (_controller.text != search) {
      _controller.value = TextEditingValue(
        text: search,
        selection: TextSelection.collapsed(
          offset: search.length,
        ),
      );
    }

    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        ref.read(searchProvider.notifier).setSearch(value);
      },
      decoration: InputDecoration(
        hintText: "Cari menu...",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: search.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  ref.read(searchProvider.notifier).clear();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}