import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/entity/persons.dart';
import '../../data/repo/personsdao_repository.dart';

class UserDetailCubit extends Cubit<void> {
  UserDetailCubit() : super(0);

  var Prepo = PersonsDaoRepository();
  Persons person = Persons();

  Future<void> fetchPersonDetails(personId) async {
    Prepo.fetchPersonDetails(person.kisiId!);
  }
}
