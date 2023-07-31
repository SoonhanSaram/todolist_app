import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:todolist_app/comps/expansion_tile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  KakaoSdk.init(nativeAppKey: dotenv.env['APP_KEY']);
  runApp(const Login());
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Login",
      theme: ThemeData.dark(),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future loginWithKakaoAccount() async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      print("token : $token");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ExpansionTiles(),
        ),
      );
    } catch (e) {
      print("로그인 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  child: Icon(
                    size: 52,
                    Icons.format_list_numbered_sharp,
                  ),
                ),
                Text(
                  "오늘 할 일",
                  style: TextStyle(fontSize: 42),
                )
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            TextButton(
              onPressed: () => loginWithKakaoAccount(),
              child: Image.asset(
                'assets/images/kakao_login_medium.png',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
