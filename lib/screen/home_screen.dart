import 'dart:convert';
import 'dart:developer';
import 'package:employees/model/employe_model.dart';
import 'package:employees/services/db.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Employee> employesdata = [];

  int? selectedIndex;
  final TextStyle textStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w400,
    fontSize: 15,
  );

  final TextStyle textStyle1 = const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w500,
    fontSize: 18,
  );

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 5,
          centerTitle: true,
          title: const Text(
            "HOME PAGE",
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _refreshData();
                });
                // setState(() {});
              },
              icon: const Icon(
                Icons.refresh_sharp,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: employesdata.length,
              itemBuilder: (context, index) {
                Employee employee = employesdata[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.cyan,
                    ),
                    child: Center(
                      child: Text(
                        employee.firstName,
                        style: textStyle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 450,
            width: double.infinity,
            color: Colors.green[100],
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      selectedIndex != null
                          ? employesdata[selectedIndex!].avatar
                          : '',
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "FirstName   : ${selectedIndex != null ? employesdata[selectedIndex!].firstName : ''} ",
                  style: textStyle1,
                ),
                const SizedBox(height: 12),
                Text(
                  "LastName   : ${selectedIndex != null ? employesdata[selectedIndex!].lastName : ''}",
                  style: textStyle1,
                ),
                const SizedBox(height: 12),
                Text(
                  "Email   :${selectedIndex != null ? employesdata[selectedIndex!].email : ''}",
                  style: textStyle1,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showEditDialog(context);
                        },
                        child: const Text(
                          "Edit",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          _showDeleteConfirmationDialog(context);
                        },
                        child: const Text("Delect"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Employee"),
          content: const Text("Are you sure you want to delete this employee?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Delete the selected employee from SQLite
                  await SQLHelper.deleteEmployee(
                      employesdata[selectedIndex!].id!);

                  setState(() {
                    employesdata.removeAt(selectedIndex!);
                    if (employesdata.isNotEmpty) {
                      selectedIndex = 0;
                    } else {
                      selectedIndex = null;
                    }
                  });

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ));
                } catch (e) {
                  print("Error deleting employee: $e");
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();

    Employee selectedEmployee = employesdata[selectedIndex!];
    firstNameController.text = selectedEmployee.firstName;
    lastNameController.text = selectedEmployee.lastName;
    emailController.text = selectedEmployee.email;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "Edit Profile",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          content: SizedBox(
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {},
                    child: Image.network(
                      selectedEmployee.avatar,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  Employee updatedEmployee = Employee(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      email: emailController.text,
                      avatar: '');

                  await SQLHelper.updateEmployee(updatedEmployee);

                  setState(() {
                    employesdata[selectedIndex!] = updatedEmployee;
                  });

                  Navigator.of(context).pop();
                },
                child: Text("Submit"),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Employee>> _fetchData() async {
    try {
      bool fetchedFromApi = false;

      final List<Map<String, dynamic>> storedData =
          await SQLHelper.getEmployees();

      if (storedData.isNotEmpty) {
        List<Employee> employees =
            storedData.map((e) => Employee.fromJson(e)).toList();

        setState(() {
          employesdata = employees;
        });

        print('Data fetched from SQLite');
      } else {
        http.Response response = await http.get(
          Uri.parse("https://reqres.in/api/users?page=1"),
        );

        if (response.statusCode == 200) {
          final List result = jsonDecode(response.body)['data'];
          List<Employee> employees = result
              .map((e) => Employee(
                    id: e['id'],
                    firstName: e['first_name'],
                    lastName: e['last_name'],
                    email: e['email'],
                    avatar: e['avatar'],
                  ))
              .toList();

          for (Employee employee in employees) {
            await SQLHelper.createEmployee(employee);
            log(employee.toString());
          }

          setState(() {
            employesdata = employees;
          });

          fetchedFromApi = true;
          print('Data fetched from API');
        } else {
          throw Exception('Failed to load data from API');
        }
      }

      return employesdata;
    } catch (e) {
      log("Error: $e");
      throw Exception('Failed to fetch and store data');
    }
  }

  void _refreshData() async {
    try {
      await SQLHelper.deleteAllEmployees();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
    } catch (e) {
      log("Error: $e");
    }
  }
}
