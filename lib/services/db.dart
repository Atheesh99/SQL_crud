import 'dart:developer';

import 'package:employees/model/employe_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    try {
      final result = await database.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='employees'");

      if (result.isEmpty) {
        await database.execute(
            "CREATE TABLE employees(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, first_name TEXT, last_name TEXT, email TEXT, avatar TEXT)");
      }
    } catch (e) {
      print("Error creating tables: $e");
    }
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'tech.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createEmployee(Employee employee) async {
    try {
      final db = await SQLHelper.db();
      final data = employee.toJson();
      final id = await db.insert('employees', data,
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
      return id;
    } catch (e) {
      print("Error creating employee: $e");
      throw Exception('Failed to create employee');
    }
  }

  static Future<List<Map<String, dynamic>>> getEmployees() async {
    try {
      final db = await SQLHelper.db();
      return db.query('employees', orderBy: "id");
    } catch (e) {
      print("Error getting employees: $e");
      throw Exception('Failed to get employees');
    }
  }

  static Future<List<Map<String, dynamic>>> getEmployee(int id) async {
    final db = await SQLHelper.db();
    return db.query('employees', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateEmployee(Employee employee) async {
    final db = await SQLHelper.db();
    final data = employee.toJson();
    final result = await db
        .update('employees', data, where: "id = ?", whereArgs: [employee.id]);
    return result;
  }

  static Future<void> deleteAllEmployees() async {
    final db = await SQLHelper.db();
    try {
      await db.delete("employees");
      log('deleted');
    } catch (err) {
      debugPrint("Something went wrong when deleting all employees: $err");
    }
  }

  static Future<void> deleteEmployee(int id) async {
    try {
      final db = await SQLHelper.db();
      await db.delete("employees", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Error deleting an employee: $err");
      throw Exception('Failed to delete employee');
    }
  }
}
