import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:widgetbook_challenge/api/widgetbook_api.dart';

/// The app.
class App extends StatelessWidget {
  /// Creates a new instance of [App].
  const App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(),
      ),
    );
  }
}

/// [HomePage] widget
class HomePage extends StatefulWidget {
  ///  Creates a new instance of [HomePage].
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ///[TextEditingController] for the name textfield
  late final TextEditingController _nameController;

  ///Validator regex for name
  static const _nameRegex = r'^[a-zA-Z]{2,30}$';

  ///Hello message
  String _hello = '';

  ///Formkey for checking validation
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    ///initializing the [TextEditingController]
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    ///Disposing the [TextEditingController]
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Challenge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _hello,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.name,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _nameController,
                validator: (value) {
                  if (value == null) return null;
                  if (RegExp(_nameRegex).hasMatch(value)) return null;
                  return 'Please enter valid name';
                },
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Loading...'),
                              CircularProgressIndicator.adaptive(),
                            ],
                          ),
                        ),
                      );
                    //wrap with try catch to handle error
                    try {
                      final _message = await WidgetbookApi()
                          .welcomeToWidgetbook(
                        message: _nameController.text.trim(),
                      )
                          .then(
                        (value) {
                          ///Hide snackbar after finish
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          return value;
                        },
                      );

                      //assign the hello message
                      setState(() {
                        _hello = _message;
                      });
                    } catch (e, s) {
                      log('Error on submit', error: e, stackTrace: s);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            duration: const Duration(
                              seconds: 2,
                            ),
                            content: Text(
                              'Please try again',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                            backgroundColor: Theme.of(context).errorColor,
                          ),
                        );
                    }
                  }
                },
                child: const Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
