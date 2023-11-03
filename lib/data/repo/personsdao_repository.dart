import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kisiler_rehberim/data/entity/persons.dart';
import 'package:kisiler_rehberim/sqlite/database_assistant.dart';

class PersonsDaoRepository {
  String email = '';
  String password = '';
  bool isLoading = false;
  final Dio _dio = Dio();
  List<Persons> persons = [];
  List<Persons> _filteredPersons = [];

  // kullanıcı giriş yaparsa veritabanına kayıt oluşturuyor
  Future<void> userSaveInformation(String email, String password) async {
    final db = await DatabaseAssistant.databaseAccess();
    await db!.insert('LoginControl', {
      'mail': email,
      'password': password,
    });
  }

  Future<bool> checkAndRedirect() async {
    final db = await DatabaseAssistant.databaseAccess();
    List<Map<String, dynamic>> records =
        await db.rawQuery("SELECT * FROM LoginControl");
    if (records.isNotEmpty) {
      email = records[0]['mail'];
      password = records[0]['password'];
      return true;
    } else {
      return false;
    }
  }

  Future<Response<Map<String, dynamic>>> loadPersonsFromApi() {
    return _dio.post(
      'http://www.motosikletci.com/api/kisiler',
      data: {
        'page': '1',
        'email': 'borabolat2015@gmail.com',
        'sifre': '29_10_1792',
      },
    );
  }

  Future<void> deletePerson(int personId) async {
    try {
      final response =
          await _dio.post('http://www.motosikletci.com/api/kisi-sil', data: {
        'email': email,
        'sifre': password,
        'id': personId, // Silinecek kişinin ID'si
      });
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['basari'] == 1) {
          // Kişi başarıyla silindi
          if (kDebugMode) {
            print('${responseData['mesaj']}');
          }
        } else {
          throw Exception(
              'Kişiyi silerken hata oluştu: ${response.statusCode}');
        }
      } else {
        throw Exception('Kişiyi silerken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> addNewPerson(
    String name,
    int? cityId,
    int? townId,
    String tel,
    int cinsiyet,
  ) async {
    try {
      final response =
          await _dio.post('http://www.motosikletci.com/api/kisi-kaydet', data: {
        'email': email,
        'sifre': password,
        'kisi_id': 0, // Kişi ID'si
        'city_id': cityId, // Şehir ID'si
        'town_id': townId, // İlçe ID'si
        'kisi_ad': name,
        'kisi_tel': tel,
        'cinsiyet': cinsiyet,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData['basari'] == 1) {
          if (kDebugMode) {
            print('${responseData['mesaj']}');
          }
        } else {
          throw Exception(
              'Kişi eklerken hata oluştu: ${responseData['mesaj']}');
        }
      } else {
        throw Exception('Kişi eklerken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchPersonDetails(int personId) async {
    final Dio _dio = Dio();
    try {
      final response =
          await _dio.post('http://www.motosikletci.com/api/kisi-goster', data: {
        'email': email,
        'sifre': password,
        'kisi_id': personId,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData.containsKey('basari') && responseData['basari'] == 1) {
          final Map<String, dynamic> kisiData = responseData['kisi'];
          return kisiData;
        } else {
          throw Exception(
              'Kişi bulunamadı veya API hatası: ${responseData['durum']}');
        }
      } else {
        throw Exception(
            'Kişi bilgilerini alırken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
      return null;
    }
  }

  Future<bool> login(
      TextEditingController mail, TextEditingController passsword) async {
    String email = mail.text;
    String password = passsword.text;
    final Dio _dio = Dio();
    final response =
        await _dio.post('http://www.motosikletci.com/api/oturum-test', data: {
      'email': email,
      'sifre': password,
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = response.data;

      if (responseData['basari'] == 1) {
        userSaveInformation(email, password);
        checkAndRedirect();
        print("Response-Bora: ${responseData['basari']}");
        return true;
      } else {
        return false;
      }
    } else {
      throw Exception('HTTP isteği başarısız: ${response.statusCode}');
    }
  }
}
