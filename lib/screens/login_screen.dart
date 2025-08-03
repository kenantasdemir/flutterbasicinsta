import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart";
import "package:flutter_svg/svg.dart";
import "package:instagramcloneapp/app_exceptions.dart";
import "package:instagramcloneapp/screens/signup_screen.dart";
import "package:instagramcloneapp/utils/colors.dart";
import "package:instagramcloneapp/utils/utils.dart";
import "package:instagramcloneapp/view_models/user_view_model.dart";
import "package:instagramcloneapp/widgets/textfield_input.dart";
import "package:provider/provider.dart";
import "../responsive/mobile_screen_layout.dart";
import "../responsive/responsive_layout.dart";
import "../responsive/web_screen_layout.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _bioController;
  late final TextEditingController _usernameController;

  late PlatformException myHata;

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _bioController = TextEditingController();
    _usernameController = TextEditingController();

    SchedulerBinding.instance.addPostFrameCallback((_) {

    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userViewModel = Provider.of<UserViewModel>(context);

    void loginUser() async {
      setState(() {
        _isLoading = true;
      });

      try {
        await userViewModel.signInUser(
          _emailController.text,
          _passwordController.text,
        );
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                ),
              ),
              (route) => false);
        }
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          showSnackBar(context, AppExceptions.show(e.code));
        }
      } catch (e) {
        if (context.mounted) {
          showSnackBar(context, "Bilinmeyen bir hata oluştu: ${e.toString()}");
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Container(), flex: 1),
              SvgPicture.asset(
                "ic_instagram.svg",
                height: 64,
              ),
              SizedBox(height: 24),
              TextFieldInput(
                textEditingController: _emailController,
                hintText: "Email adresinizi girin",
                textInputType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: 24,
              ),
              TextFieldInput(
                textEditingController: _passwordController,
                hintText: "Parola giriniz",
                textInputType: TextInputType.text,
                isPassword: true,
              ),
              SizedBox(height: 24),
              InkWell(
                onTap: loginUser,
                child: Container(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Text("Giriş yap"),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: blueColor,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Flexible(child: Container(), flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text("Hesabınız yok mu?"),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SignupScreen()));
                    },
                    child: Container(
                      child: Text("Kayddolun"),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


}
