import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:oauthapp/_core/http.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("카카오 로그인"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            child: Text("카카오로그인"),
            onPressed: () async {
              kakaoLogin();
            },
          ),
          ElevatedButton(
            child: Text("네이버로그인"),
            onPressed: () async {
              NaverLogin();
            },
          ),
        ],
      ),
    );
  }

  void kakaoLogin() async {
    try {
      // 1. 크리덴셜 로그인 - 토큰 받기
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      // Bl_yCbOpzJe4vQGNCBX_cQI0VVBvdUm3AAAAAQo9dNsAAAGP3IxzfMYNwJ_muSR4
      print('카카오계정으로 로그인 성공 ${token.accessToken}');

      // 2. 토큰(카카오)을 스프링서버에 전달하기 (스프링 서버한테 나 인증했어!! 라고 알려주는것)
      final response = await dio.get("/oauth/kakao/callback",
          queryParameters: {"accessToken": token.accessToken});

      // 3. 토큰(스프링서버) 응답받기
      final blogAccessToken = response.headers["Authorization"]!.first;
      print("blogAccessToken : ${blogAccessToken}");

      // 4. 시큐어 스토리지에 저장
      secureStorage.write(key: "blogAccessToken", value: blogAccessToken);

      // 5. static, const 변수, riverpod 상태관리 (생략)
    } catch (error) {
      print('카카오계정으로 로그인 실패 $error');
    }
  }
}

void NaverLogin() async {
  try {
    // 1. 로그인 (토큰 가져오기)
    await FlutterNaverLogin.logIn(); // 네이버 로그인 시도
    NaverAccessToken token =
        await FlutterNaverLogin.currentAccessToken; // 토큰 가져오기

    print('네이버계정으로 로그인 성공 ${token.accessToken}');

    //2. 토큰 서버로 보내기
    final response = await dio.get("/oauth/naver/callback",
        queryParameters: {"accessToken": token.accessToken});

    // 3. 토큰 응답받기
    final blogAccessToken = response.headers["Authorization"]!.first;
    print("blogAccessToken : ${blogAccessToken}");

    // 4. 시큐어 스토리지에 저장
    secureStorage.write(key: "blogAccessToken", value: blogAccessToken);
  } catch (error) {
    print('네이버계정으로 로그인 실패 $error');
  }
}
