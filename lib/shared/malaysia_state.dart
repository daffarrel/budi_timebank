import '../model/state_malaysia.dart';

class MalaysiaState {
  static final List<StateMalaysia> _allStates = [
    StateMalaysia(state: 'Johor', districts: [
      'Batu Pahat',
      'Johor Bahru',
      'Kluang',
      'Kota Tinggi',
      'Kulai',
      'Mersing',
      'Muar',
      'Pontian',
      'Segamat',
      'Tangkak'
    ]),
    StateMalaysia(state: 'Kedah', districts: [
      'Baling',
      'Bandar Baharu',
      'Kota Setar',
      'Kuala Muda',
      'Kubang Pasu',
      'Kulim',
      'Langkawi',
      'Padang Terap',
      'Pendang',
      'Pokok Sena',
      'Sik',
      'Yan'
    ]),
    StateMalaysia(state: 'Kelantan', districts: [
      'Bachok',
      'Gua Musang',
      'Jeli',
      'Kota Bharu',
      'Kuala Krai',
      'Machang',
      'Pasir Mas',
      'Pasir Puteh',
      'Tanah Merah',
      'Tumpat'
    ]),
    StateMalaysia(state: 'Melaka', districts: [
      'Alor Gajah',
      'Jasin',
      'Melaka Tengah',
      'Masjid Tanah',
      'Merlimau',
      'Jasin'
    ]),
    StateMalaysia(state: 'Negeri Sembilan', districts: [
      'Jelebu',
      'Jempol',
      'Kuala Pilah',
      'Port Dickson',
      'Rembau',
      'Seremban',
      'Tampin'
    ]),
    StateMalaysia(state: 'Pahang', districts: [
      'Bentong',
      'Bera',
      'Cameron Highlands',
      'Jerantut',
      'Kuantan',
      'Lipis',
      'Maran',
      'Pekan',
      'Raub',
      'Rompin',
      'Temerloh'
    ]),
    StateMalaysia(state: 'Pulau Pinang', districts: [
      'Barat Daya',
      'Barat Laut',
      'Seberang Perai Selatan',
      'Seberang Perai Tengah',
      'Seberang Perai Utara',
      'Timur Laut'
    ]),
    StateMalaysia(state: 'Perak', districts: [
      'Bagan Datuk',
      'Batang Padang',
      'Hilir Perak',
      'Hulu Perak',
      'Kampar',
      'Kerian',
      'Kinta',
      'Kuala Kangsar',
      'Larut, Matang dan Selama',
      'Manjung',
      'Muallim',
      'Perak Tengah',
    ]),
    StateMalaysia(state: 'Wilayah Persekutuan', districts: [
      'Kuala Lumpur',
      'Labuan',
      'Putrajaya',
    ]),
    StateMalaysia(state: 'Sabah', districts: [
      'Beaufort',
      'Beluran',
      'Kalabakan',
      'Keningau',
      'Kinabatangan',
      'Kota Belud',
      'Kota Kinabalu',
      'Kota Marudu',
      'Kuala Penyu',
      'Kudat',
      'Kunak',
      'Lahad Datu',
      'Nabawan',
      'Papar',
      'Penampang',
      'Pitas',
      'Putatan',
      'Ranau',
      'Sandakan',
      'Semporna',
      'Sipitang',
      'Tambunan',
      'Tawau',
      'Telupid',
      'Tenom',
      'Tongod',
      'Tuaran',
    ]),
    StateMalaysia(state: 'Sarawak', districts: [
      'Bau',
      'Belaga',
      'Betong',
      'Bintulu',
      'Dalat',
      'Daro',
      'Julau',
      'Kabong',
      'Kanowit',
      'Kapit',
      'Kuching',
      'Lawas',
      'Limbang',
      'Lubok Antu',
      'Lundu',
      'Marudi',
      'Matu',
      'Meradong',
      'Miri',
      'Mukah',
      'Pakan',
      'Pusa',
      'Samarahan',
      'Saratok',
      'Sarikei',
      'Selangau',
      'Serian',
      'Sibu',
      'Simunjan',
      'Song',
      'Sri Aman',
      'Tanjung Manis',
      'Tatau',
      'Tebedu',
      'Telang Usan',
    ]),
    StateMalaysia(state: 'Selangor', districts: [
      'Gombak',
      'Hulu Langat',
      'Hulu Selangor',
      'Klang',
      'Kuala Langat',
      'Kuala Selangor',
      'Petaling',
      'Sabak Bernam',
      'Sepang',
    ]),
    StateMalaysia(state: 'Terengganu', districts: [
      'Besut',
      'Dungun',
      'Hulu Terengganu',
      'Kemaman',
      'Kuala Nerus',
      'Kuala Terengganu',
      'Marang',
      'Setiu',
    ]),
    StateMalaysia(state: 'Perlis', districts: [
      'Kangar',
      'Padang Besar',
      'Arau',
      'Pauh',
      'Simpang Ampat',
    ]),
  ];

  static List<StateMalaysia> allStates() => _allStates;

  /// Get all the state names
  static List<String> allStatesName() =>
      _allStates.map((e) => e.state).toList();

  /// Get the list districts name for the given state
  static List<String> districtsForState(String state) {
    state = state.toLowerCase();
    return _allStates
        .firstWhere((element) => element.state.toLowerCase() == state)
        .districts;
  }
}
