import 'package:connection_demo/connection_demo.dart' as connection_demo;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final user = await loginUser();
  if (user != null) {
    await showMenu(user['id']);
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

Future<void> showMenu(int userId) async {
  while (true) {
    print("\n======== Expense Tracking App ========");
    print("1. Show all");
    print("2. Today's expense");
    print("3. Exit");
    stdout.write("Choose..");
    final choice = stdin.readLineSync();
    final url = Uri.parse('http://localhost:3000/expenses?user_id=$userId');
    final response = await http.get(url);
    final expenses = json.decode(response.body) as List;
    final today = DateTime.now();

    if (choice == '1') {
      print("----------- All expenses -----------");
      double total = 0;
      int count = 1;
      for (var e in expenses) {
        print("$count. ${e['item']} : ${e['paid']}₮ : ${e['date']}");
        total += e['paid'];
        count++;
      }
      print("Total expenses = ${total.toStringAsFixed(0)}₮");
    } else if (choice == '2') {
      print("----------- Today's expenses -----------");
      double total = 0;
      int count = 1;
      for (var e in expenses) {
        final date = DateTime.parse(e['date']);
        if (date.year == today.year &&
            date.month == today.month &&
            date.day == today.day) {
          print("$count. ${e['item']} : ${e['paid']}₮ : ${e['date']}");
          total += e['paid'];
          count++;
        }
      }
      print("Total expenses = ${total.toStringAsFixed(0)}₮");
    } else if (choice == '3') {
      print("----- Bye ------");
      break;
    } else {
      print("Invalid choice.");
    }
  }
}
