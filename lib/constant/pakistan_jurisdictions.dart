/// Pakistan court jurisdictions — provinces and their major cities.
///
/// Used by the lawyer "Information" screen to drive the cascading
/// province → cities selection. The lawyer picks ONE province first,
/// then can multi-select cities within that province.
///
/// City names double as the unique identifier stored in the lawyer
/// profile's `cityIds` field — kept human-readable so admin queries
/// and reports stay legible without an extra lookup table.
class PakistanJurisdictions {
  PakistanJurisdictions._();

  /// Province → list of cities.
  /// Order roughly by population / case-load relevance.
  static const Map<String, List<String>> provinces = {
    'Punjab': [
      'Lahore',
      'Faisalabad',
      'Rawalpindi',
      'Multan',
      'Gujranwala',
      'Sialkot',
      'Bahawalpur',
      'Sargodha',
      'Sheikhupura',
      'Sahiwal',
      'Kasur',
      'Okara',
      'Wazirabad',
      'Chiniot',
      'Khanewal',
      'Hafizabad',
      'Sadiqabad',
      'Burewala',
      'Vehari',
      'Dera Ghazi Khan',
      'Mianwali',
      'Toba Tek Singh',
      'Jhelum',
      'Jaranwala',
      'Khanpur',
      'Pakpattan',
      'Rajanpur',
      'Layyah',
      'Mandi Bahauddin',
      'Khushab',
      'Chakwal',
      'Attock',
      'Narowal',
      'Bhakkar',
      'Lodhran',
      'Jhang',
      'Kot Addu',
    ],
    'Sindh': [
      'Karachi',
      'Hyderabad',
      'Sukkur',
      'Larkana',
      'Mirpur Khas',
      'Shaheed Benazirabad',
      'Jacobabad',
      'Dadu',
      'Khairpur',
      'Ghotki',
      'Tando Allahyar',
      'Tando Adam',
      'Shikarpur',
      'Thatta',
      'Badin',
      'Sanghar',
      'Mithi',
      'Umerkot',
      'Naushahro Feroze',
      'Kashmore',
      'Matiari',
    ],
    'Khyber Pakhtunkhwa': [
      'Peshawar',
      'Mardan',
      'Mingora',
      'Kohat',
      'Abbottabad',
      'Bannu',
      'Dera Ismail Khan',
      'Charsadda',
      'Nowshera',
      'Swabi',
      'Mansehra',
      'Haripur',
      'Chitral',
      'Battagram',
      'Lakki Marwat',
      'Tank',
      'Hangu',
      'Karak',
      'Buner',
      'Lower Dir',
      'Upper Dir',
      'Shangla',
      'Kohistan',
      'Malakand',
    ],
    'Balochistan': [
      'Quetta',
      'Khuzdar',
      'Turbat',
      'Hub',
      'Chaman',
      'Sibi',
      'Loralai',
      'Mastung',
      'Pishin',
      'Zhob',
      'Gwadar',
      'Kalat',
      'Lasbela',
      'Kech',
      'Panjgur',
      'Kharan',
      'Awaran',
      'Nushki',
      'Ziarat',
      'Killa Saifullah',
      'Killa Abdullah',
    ],
    'Islamabad Capital Territory': [
      'Islamabad',
    ],
    'Azad Jammu & Kashmir': [
      'Muzaffarabad',
      'Mirpur',
      'Rawalakot',
      'Kotli',
      'Bagh',
      'Bhimber',
      'Pallandri',
      'Hattian Bala',
      'Neelum',
      'Haveli',
      'Sudhanoti',
    ],
    'Gilgit-Baltistan': [
      'Gilgit',
      'Skardu',
      'Hunza',
      'Chilas',
      'Astore',
      'Ghizer',
      'Ghanche',
      'Kharmang',
      'Shigar',
      'Nagar',
    ],
  };

  /// All province names in display order.
  static List<String> get provinceNames => provinces.keys.toList();

  /// Cities of a given province (empty list if province not found).
  static List<String> citiesOf(String? province) {
    if (province == null || province.isEmpty) return const [];
    return provinces[province] ?? const [];
  }

  /// Reverse lookup — find which province a given city belongs to.
  /// Returns null if not found.
  static String? provinceOf(String? city) {
    if (city == null || city.isEmpty) return null;
    for (final entry in provinces.entries) {
      if (entry.value.contains(city)) return entry.key;
    }
    return null;
  }

  /// Total city count across all provinces.
  static int get totalCities =>
      provinces.values.fold<int>(0, (sum, cities) => sum + cities.length);
}
