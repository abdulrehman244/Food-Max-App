import 'package:flutter/material.dart';

Widget buildTimeline([bool? isCheckout]) {
  return Column(
    children: [
      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(color: Colors.black, height: 5, width: 50),
           CircleAvatar(
            backgroundColor: Colors.black,
            radius: 15,
            child: Text("1", style: TextStyle(color: Colors.white)),
          ),

          // Line 1 → 2 animated
          isCheckout == true ? SizedBox(
            child:  Container(color: Colors.black, height: 5, width: 110)
          ) :  TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 110), // line width animate
            duration: Duration(seconds: 1),
            builder: (context, value, child) {
              return Container(
                color: Colors.black,
                height: 5,
                width: value,
              );
            },
          ),

          isCheckout == true ?  SizedBox(
            child:  CircleAvatar(
            backgroundColor: Colors.black,
            radius: 15,
            child: Text("2", style: TextStyle(color: Colors.white)),
          ),
          ) :  CircleAvatar(
            backgroundColor: Colors.black,
            radius: 15,
            child: Text("2", style: TextStyle(color: Colors.white)),
          ),
         
          // Line 2 → 3 animated based on isCheckout
          isCheckout == true ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (isCheckout ?? false) ? 110 : 0),
            duration: Duration(seconds: 1),
            builder: (context, value, child) {
              return Container(
                color: Colors.black,
                height: 5,
                width: value,
              );
            },
          ) : SizedBox(),

          isCheckout == true ? CircleAvatar(
            backgroundColor: (isCheckout ?? false) ? Colors.black : Colors.grey.shade300,
            radius: 15,
            child: Text(
              "3",
              style: TextStyle(
                color: (isCheckout ?? false) ? Colors.white : Colors.black,
              ),
            ),
          ) : SizedBox(),

        ],
      ),

      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(color: Colors.transparent, height: 5, width: 50),
          Text("Menu"),
          Expanded(child: Container(color: Colors.transparent, height: 5,)),
          Container(color: Colors.transparent, height: 5,width: 10,),
          Text("cart"),
          Expanded(
            child: Container(color: Colors.transparent, height: 5,)
          ),
          Text("Checkout"),
          Container(color:  Colors.transparent, height: 5, width: 40),
        ],
      ),
    ],
  );
}




// import 'package:flutter/material.dart';

// Widget buildTimeline([bool? isCheckout]) {
//   return Column(
//     children: [
//       Row(
//         mainAxisSize: MainAxisSize.max,
//         children: [
//           Container(color: Colors.black, height: 5, width: 50),
//           CircleAvatar(
//             backgroundColor: Colors.black,
//             radius: 15,
//             child: Text("1", style: TextStyle(color: Colors.white)),
//           ),
                
//           Expanded(child: Container(color: Colors.black, height: 5, width: 80)),
//           CircleAvatar(
//             backgroundColor: Colors.black,
//             radius: 15,
//             child: Text("2", style: TextStyle(color: Colors.white)),
//           ),
//           Expanded(
//             child: (isCheckout ?? false)
//                 ? Container(color: Colors.black, height: 5, width: 80)
//                 : Container(color: Colors.grey.shade300, height: 5, width: 80),
//           ),
//           CircleAvatar(
//             backgroundColor: (isCheckout ?? false) ? Colors.black : Colors.grey.shade300,
//             radius: 15,
//             child: Text(
//               "3",
//               style: TextStyle(color: (isCheckout ?? false)  ? Colors.white : Colors.black),
//             ),
//           ),
//           Container(color: (isCheckout ?? false) ?  Colors.black : Colors.grey.shade300, height: 5, width: 50),
//         ],
//       ),

//       Row(
//         mainAxisSize: MainAxisSize.max,
//         children: [
//           Container(color: Colors.transparent, height: 5, width: 50),
//          Text("Menu"),
                
//           Expanded(child: Container(color: Colors.transparent, height: 5,)),
//           Container(color: Colors.transparent, height: 5,width: 10,),
//           Text("cart"),
//           Expanded(
//             child: 
//                  Container(color: Colors.transparent, height: 5,)
//           ),
//           Text("Checkout"),
//           Container(color:  Colors.transparent, height: 5, width: 40),
//         ],
//       ),



//     ],
//   );
// }
