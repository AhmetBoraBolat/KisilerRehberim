import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kisiler_rehberim/data/entity/persons.dart';
import 'package:kisiler_rehberim/sqlite/database_assistant.dart';

class PersonsDaoRepository {
  var email = '';
  var password = '';
  bool isLoading = false;
  final Dio _dio = Dio();
  List<Persons> persons = [];

  Future<void> userSaveInformation(String daoEmail, String daoPassword) async {
    final db = await DatabaseAssistant.databaseAccess();
    await db.insert('LoginControl', {
      'mail': daoPassword,
      'password': daoPassword,
    });
    email = daoEmail;
    password = daoPassword;
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

  Future<Response<Map<String, dynamic>>> login(TextEditingController editEmail,
      TextEditingController editPassword) async {
    await checkAndRedirect();
    return _dio.post('http://www.motosikletci.com/api/oturum-test', data: {
      'email': editEmail.text,
      'sifre': editPassword.text,
    });
  }

  Future<Response<Map<String, dynamic>>> loadPersonsFromApi(int page) async {
    await checkAndRedirect();
    return _dio.post(
      'http://www.motosikletci.com/api/kisiler',
      data: {
        'page': page,
        'email': email, // Burada sınıfın alanını kullanıyoruz
        'sifre': password, // Burada sınıfın alanını kullanıyoruz
      },
    );
  }

  Future<Response<Map<String, dynamic>>> deletePersonsFromApi(
      int? personId) async {
    await checkAndRedirect();
    return _dio.post(
      'http://www.motosikletci.com/api/kisi-sil',
      data: {
        'sifre': password,
        'email': email,
        'kisi_id': personId,
      },
    );
  }

  Future<Response<Map<String, dynamic>>> addNewPerson(
    String name,
    int? cityId,
    int? townId,
    String tel,
    int cinsiyet,
  ) async {
    await checkAndRedirect();

    return _dio.post('http://www.motosikletci.com/api/kisi-kaydet', data: {
      'email': email, // Burada sınıfın alanını kullanıyoruz
      'sifre': password, // Burada sınıfın alanını kullanıyoruz
      'kisi_id': 0, // Kişi ID'si
      'city_id': cityId, // Şehir ID'si
      'town_id': townId, // İlçe ID'si
      'kisi_ad': name,
      'kisi_tel': tel,
      'cinsiyet': cinsiyet,
    });
  }

  Future<Response<Map<String, dynamic>>> fetchPersonDetailsFromApi(
      int? personId) async {
    await checkAndRedirect();
    return _dio.post(
      'http://www.motosikletci.com/api/kisi-goster',
      data: {
        'sifre': password,
        'email': email,
        'kisi_id': personId,
      },
    );
  }
}
