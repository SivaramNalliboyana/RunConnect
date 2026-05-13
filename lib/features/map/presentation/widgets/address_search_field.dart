import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:runconnect/core/theme/app_colors.dart';

class AddressSearchField extends StatefulWidget {
  const AddressSearchField({
    super.key,
    required this.onPicked,
    this.controller,
    this.proximityLat,
    this.proximityLng,
  });

  final void Function(double lat, double lng, String placeName) onPicked;
  final TextEditingController? controller;
  final double? proximityLat;
  final double? proximityLng;

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  Timer? _debounce;
  List<_Place> _suggestions = const [];
  bool _searching = false;
  String? _lastPickedText;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    final query = _controller.text.trim();
    // The listener fires for both text and selection changes. If the field
    // currently holds exactly the place we just picked, ignore the change so
    // the dropdown stays closed.
    if (query == _lastPickedText) return;
    _lastPickedText = null;
    if (query.length < 3) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    final token = dotenv.env['MAPBOX_PUBLIC_TOKEN'];
    if (token == null || token.isEmpty) return;
    setState(() => _searching = true);
    try {
      final encoded = Uri.encodeComponent(query);
      final proximity =
          (widget.proximityLat != null && widget.proximityLng != null)
          ? '&proximity=${widget.proximityLng},${widget.proximityLat}'
          : '';
      final uri = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$encoded.json'
        '?access_token=$token&autocomplete=true&limit=5$proximity',
      );
      final res = await http.get(uri);
      if (!mounted) return;
      if (res.statusCode != 200) {
        setState(() => _suggestions = const []);
        return;
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (json['features'] as List?) ?? const [];
      final places = features.map((f) {
        final m = f as Map<String, dynamic>;
        final coords = (m['center'] as List).cast<num>();
        return _Place(
          name: m['place_name'] as String,
          lng: coords[0].toDouble(),
          lat: coords[1].toDouble(),
        );
      }).toList();
      setState(() => _suggestions = places);
    } catch (_) {
      if (mounted) setState(() => _suggestions = const []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _pickPlace(_Place place) {
    _debounce?.cancel();
    _lastPickedText = place.name;
    _controller.text = place.name;
    _controller.selection = TextSelection.collapsed(offset: place.name.length);
    setState(() => _suggestions = const []);
    FocusScope.of(context).unfocus();
    widget.onPicked(place.lat, place.lng, place.name);
  }

  void _clear() {
    _debounce?.cancel();
    _lastPickedText = '';
    _controller.clear();
    setState(() => _suggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.white,
          elevation: 3,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onBackground,
              ),
              decoration: InputDecoration(
                hintText: 'Search address or city',
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.primary,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : hasText
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        onPressed: _clear,
                        splashRadius: 18,
                      )
                    : null,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Material(
            color: Colors.white,
            elevation: 3,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < _suggestions.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        color: Colors.black12,
                        indent: 44,
                      ),
                    InkWell(
                      onTap: () => _pickPlace(_suggestions[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _suggestions[i].name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onBackground,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Place {
  const _Place({required this.name, required this.lat, required this.lng});
  final String name;
  final double lat;
  final double lng;
}
