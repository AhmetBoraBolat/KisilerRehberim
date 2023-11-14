import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kisiler_rehberim/ui/cubit/user_detail_cubit.dart';

class PersonDetail extends StatefulWidget {
  final int? personId;

  const PersonDetail({Key? key, this.personId}) : super(key: key);

  @override
  State<PersonDetail> createState() => _PersonDetailState();
}

class _PersonDetailState extends State<PersonDetail> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _telController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  String? selectedCity;
  String? selectedTown;
  String? cityId;
  String? townId;
  int selectedGender = 0;
  Map<String, String> cities = {};
  Map<String, String> towns = {};

  @override
  void initState() {
    super.initState();
    pageParameters();
  }

  Future<void> pageParameters() async {
    cities = await context.read<UserDetailCubit>().getCity();
    if (widget.personId != null) {
      fetchPersonDetails();
    }
  }

  Future<void> fetchPersonDetails() async {
    cities = await context.read<UserDetailCubit>().getCity();
    final userData = await context
        .read<UserDetailCubit>()
        .fetchPersonDetails(widget.personId!);

    setState(() {
      _nameController.text = userData['kisi_ad'] ?? '';
      _telController.text = userData['kisi_tel'] ?? '';
      _genderController.text = userData['cinsiyet']?.toString() ?? '';
    });
  }

  Future<void> savePersonParameters() async {}

  Future<void> _savePerson(BuildContext context) async {
    if (selectedCity != null && selectedTown != null) {
      if (widget.personId == null) {
        await context.read<UserDetailCubit>().addNewPerson(
              _nameController.text,
              int.tryParse(cityId!),
              int.tryParse(townId!),
              _telController.text,
              selectedGender,
            );
      }
    } else {
      if (kDebugMode) {
        print('GEREKLİ ALANLAR DOLDURULMADI');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.personId == null ? 'Kişi Ekle' : 'Kişi Detay'),
        actions: [
          if (widget.personId == null)
            IconButton(
              onPressed: () {
                _savePerson(context);
                Navigator.pop(context);
              },
              icon: Icon(Icons.save),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Ad'),
                enabled: widget.personId == null,
              ),
              TextField(
                controller: _telController,
                decoration: InputDecoration(labelText: 'Telefon'),
                enabled: widget.personId == null,
              ),
              TextField(
                controller: _genderController,
                decoration: InputDecoration(labelText: 'Cinsiyet'),
                enabled: widget.personId == null,
              ),
              if (widget.personId == null) ...[
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  items: cities.keys.map((String cityName) {
                    return DropdownMenuItem<String>(
                      value: cityName,
                      child: Text(cityName),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      towns = await context
                          .read<UserDetailCubit>()
                          .getTown(int.tryParse(cityId!));
                      setState(() {
                        cityId = cities[newValue];
                        selectedCity = newValue;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Şehir'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedTown,
                  items: towns.keys.map((String townName) {
                    return DropdownMenuItem<String>(
                      value: townName,
                      child: Text(townName),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      townId = towns[newValue!];
                      selectedTown = newValue;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'İlçe'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
