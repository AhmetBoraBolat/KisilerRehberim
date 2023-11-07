import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kisiler_rehberim/data/entity/persons.dart';
import 'package:kisiler_rehberim/data/repo/personsdao_repository.dart';

class HomePageCubit extends Cubit<List<Persons>> {
  HomePageCubit() : super([]);

  final PersonsDaoRepository _repo = PersonsDaoRepository();
  List<Persons> _persons = [];
  List<Persons> _filteredPersons = [];
  int currentPage = 1;
  bool isLoading = false;

  Future<void> loadPersons() async {
    if (isLoading) {
      return;
    }
    try {
      isLoading = true;
      final response = await _repo.loadPersonsFromApi(currentPage);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseData = response.data;

        if (responseData!.containsKey('kisiler')) {
          final Map<String, dynamic> kisilerData = responseData['kisiler'];
          final List<dynamic> personsData = kisilerData['data'];

          final List<Persons> persons = personsData
              .map((personData) => Persons.fromJson(personData))
              .toList();

          _persons.addAll(persons);
          _filteredPersons.addAll(persons);
          emit(_filteredPersons);
          emit(_persons);
          currentPage++;
        } else {
          throw Exception('"kisiler" anahtarı bulunamadı.');
        }
      } else {
        throw Exception('Kişileri alırken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
    } finally {
      isLoading = false;
    }
  }

  void filterPersons(String searchTerm) {
    if (searchTerm.isEmpty) {
      emit(_persons);
    } else {
      final filteredPersons = _persons.where((person) {
        final nameMatches =
            person.kisiAd?.toLowerCase().contains(searchTerm.toLowerCase());
        final genderMatches = person.cinsiyet == 1
            ? 'erkek' == searchTerm.toLowerCase()
            : 'kadın' == searchTerm.toLowerCase();
        final cityMatches =
            person.cityName?.toLowerCase().contains(searchTerm.toLowerCase());
        return nameMatches! || genderMatches || cityMatches!;
      }).toList();
      emit(filteredPersons);
    }
  }

  Future<void> deletePerson(int? personId) async {
    final response = await _repo.deletePersonsFromApi(personId);
    if (kDebugMode) {
      print("HOMEPAGE CUBİT deletePerson : $response");
    }
    if (response.statusCode == 200) {
      final Map<String, dynamic>? responseData = response.data;
      if (kDebugMode) {
        print("deletePerson RESPONSE DATA : ${response.data}");
      }
      if (responseData?['basari'] == 1 && responseData?['durum'] == 3) {
        // Kişi başarıyla silindi
        if (kDebugMode) {
          print('${responseData?['mesaj']!}');
        }
        _persons.removeWhere((person) => person.kisiId == personId);
        emit(_persons);
      } else {
        if (kDebugMode) {
          print(
              '${responseData?['mesaj']} - ${responseData?['basari']} - ${responseData?['durum']}');
        }
      }
    } else {
      throw Exception('Kişiyi silerken hata oluştu: ${response.statusCode}');
    }
  }

  Future<void> fetchPersonDetails(int? personId) async {
    final response = await _repo.fetchPersonDetailsFromApi(personId);
    if (response.statusCode == 200) {
      final Map<String, dynamic>? responseData = response.data;
      if (responseData!.containsKey('basari') && responseData['basari'] == 1) {
        // int personId = response.data?['kisi']['kisi_id'];
      } else {
        throw Exception(
            'Kişi bulunamadı veya API hatası: ${responseData['durum']}');
      }
    } else {
      throw Exception(
          'Kişi bilgilerini alırken hata oluştu: ${response.statusCode}');
    }
  }

  Future<void> addNewPerson(
      String name, int? cityId, int? townId, String tel, int cinsiyet) async {
    final response =
        await _repo.addNewPerson(name, cityId, townId, tel, cinsiyet);
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
}
