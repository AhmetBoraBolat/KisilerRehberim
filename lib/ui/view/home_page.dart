import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kisiler_rehberim/data/entity/persons.dart';
import 'package:kisiler_rehberim/ui/cubit/home_page_cubit.dart';
import 'package:kisiler_rehberim/ui/view/user_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HomePageCubit>().loadPersons();
  }

  Future<void> _showAddPersonDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController cityIdController = TextEditingController();
    TextEditingController townIdController = TextEditingController();
    TextEditingController telController = TextEditingController();
    int selectedGender = 1;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Yeni Kişi Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'İsim'),
              ),
              TextField(
                controller: cityIdController,
                decoration: InputDecoration(labelText: 'Şehir ID'),
              ),
              TextField(
                controller: townIdController,
                decoration: InputDecoration(labelText: 'İlçe ID'),
              ),
              TextField(
                controller: telController,
                decoration: InputDecoration(labelText: 'Telefon'),
              ), // Buradaki parantezi kapatmayı unutmuşsunuz
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final homePageCubit = context.read<HomePageCubit>();
                homePageCubit.addNewPerson(
                  nameController.text,
                  int.tryParse(cityIdController.text),
                  int.tryParse(townIdController.text),
                  telController.text,
                  selectedGender,
                );
                Navigator.of(context).pop();
              },
              child: Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _filteredPersons =
        context.select((HomePageCubit cubit) => cubit.state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişiler Rehberi'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (_searchController.text.isNotEmpty) {
            return true;
          }
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.pixels >=
                  scrollNotification.metrics.maxScrollExtent) {
            final homePageCubit = context.read<HomePageCubit>();
            homePageCubit.loadPersons();
          }
          return false;
        },
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  final homePageCubit = context.read<HomePageCubit>();
                  homePageCubit.filterPersons(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Arama...',
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<HomePageCubit, List<Persons>>(
                builder: (context, persons) {
                  return ListView.builder(
                    itemCount: persons.length,
                    itemBuilder: (context, index) {
                      final person = persons[index];
                      return ListTile(
                        title: Row(
                          children: [
                            Text(
                              person.kisiAd ?? '',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Spacer(),
                            Text(
                              person.cityName ?? '',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        subtitle:
                            Text(person.cinsiyet == 1 ? 'Erkek' : 'Kadın'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                final int personId = person.kisiId ?? 0;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PersonDetail(
                                      person: person,
                                      personId: personId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Kişiyi Sil'),
                                      content: const Text(
                                        'Bu kişiyi silmek istediğinizden emin misiniz?',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Hayır'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (kDebugMode) {
                                              print(
                                                  "KISI ID: ${person.kisiId}");
                                            }
                                            context
                                                .read<HomePageCubit>()
                                                .deletePerson(person.kisiId);
                                            context
                                                .read<HomePageCubit>()
                                                .loadPersons();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Evet'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPersonDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
