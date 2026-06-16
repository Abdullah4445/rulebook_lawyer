import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/model/jurisdiction_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fetches the country → province → city hierarchy from the admin
/// panel's `/api/jurisdictions` endpoint and caches it on disk.
///
/// Strategy:
///   - First read: attempt network fetch, fall back to cache on failure.
///   - Subsequent reads: return cache if version matches, else refetch.
///   - TTL: 24h soft (we always try the network first to detect new
///     countries / cities that admin has added).
class JurisdictionService {
  JurisdictionService._();
  static final JurisdictionService instance = JurisdictionService._();

  static const String _cacheKey = 'jurisdictions_cache_v1';
  static const String _versionKey = 'jurisdictions_version_v1';
  static const Duration _networkTimeout = Duration(seconds: 10);

  /// In-memory copy populated on first successful load. Cleared on signOut.
  List<JurisdictionCountry>? _memo;

  Future<List<JurisdictionCountry>> getCountries({bool forceRefresh = false}) async {
    if (_memo != null && _memo!.isNotEmpty && !forceRefresh) {
      return _memo!;
    }

    // Try network first.
    final fresh = await _fetchFromNetwork();
    if (fresh != null) {
      _memo = fresh;
      return fresh;
    }

    // Network failed — fall back to disk cache.
    final cached = await _loadFromCache();
    if (cached.isNotEmpty) {
      _memo = cached;
      return cached;
    }

    return [];
  }

  Future<List<JurisdictionCountry>?> _fetchFromNetwork() async {
    try {
      final uri = Uri.parse('${Constant.globalUrl}api/jurisdictions');
      // Bypass ngrok-free's HTML interstitial — without it ngrok returns a
      // "Visit Site" page with status 200, jsonDecode throws and the catch
      // below kills the whole load. Production servers ignore this header.
      final resp = await http
          .get(uri, headers: {'ngrok-skip-browser-warning': 'true'})
          .timeout(_networkTimeout);
      if (resp.statusCode != 200) return null;

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final list = (body['countries'] as List? ?? [])
          .map((c) => JurisdictionCountry.fromJson(c as Map<String, dynamic>))
          .toList();
      // Persist for offline fallback.
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(body['countries']));
        await prefs.setString(_versionKey, body['version']?.toString() ?? '');
      } catch (_) {/* persistence is best-effort */}
      return list;
    } catch (_) {
      return null;
    }
  }

  Future<List<JurisdictionCountry>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((c) => JurisdictionCountry.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void clearMemo() {
    _memo = null;
  }
}
