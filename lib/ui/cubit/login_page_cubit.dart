import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/personsdao_repository.dart';
import '../view/home_page.dart';

class LoginPageCubit extends Cubit<Map<String, String>> {
  LoginPageCubit() : super(<String, String>{});

  var pRepo = PersonsDaoRepository();

  Future<bool> login(
      TextEditingController mail, TextEditingController password) async {
    final response = await pRepo.login(mail, password);
    if (response.statusCode == 200) {
      final Map<String, dynamic>? responseData = response.data;

      if (responseData?['basari'] == 1) {
        if (!await pRepo.checkAndRedirect()) {
          pRepo.userSaveInformation(mail.text, password.text);
        }
        return true;
      }
      return false;
    } else {
      throw Exception('HTTP isteği başarısız: ${response.statusCode}');
    }
  }

  Future<void> checkAndRedirect(BuildContext context) async {
    var result = await pRepo.checkAndRedirect();
    if (result) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    }
  }
}
