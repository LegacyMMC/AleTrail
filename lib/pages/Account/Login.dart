import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showLoginForm = false;
  bool _showRegisterForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            if (!_showLoginForm &&!_showRegisterForm)
              Image.asset(
                'Assets/Background.png',
                width: 400, // Specify width as needed
                height: 400, // Specify height as needed
              ),
            if (!_showLoginForm && !_showRegisterForm)
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showLoginForm = true;
                  });
                },
                child: Text('Login'),
              ),
            SizedBox(height: 20),
            if (!_showRegisterForm && !_showLoginForm)
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showRegisterForm = true;
                  });
                },
                child: Text('Register'),
              ),
            SizedBox(height: 20),
            if (_showLoginForm)
              _buildLoginForm(),
            if (_showRegisterForm)
              _buildRegisterForm(),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Add functionality to open business registration form
                _openBusinessRegistrationForm();
              },
              child: Text(
                'Register Business',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter your email',
              labelText: 'Email',
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              labelText: 'Password',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add login functionality
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter your email',
              labelText: 'Email',
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              labelText: 'Password',
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              labelText: 'Confirm Password',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add register functionality
            },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }

  void _openBusinessRegistrationForm() {
    // Add functionality to open business registration form
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Business Registration Form'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Add business registration form fields here
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter business name',
                    labelText: 'Business Name',
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter business address',
                    labelText: 'Business Address',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality to register business
                  },
                  child: Text('Register Business'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}