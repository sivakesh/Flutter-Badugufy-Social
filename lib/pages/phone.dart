import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Phone extends StatefulWidget {
  Phone({Key key}) : super(key: key);

  @override
  _PhoneState createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
final FirebaseAuth _auth = FirebaseAuth.instance;
TextEditingController _smsCodeController = TextEditingController();
TextEditingController _phoneNumberController = TextEditingController();
String verificationId;


/// Sends the code to the specified phone number.
  Future<void> _sendCodeToPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted = (AuthCredential user) {
      setState(() {
          // print('Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $user');
      });
    };

    final PhoneVerificationFailed verificationFailed = (AuthException authException) {
      setState(() {
        // print('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');}
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationId = verificationId;
      // print("code sent to " + _phoneNumberController.text);
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      // print("time out");
    };

     await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }
  
@override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Phone Auth"),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new TextField(
              controller:  _phoneNumberController,
            ),
            new TextField(
              controller: _smsCodeController,
            ),
            new FlatButton(
              onPressed: () => _signInWithPhoneNumber(_smsCodeController.text),
              child: const Text("Sign In"))
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _sendCodeToPhoneNumber(),
        tooltip: 'get code',
        child: new Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// Sign in using an sms code as input.
  void _signInWithPhoneNumber(String smsCode) async {
    //  await FirebaseAuth.instance
    //     .signInWithPhoneNumber(
    //       verificationId: verificationId,
    //       smsCode: smsCode)
    //     .then((FirebaseUser user) async {
    //       final FirebaseUser currentUser = await _auth.currentUser();
    //       assert(user.uid == currentUser.uid);
    //       print('signed in with phone number successful: user -> $user');
    //     });

    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);


    // return 'signInWithGoogle succeeded: $user';

  }


}