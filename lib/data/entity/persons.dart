class Persons {
  int? kisiId;
  String? kisiAd;
  String? kisiTel;
  int? cinsiyet;
  int? cityId;
  int? townId;
  String? cityName;
  String? townName;

  Persons({
    this.kisiId,
    this.kisiAd,
    this.kisiTel,
    this.cinsiyet,
    this.cityId,
    this.townId,
    this.cityName,
    this.townName,
  });

  factory Persons.fromJson(Map<String, dynamic> json) {
    return Persons(
      kisiId: json['kisi_id'],
      kisiAd: json['kisi_ad'],
      kisiTel: json['kisi_tel'],
      cinsiyet: json['cinsiyet'],
      cityId: json['city_id'],
      townId: json['town_id'],
      cityName: json['city_name'],
      townName: json['town_name'],
    );
  }
}
