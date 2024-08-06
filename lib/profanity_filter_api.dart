import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> profanityTextCheck(String message) async {
  final url = Uri.parse('https://vector.profanity.dev');

  // The JSON body you want to send
  final Map<String, dynamic> requestBody = {
    'message': message,
  };

  try {
    // Send the POST request with the JSON body
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // Specify the content type
      },
      body: json.encode(requestBody), // Encode the Map to a JSON string
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // Request was successful
      print('Response body: ${response.body}');
    } else {
      // Request failed
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors that occur during the request
    print('Error: $e');
  }
}
