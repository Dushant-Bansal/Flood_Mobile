import 'dart:async';
import 'package:clipboard/clipboard.dart';
import 'package:flood_mobile/Api/auth_api.dart';
import 'package:flood_mobile/Pages/login_screen/widgets/custom_dialog_animation.dart';
import 'package:flood_mobile/Pages/login_screen/widgets/login_screen_textfield.dart';
import 'package:flood_mobile/Pages/widgets/toast_component.dart';
import 'package:flood_mobile/Route/routes.dart';
import 'package:flood_mobile/Blocs/api_bloc/api_bloc.dart';
import 'package:flood_mobile/Blocs/api_bloc/api_bloc_event.dart';
import 'package:flood_mobile/Blocs/login_screen_bloc/login_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flood_mobile/Blocs/theme_bloc/theme_bloc.dart';

class LoginScreen extends StatefulWidget {
  final int? themeIndex;

  const LoginScreen({Key? key, this.themeIndex}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPass = true;
  bool showSpinner = false;
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController urlController =
      new TextEditingController(text: 'http://localhost:3000');
  final _formKey = GlobalKey<FormState>();
  late int themeIndex;

  @override
  void initState() {
    super.initState();
    themeIndex = widget.themeIndex ?? 2;
  }

  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return LoadingOverlay(
      color: ThemeBloc.theme(themeIndex).primaryColor,
      isLoading: showSpinner,
      child: Scaffold(
        backgroundColor: ThemeBloc.theme(themeIndex).primaryColor,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Container(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: wp * 0.08, right: wp * 0.08, top: hp * 0.08),
                  child: Column(
                    children: <Widget>[
                      Image(
                        key: Key('Flood Icon'),
                        image: AssetImage(
                          'assets/images/icon.png',
                        ),
                        width: 100,
                        height: 100,
                      ),
                      Text(
                        'Welcome to Flood',
                        style: TextStyle(
                            color: ThemeBloc.theme(themeIndex)
                                .textTheme
                                .bodyLarge!
                                .color!,
                            fontWeight: FontWeight.bold,
                            fontSize: 28),
                      ),
                      Text(
                        'Sign in to your account',
                        style: TextStyle(
                            color: ThemeBloc.theme(themeIndex)
                                .textTheme
                                .bodyLarge!
                                .color!,
                            fontWeight: FontWeight.normal,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: hp * 0.06,
                      ),
                      LoginScreenTextField(
                        key: Key('Url TextField'),
                        controller: urlController,
                        labelText: 'URL',
                        prefixIcon: Icons.link,
                        themeIndex: themeIndex,
                        trailingIconButton: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              FlutterClipboard.paste().then((value) {
                                setState(() {
                                  urlController.text = value;
                                });
                              });
                            },
                            icon: Icon(
                              Icons.paste,
                              color: ThemeBloc.theme(themeIndex)
                                  .textTheme
                                  .bodyLarge!
                                  .color!,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: hp * 0.01,
                      ),
                      LoginScreenTextField(
                        key: Key('Username TextField'),
                        controller: usernameController,
                        labelText: 'Username',
                        prefixIcon: Icons.person,
                        themeIndex: themeIndex,
                      ),
                      SizedBox(
                        height: hp * 0.01,
                      ),
                      LoginScreenTextField(
                        key: Key('Password TextField'),
                        controller: passwordController,
                        labelText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        themeIndex: themeIndex,
                        obscureText: showPass,
                        trailingIconButton: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                showPass = !showPass;
                              });
                            },
                            icon: Icon(
                              (showPass)
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: ThemeBloc.theme(themeIndex)
                                  .textTheme
                                  .bodyLarge!
                                  .color!,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: hp * 0.06,
                      ),
                      Container(
                        height: hp * 0.07,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState != null &&
                                _formKey.currentState!.validate()) {
                              BlocProvider.of<ApiBloc>(context, listen: false)
                                  .add(
                                SetBaseUrlEvent(url: urlController.text),
                              );
                              await Future.delayed(Duration.zero);
                              setState(() {
                                showSpinner = true;
                              });
                              bool isLoginSuccessful = await AuthApi.loginUser(
                                  username: usernameController.text,
                                  password: passwordController.text,
                                  context: context);
                              if (isLoginSuccessful) {
                                Toasts.showSuccessToast(
                                    msg: 'Login Successful');
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  Routes.homeScreenRoute,
                                  (Route<dynamic> route) => false,
                                  arguments: themeIndex,
                                );
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                bool batteryOptimizationInfoSeen =
                                    prefs.getBool(
                                            'batteryOptimizationInfoSeen') ??
                                        false;
                                if (batteryOptimizationInfoSeen == false) {
                                  BlocProvider.of<LoginScreenBloc>(context,
                                          listen: false)
                                      .add(
                                          SetBatteryOptimizationInfoStatusEvent(
                                              seen: true));

                                  Future.delayed(
                                    Duration.zero,
                                    () => showGeneralDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      barrierColor: Colors.black54,
                                      // space around dialog
                                      transitionDuration:
                                          Duration(milliseconds: 1000),
                                      transitionBuilder:
                                          (context, a1, a2, child) {
                                        return ScaleTransition(
                                          scale: CurvedAnimation(
                                              parent: a1,
                                              curve: Curves.elasticOut,
                                              reverseCurve:
                                                  Curves.easeOutCubic),
                                          child: CustomDialogAnimation(
                                            themeIndex: 2,
                                          ),
                                        );
                                      },
                                      pageBuilder: (BuildContext context,
                                          Animation<double> animation,
                                          Animation<double>
                                              secondaryAnimation) {
                                        return Container();
                                      },
                                    ),
                                  );
                                }
                              } else {
                                Toasts.showFailToast(msg: 'Login Error');
                              }
                              setState(() {
                                showSpinner = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            backgroundColor:
                                ThemeBloc.theme(themeIndex).primaryColorDark,
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: hp * 0.06,
                      ),
                      IconButton(
                        key: Key('Github Icon key'),
                        icon: FaIcon(
                          FontAwesomeIcons.github,
                        ),
                        color: ThemeBloc.theme(themeIndex).iconTheme.color,
                        onPressed: () {
                          launchUrl(Uri.parse(
                            'https://github.com/CCExtractor/Flood_Mobile#usage--screenshots',
                          ));
                        },
                        iconSize: hp * 0.05,
                      ),
                      SizedBox(
                        height: hp * 0.02,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
