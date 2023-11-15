import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
  String? selectedCityId;
  String? selectedTownId;
  Map<String, String> cities = {};
  Map<String, String> towns = {};
  File? imageFile;

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
    final userData = await context
        .read<UserDetailCubit>()
        .fetchPersonDetails(widget.personId!);

    setState(() {
      _nameController.text = userData['kisi_ad'] ?? '';
      _telController.text = userData['kisi_tel'] ?? '';
      _genderController.text = userData['cinsiyet']?.toString() ?? '';
    });
  }

  Future<void> _savePerson(BuildContext context) async {
    if (selectedCityId != null && selectedTownId != null) {
      if (widget.personId == null) {
        await context.read<UserDetailCubit>().addNewPerson(
              name: _nameController.text,
              cityId: int.tryParse(selectedCityId!),
              townId: int.tryParse(selectedTownId!),
              tel: _telController.text,
              cinsiyet: int.parse(_genderController.text),
              image: imageFile,
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
      body: BlocBuilder<UserDetailCubit, Map<String, dynamic>>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('How to upload the image ?'),
                          alignment: Alignment.center,
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () => getImage(
                                    source: ImageSource.camera,
                                  ),
                                  child: const Text('Fotoğraf çek'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      getImage(source: ImageSource.gallery),
                                  child: const Text('Fotoğraf seç'),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                    child: imageFile != null
                        ? Container(
                            width: 300,
                            height: 300,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              image: DecorationImage(
                                image: FileImage(imageFile!),
                                fit: BoxFit.cover,
                              ),
                              border:
                                  Border.all(width: 8, color: Colors.black12),
                              borderRadius: BorderRadius.circular(12),
                            ))
                        : Container(
                            width: 300,
                            height: 300,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              border:
                                  Border.all(width: 8, color: Colors.black12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Click to select a picture',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                  ),
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
                  widget.personId == null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 175,
                              child: RadioListTile(
                                title: const Text('Erkek'),
                                value: '1',
                                groupValue: _genderController.text,
                                onChanged: (value) {
                                  setState(() {
                                    _genderController.text = value!;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 175,
                              child: RadioListTile(
                                title: const Text('Kadın'),
                                value: '2',
                                groupValue: _genderController.text,
                                onChanged: (value) {
                                  setState(() {
                                    _genderController.text = value!;
                                  });
                                },
                              ),
                            )
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            _genderController.text == '1' ? 'Erkek' : 'Kadın',
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                  if (widget.personId == null) ...[
                    DropdownButtonFormField<String>(
                      value: selectedCityId,
                      items: cities.entries
                          .map((MapEntry<String, String> cityEntry) {
                        return DropdownMenuItem<String>(
                          value: cityEntry.value,
                          child: Text(cityEntry.key),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          selectedCityId = newValue;
                          if (kDebugMode) {
                            print('SELECTED CITY ID : $selectedCityId');
                          }
                          context
                              .read<UserDetailCubit>()
                              .getTown(int.parse(selectedCityId!))
                              .then((result) {
                            setState(() {
                              towns = result;
                              selectedTownId = null;
                            });
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Şehir'),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedTownId,
                      items: towns.entries
                          .map((MapEntry<String, String> townEntry) {
                        return DropdownMenuItem<String>(
                          value: townEntry.value,
                          child: Text(townEntry.key),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          selectedTownId = newValue;
                        }
                      },
                      decoration: const InputDecoration(labelText: 'İlçe'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> getImage({required ImageSource source}) async {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 70,
    );
    if (file?.path != null) {
      setState(() {
        imageFile = File(file!.path);
      });
    } else {
      throw Exception('Hata oluştu : getImage');
    }
  }
}
