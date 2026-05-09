/// Models for the country → province → city hierarchy fetched from
/// the admin panel's `/api/jurisdictions` endpoint.
class JurisdictionCountry {
  final int id;
  final String iso;
  final String name;
  final String? currency;
  final String? dialCode;
  final String? flag;
  final List<JurisdictionProvince> provinces;

  const JurisdictionCountry({
    required this.id,
    required this.iso,
    required this.name,
    required this.provinces,
    this.currency,
    this.dialCode,
    this.flag,
  });

  factory JurisdictionCountry.fromJson(Map<String, dynamic> json) {
    return JurisdictionCountry(
      id: (json['id'] as num).toInt(),
      iso: (json['iso'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      currency: json['currency'] as String?,
      dialCode: json['dial_code'] as String?,
      flag: json['flag'] as String?,
      provinces: (json['provinces'] as List? ?? [])
          .map((p) => JurisdictionProvince.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'iso': iso,
        'name': name,
        'currency': currency,
        'dial_code': dialCode,
        'flag': flag,
        'provinces': provinces.map((p) => p.toJson()).toList(),
      };
}

class JurisdictionProvince {
  final int id;
  final String name;
  final String? code;
  final List<JurisdictionCity> cities;

  const JurisdictionProvince({
    required this.id,
    required this.name,
    required this.cities,
    this.code,
  });

  factory JurisdictionProvince.fromJson(Map<String, dynamic> json) {
    return JurisdictionProvince(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      code: json['code'] as String?,
      cities: (json['cities'] as List? ?? [])
          .map((c) => JurisdictionCity.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'cities': cities.map((c) => c.toJson()).toList(),
      };
}

class JurisdictionCity {
  final int id;
  final String name;
  final double? lat;
  final double? lng;

  const JurisdictionCity({
    required this.id,
    required this.name,
    this.lat,
    this.lng,
  });

  factory JurisdictionCity.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
    return JurisdictionCity(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      lat: toDouble(json['lat']),
      lng: toDouble(json['lng']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
      };
}
