import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Contacts',
              style: TextStyle(
                  fontFamily: 'MontserratAlternates',
                  fontSize: 16,
                  color: Color(0xFF000000),
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Phones',
                style: TextStyle(
                    fontFamily: 'MontserratAlternates',
                    fontSize: 16,
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                child: const Image(
                  image: AssetImage('assets/images/phone.png'),
                  width: 26,
                  height: 26,
                ),
                margin: const EdgeInsets.all(10),
              ),
              Column(
                children: const [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '+7 (812) 242-62-35',
                      style: TextStyle(
                        fontFamily: 'MontserratAlternates',
                        fontSize: 16,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Nautic Rus',
                      style: TextStyle(
                        fontFamily: 'MontserratAlternates',
                        fontSize: 12,
                        color: Color(0xFF737373),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          Row(
            children: [
              Container(
                child: const Image(
                  image: AssetImage('assets/images/mobile.png'),
                  width: 26,
                  height: 26,
                ),
                margin: const EdgeInsets.all(10),
              ),
              Column(
                children: const [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '+7 (921) 611-81-65',
                      style: TextStyle(
                        fontFamily: 'MontserratAlternates',
                        fontSize: 16,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Supports',
                      style: TextStyle(
                        fontFamily: 'MontserratAlternates',
                        fontSize: 12,
                        color: Color(0xFF737373),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          Container(
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'email',
                style: TextStyle(
                    fontFamily: 'MontserratAlternates',
                    fontSize: 16,
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                child: const Image(
                  image: AssetImage('assets/images/mail.png'),
                  width: 26,
                  height: 26,
                ),
                margin: const EdgeInsets.all(10),
              ),
              Column(
                children: const [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'office@nautic-rus.ru',
                      style: TextStyle(
                        fontFamily: 'MontserratAlternates',
                        fontSize: 16,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          Container(
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Address',
                style: TextStyle(
                    fontFamily: 'MontserratAlternates',
                    fontSize: 16,
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                child: const Image(
                  image: AssetImage('assets/images/building.png'),
                  width: 28,
                  height: 30,
                ),
                margin: const EdgeInsets.all(10),
              ),
              Column(
                children: const [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '9/4 Kronshtadtskaya str. build.1,\nSt. Petersburg, Russia, 198096\nOffice 303',
                      style: TextStyle(
                        fontFamily: 'MontserratAlternates',
                        fontSize: 16,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),

          Expanded(
            child: Container(),
          ),
          // Expanded(
          //   child: WebView(
          //     data: r"""""",
          //     //data: r"""<iframe src="https://yandex.ru/map-widget/v1/?um=constructor%3Ae20b5dc9f5bb93f03c2ff70bd1a8341efb00a357cf04e76b4ea66140297efd62&amp;source=constructor" width="400" height="400" frameborder="0"></iframe>""",
          //   ),
          // ),
        ],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20.0),
    );
  }
}
