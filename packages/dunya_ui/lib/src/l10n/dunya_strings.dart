/// Default UI strings used across Dunya widgets.
///
/// Override by passing a custom instance to [DunyaCountryPicker] or
/// by providing string parameters directly on widgets.
///
/// For localization, create locale-specific instances:
/// ```dart
/// const kDunyaStringsAr = DunyaStrings(
///   selectCountry: 'اختر الدولة',
///   search: 'بحث...',
///   noResults: 'لم يتم العثور على دول',
///   cancel: 'إلغاء',
///   phoneHint: 'رقم الهاتف',
/// );
/// ```
class DunyaStrings {
  /// Title text for the picker header (e.g. `'Select Country'`).
  final String selectCountry;

  /// Placeholder text for the search bar.
  final String search;

  /// Text shown when search yields no results.
  final String noResults;

  /// Cancel button text (used in dialog mode).
  final String cancel;

  /// Placeholder text for the phone number input field.
  final String phoneHint;

  const DunyaStrings({
    this.selectCountry = 'Select Country',
    this.search = 'Search...',
    this.noResults = 'No countries found',
    this.cancel = 'Cancel',
    this.phoneHint = 'Phone number',
  });

  static const en = DunyaStrings();

  static const ar = DunyaStrings(
    selectCountry: 'اختر الدولة',
    search: 'بحث...',
    noResults: 'لم يتم العثور على دول',
    cancel: 'إلغاء',
    phoneHint: 'رقم الهاتف',
  );

  static const es = DunyaStrings(
    selectCountry: 'Seleccionar país',
    search: 'Buscar...',
    noResults: 'No se encontraron países',
    cancel: 'Cancelar',
    phoneHint: 'Número de teléfono',
  );

  static const fr = DunyaStrings(
    selectCountry: 'Sélectionner un pays',
    search: 'Rechercher...',
    noResults: 'Aucun pays trouvé',
    cancel: 'Annuler',
    phoneHint: 'Numéro de téléphone',
  );

  static const de = DunyaStrings(
    selectCountry: 'Land auswählen',
    search: 'Suchen...',
    noResults: 'Keine Länder gefunden',
    cancel: 'Abbrechen',
    phoneHint: 'Telefonnummer',
  );

  static const tr = DunyaStrings(
    selectCountry: 'Ülke seçin',
    search: 'Ara...',
    noResults: 'Ülke bulunamadı',
    cancel: 'İptal',
    phoneHint: 'Telefon numarası',
  );

  static const zh = DunyaStrings(
    selectCountry: '选择国家',
    search: '搜索...',
    noResults: '未找到国家',
    cancel: '取消',
    phoneHint: '电话号码',
  );

  static const hi = DunyaStrings(
    selectCountry: 'देश चुनें',
    search: 'खोजें...',
    noResults: 'कोई देश नहीं मिला',
    cancel: 'रद्द करें',
    phoneHint: 'फ़ोन नंबर',
  );

  static const ru = DunyaStrings(
    selectCountry: 'Выберите страну',
    search: 'Поиск...',
    noResults: 'Страны не найдены',
    cancel: 'Отмена',
    phoneHint: 'Номер телефона',
  );

  static const ja = DunyaStrings(
    selectCountry: '国を選択',
    search: '検索...',
    noResults: '国が見つかりません',
    cancel: 'キャンセル',
    phoneHint: '電話番号',
  );

  static const ko = DunyaStrings(
    selectCountry: '국가 선택',
    search: '검색...',
    noResults: '국가를 찾을 수 없습니다',
    cancel: '취소',
    phoneHint: '전화번호',
  );

  static const pt = DunyaStrings(
    selectCountry: 'Selecionar país',
    search: 'Pesquisar...',
    noResults: 'Nenhum país encontrado',
    cancel: 'Cancelar',
    phoneHint: 'Número de telefone',
  );

  static const it = DunyaStrings(
    selectCountry: 'Seleziona paese',
    search: 'Cerca...',
    noResults: 'Nessun paese trovato',
    cancel: 'Annulla',
    phoneHint: 'Numero di telefono',
  );

  static const ur = DunyaStrings(
    selectCountry: 'ملک منتخب کریں',
    search: 'تلاش...',
    noResults: 'کوئی ملک نہیں ملا',
    cancel: 'منسوخ',
    phoneHint: 'فون نمبر',
  );

  /// Returns strings for a locale code. Falls back to English.
  static DunyaStrings forLocale(String locale) {
    final lang = locale.toLowerCase().split(RegExp(r'[_-]')).first;
    switch (lang) {
      case 'ar':
        return ar;
      case 'de':
        return de;
      case 'es':
        return es;
      case 'fr':
        return fr;
      case 'hi':
        return hi;
      case 'it':
        return it;
      case 'ja':
        return ja;
      case 'ko':
        return ko;
      case 'pt':
        return pt;
      case 'ru':
        return ru;
      case 'tr':
        return tr;
      case 'ur':
        return ur;
      case 'zh':
        return zh;
      default:
        return en;
    }
  }
}
