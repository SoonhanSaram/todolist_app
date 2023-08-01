import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:todolist_app/comps/expansion_tile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  KakaoSdk.init(nativeAppKey: dotenv.env['APP_KEY'], javaScriptAppKey: dotenv.env['JAVASCRIPT_APP_KEY']);
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
  void changepage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExpansionTiles(),
      ),
    );
  }

  Future loginWithKakaoAccount() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        changepage();
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          changepage();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        changepage();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
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
