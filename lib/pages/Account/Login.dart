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
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              child:
              Image.asset(
                'Assets/Background.png',
                width: _showLoginForm || _showRegisterForm ? 200.0 : 400.0, // Specify width as needed
                height: _showLoginForm || _showRegisterForm ? 200.0 : 400.0, // Specify height as needed
              ),
            ),

            if (!_showLoginForm && !_showRegisterForm)
              ElevatedButton(

                onPressed: () {
                  setState(() {
                    _showLoginForm = true;
                  });
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(200, 50)), // Change the size here
                ),
                child: Text('Login'),
              ),
            SizedBox(height: 20),
            if (!_showRegisterForm && !_showLoginForm)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showRegisterForm = true;
                  });
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(150, 40)), // Change the size here
                ),
                child: Text('Register'),
              ),
            SizedBox(height: 20),
            if (_showLoginForm)
              _buildLoginForm(),
            if (_showRegisterForm)
              _buildRegisterForm(),
            SizedBox(height: 20),

            if(!_showLoginForm)
            GestureDetector(
              onTap: () {
                // Add functionality to open business registration form
                _openBusinessRegistrationForm();
              },
              child: Text(
                'Register Business',
                style: TextStyle(
                  color: Colors.purple,
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 2.0),
              ),
              hintText: 'Enter Email',
              labelText: "Email"
            ),
          ),

          SizedBox(height: 20),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
              hintText: 'Enter your password',
              labelText: 'Password',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(150, 40)), // Change the size here
            ),
            onPressed: () {
              // Add login functionality
            },

            child: Text('Login'),

          ),
          ElevatedButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(200, 30)), // Change the size here
            ),
            onPressed: () {
              // Add login functionality
            },

            child: Text('Google Sign In'),

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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
              hintText: 'Enter your email',
              labelText: 'Email',
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
              hintText: 'Enter your password',
              labelText: 'Password',
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.purple, width: 1.0),
              ),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.purple, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.purple, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.purple, width: 1.0),
                    ),
                    hintText: 'Enter business name',
                    labelText: 'Business Name',
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.purple, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.purple, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.purple, width: 1.0),
                    ),
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