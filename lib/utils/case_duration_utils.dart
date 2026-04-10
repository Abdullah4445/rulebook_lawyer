class CaseDurationUtils {
  static const String defaultUnit = 'days';
  static const List<String> units = ['days', 'weeks', 'months'];

  static String normalizeUnit(String? unit) {
    switch ((unit ?? '').trim().toLowerCase()) {
      case 'day':
      case 'days':
        return 'days';
      case 'week':
      case 'weeks':
        return 'weeks';
      case 'month':
      case 'months':
        return 'months';
      default:
        return defaultUnit;
    }
  }

  static String unitLabel(String unit, {bool singular = false}) {
    switch (normalizeUnit(unit)) {
      case 'days':
        return singular ? 'Day' : 'Days';
      case 'weeks':
        return singular ? 'Week' : 'Weeks';
      case 'months':
        return singular ? 'Month' : 'Months';
      default:
        return singular ? 'Day' : 'Days';
    }
  }

  static String _buildLabel(int value, String unit) {
    final normalizedUnit = normalizeUnit(unit);
    final bool isSingular = value == 1;
    return '$value ${unitLabel(normalizedUnit, singular: isSingular)}';
  }

  static Map<String, dynamic>? buildDuration({
    required String valueText,
    required String unit,
  }) {
    final int? value = int.tryParse(valueText.trim());
    if (value == null || value <= 0) {
      return null;
    }

    final normalizedUnit = normalizeUnit(unit);
    return {
      'value': value,
      'unit': normalizedUnit,
      'label': _buildLabel(value, normalizedUnit),
    };
  }

  static Map<String, dynamic>? normalizeDuration(dynamic raw) {
    if (raw == null) return null;

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final dynamic valueRaw = map['value'] ?? map['count'] ?? map['durationValue'];
      final int? value = valueRaw is int
          ? valueRaw
          : int.tryParse(valueRaw?.toString().trim() ?? '');
      final String unit = normalizeUnit(
        map['unit']?.toString() ?? map['durationUnit']?.toString(),
      );

      if (value != null && value > 0) {
        return {
          'value': value,
          'unit': unit,
          'label': map['label']?.toString().trim().isNotEmpty == true
              ? map['label'].toString().trim()
              : _buildLabel(value, unit),
        };
      }

      final String label = map['label']?.toString().trim() ?? '';
      if (label.isNotEmpty) {
        return {
          'label': label,
        };
      }
      return null;
    }

    if (raw is int) {
      return {
        'value': raw,
        'unit': defaultUnit,
        'label': _buildLabel(raw, defaultUnit),
      };
    }

    final String text = raw.toString().trim();
    if (text.isEmpty) return null;

    final regex = RegExp(r'^(\d+)\s*(day|days|week|weeks|month|months)$', caseSensitive: false);
    final match = regex.firstMatch(text);
    if (match != null) {
      final int? value = int.tryParse(match.group(1) ?? '');
      if (value != null && value > 0) {
        final unit = normalizeUnit(match.group(2));
        return {
          'value': value,
          'unit': unit,
          'label': _buildLabel(value, unit),
        };
      }
    }

    return {
      'label': text,
    };
  }

  static String formatDuration(dynamic raw, {String fallback = ''}) {
    final normalized = normalizeDuration(raw);
    if (normalized == null) return fallback;

    final String label = normalized['label']?.toString().trim() ?? '';
    if (label.isNotEmpty) {
      return label;
    }

    final int? value = normalized['value'] is int
        ? normalized['value'] as int
        : int.tryParse(normalized['value']?.toString() ?? '');
    if (value == null || value <= 0) return fallback;

    return _buildLabel(value, normalized['unit']?.toString() ?? defaultUnit);
  }
}

