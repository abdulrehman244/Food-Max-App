import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'splash_viewmodel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<SplashViewModel>(context, listen: false).startAnimation(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SplashViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack( 
        fit: StackFit.expand,
        children: [
          // Pehli background image
          SvgPicture.asset(
            'assets/svg_images/Splash1.svg',
            fit: BoxFit.cover,
          ),
    
          // Fade-in wali second image
          AnimatedOpacity(
            opacity: vm.showSecondImage ? 1.0 : 0.0,
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            child: SvgPicture.asset(
              'assets/svg_images/splash2.svg',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}


