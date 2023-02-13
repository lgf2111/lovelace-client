import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lovelace/utils/colors.dart';
import 'package:lovelace/resources/storage_methods.dart';
import 'package:lovelace/widgets/text_field_input.dart';

class UnlockAppDialog extends StatefulWidget {
  const UnlockAppDialog({super.key});

  @override
  State<UnlockAppDialog> createState() => _UnlockAppDialogState();
}

class _UnlockAppDialogState extends State<UnlockAppDialog> {
  StorageMethods storageMethods = StorageMethods();
  final TextEditingController _emailController = TextEditingController();
  String message = "";
  bool isUnlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AlertDialog(
        title: const Text('Unlock App', style: TextStyle(fontSize: 21)),
        content: SizedBox(
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Enter Email",
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: TextFieldInput(
                  label: "Email",
                  hintText: "Enter your email",
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                  validator: (value) {
                    return null;
                  },
                ),
              ),
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate email in local storage
                    message = "Incorrect email address!";
                    String email = _emailController.text;
                    final userObjectString =
                        await storageMethods.read("userDetails");
                    final userEmail = jsonDecode(userObjectString)["email"];
    
                    if (email == userEmail) {
                      // when valid
                      isUnlocked = true;
                      message = "App unlocked!";
                      Navigator.pop(context);
                    }
    
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(message)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    // fixedSize: Size(250, 50),
                  ),
                  child: const Text(
                    "UNLOCK",
                    style:
                        TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
