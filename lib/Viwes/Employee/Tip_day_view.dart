import 'package:flutter/material.dart';
class TipDay extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo[400],borderRadius: BorderRadius.circular(20),

            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle
                  ),
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 15,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('نصيحة اليوم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text('كن أفضل من الأمس ',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white
                      ),),
                    SizedBox(height: 10,),
                  ],
                )

              ],),
          ),

        ],
      ),
    );
  }
}


