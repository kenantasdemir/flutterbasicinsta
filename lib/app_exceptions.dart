class AppExceptions {
  static String show(String hataKodu) {
    switch (hataKodu) {
      case 'email-already-in-use':
        return "Bu mail adresi zaten kullanımda, lütfen farklı bir mail kullanınız";

      case 'invalid-credential':
        return "giriş bilgileri hatalı";
      case 'user-not-found':
        return "Bu kullanıcı sistemde bulunmamaktadır. Lütfen önce kullanıcı oluşturunuz";
      case 'wrong-password':
        return "Email veya şifre yanlış";

      case 'account-exists-with-different-credential':
        return "Facebook hesabınızdaki mail adresi daha önce gmail veya email yöntemi ile sisteme kaydedilmiştir. Lütfen bu mail adresi ile giriş yapın";
      case 'too-many-requests':
        return "Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.";

      default:
        return "Bir hata oluştu: $hataKodu";
    }
  }
}