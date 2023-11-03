import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kisiler_rehberim/ui/cubit/home_page_cubit.dart';
import 'package:kisiler_rehberim/ui/cubit/login_page_cubit.dart';
import 'package:kisiler_rehberim/ui/cubit/user_detail_cubit.dart';
import 'package:kisiler_rehberim/ui/view/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginPageCubit()),
        BlocProvider(create: (context) => UserDetailCubit()),
        BlocProvider(create: (context) => HomePageCubit()),
      ],
      child: const MaterialApp(
        title: 'Kişiler Rehberim',
        home: const LoginPage(),
      ),
    );
  }
}
