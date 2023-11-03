import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kisiler_rehberim/data/entity/persons.dart';
import 'package:kisiler_rehberim/data/repo/personsdao_repository.dart';

class HomePageCubit extends Cubit<List<Persons>> {
  HomePageCubit() : super([]);

  final PersonsDaoRepository _repo = PersonsDaoRepository();
  List<Persons> _persons = [];

  Future<void> loadPersons() async {
    const apiUrl = 'http://www.motosikletci.com/api/kisiler';

    try {
      final response = await _repo.loadPersonsFromApi();

      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseData = response.data;

        if (responseData!.containsKey('kisiler')) {
          final List<dynamic> personsData = responseData['kisiler']['data'];

          final List<Persons> persons = personsData
              .map((personData) => Persons.fromJson(personData))
              .toList();

          emit(persons);
        } else {
          throw Exception('"kisiler" anahtarı bulunamadı.');
        }
      } else {
        throw Exception('Kişileri alırken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  void filterPersons(String searchTerm) {
    if (searchTerm.isEmpty) {
      emit(
          _persons); // Eğer filtreleme yapmıyorsanız tüm kişileri emit edebilirsiniz.
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

  Future<void> deletePerson(int personId) async {
    await _repo.deletePerson(personId);
    loadPersons(); // Kişi silindikten sonra kişileri yeniden yükle
  }

  Future<void> addNewPerson(
      String name, int? cityId, int? townId, String tel, int cinsiyet) async {
    await _repo.addNewPerson(name, cityId, townId, tel, cinsiyet);
    loadPersons(); // Yeni kişi ekledikten sonra kişileri yeniden yükle
  }
}
