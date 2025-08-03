import "dart:typed_data";
import 'package:flutter/material.dart';
import "package:flutter_svg/svg.dart";
import "package:image_picker/image_picker.dart";
import "package:instagramcloneapp/screens/login_screen.dart";
import "package:instagramcloneapp/utils/colors.dart";
import "package:instagramcloneapp/view_models/user_view_model.dart";
import "package:instagramcloneapp/widgets/textfield_input.dart";
import "package:provider/provider.dart";
import "../app_exceptions.dart";
import "../utils/utils.dart";
import "package:firebase_auth/firebase_auth.dart";

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _bioController;
  late final TextEditingController _usernameController;
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _bioController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void signUpUser() async {
    if (_image == null) {
      showSnackBar(context, "Lütfen bir profil fotoğrafı seçin.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var userViewModel = Provider.of<UserViewModel>(context, listen: false);
      await userViewModel.signUpUser(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
        _bioController.text,
        _image!,
      );

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        showSnackBar(context, "Kayıt başarılı! Lütfen giriş yapın.");
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

  void showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Kamera"),
              onTap: () async {
                Navigator.of(context).pop();
                Uint8List im = await pickImage(ImageSource.camera);
                setState(() {
                  _image = im;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Galeri"),
              onTap: () async {
                Navigator.of(context).pop();
                Uint8List im = await pickImage(ImageSource.gallery);
                setState(() {
                  _image = im;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text("İptal"),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var userViewModel = Provider.of<UserViewModel>(context);
return Scaffold(
  resizeToAvoidBottomInset: true,
  body: SafeArea(
    child: SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Flexible(child: SizedBox(), flex: 1),
            SvgPicture.asset(
              "assets/ic_instagram.svg",
              colorFilter: const ColorFilter.srgbToLinearGamma(),
              height: 64,
            ),
            const SizedBox(height: 64),
            Stack(
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundImage: _image != null
                      ? MemoryImage(_image!)
                      : const NetworkImage(
                          "https://images.unsplash.com/photo-1748019156345-64162e5b877e?q=80&w=2160&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        ) as ImageProvider,
                ),
                Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                    onPressed: showImageSourceActionSheet,
                    icon: const Icon(Icons.add_a_photo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFieldInput(
              textEditingController: _usernameController,
              hintText: "Kullanıcı adı giriniz",
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 24),
            TextFieldInput(
              textEditingController: _emailController,
              hintText: "Email adresi giriniz",
              textInputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            TextFieldInput(
              textEditingController: _passwordController,
              hintText: "Parola giriniz",
              textInputType: TextInputType.text,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            TextFieldInput(
              textEditingController: _bioController,
              hintText: "Biyografi ekleyin",
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: signUpUser,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  color: blueColor,
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Text("Kaydolun"),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Zaten bir hesabın var mı? "),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Giriş yap",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  ),
);

  
  }
}
