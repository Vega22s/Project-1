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
    print("\n=========== Expense Tracking App ===========");
    print("Welcome $username");
    print("1. All expenses");
    print("2. Today's expense");
    print("3. Search expense");
    print("4. Add new expense");
    print("5. Delete an expense");
    print("6. Exit");
    stdout.write("Choose... ");
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
        final date = DateTime.parse(e['date']).toLocal();
        print("$count. ${e['item']} : ${e['paid']}฿ : ${date.toString()}");
        total += (e['paid'] as num).toDouble();
        count++;
      }
      print("Total expenses = ${total.toStringAsFixed(0)}฿");
    } else if (choice == '2') {
      print("----------- Today's expenses -----------");
      double total = 0;
      int count = 1;
      for (var e in expenses) {
        final date = DateTime.parse(e['date']).toLocal();
        if (date.year == today.year &&
            date.month == today.month &&
            date.day == today.day) {
          print("$count. ${e['item']} : ${e['paid']}฿ : ${date.toString()}");
          total += (e['paid'] as num).toDouble();
          count++;
        }
      }
      print("Total expenses = ${total.toStringAsFixed(0)}฿");
    } else if (choice == '3') {
      stdout.write("Search item: ");
      final keyword = stdin.readLineSync() ?? "";
      final found = expenses.where(
        (e) =>
            e['item'].toString().toLowerCase().contains(keyword.toLowerCase()),
      );
      if (found.isEmpty) {
        print("No matching expenses.");
      } else {
        for (var e in found) {
          final date = DateTime.parse(e['date']).toLocal();
          print("${e['item']} : ${e['paid']}฿ : ${date.toString()}");
        }
      }
    } else if (choice == '4') {
      print("===== Add new item =====");
      stdout.write("Item: ");
      final item = stdin.readLineSync() ?? "";
      stdout.write("Paid: ");
      final paid = double.tryParse(stdin.readLineSync() ?? "0") ?? 0;

      final newExpense = {
        "user_id": userId,
        "item": item,
        "paid": paid,
        "date": DateTime.now().toIso8601String(),
      };

      final addUrl = Uri.parse('http://localhost:3000/expenses');
      final addResponse = await http.post(
        addUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode(newExpense),
      );

      if (addResponse.statusCode == 201) {
        print("Inserted!");
      } else {
        print("Failed to insert.");
      }
    } else if (choice == '5') {
      print("===== Delete an expense =====");
      for (int i = 0; i < expenses.length; i++) {
        print("${i + 1}. ${expenses[i]['item']} : ${expenses[i]['paid']}฿");
      }
      stdout.write("Enter number to delete: ");
      final idx = int.tryParse(stdin.readLineSync() ?? "");
      if (idx != null && idx > 0 && idx <= expenses.length) {
        final expenseId = expenses[idx - 1]['id'];
        final delUrl = Uri.parse('http://localhost:3000/expenses/$expenseId');
        final delResponse = await http.delete(delUrl);
        if (delResponse.statusCode == 200) {
          print("Deleted!");
        } else {
          print("Failed to delete.");
        }
      } else {
        print("Invalid choice.");
      }
    } else if (choice == '6') {
      print("----- Bye ------");
      break;
    } else {
      print("Invalid choice.");
    }
  }
}
