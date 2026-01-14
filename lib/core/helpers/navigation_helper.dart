import 'package:flutter/material.dart';

class Nav {

static void to(BuildContext context, Widget page) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        // Slide from bottom + fade
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // bottom se
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    ),
  );
}

static void toAnimated(BuildContext context, Widget page){
   Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, animation, __) {
        return page;
      },
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        // 🔥 Right-to-left slide animation
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Right side se start
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ),
  );
}



static void toAnimatedReplacement(BuildContext context, Widget page){
   Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, animation, __) {
        return page;
      },
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        // 🔥 Right-to-left slide animation
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Right side se start
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ),
  );
}





  // static to(BuildContext context, Widget page) {
  //   Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  // }

  // static off(BuildContext context, Widget page) {
  //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  // }


   static void off(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  static back(BuildContext context) {
    Navigator.pop(context);
  }


}
