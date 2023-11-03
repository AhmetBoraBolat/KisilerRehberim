import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kisiler_rehberim/data/entity/persons.dart';
import 'package:kisiler_rehberim/ui/cubit/user_detail_cubit.dart';

class PersonDetail extends StatefulWidget {
  final Persons person;
  final int personId;
  PersonDetail({required this.person, required this.personId});

  @override
  State<PersonDetail> createState() => _PersonDetailState();
}

class _PersonDetailState extends State<PersonDetail> {
  TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  Future<void> fetchPersonDetails() async {
    context.read<UserDetailCubit>().fetchPersonDetails(widget.personId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kişi Düzenle: ${widget.person.kisiAd}'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                // Düzenleme işlemi burada yapılabilir
                // _nameController.text ile güncel değeri alabilirsiniz
                setState(() {
                  _isEditing = false;
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              readOnly:
                  !_isEditing, // Düzenleme modunda olup olmadığını kontrol eder
              decoration: InputDecoration(labelText: 'Kişi Adı'),
            ),
            Text(
              'Cinsiyet: ${widget.person.cinsiyet == 1 ? "Erkek" : "Kadın"}',
            ),
            // Diğer kişi bilgilerini görüntüleme veya düzenleme alanları
          ],
        ),
      ),
    );
  }
}
