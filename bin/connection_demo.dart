import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final user = await loginUser();
  if (user != null) {
    await showMenu(user['id'], user['username']);
  }
}

Future<Map<String, dynamic>?> loginUser() async {
  print("==== Login ====");
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();

  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();

  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'username': username, 'password': password}),
  );

  if (response.statusCode == 200) {
    final user = json.decode(response.body);
    return user;
  } else {
    return null;
  }
}

Future<void> showMenu(int userId, String username) async {
  while (true) {
}
