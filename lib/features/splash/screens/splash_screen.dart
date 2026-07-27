import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/services/app_start_service.dart';

import '../../settings/screens/setup_screen.dart';
import '../../auth/screens/login_screen.dart';


class SplashScreen extends ConsumerStatefulWidget {

  const SplashScreen({
    super.key,
  });


  @override
  ConsumerState<SplashScreen> createState()
      => _SplashScreenState();

}



class _SplashScreenState
    extends ConsumerState<SplashScreen> {


  @override
  void initState() {

    super.initState();

    checkStart();

  }



  Future<void> checkStart() async {


    final service =
        getIt<AppStartService>();


    final firstRun =
        await service.isFirstRun();



    if (!mounted) return;


    if (firstRun) {

      Navigator.pushReplacement(
        context,
        FluentPageRoute(
          builder: (_) =>
              const SetupScreen(),
        ),
      );


    } else {


      Navigator.pushReplacement(
        context,
        FluentPageRoute(
          builder: (_) =>
              const LoginScreen(),
        ),
      );

    }


  }



  @override
  Widget build(BuildContext context) {

    return const ScaffoldPage(

      content: Center(

        child: Text(
          "OilMaster Pro",
          style: TextStyle(
            fontSize: 35,
          ),
        ),

      ),

    );

  }

}