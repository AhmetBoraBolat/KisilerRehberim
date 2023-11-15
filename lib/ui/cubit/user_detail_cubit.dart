import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/personsdao_repository.dart';

class UserDetailCubit extends Cubit<Map<String, dynamic>> {
  UserDetailCubit() : super({});

  var _repo = PersonsDaoRepository();

  Future<Map<String, dynamic>> fetchPersonDetails(personId) async {
    final response = await _repo.fetchPersonDetailsFromApi(personId);
    if (response.statusCode == 200) {
      final Map<String, dynamic>? responseData = response.data;
      if (responseData?['basari'] == 1 && responseData?['durum'] == 1) {
        var userData = responseData!['kisi'];
        emit(userData);
        return userData;
      }
    }

    throw Exception('Failed to fetch person details');
  }

  Future<void> addNewPerson({
    required String name,
    required int? cityId,
    required int? townId,
    required String tel,
    required int cinsiyet,
    required File? image,
  }) async {
    final response =
        await _repo.addNewPerson(cityId, name, townId, tel, cinsiyet, image);
    if (response.statusCode == 200) {
      final Map<String, dynamic>? responseData = response.data;
      if (responseData?['basari'] == 1) {
        if (kDebugMode) {
          print('${responseData?['mesaj']}');
        }
      } else {
        throw Exception('Kişi eklerken hata oluştu: ${responseData?['mesaj']}');
      }
    } else {
      throw Exception('Kişi eklerken hata oluştu: ${response.statusCode}');
    }
  }

  Future<Map<String, String>> getCity() async {
    final response = await _repo.getCity();
    Map<String, String> cities = {};
    if (response.statusCode == 200) {
      final Map<String, dynamic>? responseData = response.data;
      if (responseData != null && responseData.containsKey('iller')) {
        final List<dynamic> citiesData = responseData['iller'];
        for (var cityData in citiesData) {
          final String cityName = cityData['city_name'];
          final String cityId = cityData['city_id'].toString();
          cities[cityName] = cityId;
        }
      }
    }
    emit(cities);
    return cities;
  }

  Future<Map<String, String>> getTown(int? cityId) async {
    final response = await _repo.getTown(cityId!);
    Map<String, String> town = {};
    if (response.statusCode == 200) {
      final Map<String, dynamic>? responseData = response.data;
      if (responseData?['basari'] == 1 && responseData?['durum'] == 1) {
        final List<dynamic> districtsData = responseData?['ilceler'];
        for (var townData in districtsData) {
          final String townName = townData['town_name'];
          final String townId = townData['town_id'].toString();
          town[townName] = townId;
        }
      } else {
        if (kDebugMode) {
          print('${responseData?['basari']}getTown FONKSİYONUNDA SIKINTI VAR');
        }
      }
    }
    emit(town);
    return town;
  }
}
