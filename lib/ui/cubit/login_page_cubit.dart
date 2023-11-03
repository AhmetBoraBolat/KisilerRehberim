import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/personsdao_repository.dart';
import '../view/home_page.dart';

class LoginPageCubit extends Cubit<Map<String, String>> {
  LoginPageCubit() : super(<String, String>{});

  var Prepo = PersonsDaoRepository();

  Future<bool> login(
      TextEditingController mail, TextEditingController passsword) async {
    return await Prepo.login(mail, passsword);
  }

  Future<void> checkAndRedirect(BuildContext context) async {
    final result = await Prepo.checkAndRedirect();
    if (result) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    }
  }
}
