import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:night_life/models/club.dart';
import 'package:night_life/services/database.dart';
import 'package:night_life/widgets/heros/club_detail.dart';

class Recommended extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Club>>(
      stream: DatabaseService().userDataStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          List<Club> data = snapshot.data;

          return ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(
              data.length,
              (index) => GestureDetector(
                child: Hero(
                  tag: '${data[index].name}recommend',
                  child: Card(
                    color: Colors.black,
                    child: Container(
                      width: 180.0,
                      height: 110.0,
                      child: Stack(
                        children: <Widget>[
                          Image.network(data[index].img,
                              fit: BoxFit.cover,
                              color: Color.fromRGBO(255, 255, 255, 0.8),
                              colorBlendMode: BlendMode.modulate),
                          Positioned(
                            top: 80,
                            left: 10,
                            child: Text(
                              data[index].name,
                              style: TextStyle(
                                  fontFamily: 'PierSans',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RecommendDetail(data[index])));
                },
              ),
            ),
          );
        }
      },
    );
  }
}
